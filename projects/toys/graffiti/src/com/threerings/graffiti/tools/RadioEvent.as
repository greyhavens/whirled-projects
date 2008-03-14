// $Id$

package com.threerings.graffiti.tools {
    
import flash.events.Event;

public class RadioEvent extends Event
{
    public static const BUTTON_SELECTED :String = "buttonSelected";

    public function RadioEvent (event :String, value :*) :void
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
