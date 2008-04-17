package spades.card {

import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Timer;

import com.whirled.game.GameControl;
import com.whirled.game.StateChangedEvent;
import com.whirled.game.MessageReceivedEvent;

import spades.Debug;

/** Regulates the length of time consumed by a player making a move. Basically just listens for 
 *  turn changes and dispatches events when a certain amount of time has passed. */
public class TurnTimer extends EventDispatcher
{
    /** Creates a new turn timer for a given game control and table. 
     *  @param gameCtrl the game control
     *  @param table the table where turns are being timed
     *  @param bids the bids (needed because more time is allowed for bidding) */
    public function TurnTimer (
        gameCtrl :GameControl, 
        table :Table, 
        bids :Bids,
        trick :Trick)
    {
        _gameCtrl = gameCtrl;
        _table = table;
        _bids = bids;
        _trick = trick;
        
        var tracker :Array = new Array(table.numPlayers);
        for (var i :int = 0; i < tracker.length; ++i) {
            tracker[i] = 0;
        }
        _gameCtrl.net.set(EXPIRY_TRACKER, tracker);

        gameCtrl.game.addEventListener(
            StateChangedEvent.TURN_CHANGED, 
            handleTurnChanged);
        _gameCtrl.net.addEventListener(
            MessageReceivedEvent.MESSAGE_RECEIVED,
            handleMessage);
        _timer.addEventListener(TimerEvent.TIMER, timerListener);
    }

    /** Access the amount of time allowed for bidding. */
    public function get bidTime () :Number
    {
        return _bidTime;
    }

    /** Access the amount of time allowed for bidding. */
    public function set bidTime (time :Number) :void
    {
        _bidTime = time;
    }

    /** Access the amount of time allowed for leading a trick. */
    public function get leadTime () :Number
    {
        return _leadTime;
    }

    /** Access the amount of time allowed for leading a trick. */
    public function set leadTime (time :Number) :void
    {
        _leadTime = time;
    }

    /** Access the amount of time allowed for playing a card. */
    public function get playTime () :Number
    {
        return _playTime;
    }

    /** Access the amount of time allowed for playing a card. */
    public function set playTime (time :Number) :void
    {
        _playTime = time;
    }

    /** Disable the turn timer. For debugging specific game play situations. */
    public function disable () :void
    {
        _enabled = false;
    }

    /** Restart the timer for the current turnholder. Used if there is a multi-stage turn where 
     *  the turn holder does not change. */
    public function restart () :void
    {
        if (!_gameCtrl.game.amInControl()) {
            Debug.debug("TurnTimer.restart called with no effect");
            return;
        }

        if (!_enabled) {
            return;
        }

        if (turnHolder != 0) {
            var seat :int = _table.getAbsoluteFromId(turnHolder);
            var bidding :Boolean = !_bids.hasBid(seat);
            var leading :Boolean = !bidding && _trick.length == 0;

            var time :Number;
            if (bidding) {
                time = _bidTime;
            }
            else if (leading) {
                time = _leadTime;
            }
            else {
                time = _playTime;
            }

            // diminish by the number of expiries in past turns
            var divisor :int = countExpiries(seat);
            time /= (1 + divisor * HISTORY_EFFECT);

            _gameCtrl.net.sendMessage(MSG_START, [turnHolder, time]);
            _lastTurnHolder = turnHolder;
        }
    }

    protected function handleTurnChanged (event :StateChangedEvent) :void
    {
        if (!_gameCtrl.game.amInControl() || !_enabled) {
            return;
        }

        if (_lastTurnHolder != 0) {
            addHistory(_lastTurnHolder, false, 4);
            _lastTurnHolder = 0;
            _timer.stop();
        }

        restart();
    }

    protected function handleMessage (event :MessageReceivedEvent) :void
    {
        var player :int;

        if (event.name == MSG_START) {
            player = (event.value as Array)[0] as int;
            var time :Number = (event.value as Array)[1] as Number;

            if (turnHolder == player) {
                if (_gameCtrl.game.amInControl()) {
                    _timer.delay = time * 1000;
                    _timer.reset();
                    _timer.start();
                }
                dispatchEvent(new TurnTimerEvent(
                    TurnTimerEvent.STARTED, player, time));
                Debug.debug("Turn timer started for " + 
                    _table.getNameFromId(player) + ", time " + time);
            }
        }
        else if (event.name == MSG_EXPIRED) {
            player = event.value as int;
            if (turnHolder == player) {
                if (_gameCtrl.game.amInControl()) {
                    addHistory(player, true, 1);
                    _lastTurnHolder = 0;
                }
                dispatchEvent(new TurnTimerEvent(
                    TurnTimerEvent.EXPIRED, player, time));
                Debug.debug("Turn timer expired for " + 
                    _table.getNameFromId(player));
            }
        }
    }

    protected function get turnHolder () :int
    {
        return _gameCtrl.game.getTurnHolderId();
    }

    protected function timerListener (event :TimerEvent) :void
    {
        if (_gameCtrl.game.amInControl()) {
            if (_lastTurnHolder == turnHolder) {
                _gameCtrl.net.sendMessage(MSG_EXPIRED, _lastTurnHolder);
            }
            else {
                Debug.debug("Last turn holder was " + _lastTurnHolder + " but current is " + turnHolder);
            }
        }
    }

    protected function countExpiries (seat :int) :int
    {
        var tracker :Array = _gameCtrl.net.get(EXPIRY_TRACKER) as Array;
        var counter :int = tracker[seat] as int;
        var count :int = 0;
        while (counter != 0) {
            count += (counter & 1);
            counter >>= 1;
        }
        return count;
    }

    protected function addHistory (
        turnHolder :int, 
        expired :Boolean, 
        count :int) :void
    {
        var seat :int = _table.getAbsoluteFromId(turnHolder);
        var tracker :Array = _gameCtrl.net.get(EXPIRY_TRACKER) as Array;

        var history :int = tracker[seat];
        while (count-- > 0) {
            history <<= 1;
            if (expired) {
                history |= 1;
            }
            history &= HISTORY_MASK;
        }

        _gameCtrl.net.setAt(EXPIRY_TRACKER, seat, history);

        Debug.debug("Player " + _table.getNameFromId(turnHolder) + 
            " now has " + countExpiries(seat) + " expiries");
    }

    protected var _gameCtrl :GameControl;
    protected var _table :Table;
    protected var _bids :Bids;
    protected var _trick :Trick;
    protected var _timer :Timer = new Timer(0, 1);
    protected var _bidTime :Number = 30;
    protected var _leadTime :Number = 20;
    protected var _playTime :Number = 10;
    protected var _lastTurnHolder :int = 0;
    protected var _enabled :Boolean = true;

    protected static const EXPIRY_TRACKER :String = "turntimer.expirytracker";
    protected static const MSG_START :String = "turntimer.start";
    protected static const MSG_EXPIRED :String = "turntimer.stop";
    protected static const HISTORY_SIZE :int = 8;
    protected static const HISTORY_MASK :int = 0x000000FF;
    protected static const HISTORY_EFFECT :Number = 0.25;
}

}
