package spades.graphics {

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.geom.Point;
import com.whirled.game.StateChangedEvent;
import com.whirled.game.SizeChangedEvent;
import com.threerings.util.MultiLoader;
import com.threerings.util.Assert;
import caurina.transitions.Tweener;
import spades.Debug;
import spades.Model;
import spades.card.SpadesBids;
import com.whirled.contrib.card.Card;
import com.whirled.contrib.card.Table;
import com.whirled.contrib.card.HandEvent;
import com.whirled.contrib.card.trick.Bids;
import com.whirled.contrib.card.trick.BidEvent;
import com.whirled.contrib.card.trick.Trick;
import com.whirled.contrib.card.trick.TrickEvent
import com.whirled.contrib.card.graphics.CardSprite;
import com.whirled.contrib.card.graphics.PlayerSprite;
import com.whirled.contrib.card.graphics.NormalBiddingSprite;
import com.whirled.contrib.card.graphics.HandSprite;
import com.whirled.contrib.card.graphics.MainTrickSprite;
import com.whirled.contrib.card.graphics.TeamSprite;
import com.whirled.contrib.card.graphics.LocalTweener;

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

        LocalTweener.addTweenFn = Tweener.addTween;
        LocalTweener.removeTweensFn = Tweener.removeTweens;
        LocalTweener.isTweeningFn = Tweener.isTweening;

        _model = model;
        _factory = new Factory();

        _players = new Array(table.numPlayers);
        for (var seat :int = 0; seat < table.numPlayers; ++seat) {
            var name :String = table.getNameFromRelative(seat);
            var p :PlayerSprite = _factory.createPlayerSprite(table, 
                table.getIdFromRelative(seat), _model.timer);
            addChild(p);
            _players[seat] = p;

            p.setHeadShot(_model.gameCtrl.local.getHeadShot(
                 table.getIdFromRelative(seat)));
        }

        if (_model.hand != null) {
            _hand = _factory.createHandSprite(_model.hand);
            addChild(_hand);
        }

        _trick = new MainTrickSprite(
            _model.trick, table, _players, _hand);
        addChild(_trick);

        _teams[0] = _factory.createTeamSprite(_model.scores, 0, 
            new Point(LAST_TRICK_OFFSET, 0));
        addChild(_teams[0] as TeamSprite);

        _teams[1] = _factory.createTeamSprite(_model.scores, 1, 
            new Point(-LAST_TRICK_OFFSET, 0));
        addChild(_teams[1] as TeamSprite);

        _normalBids = _factory.createNormalBiddingSprite(_model.bids);
        addChild(_normalBids);

        _blindNilBids = new BlindNilBiddingSprite(_model.bids);
        addChild(_blindNilBids);

        // update the turn highlighter
        handleTurnChanged(null);

        // listen for the trick changing
        _model.trick.addEventListener(TrickEvent.COMPLETED, trickListener);
        _model.trick.addEventListener(TrickEvent.CARD_PLAYED, trickListener);

        // listen for blind nil updates
        _model.bids.addEventListener(BidEvent.PLACED, bidListener);
        _model.bids.addEventListener(BidEvent.RESET, bidListener);

        // listen for passing cards between players
        if (_model.hand != null) {
            _model.hand.addEventListener(HandEvent.PASSED, handListener);
        }

        _model.gameCtrl.game.addEventListener(
            StateChangedEvent.ROUND_ENDED, 
            handleRoundEnded);
        _model.gameCtrl.game.addEventListener(
            StateChangedEvent.TURN_CHANGED, 
            handleTurnChanged);
        _model.gameCtrl.game.addEventListener(
            StateChangedEvent.GAME_ENDED, 
            handleGameEnded);
        _model.gameCtrl.game.addEventListener(
            StateChangedEvent.GAME_STARTED, 
            handleGameStarted);
        _model.gameCtrl.local.addEventListener(
            SizeChangedEvent.SIZE_CHANGED,
            handleSizeChanged);

        updateSize(_model.gameCtrl.local.getSize());
        layout();

        function gotBackground (background :DisplayObject) :void
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

    protected function handleGameStarted (event :StateChangedEvent) :void
    {
        if (_hand != null) {
            _hand.visible = true;
        }
        _trick.visible = true;
    }

    protected function handleGameEnded (event :StateChangedEvent) :void
    {
        _normalBids.visible = false;
        _blindNilBids.visible = false;
        if (_hand != null) {
            _hand.visible = false;
        }
        _trick.visible = false;
        TeamSprite(_teams[0]).clearLastTrick();
        TeamSprite(_teams[1]).clearLastTrick();
    }

    protected function handleTurnChanged (event :StateChangedEvent) :void
    {
        var id :int = _model.gameCtrl.game.getTurnHolderId();
        setPlayerTurn(table.getAbsoluteFromId(id));
    }

    protected function positionChild (child :DisplayObject, pos :Point) :void
    {
        child.x = pos.x;
        child.y = pos.y;
    }

    /** Position all the children. */
    protected function layout () :void
    {
        if (_hand != null) {
            positionChild(_hand, HAND_POSITION);
        }
        positionChild(_trick, TRICK_POSITION);
        positionChild(_teams[0] as TeamSprite, LEFT_TEAM_POSITION);
        positionChild(_teams[1] as TeamSprite, RIGHT_TEAM_POSITION);
        positionChild(_normalBids, NORMAL_BIDS_POSITION);
        positionChild(_blindNilBids, NORMAL_BIDS_POSITION);
        _players.forEach(positionPlayer);

        function positionPlayer (p :PlayerSprite, seat :int, a :Array) :void {
            positionChild(p, PLAYER_POSITIONS[seat] as Point);
        }
    }

    protected function trickListener (event :TrickEvent) :void
    {
        if (event.type == TrickEvent.COMPLETED) {
            var trick :Trick = event.target as Trick;
            var teamIdx :int = table.getTeamFromId(event.player).index;
            var playerPos :Point = getPlayer(table.getRelativeFromId(
                event.player)).localToGlobal(new Point(0, 0));
            var mainTrickPos :Point = _trick.localToGlobal(new Point(0, 0));
            TeamSprite(_teams[teamIdx]).takeTrick(
                _trick.orphanCards(), mainTrickPos, playerPos);
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
        else if (event.type == TrickEvent.CARD_PLAYED) {
            var bids :Bids = _model.bids;
            for (seat = 0; seat < _players.length; ++seat) {
                p = PlayerSprite(_players[seat]);
                if (bids.getBid(table.getAbsoluteFromRelative(seat)) != 0) {
                    p.showCaption("");
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
            if (event.player > 0) {
                seat = table.getRelativeFromId(event.player);
                p = PlayerSprite(_players[seat]);
                if (event.value == 0) {
                    if (SpadesBids(_model.bids).isBlind(
                        table.getAbsoluteFromRelative(seat))) {
                        p.showCaption("Blind Nil");
                    }
                    else {
                        p.showCaption("Nil");
                    }
                }
                else {
                    p.showCaption("Bid: " + event.value);
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
        Assert.isNotNull(_hand);

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
                    card = _factory.createCard(
                        Card.createFaceDownCard());
                    cards.push(card);
                    card.x = x;
                    card.y = y;
                    card.alpha = 0;
                    addChild(card);

                    var tween :Object = {
                        alpha: 1.0,
                        time: 0.5};
                    Tweener.addTween(card, tween);

                    x += _factory.getCardWidth() / 2;
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

            x += _factory.getCardWidth() / 2;
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

    protected function handleSizeChanged (event :SizeChangedEvent) :void
    {
        updateSize(event.size);
    }

    protected function updateSize (size :Point) :void
    {
        const IDEAL_WIDTH :int = 700;
        const IDEAL_HEIGHT :int = 500;

        var width :int = Math.max(size.x, IDEAL_WIDTH);
        var height :int = Math.max(size.y, IDEAL_HEIGHT);

        var xscale :Number = width / IDEAL_WIDTH;
        var yscale :Number = height / IDEAL_HEIGHT;
        var scale :Number = Math.min(xscale, yscale);

        Debug.debug("Current size is " + size.x + "x" + size.y + ", Scaling to " + scale);

        // scale will be 1 or higher, since we don't let width/height get smaller than IDEAL
        scaleX = scale;
        scaleY = scale;

        x = (width - (IDEAL_WIDTH * scale)) / 2;
        y = (height - (IDEAL_HEIGHT * scale)) / 2;
    }


    protected var _model :Model;
    protected var _players :Array;
    protected var _normalBids :NormalBiddingSprite;
    protected var _blindNilBids :BlindNilBiddingSprite;
    protected var _hand :HandSprite;
    protected var _trick :MainTrickSprite;
    protected var _teams :Array = [null, null];
    protected var _factory :Factory;

    /** Positions of other players' on the table (relative to the local player). */
    protected static const PLAYER_POSITIONS :Array = [
        new Point(350, 350),  // me
        new Point(145, 200),  // my left
        new Point(350, 60),  // opposite
        new Point(555, 200)   // my right
    ];

    /** Position of the center of the local player's hand. */
    protected static const HAND_POSITION :Point = new Point(350, 455);

    /** Position of the center of the bid slider */
    protected static const NORMAL_BIDS_POSITION :Point = new Point(350, 195);

    /** Position of the center of the trick pile */
    protected static const TRICK_POSITION :Point = new Point(350, 205);

    /** Position of the left-hand team */
    protected static const LEFT_TEAM_POSITION :Point = new Point(95, 45);

    /** Position of the right-hand team */
    protected static const RIGHT_TEAM_POSITION :Point = new Point(605, 45);

    /** Offset of the last trick, relative to the team. */
    protected static const LAST_TRICK_OFFSET :Number = 130;

    [Embed(source="../../../rsrc/background.png", mimeType="application/octet-stream")]
    protected static const BACKGROUND :Class;
}

}
