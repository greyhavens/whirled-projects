package flashmob.server {

import com.whirled.contrib.EventHandlerManager;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.events.IEventDispatcher;

import flashmob.GameDataListener;

public class ServerMode
    implements GameDataListener
{
    public function setup () :void {}
    public function destroy () :void {}

    public function onMsgReceived (e :MessageReceivedEvent) :void {}
    public function onPropChanged (e :PropertyChangedEvent) :void {}
    public function onElemChanged (e :ElementChangedEvent) :void {}

    /**
     * Adds the specified listener to the specified dispatcher for the specified event.
     *
     * Listeners registered in this way will be automatically unregistered when the ObjectDB is
     * shutdown.
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

    /**
     * Registers a zero-arg callback function that should be called once when the event fires.
     *
     * Listeners registered in this way will be automatically unregistered when the ObjectDB is
     * shutdown.
     */
    protected function registerOneShotCallback (dispatcher :IEventDispatcher, event :String,
        callback :Function, useCapture :Boolean = false, priority :int = 0) :void
    {
        _events.registerOneShotCallback(dispatcher, event, callback, useCapture, priority);
    }

    internal function setupInternal () :void
    {
        setup();
    }

    internal function destroyInternal () :void
    {
        destroy();
        _events.freeAllHandlers();
    }

    protected var _events :EventHandlerManager = new EventHandlerManager();
}

}
