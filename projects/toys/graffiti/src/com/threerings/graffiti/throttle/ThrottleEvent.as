// $Id$

package com.threerings.graffiti.throttle {

import flash.events.Event;

public class ThrottleEvent extends Event
{
    public static const INBOUND_MESSAGE :String = "inboundMessage";

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
