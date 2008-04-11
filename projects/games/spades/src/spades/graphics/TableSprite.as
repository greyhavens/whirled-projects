package spades.graphics {

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.utils.Timer;
import flash.display.Bitmap;
import flash.geom.Point;

import com.threerings.flash.Vector2;
import com.whirled.game.StateChangedEvent;
import com.threerings.util.MultiLoader;

import caurina.transitions.Tweener;

import spades.Model;
import spades.card.Card;
import spades.card.CardArray;
import spades.card.CardArrayEvent;
import spades.card.Trick;
import spades.card.TrickEvent
import spades.card.Table;
import spades.card.Bids;
import spades.card.SpadesBids;
import spades.card.BidEvent;
import spades.card.Hand;
import spades.card.HandEvent;
import spades.card.Scores;
import spades.card.Team;

/**
 * Display object for drawing a spades game.
 */
public class TableSprite extends Sprite
{
    /** Create a new table.
     *  @param playerNames the names of the players, in seat order
     *  @param localSeat the seat that the local player is sitting in */
    public function TableSprite (model :Model)
    {
        MultiLoader.getContents(BACKGROUND, gotBackground);

        _model = model;

        _players = new Array(table.numPlayers);
        for (var seat :int = 0; seat < table.numPlayers; ++seat) {
            var name :String = table.getNameFromRelative(seat);
            var p :PlayerSprite = new PlayerSprite(name, 
                table.getTeamFromRelative(seat));
            addChild(p);
            _players[seat] = p;

            p.setHeadShot(_model.gameCtrl.local.getHeadShot(
                 table.getIdFromRelative(seat)));
        }
        
        _hand = new HandSprite(_model.hand);
        addChild(_hand);

        _trick = new MainTrickSprite(_model.trick, table, _players, _hand);
        addChild(_trick);

        _teams[0] = new TeamSprite(_model.scores, 0, 
            TRICK_POSITION, new Vector2(LAST_TRICK_OFFSET, 0));
        addChild(_teams[0] as TeamSprite);

        _teams[1] = new TeamSprite(_model.scores, 1, 
            TRICK_POSITION, new Vector2(-LAST_TRICK_OFFSET, 0));
        addChild(_teams[1] as TeamSprite);

        _normalBids = new NormalBiddingSprite(_model.bids);
        addChild(_normalBids);

        _blindNilBids = new BlindNilBiddingSprite(_model.bids);
        addChild(_blindNilBids);

        // listen for the trick changing
        _model.trick.addEventListener(TrickEvent.COMPLETED, trickListener);

        // listen for blind nil updates
        _model.bids.addEventListener(BidEvent.PLACED, bidListener);
        _model.bids.addEventListener(BidEvent.RESET, bidListener);

        // listen for passing cards between players
        _model.hand.addEventListener(HandEvent.PASSED, handListener);

        // listen for our removal to prevent stranded listeners
        addEventListener(Event.REMOVED, removedListener);

        _model.gameCtrl.game.addEventListener(
            StateChangedEvent.ROUND_ENDED, 
            handleRoundEnded);
        _model.gameCtrl.game.addEventListener(
            StateChangedEvent.TURN_CHANGED, 
            handleTurnChanged);

        layout();

        function gotBackground (background :Bitmap) :void
        {
            addChildAt(background, 0);
        }
    }

    /** Highlight a player to show it is his turn. Also unhighlights any previous. 
     *  If a seat less than 0 is given, then all players are unhighlighted. */
    protected function setPlayerTurn (seat :int) :void
    {
        if (seat >= 0) {
            seat = table.getRelativeFromAbsolute(seat);
        }

        _players.forEach(setTurn);

        function setTurn (p :PlayerSprite, index :int, array :Array) :void
        {
            p.setTurn(index == seat);
        }
    }

    protected function handleRoundEnded (event :StateChangedEvent) :void
    {
        setPlayerTurn(-1);
    }

    protected function handleTurnChanged (event :StateChangedEvent) :void
    {
        var id :int = _model.gameCtrl.game.getTurnHolderId();
        setPlayerTurn(table.getAbsoluteFromId(id));
    }

    protected function positionChild (child :DisplayObject, pos :Vector2) :void
    {
        child.x = pos.x;
        child.y = pos.y;
    }

    /** Position all the children. */
    protected function layout () :void
    {
        positionChild(_hand, HAND_POSITION);
        positionChild(_trick, TRICK_POSITION);
        positionChild(_teams[0] as TeamSprite, LEFT_TEAM_POSITION);
        positionChild(_teams[1] as TeamSprite, RIGHT_TEAM_POSITION);
        positionChild(_normalBids, NORMAL_BIDS_POSITION);
        positionChild(_blindNilBids, NORMAL_BIDS_POSITION);
        _players.forEach(positionPlayer);

        function positionPlayer (p :PlayerSprite, seat :int, a :Array) :void {
            positionChild(p, PLAYER_POSITIONS[seat] as Vector2);
        }
    }

    protected function trickListener (event :TrickEvent) :void
    {
        if (event.type == TrickEvent.COMPLETED) {
            var trick :Trick = event.target as Trick;
            var teamIdx :int = table.getTeamFromId(event.player).index;
            TeamSprite(_teams[teamIdx]).takeTrick(_trick.orphanCards());
            TeamSprite(_teams[(teamIdx + 1) % 2]).clearLastTrick();

            var seat :int = table.getAbsoluteFromId(event.player);
            if (_model.bids.getBid(seat) == 0) {
                var p :PlayerSprite = PlayerSprite(
                    _players[table.getRelativeFromAbsolute(seat)]);
                if (SpadesBids(_model.bids).isBlind(seat)) {
                    p.showCaption("Failed Blind Nil", true);
                }
                else {
                    p.showCaption("Failed Nil", true);
                }
            }
        }
    }

    // TODO: move to a subclass of PlayerSprite
    protected function bidListener (event :BidEvent) :void
    {
        var seat :int;
        var p :PlayerSprite;

        if (event.type == BidEvent.PLACED) {
            if (event.value == 0 && event.player > 0) {
                seat = table.getRelativeFromId(event.player);
                p = PlayerSprite(_players[seat]);
                if (SpadesBids(_model.bids).isBlind(
                    table.getAbsoluteFromRelative(seat))) {
                    p.showCaption("Blind Nil");
                }
                else {
                    p.showCaption("Nil");
                }
            }
        }
        else if (event.type == BidEvent.RESET) {
            for (seat = 0; seat < _players.length; ++seat) {
                p = PlayerSprite(_players[seat]);
                p.showCaption("");
            }
        }
    }

    protected function handListener (event :HandEvent) :void
    {
        var i :int;
        var card :CardSprite;

        if (event.type == HandEvent.PASSED) {
            if (event.player == table.getLocalId()) {
                var removed :Array = _hand.finalizeRemovals();
                for (i = 0; i < removed.length; ++i) {
                    card = CardSprite(removed[i]);
                    var pos :Point = new Point(card.x, card.y);
                    pos = _hand.localToGlobal(pos);
                    pos = globalToLocal(pos);
                    addChild(card);
                    card.x = pos.x;
                    card.y = pos.y;
                }
                animatePass(removed, event.targetPlayer);
            }
            else if (event.targetPlayer != table.getLocalId()) {
                var cards :Array = new Array();
                var player :PlayerSprite = getPlayer(
                    table.getRelativeFromId(event.player));
                var x :Number = player.x;
                var y :Number = player.y;
                for (i = 0; i < event.count; ++i) {
                    card = new CardSprite(Card.createFaceDownCard());
                    cards.push(card);
                    card.x = x;
                    card.y = y;
                    card.alpha = 0;
                    addChild(card);

                    var tween :Object = {
                        alpha: 1.0,
                        time: 0.5};
                    Tweener.addTween(card, tween);

                    x += CardSprite.WIDTH / 2;
                }
                animatePass(cards, event.targetPlayer, 0.5);
            }
        }
    }

    protected function animatePass (
        cards :Array, 
        target :int, 
        delay :Number=0) :void
    {
        var player :PlayerSprite = getPlayer(table.getRelativeFromId(target));
        var x :Number = player.x;
        var y :Number = player.y;
        for (var i :int = 0; i < cards.length; ++i) {
            var c :CardSprite = CardSprite(cards[i]);

            var tween :Object = {
                x: x, y :y, 
                time: 2.0,
                delay: delay
            };
            Tweener.addTween(c, tween);

            tween = {
                alpha: 0, 
                time: 0.5,
                delay: delay + 1.5,
                onComplete: removeChild,
                onCompleteParams: [c]
            };
            Tweener.addTween(c, tween);

            x += CardSprite.WIDTH / 2;
        }
    }

    protected function removedListener (event :Event) :void
    {
        if (event.target == this) {
            removeChild(_trick);
            removeChild(_hand);
            removeChild(_teams[0] as TeamSprite);
            removeChild(_teams[1] as TeamSprite);
        }
    }

    protected function getPlayer (seat :int) :PlayerSprite
    {
        return _players[seat] as PlayerSprite;
    }

    protected function get table () :Table
    {
        return _model.table;
    }

    protected var _model :Model;
    protected var _players :Array;
    protected var _normalBids :NormalBiddingSprite;
    protected var _blindNilBids :BlindNilBiddingSprite;
    protected var _hand :HandSprite;
    protected var _trick :MainTrickSprite;
    protected var _teams :Array = [null, null];

    /** Positions of other players' on the table (relative to the local player). */
    protected static const PLAYER_POSITIONS :Array = [
        new Vector2(350, 350),  // me
        new Vector2(145, 200),  // my left
        new Vector2(350, 60),  // opposite
        new Vector2(555, 200)   // my right
    ];

    /** Position of the center of the local player's hand. */
    protected static const HAND_POSITION :Vector2 = new Vector2(350, 455);

    /** Position of the center of the bid slider */
    protected static const NORMAL_BIDS_POSITION :Vector2 = new Vector2(350, 195);

    /** Position of the center of the trick pile */
    protected static const TRICK_POSITION :Vector2 = new Vector2(350, 205);

    /** Position of the left-hand team */
    protected static const LEFT_TEAM_POSITION :Vector2 = new Vector2(95, 45);

    /** Position of the right-hand team */
    protected static const RIGHT_TEAM_POSITION :Vector2 = new Vector2(605, 45);

    /** Offset of the last trick, relative to the team. */
    protected static const LAST_TRICK_OFFSET :Number = 130;

    [Embed(source="../../../rsrc/background.png", mimeType="application/octet-stream")]
    protected static const BACKGROUND :Class;
}

}
