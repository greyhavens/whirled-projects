// $Id$

package com.threerings.graffiti.tools {
    
import flash.events.Event;

public class ToolEvent extends Event
{
    public static const TOOL_PICKED :String = "toolPicked";
    public static const BACKGROUND_COLOR :String = "backgroundColor";
    public static const BACKGROUND_TRANSPARENCY :String = "backgroundTransparency";
    public static const DONE_EDITING :String = "doneEditing";
    public static const COLOR_PICKING :String = "colorPicking";
    public static const HIDE_FURNI :String = "hideFurni";
    public static const UNDO_ONCE :String = "undoOnce";

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
