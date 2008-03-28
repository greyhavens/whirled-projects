package spades.graphics {

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.events.MouseEvent;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

import spades.card.CardArray;
import spades.card.CardArrayEvent;

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
        new Position(50, 50),  // me
        new Position(25, 30),  // my left
        new Position(50, 10),  // opposite
        new Position(75, 30)   // my right
    ];

    /** Position of the center of the local player's hand. */
    public static const HAND_POSITION :Position = new Position(50, 75);

    /** Position of the center of the bid slider */
    public static const SLIDER_POSITION :Position = new Position(50, 60);

    /** Position of the center of the trick pile */
    public static const TRICK_POSITION :Position = new Position(50, 30);

    /** Position of the center of the trick pile */
    public static const LAST_TRICK_POSITION :Position = new Position(10, 10);

    /** Create a new table.
     *  @param playerNames the names of the players, in seat order
     *  @param localSeat the seat that the local player is sitting in */
    public function TableSprite (
        playerNames :Array, 
        localSeat :int,
        trick :CardArray,
        hand :CardArray)
    {
        _numPlayers = playerNames.length;
        _localSeat = localSeat;

        _players = playerNames.map(createPlayer);

        _hand = new HandSprite(hand);
        Display.move(_hand, HAND_POSITION);
        addChild(_hand);

        _trick = new TrickSprite(trick, _numPlayers);
        Display.move(_trick, TRICK_POSITION);
        addChild(_trick);

        _lastTrick = new TrickSprite(new CardArray(), _numPlayers);
        Display.move(_lastTrick, LAST_TRICK_POSITION);
        addChild(_lastTrick);

        // listen for clicks on cards
        _hand.addEventListener(MouseEvent.CLICK, clickListener);

        // listen for the trick changing
        trick.addEventListener(CardArrayEvent.CARD_ARRAY, trickListener);

        // listen for our removal to prevent stranded listeners
        addEventListener(Event.REMOVED, removedListener);

        // listen for expiry of the last trick visibility
        _lastTrickTimer.addEventListener(TimerEvent.TIMER, timerListener);

        function createPlayer (
            name :String, 
            seat :int, 
            names :Array) :PlayerSprite
        {
            var p :PlayerSprite = new PlayerSprite(name);
            var relative :int = getRelativeSeat(seat);
            Display.move(p, PLAYER_POSITIONS[relative] as Position);
            addChild(p);
            return p;
        }
    }

    /** Highlight a player to show it is his turn. Also unhighlights any previous.
     *  If NO_SEAT is given, then all players are unhighlighted. */
    public function setPlayerTurn (seat :int) :void
    {
        _players.forEach(setTurn);

        function setTurn (p :PlayerSprite, index :int, array :Array) :void
        {
            p.setTurn(index == seat);
        }
    }

    /** Change a player's bid value. If NO_BID is given, then the value is shown
     *  as blank. */
    public function setPlayerBid (seat :int, bid :int) :void
    {
        getPlayer(seat).setBid(bid);
    }

    /** Set the number of tricks taken by a player. */
    public function setPlayerTricks (seat :int, tricks :int) :void
    {
        getPlayer(seat).setTricks(tricks);
    }

    /** Set the seating position that is kicking off the trick so that the cards in the trick will 
     *  show up in front of the right seat. */
    public function setTrickLeader (seat :int) :void
    {
        _trick.leader = getRelativeSeat(seat);
    }

    /** Set the seat that is currently winning the trick. */
    public function setTrickWinner (seat :int) :void
    {
        _trick.setWinner(getRelativeSeat(seat));
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
                Display.move(_bid, SLIDER_POSITION);
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

    protected function clickListener (event :MouseEvent) :void
    {
        var card :CardSprite = CardArraySprite.exposeCard(event.target);
        if (card != null && _handCallback != null) {
            var callback :Function = _handCallback;
            _handCallback = null;
            callback(card.card);
        }
    }

    protected function trickListener (event :CardArrayEvent) :void
    {
        if (event.action == CardArrayEvent.ACTION_PRERESET) {
            if (event.target != _trick.target) {
                throw new Error("Event target not the trick?!");
            }
            _lastTrick.leader = _trick.leader;
            _lastTrick.target.reset(_trick.target.ordinals);
            _lastTrick.winningCard = _trick.winningCard;
            _lastTrickTimer.reset();
            _lastTrickTimer.start();
        }
    }

    protected function timerListener (event :TimerEvent) :void
    {
        _lastTrick.target.reset();
        _lastTrickTimer.stop();
    }

    protected function removedListener (event :Event) :void
    {
        if (event.target == this) {
            _trick.target.removeEventListener(
                CardArrayEvent.CARD_ARRAY, trickListener);
        }
    }

    protected function getPlayer (seat :int) :PlayerSprite
    {
        return _players[seat] as PlayerSprite;
    }

    /** Get the index of the seat relative to the local player. I.e. local player = 0, player to the 
     *  left = 1, across = 2, right = 3. */
    protected function getRelativeSeat (seat :int) :int
    {
        return (seat + _numPlayers - _localSeat) % _numPlayers;
    }

    protected var _numPlayers :int;
    protected var _players :Array;
    protected var _localSeat :int;
    protected var _bid :BidSprite;
    protected var _hand :HandSprite;
    protected var _trick :TrickSprite;
    protected var _lastTrick :TrickSprite;
    protected var _handCallback :Function;
    protected var _lastTrickTimer :Timer = 
        new Timer(LAST_TRICK_VISIBILITY_DURATION * 1000, 1);

    /** Seconds that the last trick is visible. */
    protected const LAST_TRICK_VISIBILITY_DURATION :int = 5;
}

}
