// $Id$

package com.threerings.graffiti {

import flash.display.Sprite;

import flash.events.Event;

import com.threerings.util.Log;

import com.threerings.graffiti.throttle.Throttle;
import com.threerings.graffiti.throttle.ThrottleEvent;

public class Manager
{
    public function Manager (throttle :Throttle)
    {
        _throttle = throttle;
        _throttle.addEventListener(ThrottleEvent.INBOUND_MESSAGE, messageReceived);
        _throttle.control.requestControl();
    }

    public function messageReceived (event :ThrottleEvent) :void
    {
        // TODO
    }

    private static const log :Log = Log.getLog(Manager);

    protected var _throttle :Throttle;
}
}
