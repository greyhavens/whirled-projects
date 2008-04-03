package spades.graphics {

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.events.MouseEvent;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

import com.threerings.flash.Vector2;

import spades.card.CardArray;
import spades.card.CardArrayEvent;
import spades.card.Trick;
import spades.card.TrickEvent
import spades.card.Table;
import spades.card.Bids;
import spades.card.BidEvent;

/**
 * Display object for drawing a spades game.
 */
public class TableSprite extends Sprite
{
    /** Seat value to indicate no seat. */
    public static const NO_SEAT :int = -1;

    /** Bid value to indicate no bid has been placed yet. */
    public static const NO_BID :int = -1;

    /** Positions of other players' on the table (relative to the local player). */
    public static const PLAYER_POSITIONS :Array = [
        new Vector2(350, 350),  // me
        new Vector2(145, 200),  // my left
        new Vector2(350, 60),  // opposite
        new Vector2(555, 200)   // my right
    ];

    /** Position of the center of the local player's hand. */
    public static const HAND_POSITION :Vector2 = new Vector2(350, 455);

    /** Position of the center of the bid slider */
    public static const SLIDER_POSITION :Vector2 = new Vector2(350, 255);

    /** Position of the center of the trick pile */
    public static const TRICK_POSITION :Vector2 = new Vector2(350, 205);

    /** Position of the left-hand team */
    public static const LEFT_TEAM_POSITION :Vector2 = new Vector2(95, 45);

    /** Position of the right-hand team */
    public static const RIGHT_TEAM_POSITION :Vector2 = new Vector2(605, 45);

    /** Offset of the last trick, relative to the team. */
    public static const LAST_TRICK_OFFSET :Number = 130;

    /** Create a new table.
     *  @param playerNames the names of the players, in seat order
     *  @param localSeat the seat that the local player is sitting in */
    public function TableSprite (
        seating :Table,
        winningScore :int,
        bids :Bids,
        trick :Trick,
        hand :CardArray)
    {
        _seating = seating;
        _winningScore = winningScore;

        _players = new Array(_seating.numPlayers);
        for (var seat :int = 0; seat < _seating.numPlayers; ++seat) {
            var name :String = _seating.getNameFromRelative(seat);
            var p :PlayerSprite = new PlayerSprite(name);
            addChild(p);
            _players[seat] = p;
        }
        
        _hand = new HandSprite(hand);
        addChild(_hand);

        _trick = new MainTrickSprite(trick, _seating, _players, _hand);
        addChild(_trick);

        _teams[0] = new TeamSprite(_seating, [0, 2], bids,
            TRICK_POSITION, new Vector2(LAST_TRICK_OFFSET, 0));
        addChild(_teams[0] as TeamSprite);

        _teams[1] = new TeamSprite(_seating, [1, 3], bids,
            TRICK_POSITION, new Vector2(-LAST_TRICK_OFFSET, 0));
        addChild(_teams[1] as TeamSprite);

        // listen for clicks on cards
        _hand.addEventListener(MouseEvent.CLICK, clickListener);

        // listen for the trick changing
        trick.addEventListener(TrickEvent.COMPLETED, trickListener);

        // listen for our removal to prevent stranded listeners
        addEventListener(Event.REMOVED, removedListener);

        layout();
    }

    /** Retrieve a callback to set a player's head shot. */
    public function getHeadShotCallback (seat :int) :Function
    {
        return getPlayer(_seating.getRelativeFromAbsolute(seat)).setHeadShot;
    }

    /** Set team scores. */
    public function setTeamScores (scores :Array) :void
    {
        var offset :int = 0;
        if (_seating.getLocalSeat() == 1 || _seating.getLocalSeat() == 3) {
            offset = 1;
        }
        _teams[0].setScore(scores[offset], _winningScore); 
        _teams[1].setScore(scores[(offset + 1) % 2], _winningScore); 
    }

    /** Highlight a player to show it is his turn. Also unhighlights any previous.
     *  If NO_SEAT is given, then all players are unhighlighted. */
    public function setPlayerTurn (seat :int) :void
    {
        seat = _seating.getRelativeFromAbsolute(seat);
        _players.forEach(setTurn);

        function setTurn (p :PlayerSprite, index :int, array :Array) :void
        {
            p.setTurn(index == seat);
        }
    }

    /** Set the number of tricks taken by a player. */
    public function setPlayerTricks (seat :int, tricks :int) :void
    {
        seat = _seating.getRelativeFromAbsolute(seat);
        getTeam(seat).setTricks(getTeamPlayer(seat), tricks);
    }

    /** Show the bid slider and call the given function when a bid is selected. The signature of 
     *  the completion function should be:
     *
     *    function callback (bid :int) :void 
     **/
    public function showBidControl (
        show :Boolean, 
        max :int, 
        callback :Function) :void
    {
        if (show) {
            if (_bid == null) {
                _bid = new BidSprite(max, callback);
                positionChild(_bid, SLIDER_POSITION);
                addChild(_bid);
            }
        }
        else {
            if (_bid != null) {
                removeChild(_bid);
                _bid = null;
            }
        }
    }

    /** Disable all the player's cards. Called for example before bidding completes or when it 
     *  is someone else's turn. */
    public function disableHand () :void
    {
        _hand.disable();
    }

    /** Enable some or all of the player's cards. Call a function when a card is selected. Called 
     *  when it is the player's turn with the set of legal cards to play. The callback should have 
     *  a signature compatible with:
     *
     *     function callback (card :Card) :void
     *
     *  To prevent spastic clicking from causing multiple network sends, the callback is reset as 
     *  it is called.
     *  @param subset the cards to enable. If null, all cards are enabled. */
    public function enableHand (callback :Function, subset :CardArray=null) :void
    {
        _hand.enable(subset);
        _handCallback = callback;
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
        _players.forEach(positionPlayer);

        function positionPlayer (p :PlayerSprite, seat :int, a :Array) :void {
            positionChild(p, PLAYER_POSITIONS[seat] as Vector2);
        }
    }

    protected function clickListener (event :MouseEvent) :void
    {
        var card :CardSprite = CardArraySprite.exposeCard(event.target);
        if (card != null && _handCallback != null && 
            card.state != CardSprite.DISABLED) {
            var callback :Function = _handCallback;
            _handCallback = null;
            callback(card.card);
        }
    }

    protected function trickListener (event :TrickEvent) :void
    {
        if (event.type == TrickEvent.COMPLETED) {
            var trick :Trick = event.target as Trick;
            var seat :int = _seating.getRelativeFromId(event.player);
            getTeam(seat).takeTrick(_trick.orphanCards());
            getTeam((seat + 1) % 2).clearLastTrick();
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

    /** Get the team sprite for a relative seating position. */
    protected function getTeam (relativeSeat :int) :TeamSprite
    {
        if (relativeSeat == 0 || relativeSeat == 2) {
            return _teams[0];
        }
        else {
            return _teams[1];
        }
    }

    /** Get the index of a player within his team for a relative seating position. */
    protected function getTeamPlayer (relativeSeat :int) :int
    {
        if (relativeSeat == 0 || relativeSeat == 1) {
            return 0;
        }
        else {
            return 1;
        }
    }

    protected var _players :Array;
    protected var _seating :Table;
    protected var _bid :BidSprite;
    protected var _hand :HandSprite;
    protected var _trick :MainTrickSprite;
    protected var _handCallback :Function;
    protected var _teams :Array = [null, null];
    protected var _winningScore :int;

    /** Seconds that the last trick is visible. */
    protected const LAST_TRICK_VISIBILITY_DURATION :int = 5;
}

}
