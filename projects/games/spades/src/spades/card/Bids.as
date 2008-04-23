package spades.card {

import flash.events.EventDispatcher;

import com.whirled.game.ElementChangedEvent;
import com.whirled.game.PropertyChangedEvent;
import com.whirled.game.GameControl;

/** Manages the player bids for a trick taking card game such as spades. Changes to bids are sent 
 *  to the server and the data structure is only modified once the reply is received, at which time 
 *  a BidEvent is dispatched.*/
public class Bids extends EventDispatcher
{
    /** Create a new set of player bids. 
     *  @param gameCtrl the game control object used to set up the storage and communicate with 
     *  the server. 
     *  @param maximum the maximum bid that the game rules will allow (the turn maximum is 
     *  typically lower and set in the request method) */
    public function Bids (gameCtrl :GameControl, maximum :int)
    {
        _gameCtrl = gameCtrl;
        _maximum = maximum;
        _bids = new NetArray(gameCtrl, ARRAYNAME, players.length, NO_BID);

        _gameCtrl.net.addEventListener(
            ElementChangedEvent.ELEMENT_CHANGED,
            handleElementChanged);
        _gameCtrl.net.addEventListener(
            PropertyChangedEvent.PROPERTY_CHANGED,
            handlePropertyChanged);
    }

    /** Request a bid from the local player up to a specified maximum amount. This is not a network 
     *  event and immediately dispatches a BidEvent.REQUESTED event. */
    public function request (max :int) :void
    {
        var playerId :int = _gameCtrl.game.getMyId();
        dispatchEvent(new BidEvent(BidEvent.REQUESTED, playerId, max));
        _hasSelected = false;
    }

    /** Select the given bid on behalf of the local player. This is not a network event and 
     *  immediately sends a BidEvent.SELECTED event. */
    public function select (value :int) :void
    {
        var playerId :int = _gameCtrl.game.getMyId();
        dispatchEvent(new BidEvent(BidEvent.SELECTED, playerId, value));
        _hasSelected = true;
    }

    /** Send a bid request to the server on behalf of the local player. When the reply is received,
     *  a BidEvent.PLACED event will be dispatched. If all bids are in, a BidEvent.COMPLETED event 
     *  will be sent. 
     *  @throws CardException if the player has already bid. */
    public function placeBid (value :int) :void
    {
        var seat :int = _gameCtrl.game.seating.getMyPosition();
        if (_bids.getAt(seat) != NO_BID) {
            throw new CardException("Player may not bid twice");
        }
        if (value == NO_BID) {
            throw new CardException("Player may not unbid");
        }
        _bids.setAt(seat, value);
    }

    /** Send a message to the server to clear all bids in preparation for the next round. When the 
     *  reply is received, a BidEvent.RESET event will be dispatched. */
    public function reset () :void
    {
        _bids.reset();
    }

    /** Access the maximum bid value. */
    public function get maximum () :int
    {
        return _maximum;
    }

    /** Access the number of bids placed so far. */
    public function get length () :int
    {
        var count :int = 0;
        for (var i :int = 0; i < _bids.length; ++i) {
            if (_bids.getAt(i) != NO_BID) {
                ++count;
            }
        }
        return count;
    }

    /** Access whether or not all bids have been placed. */
    public function get complete () :Boolean
    {
        return length == players.length;
    }

    /** Get the bid for an absolute seating position. */
    public function getBid (seat :int) :int
    {
        return _bids.getAt(seat);
    }

    /** Check if the player in an absolute seating position has placed a bid yet. */
    public function hasBid (seat :int) :Boolean
    {
        return _bids.getAt(seat) != NO_BID;
    }

    /** Access whether or not a bid has been selected since the call to request a bid. This is 
     *  necessary for the auto-play feature to prevent a second bid from occurring while the first 
     *  one is propagating. */
    public function get hasSelected () :Boolean
    {
        return _hasSelected;
    }

    protected function handleElementChanged (event :ElementChangedEvent) :void
    {
        if (event.name == ARRAYNAME) {

            var bid :int = event.newValue as int;
            var playerId :int = players[event.index];

            dispatchEvent(new BidEvent(BidEvent.PLACED, playerId, bid));

            if (complete) {
                dispatchEvent(new BidEvent(BidEvent.COMPLETED));
            }
        }
    }

    protected function handlePropertyChanged (event :PropertyChangedEvent) :void
    {
        if (event.name == ARRAYNAME) {
            dispatchEvent(new BidEvent(BidEvent.RESET));
        }
    }

    protected function get players () :Array
    {
        return _gameCtrl.game.seating.getPlayerIds();
    }

    protected var _gameCtrl :GameControl;
    protected var _bids :NetArray;
    protected var _maximum :int;
    protected var _hasSelected :Boolean;

    protected static const ARRAYNAME :String = "bids";

    protected static const NO_BID: int = -1;
}

}
