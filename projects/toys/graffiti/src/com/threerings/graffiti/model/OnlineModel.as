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

import com.threerings.graffiti.tools.Brush;

public class OnlineModel extends Model
{
    public function OnlineModel (control :FurniControl) 
    {
        super();

        _control = control;

        _timer = setInterval(tick, TICK_INTERVAL);
        control.addEventListener(Event.UNLOAD, function (event :Event) :void {
            clearInterval(_timer);
        });

        deserialize(control.lookupMemory(STORED_MODEL) as ByteArray);
    }

    public override function beginStroke (id :String, from :Point, to :Point, color :int, 
                                          brush :Brush) :void
    {
        super.beginStroke(id, from, to, color, brush);
        _dirty = true;
    }

    public override function extendStroke (id :String, to :Point) :void
    {
        super.extendStroke(id, to);
        _dirty = true;
    }

    public override function setBackgroundColor (color :uint) :void
    {
        super.setBackgroundColor(color);
        _dirty = true;
    }

    protected function tick () :void
    {
        if (_dirty) {
            var time :int = getTimer();
            log.debug("updating memory [" + (time - _lastUpdate) + "]");
            _lastUpdate = time;
            // the serialized version of the strokes is kept up to date in Model
            _control.updateMemory(STORED_MODEL, _serializedStrokes);
            _dirty = false;
        }
    }

    private static const log :Log = Log.getLog(OnlineModel);

    protected static const STORED_MODEL :String = "storedModel";
    /** The delay in ms between full memory updates with the serialized board art. */
    protected static const TICK_INTERVAL :int = 1500;

    protected var _control :FurniControl;
    protected var _dirty :Boolean = false;
    protected var _timer :uint = 0;
    protected var _lastUpdate :int;
}
}
