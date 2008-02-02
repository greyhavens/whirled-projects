package lawsanddisorder {

import flash.utils.Timer;
import flash.events.TimerEvent;
import flash.events.MouseEvent;

import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.util.HashMap;

import com.whirled.WhirledGameControl;
import com.whirled.GameSubControl;

import lawsanddisorder.component.*;

/**
 * Manages property and message events, propagating them out to registered listeners.
 * 
 * TODO does ezgame already have some method to switch listeners on event name?
 */
public class EventHandler
{
	/**
	 * Invoke the given function in delay milliseconds.	 */
    public static function invokeLater (delaySeconds :int, func :Function) :void
    {
        var timer :Timer = new Timer(delaySeconds*1000, 1);
        timer.addEventListener(TimerEvent.TIMER, func);
        timer.start();
    }
    
    /**
     * Constructor - add event listeners and maybe get the board if it's setup */
    public function EventHandler (ctx :Context)
    {
        _ctx = ctx;
        _ctx.control.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);
        _ctx.control.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
    }
    
    /**
     * Called when our distributed game state changes.
     */
    protected function propertyChanged (event :PropertyChangedEvent) :void
    {
        var listeners :Array = _propertyListeners.get(event.name);
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
        var listeners :Array = _messageListeners.get(event.name);
        if (listeners != null) {
            // iterate through and perform each listener
            for (var i :int = 0; i < listeners.length; i++) {
                var listener :Function = listeners[i];
                listener(event);
            }
        }
    }
    
    /**
     * Registers a function to be called when a distributed property is changed.
     * TODO add indexes??
     */
    public function addPropertyListener (property :String, listener :Function) :void
    {
        var listeners :Array = _propertyListeners.get(property);
        // property already has a listener, add this one
        if (listeners != null) {
            listeners.push(listener);
        }
        // property doesn't have any listeners yet, add to map
        else {
            listeners = new Array();
            listeners.push(listener);
            _propertyListeners.put(property, listeners);
        }
    }
    
    /**
     * De-registers a function from being called when a distributed property is changed.
     */
    public function removePropertyListener (property :String, listener :Function) :void
    {
        //_ctx.log("removing property " + property + " listener.");
        var listeners :Array = _propertyListeners.get(property);
        // property has no listeners, oops!
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
        // TODO is this necessary?  might be less efficient?
        if (listeners.length == 0) {
            _propertyListeners.remove(property);
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
     * Wrapper for retrieving data values from the WhirledGameControl
     */
    public function getData (propName :String, index :int = -1) :*
    {
        return _ctx.control.net.get(propName, index);
    }
    
    /**
     * Wrapper for setting data values with the WhirledGameControl
     */
    public function setData (propName :String, value :Object, index :int = -1) :void
    {
        _ctx.control.net.set(propName, value, index);
    }
        
    /**
     * Game is over; calculate the scores and send a message to everyone.
     * Assumes player seats may have changed during the game and rebuilds playerIds array.
     * TODO go one more round after the deck is empty?
     */
    public function endGame () :void
    {
        var playerIds :Array = new Array;
        var playerScores :Array = new Array;
        
        for each (var player :Player in _ctx.board.players) {
            playerIds.push(player.serverId);
            playerScores.push(player.monies);
            _ctx.log("score for player " + player.id + " (server id: " + player.serverId + ") is " + player.monies);
        }
           _ctx.control.game.endGameWithScores(playerIds, playerScores, GameSubControl.TO_EACH_THEIR_OWN);
    }
    
    /** Context */
    protected var _ctx :Context;

    /** Map of listener functions for distributed property changes.
     *  Types <String, Array<Function>> */
    protected var _propertyListeners :HashMap = new HashMap();
    
    /** Map of listener functions for game messages.
     *  Types <String, Array<Function>> */
    protected var _messageListeners :HashMap = new HashMap();
}
}