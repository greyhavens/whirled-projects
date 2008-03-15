// $Id$

package com.threerings.graffiti.tools {
    
import flash.events.Event;

public class ToolEvent extends Event
{
    public static const BRUSH_PICKED :String = "brushPicked";
    public static const BACKGROUND_COLOR :String = "backgroundColor";
    public static const BACKGROUND_TRANSPARENCY :String = "backgroundTransparency";
    public static const CLEAR_CANVAS :String = "clearCanvas";
    public static const DONE_EDITING :String = "doneEditing";

    public function ToolEvent (event :String, value :* = undefined) :void
    {
        super(event);
        _value = value;
    }

    public function get value () :*
    {
        return _value;
    }

    protected var _value :*;
}
}
