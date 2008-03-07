// $Id$

package com.threerings.graffiti.throttle {

import flash.events.Event;

public class ThrottleEvent extends Event
{
    public static const TEMP_STROKE_MESSAGE :String = "tempStrokeMessage";
    public static const MANAGER_STROKE_MESSAGE :String = "managerStrokeMessage";

    public function ThrottleEvent (name :String, message :ThrottleMessage) 
    {
        super(name);
        _message = message;
    }

    public function get message () :ThrottleMessage
    {
        return _message;
    }

    protected var _message :ThrottleMessage;
}
}
