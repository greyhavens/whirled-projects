// $Id$

package com.threerings.graffiti.model {

import flash.events.Event;

import flash.geom.Point;

import flash.utils.setInterval; // function import
import flash.utils.clearInterval; // function import
import flash.utils.getTimer; // function import
import flash.utils.ByteArray;

import com.threerings.util.Log;

import com.whirled.ControlEvent;
import com.whirled.FurniControl;

import com.threerings.graffiti.throttle.Throttle;
import com.threerings.graffiti.throttle.ThrottleEvent;
import com.threerings.graffiti.throttle.ThrottleMessage;
import com.threerings.graffiti.throttle.ThrottleStrokeMessage;
import com.threerings.graffiti.throttle.StrokeBeginMessage;
import com.threerings.graffiti.throttle.StrokeExtendMessage;
import com.threerings.graffiti.throttle.StrokeEndMessage;

import com.threerings.graffiti.tools.Brush;

public class OnlineModel extends Model
{
    public function OnlineModel (throttle :Throttle)
    {
        super();

        _throttle = throttle;
        _throttle.addEventListener(ThrottleEvent.TEMP_STROKE_MESSAGE, tempMessageReceived);
        _throttle.addEventListener(ThrottleEvent.MANAGER_STROKE_MESSAGE, managerMessageReceived);
    }

    public override function extendStroke (id :String, to :Point, end :Boolean = false) :void
    {
        super.extendStroke(id, to, end);
        if (idFromMe(id)) {
            _throttle.pushMessage(new StrokeExtendMessage(id, to));
        }
    }

    public override function endStroke (id :String) :void
    {
        super.endStroke(id);
        if (idFromMe(id)) {
            _throttle.pushMessage(new StrokeEndMessage(id, _tempStrokesMap.get(id)));
        }
    }

    public override function getKey () :String
    {
        // in the online model, keys are prepended with the instance id
        return _throttle.control.getInstanceId() + ":" + super.getKey();
    }

    protected override function strokeBegun (id :String, stroke :Stroke) :void
    {
        super.strokeBegun(id, stroke);
        if (idFromMe(id)) {
            _throttle.pushMessage(new StrokeBeginMessage(id, stroke));
        }
    }

    protected function idFromMe (id :String) :Boolean {
        return id.indexOf(_throttle.control.getInstanceId() + ":") != -1;
    }

    protected function tempMessageReceived (event :ThrottleEvent) :void
    {
        var message :ThrottleMessage = event.message;
        if (!(message is ThrottleStrokeMessage)) {
            log.debug("unknown temp message type [" + message + "]");
            return;
        }

        var strokeMessage :ThrottleStrokeMessage = message as ThrottleStrokeMessage;
        if (idFromMe(strokeMessage.strokeId)) {
            log.debug("received a message sent by me");
            return;
        }

        log.debug("processing message [" + message + "]");
        if (strokeMessage is StrokeBeginMessage) {
            strokeBegun(strokeMessage.strokeId, (strokeMessage as StrokeBeginMessage).stroke);
        } else if (strokeMessage is StrokeExtendMessage) {
            extendStroke(strokeMessage.strokeId, (strokeMessage as StrokeExtendMessage).to);
        } else if (strokeMessage is StrokeEndMessage) {
            // NOOP - managers care about this.
        } else {
            log.debug("unkown temp stroke message type [" + message + "]");
        }
    }

    protected function managerMessageReceived (event :ThrottleEvent) :void
    {
        // TODO
    }

    private static const log :Log = Log.getLog(OnlineModel);

    protected var _throttle :Throttle;
}
}
