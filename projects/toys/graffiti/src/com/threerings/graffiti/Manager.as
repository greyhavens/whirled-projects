// $Id$

package com.threerings.graffiti {

import flash.display.Sprite;

import flash.events.Event;

import com.threerings.util.Log;

import com.whirled.ControlEvent;
import com.whirled.FurniControl;

public class Manager
{
    public function Manager (control :FurniControl)
    {
        _control = control;
        _control.requestControl();
        _control.addEventListener(ControlEvent.MESSAGE_RECEIVED, messageReceived);
    }

    protected function messageReceived (event :ControlEvent) :void
    {
        // TODO
    }
    
    private static const log :Log = Log.getLog(Manager);

    protected var _control :FurniControl;
}
}
