// $Id$

package com.threerings.graffiti.throttle {

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;

import flash.utils.ByteArray;
import flash.utils.Timer;

import com.threerings.util.Log;

import com.whirled.ControlEvent;
import com.whirled.FurniControl;

import com.threerings.graffiti.model.OnlineModel;

[Event(name="tempStrokeMessage", type="ThrottleEvent")];
[Event(name="managerStrokeMessage", type="ThrottleEvent")];

public class Throttle extends EventDispatcher
{
    /** Only access the control to retrieve information.  Let Throttle handle all sends! */
    public var control :FurniControl;

    public function Throttle (control :FurniControl) 
    {
        this.control = control;
        control.addEventListener(ControlEvent.MESSAGE_RECEIVED, messageReceived);
        control.addEventListener(Event.UNLOAD, unload);

        _timer = new Timer(THROTTLE_TIMING);
        _timer.addEventListener(TimerEvent.TIMER, tick);
        _timer.start();
    }

    public function pushMessage (message :ThrottleMessage) :void
    {
        log.debug("pushMessage [" + message + "]");
        _pendingMessages.push(message);
    }

    protected function messageReceived (event :ControlEvent) :void
    {
        if (event.name != THROTTLE_MESSAGE) {
            return;
        }

        var bytes :ByteArray = event.value as ByteArray;
        bytes.uncompress();

        var messageCount :int = bytes.readInt();
        log.debug("reading messages [" + messageCount + "]");
        for (var ii :int = 0; ii < messageCount; ii++) {
            var type :int = bytes.readInt(); 
            applyMessage(type, bytes);
        }
    }

    protected function dispatchTemp (message :ThrottleMessage) :void
    {
        log.debug("dispatchTemp [" + message + "]");
        dispatchEvent(new ThrottleEvent(ThrottleEvent.TEMP_MESSAGE, message));
    }

    protected function dispatchManager (message :ThrottleMessage) :void
    {
        log.debug("dispatchManger [" + message + "]");
        dispatchEvent(new ThrottleEvent(ThrottleEvent.MANAGER_MESSAGE, message));
    }

    protected function applyMessage (type :int, bytes :ByteArray) :void
    {
        switch (type) {
        case MESSAGE_TYPE_STROKE_BEGIN: 
            dispatchTemp(StrokeBeginMessage.deserialize(bytes)); break;

        case MESSAGE_TYPE_STROKE_EXTEND: 
            dispatchTemp(StrokeExtendMessage.deserialize(bytes)); break;

        case MESSAGE_TYPE_STROKE_END: 
            dispatchTemp(StrokeEndMessage.deserialize(bytes)); break;

        case MESSAGE_TYPE_ALTER_BACKGROUND:
            dispatchTemp(AlterBackgroundMessage.deserialize(bytes)); break;
            
        case MESSAGE_TYPE_ALTER_BACKGROUND_MANAGER:
            dispatchManager(AlterBackgroundMessage.deserialize(bytes)); break

        case MESSAGE_TYPE_STRIP_ID:
            dispatchTemp(StripIdMessage.deserialize(bytes)); break;

        case MESSAGE_TYPE_REMOVE_STROKE:
            dispatchTemp(RemoveStrokeMessage.deserialize(bytes)); break;

        case MESSAGE_TYPE_EDITOR_CLOSED:
            dispatchTemp(EditorClosedMessage.deserialize(bytes)); break;

        default:
            log.warning("unknown message type! [" + type + "]");
        }
    }

    protected function tick (event :TimerEvent) :void
    {
        if (_pendingMessages.length == 0) {
            return;
        }

        var bytes :ByteArray = new ByteArray();
        bytes.writeInt(_pendingMessages.length);
        while (_pendingMessages.length > 0) {
            var message :ThrottleMessage = _pendingMessages.shift() as ThrottleMessage;
            bytes.writeInt(typeForMessage(message));
            message.serialize(bytes);
        }
        bytes.compress();
        control.sendMessage(THROTTLE_MESSAGE, bytes);
    }

    protected function typeForMessage (message :ThrottleMessage) :int
    {
        if (message is StrokeBeginMessage) {
            return MESSAGE_TYPE_STROKE_BEGIN;
        } else if (message is StrokeExtendMessage) {
            return MESSAGE_TYPE_STROKE_EXTEND;
        } else if (message is StrokeEndMessage) {
            return MESSAGE_TYPE_STROKE_END;
        } else if (message is ManagerAlterBackgroundMessage) {
            return MESSAGE_TYPE_ALTER_BACKGROUND_MANAGER;
        } else if (message is AlterBackgroundMessage) {
            return MESSAGE_TYPE_ALTER_BACKGROUND;
        } else if (message is StripIdMessage) {
            return MESSAGE_TYPE_STRIP_ID;
        } else if (message is RemoveStrokeMessage) {
            return MESSAGE_TYPE_REMOVE_STROKE;
        } else if (message is EditorClosedMessage) {
            return MESSAGE_TYPE_EDITOR_CLOSED;
        } else {
            log.warning("Unknown message for type encoding! [" + message + "]");
            return -1;
        }
    }

    protected function unload (event :Event) :void 
    {
        _timer.stop();
    }

    private static var log :Log = Log.getLog(Throttle);

    protected static const THROTTLE_MESSAGE :String = "throttleMessage";
    protected static const THROTTLE_TIMING :int = 250; // in ms

    protected static const MESSAGE_TYPE_STROKE_BEGIN :int = 1;
    protected static const MESSAGE_TYPE_STROKE_EXTEND :int = 2;
    protected static const MESSAGE_TYPE_STROKE_END :int = 3;
    protected static const MESSAGE_TYPE_ALTER_BACKGROUND :int = 4;
    protected static const MESSAGE_TYPE_ALTER_BACKGROUND_MANAGER :int = 5;
    protected static const MESSAGE_TYPE_STRIP_ID :int = 6;
    protected static const MESSAGE_TYPE_REMOVE_STROKE :int = 7;
    protected static const MESSAGE_TYPE_EDITOR_CLOSED :int = 8;

    protected var _pendingMessages :Array = [];
    protected var _timer :Timer;
}
}
