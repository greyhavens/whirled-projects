//
// $Id$
package locksmith.view {

import flash.display.Sprite;
import flash.events.IEventDispatcher;

import com.whirled.contrib.EventHandlerManager;

public class LocksmithSprite extends Sprite
{
    public function LocksmithSprite (eventMgr :EventHandlerManager)
    {
        _eventMgr = eventMgr;
    }

    public function registerListener (event :String, listener :Function,
        dispatcher :IEventDispatcher = null) :void
    {
        _eventMgr.registerListener(getDispatcher(dispatcher), event, listener);
    }

    public function unregisterListener (event :String, listener :Function,
        dispatcher :IEventDispatcher = null) :void
    {
        _eventMgr.unregisterListener(getDispatcher(dispatcher), event, listener);
    }

    public function registerOneShotCallback (event :String, callback :Function,
        dispatcher :IEventDispatcher = null) :void
    {
        _eventMgr.registerOneShotCallback(getDispatcher(dispatcher), event, callback);
    }

    public function conditionalCall (callback :Function, callNow :Boolean, event :String,
        dispatcher :IEventDispatcher = null) :void
    {
        _eventMgr.conditionalCall(callback, callNow, getDispatcher(dispatcher), event);
    }

    public function freeAllOn (event :String, dispatcher :IEventDispatcher = null) :void
    {
        _eventMgr.registerOneShotCallback(
            getDispatcher(dispatcher), event, _eventMgr.freeAllHandlers, false, -100);
    }

    protected function getDispatcher (dispatcher :IEventDispatcher) :IEventDispatcher 
    {
        return dispatcher != null ? dispatcher : this;
    }

    protected var _eventMgr :EventHandlerManager;
}
}
