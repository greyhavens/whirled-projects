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
        _bids = new Array(players.length);

        _gameCtrl.net.addEventListener(
            ElementChangedEvent.ELEMENT_CHANGED,
            handleElementChanged);
        _gameCtrl.net.addEventListener(
            PropertyChangedEvent.PROPERTY_CHANGED,
            handlePropertyChanged);


        reset();
    }

    /** Request a bid from the local player up to a specified maximum amount. This is not a network 
     *  event and immediately dispatches a BidEvent.REQUESTED event. */
    public function request (max :int) :void
    {
        var playerId :int = _gameCtrl.game.getMyId();
        dispatchEvent(new BidEvent(BidEvent.REQUESTED, playerId, max));
    }

    /** Select the given bid on behalf of the local player. This is not a network event and 
     *  immediately sends a BidEvent.SELECTED event. */
    public function select (value :int) :void
    {
        var playerId :int = _gameCtrl.game.getMyId();
        dispatchEvent(new BidEvent(BidEvent.SELECTED, playerId, value));
    }

    /** Send a bid request to the server on behalf of the local player. When the reply is received,
     *  a BidEvent.PLACED event will be dispatched. If all bids are in, a BidEvent.COMPLETED event 
     *  will be sent. 
     *  @throws CardException if the player has already bid. */
    public function placeBid (value :int) :void
    {
        var seat :int = _gameCtrl.game.seating.getMyPosition();
        if (_bids[seat] != NO_BID) {
            throw new CardException("Player may not bid twice");
        }
        if (value == NO_BID) {
            throw new CardException("Player may not unbid");
        }
        _gameCtrl.net.setAt(ARRAYNAME, seat, value);
    }

    /** Send a message to the server to clear all bids in preparation for the next round. When the 
     *  reply is received, a BidEvent.RESET event will be dispatched. */
    public function reset () :void
    {
        var noBids :Array = new Array(players.length);
        for (var i :int = 0; i < noBids.length; ++i) {
            noBids[i] = NO_BID;
        }

        _gameCtrl.net.set(ARRAYNAME, noBids);
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
            if (_bids[i] != NO_BID) {
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
        return _bids[seat];
    }

    public function hasBid (seat :int) :Boolean
    {
        return _bids[seat] != NO_BID;
    }

    protected function handleElementChanged (event :ElementChangedEvent) :void
    {
        if (event.name == ARRAYNAME) {

            var seat :int = event.index;
            var bid :int = event.newValue as int;
            var playerId :int = players[seat];

            _bids[seat] = bid;

            dispatchEvent(new BidEvent(BidEvent.PLACED, playerId, bid));

            if (complete) {
                dispatchEvent(new BidEvent(BidEvent.COMPLETED));
            }
        }
    }

    protected function handlePropertyChanged (event :PropertyChangedEvent) :void
    {
        if (event.name == ARRAYNAME) {
            for (var i :int = 0; i < _bids.length; ++i) {
                _bids[i] = NO_BID;
            }

            dispatchEvent(new BidEvent(BidEvent.RESET));
        }
    }

    protected function get players () :Array
    {
        return _gameCtrl.game.seating.getPlayerIds();
    }

    protected var _gameCtrl :GameControl;
    protected var _bids :Array;
    protected var _maximum :int;

    protected static const ARRAYNAME :String = "bids";

    protected static const NO_BID: int = -1;
}

}
