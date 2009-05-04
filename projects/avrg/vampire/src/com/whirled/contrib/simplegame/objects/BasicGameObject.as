package com.whirled.contrib.simplegame.objects
{
import com.whirled.contrib.EventHandlerManager;

import flash.events.EventDispatcher;

public class BasicGameObject extends EventDispatcher
{
    public function shutdown () :void
    {
        _events.freeAllHandlers();
    }

    protected var _events :EventHandlerManager = new EventHandlerManager();
}
}