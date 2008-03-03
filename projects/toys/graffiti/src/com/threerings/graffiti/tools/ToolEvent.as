// $Id$

package com.threerings.graffiti.tools {
    
import flash.events.Event;

public class ToolEvent extends Event
{
    public static const COLOR_PICKED :String = "colorPicked";
    public static const BRUSH_PICKED :String = "brushPicked";
    public static const BACKGROUND_COLOR :String = "backgroundColor";

    public function ToolEvent (event :String, value :*) :void
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
