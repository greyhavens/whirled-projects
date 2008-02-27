// $Id$

package com.threerings.graffiti.tools {
    
import flash.events.Event;

public class ToolEvent extends Event
{
    public static const COLOR_PICKED :String = "colorPicked";

    public function ToolboxEvent (event :String, value :*) :void
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
