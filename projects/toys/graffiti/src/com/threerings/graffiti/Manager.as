// $Id$

package com.threerings.graffiti {

import flash.display.Sprite;

import flash.events.Event;

import com.threerings.util.Log;

import com.whirled.ControlEvent;

import com.threerings.graffiti.throttle.Throttle;

public class Manager
{
    public function Manager (throttle :Throttle)
    {
        _throttle = throttle;
        _throttle.control.requestControl();
        _throttle.control.addEventListener(ControlEvent.MESSAGE_RECEIVED, messageReceived);
    }

    protected function messageReceived (event :ControlEvent) :void
    {
        // TODO
    }
    
    private static const log :Log = Log.getLog(Manager);

    protected var _throttle :Throttle;
}
}
