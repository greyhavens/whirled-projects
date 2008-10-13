package lawsanddisorder {

import com.threerings.util.HashMap;
import com.whirled.game.CoinsAwardedEvent;
import com.whirled.game.ElementChangedEvent;
import com.whirled.game.GameSubControl;
import com.whirled.game.MessageReceivedEvent;
import com.whirled.game.PropertyChangedEvent;
import com.whirled.game.StateChangedEvent;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import lawsanddisorder.component.*;

/**
 * Manages property and message events, propagating them out to registered listeners.
 * TODO don't pass events in to listeners; detach from com.whirled.game?
 * TODO actually dispatch events
 */
public class EventHandler extends EventDispatcher
{
    /** Event that fires when some player's turn just started (including AIs) */
    public static const TURN_CHANGED :String = "turnChanged";
    
    /** Event that fires when the player's turn is ending */
    public static const MY_TURN_ENDED :String = "turnEnded";

    /** Event that fires when the player's turn is starting */
    public static const MY_TURN_STARTED :String = "turnStarted";

    /** Event that fires when the last round starts */
    public static const LAST_ROUND_STARTED :String = "lastRoundStarted";

    /**
     * Constructor - add event listeners and maybe get the board if it's setup 
     */
    public function EventHandler (ctx :Context)
    {
        _ctx = ctx;
        _ctx.control.game.addEventListener(StateChangedEvent.GAME_ENDED, gameEnded);
        _ctx.control.player.addEventListener(CoinsAwardedEvent.COINS_AWARDED, coinsAwarded);
        _ctx.control.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);
        _ctx.control.net.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, elementChanged);
        _ctx.control.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
        _ctx.control.game.addEventListener(StateChangedEvent.TURN_CHANGED, turnChanged);
        addMessageListener(LAST_ROUND_STARTED, lastRoundStarted);
    }

    /**
     * Invoke the given function in delay seconds.
     * TODO: replace with startTimer
     */
    public static function invokeLater (delaySeconds :int, func :Function) :void
    {
        var timer :Timer = new Timer(delaySeconds*1000, 1);
        timer.addEventListener(TimerEvent.TIMER, func);
        timer.start();
    }

    /**
     * Invoke the given function in delay milliseconds.
     */
    public static function startTimer (delayMillis :int, func :Function, numFires :int = 1) :void
    {
        var timer :Timer = new Timer(delayMillis, numFires);
        timer.addEventListener(TimerEvent.TIMER, function (event :Event): void { func(); });
        timer.start();
    }

    /**
     * Called when our distributed game state changes.
     */
    protected function propertyChanged (event :PropertyChangedEvent) :void
    {
        var key :String = event.name + "::" + "-1";
        var dataEvent :DataChangedEvent = new DataChangedEvent(event.name, event.oldValue, event.newValue, -1);
        dispatchDataEvent(key, dataEvent);
    }

    /**
     * Called when an element of a distributed array changes.  Call each listener.
     */
    protected function elementChanged (event :ElementChangedEvent) :void
    {
        var key :String = event.name + "::" + event.index;
        var dataEvent :DataChangedEvent = new DataChangedEvent(event.name, event.oldValue, event.newValue, event.index);
        dispatchDataEvent(key, dataEvent);

        // also send event to listeners who are inerested in a change to any or all elements
        var allKey :String = event.name + "::" + "-1";
        dispatchDataEvent(allKey, dataEvent);
    }

    /**
     * Dispatch the given data changed event to listeners registered with the given key.
     */
    protected function dispatchDataEvent (key :String, event :DataChangedEvent) :void
    {
        var listeners :Array = _dataListeners.get(key);
        if (listeners != null) {
            // iterate through and perform each listener
            for (var i :int = 0; i < listeners.length; i++) {
                var listener :Function = listeners[i];
                listener(event);
            }
        }
    }

    /**
     * Called when a message comes in.  Call each listener function in order.
     */
    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        // convert from Whirled event to our own to reduce dependencies
        var messageEvent :MessageEvent = new MessageEvent(event.name, event.value);
        var listeners :Array = _messageListeners.get(messageEvent.name);
        if (listeners != null) {
            // iterate through and perform each listener
            for (var i :int = 0; i < listeners.length; i++) {
                var listener :Function = listeners[i];
                listener(messageEvent);
            }
        }
    }

    /**
     * Registers a function to be called when a distributed property is changed.
     */
    public function addDataListener (name :String, listener :Function, index :int = -1) :void
    {
        var key :String = name + "::" + index;
        var listeners :Array = _dataListeners.get(key);
        // key already has a listener, add this one
        if (listeners != null) {
            listeners.push(listener);
        }
        // key doesn't have any listeners yet, add to map
        else {
            listeners = new Array();
            listeners.push(listener);
            _dataListeners.put(key, listeners);
        }
    }

    /**
     * De-registers a function from being called when a distributed property is changed.
     */
    public function removeDataListener (name :String, listener :Function, index :int = -1) :void
    {
        var key :String = name + "::" + index;
        var listeners :Array = _dataListeners.get(key);
        // key has no listeners, oops!
        if (listeners == null) {
            return
        }
        // iterate through and remove our listener
        for (var i :int = 0; i < listeners.length; i++) {
            if (listeners[i] == listener) {
                listeners.splice(i, 1);
            }
        }
        // remove key entirely if that was the only listener
        // TODO is this necessary?  might be less efficient?
        if (listeners.length == 0) {
            _dataListeners.remove(key);
        }
    }

    /**
     * Registers a function to be called when a game message arrives.
     */
    public function addMessageListener (message :String, listener :Function) :void
    {
        var listeners :Array = _messageListeners.get(message);
        // message already has a listener, add this one
        if (listeners != null) {
            listeners.push(listener);
        }
        // message doesn't have any listeners yet, add to map
        else {
            listeners = new Array();
            listeners.push(listener);
            _messageListeners.put(message, listeners);
        }
    }

    /**
     * De-registers a function from being called when a game message arrives.
     */
    public function removeMessageListener (message :String, listener :Function) :void
    {
        var listeners :Array = _messageListeners.get(message);
        // message has no listeners, oops!
        if (listeners == null) {
            return
        }
        // iterate through and remove our listener
        for (var i :int = 0; i < listeners.length; i++) {
            if (listeners[i] == listener) {
                listeners.splice(i, 1);
            }
        }
        // remove property entirely if that was the only listener
        if (listeners.length == 0) {
            _messageListeners.remove(message);
        }
    }


    /**
     * Wrapper for retrieving data values from the control
     */
    public function getData (propName :String, index :int = -1) :*
    {
        var propertyValue :* = _ctx.control.net.get(propName);
        if (index > -1) {
            if (propertyValue == null) {
                return null;
            }
            else {
              return propertyValue[index];
            }
        }
        else {
            return propertyValue;
        }
    }

    /**
     * Wrapper for setting data values with the control
     */
    public function setData (propName :String, value :Object, index :int = -1, isDictionary :Boolean = false) :void
    {
        if (index > -1 && isDictionary) {
            _ctx.control.net.setIn(propName, index, value);
        }
        else if (index > -1) {
            _ctx.control.net.setAt(propName, index, value);
        }
        else {
            _ctx.control.net.set(propName, value);
        }
    }

    /**
     * The deck is empty; start the last round.  When this player's turn starts again, that
     * will signal the end of the game.
     */
    public function startLastRound () :void
    {
        // last round has already started, quit
        if (_lastRoundStarted) {
            return;
        }
        _lastTurnStarted = true;
        _ctx.sendMessage(LAST_ROUND_STARTED, _ctx.player.id);
        _ctx.broadcast("The deck is empty, so this is the last round.  This is " +
            _ctx.player.playerName + "'s last turn.");
    }

    /**
     * Message event received when the last round starts.
     */
    protected function lastRoundStarted (event :MessageEvent) :void
    {
        _lastRoundStarted = true;
        _ctx.eventHandler.addEventListener(EventHandler.MY_TURN_STARTED, lastRoundTurnStarted);
    }

    /**
     * Fires when a turn starts during the last round.  If this is the player's second
     * turn during the last round, end the game.
     */
    protected function lastRoundTurnStarted (event :Event) :void
    {
        _ctx.log("EventHandler.lastRoundTurnStarted");
        if (!_lastTurnStarted) {
            _lastTurnStarted = true;
        }
        else {
            _ctx.eventHandler.removeEventListener(EventHandler.MY_TURN_STARTED, 
               lastRoundTurnStarted);
            endGame();
        }
    }

    /**
     * The last round ended, so finally end the game.
     * Calculate the scores and send a message to everyone, awarding flow.
     * Assumes player seats may have changed during the game and rebuilds playerIds array.
     */
    protected function endGame () :void
    {
        _ctx.log("EventHandler.endGame");
        // whoever's turn it is when the game ends,
        // end every player's turn to lock the board.
        _ctx.board.endTurnButton.gameEnded();

        // prepare for a possible rematch
        _lastRoundStarted = false;
        _lastTurnStarted = false;
        _ctx.eventHandler.removeEventListener(EventHandler.MY_TURN_STARTED, endGame);

        var playerIds :Array = new Array;
        var playerScores :Array = new Array;

        // TODO use winning percentile instead?
        for each (var player :Player in _ctx.board.players.playerObjects) {
            playerIds.push(player.serverId);
            playerScores.push(player.monies);
        }

        _ctx.control.game.endGameWithScores(playerIds, playerScores, 
            GameSubControl.CASCADING_PAYOUT);
    }

    /**
     * Handler for recieving game end events
     */
    protected function gameEnded (event :StateChangedEvent) :void
    {
        _ctx.notice("Game over - thanks for playing!");
        _lastRoundStarted = false;
    }

    /**
     * Handler for receiving coins awarded events
     */
    protected function coinsAwarded (event :CoinsAwardedEvent) :void
    {
        _ctx.notice("You got: " + event.amount + " coins for playing.  That's " + event.percentile + "%");
    }

    /**
     * Dispatch an internal turn changed event because the turn has changed.
     */
    protected function turnChanged (event :StateChangedEvent) :void
    {
        // there are two turnChanged events when the game starts, ignore the first
        if (_ctx.board == null) {
            return;
        }
        
        // set the turnHolder before sending out the word to other components
        _ctx.board.players.calculateTurnHolder();
        dispatchEvent(new Event(EventHandler.TURN_CHANGED));
    }
    
    /** Context */
    protected var _ctx :Context;

    /** Map of listener functions for distributed property changes.
     *  Types <String, Array<Function>> */
    protected var _dataListeners :HashMap = new HashMap();

    /** Map of listener functions for game messages.
     *  Types <String, Array<Function>> */
    protected var _messageListeners :HashMap = new HashMap();

    /** Determines whether the last round of the game has begun */
    protected var _lastRoundStarted :Boolean = false;

    /** Whether the player has taken their last turn or not */
    protected var _lastTurnStarted :Boolean = false;
}
}