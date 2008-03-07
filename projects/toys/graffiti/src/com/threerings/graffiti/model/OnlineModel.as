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
        _throttle.addEventListener(ThrottleEvent.INBOUND_MESSAGE, messageReceived);
    }

    public override function beginStroke (id :String, from :Point, to :Point, color :int, 
        brush :Brush) :void
    {
        super.beginStroke(id, from, to, color, brush);
        _throttle.pushMessage(new StrokeBeginMessage(id, _tempStrokes.get(id)));
    }

    public override function extendStroke (id :String, to :Point, end :Boolean = false) :void
    {
        super.extendStroke(id, to, end);
        _throttle.pushMessage(new StrokeExtendMessage(id, to));
    }

    public override function endStroke (id :String) :void
    {
        super.endStroke(id);
        _throttle.pushMessage(new StrokeEndMessage(id, _tempStrokes.get(id)));
    }

    public override function getKey () :String
    {
        // in the online model, keys are prepended with the instance id
        return _throttle.control.getInstanceId() + ":" + super.getKey();
    }

    protected function messageReceived (event :ThrottleEvent) :void
    {
        // TODO
    }

    private static const log :Log = Log.getLog(OnlineModel);

    protected var _throttle :Throttle;
}
}
