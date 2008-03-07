// $Id$

package com.threerings.graffiti.throttle {

import flash.utils.ByteArray;

import com.threerings.util.Log;

import com.whirled.ControlEvent;
import com.whirled.FurniControl;

import com.threerings.graffiti.model.OnlineModel;

public class Throttle 
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

    public function set model (m :OnlineModel) :void
    {
        _model = m;
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
        if (_model == null) {
            log.warning("null model!");
            return;
        }

        switch (type) {
        case MESSAGE_TYPE_STROKE_BEGIN: StrokeBeginMessage.deserialize(bytes).apply(_model);
        case MESSAGE_TYPE_STROKE_EXTEND: StrokeExtendMessage.deserialize(bytes).apply(_model);
        case MESSAGE_TYPE_STROKE_END: StrokeEndMessage.deserialize(bytes).apply(_model);

        default:
            log.warning("unknown message type! [" + type + "]");
        }
    }

    private static var log :Log = Log.getLog(Throttle);

    protected var _pendingMessages :Array = [];
    protected var _model :OnlineModel;
}
}
