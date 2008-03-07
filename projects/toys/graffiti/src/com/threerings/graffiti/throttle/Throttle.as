// $Id$

package com.threerings.graffiti.throttle {

import flash.events.EventDispatcher;

import flash.utils.ByteArray;

import com.threerings.util.Log;

import com.whirled.ControlEvent;
import com.whirled.FurniControl;

import com.threerings.graffiti.model.OnlineModel;

[Event(name="inboundMessage", type="ThrottleEvent")];

public class Throttle extends EventDispatcher
{
    public static const MESSAGE_TYPE_STROKE_BEGIN :int = 1;
    public static const MESSAGE_TYPE_STROKE_EXTEND :int = 2;
    public static const MESSAGE_TYPE_STROKE_END :int = 3;

    /** Only access the control to retrieve information.  Let Throttle handle all sends! */
    public var control :FurniControl;

    public function Throttle (control :FurniControl) 
    {
        this.control = control;
        control.addEventListener(ControlEvent.MESSAGE_RECEIVED, messageReceived);
    }

    public function pushMessage (message :ThrottleMessage) :void
    {
        _pendingMessages.push(message);
    }

    protected function messageReceived (event :ControlEvent) :void
    {
        var bytes :ByteArray = event.value as ByteArray;
        bytes.uncompress();

        var messageCount :int = bytes.readInt();
        for (var ii :int = 0; ii < messageCount; ii++) {
            var type :int = bytes.readInt(); 
            applyMessage(type, bytes);
        }
    }

    protected function applyMessage (type :int, bytes :ByteArray) :void
    {
        switch (type) {
        case MESSAGE_TYPE_STROKE_BEGIN: 
            dispatchEvent(new ThrottleEvent(ThrottleEvent.INBOUND_MESSAGE, 
                          StrokeBeginMessage.deserialize(bytes)));
        case MESSAGE_TYPE_STROKE_EXTEND: 
            dispatchEvent(new ThrottleEvent(ThrottleEvent.INBOUND_MESSAGE,
                          StrokeExtendMessage.deserialize(bytes)));
        case MESSAGE_TYPE_STROKE_END: 
            dispatchEvent(new ThrottleEvent(ThrottleEvent.INBOUND_MESSAGE,
                          StrokeEndMessage.deserialize(bytes)));

        default:
            log.warning("unknown message type! [" + type + "]");
        }
    }

    private static var log :Log = Log.getLog(Throttle);

    protected var _pendingMessages :Array = [];
}
}
