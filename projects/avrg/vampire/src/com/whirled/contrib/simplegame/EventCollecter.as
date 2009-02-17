package com.whirled.contrib.simplegame
{
import com.whirled.contrib.EventHandlerManager;

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

public class EventCollecter extends EventDispatcher
{
    public function EventCollecter()
    {
    }
    
    /**
     * Adds the specified listener to the specified dispatcher for the specified event.
     *
     * Listeners registered in this way will be automatically unregistered when the SimObject is
     * destroyed.
     */
    protected function registerListener (dispatcher :IEventDispatcher, event :String,
        listener :Function, useCapture :Boolean = false, priority :int = 0) :void
    {
        _events.registerListener(dispatcher, event, listener, useCapture, priority);
    }

    /**
     * Removes the specified listener from the specified dispatcher for the specified event.
     */
    protected function unregisterListener (dispatcher :IEventDispatcher, event :String,
        listener :Function, useCapture :Boolean = false) :void
    {
        _events.unregisterListener(dispatcher, event, listener, useCapture);
    }
    
    public function shutdown() :void
    {
        freeEventHandlers();
    } 
    
    protected function freeEventHandlers () :void
    {
        _events.freeAllHandlers();
    }
    
    protected var _events :EventHandlerManager = new EventHandlerManager();
    
}
}