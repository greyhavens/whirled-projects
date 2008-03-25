package spades.graphics {

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.events.MouseEvent;

import spades.card.CardArray;

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
        new Position(50, 40),  // me
        new Position(25, 25),  // my left
        new Position(50, 10),  // opposite
        new Position(75, 25)   // my right
    ];

    /** Position of the center of the local player's hand. */
    public static const HAND_POSITION :Position = new Position(50, 75);

    /** Position of the center of the bid slider */
    public static const SLIDER_POSITION :Position = new Position(50, 60);

    /** Position of the center of the trick pile */
    public static const TRICK_POSITION :Position = new Position(50, 25);

    /** Create a new table.
     *  @param playerNames the names of the players, in seat order
     *  @param localSeat the seat that the local player is sitting in */
    public function TableSprite (
        playerNames :Array, 
        localSeat :int,
        trick :CardArray,
        hand :CardArray)
    {
        _players = playerNames.map(createPlayer);

        _hand = new CardArraySprite(hand);
        Display.move(_hand, HAND_POSITION);
        addChild(_hand);

        _trick = new CardArraySprite(trick);
        Display.move(_trick, TRICK_POSITION);
        addChild(_trick);

        // listen for clicks on cards
        _hand.addEventListener(MouseEvent.CLICK, clickListener);

        function createPlayer (
            name :String, 
            seat :int, 
            names :Array) :PlayerSprite
        {
            var p :PlayerSprite = new PlayerSprite(name);
            var relative :int = (seat + names.length - localSeat) % names.length;
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
        var target :DisplayObject = event.target as DisplayObject;
        while (!(target is CardArraySprite)) {
            if (target is CardSprite) {
                if (_handCallback != null) {
                    var callback :Function = _handCallback;
                    _handCallback = null;
                    callback(CardSprite(target).card);
                }
                break;
            }
            target = target.parent;
        }
    }

    protected function getPlayer (seat :int) :PlayerSprite
    {
        return _players[seat] as PlayerSprite;
    }

    protected var _players :Array;
    protected var _bid :BidSprite;
    protected var _hand :CardArraySprite;
    protected var _trick :CardArraySprite;
    protected var _handCallback :Function;
}

}
