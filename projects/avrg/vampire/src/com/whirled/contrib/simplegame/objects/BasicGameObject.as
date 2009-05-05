package com.whirled.contrib.simplegame.objects
{
import com.whirled.contrib.EventHandlerManager;

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

public class BasicGameObject extends EventDispatcher
{
    public function shutdown () :void
    {
        _events.freeAllHandlers();
    }

    public function registerListener (dispatcher :IEventDispatcher, event :String,
        listener :Function, useCapture :Boolean = false, priority :int = 0,
        useWeakReference :Boolean = false) :void
    {
        _events.registerListener(dispatcher, event, listener, useCapture, priority,
            useWeakReference);
    }

    protected var _events :EventHandlerManager = new EventHandlerManager();
}
}