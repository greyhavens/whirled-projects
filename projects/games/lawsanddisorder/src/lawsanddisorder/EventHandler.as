package lawsanddisorder {

import flash.utils.getTimer;
import flash.events.MouseEvent;

import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.util.HashMap;

import com.whirled.WhirledGameControl;
import lawsanddisorder.component.*;

/**
 * Manages property and message events, propagating them out to registered listeners.
 * 
 * TODO does ezgame already have some method to switch listeners on event name?
 */
public class EventHandler
{
    /**
     * Constructor - add event listeners and maybe get the board if it's setup */
    public function EventHandler (ctx :Context)
    {
        _ctx = ctx;
        _ctx.control.addEventListener(PropertyChangedEvent.TYPE, propertyChanged);
        _ctx.control.addEventListener(MessageReceivedEvent.TYPE, messageReceived);
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