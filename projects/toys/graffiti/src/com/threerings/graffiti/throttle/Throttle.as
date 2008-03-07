// $Id$

package com.threerings.graffiti.throttle {

import com.whirled.FurniControl;

public class Throttle 
{
    public static const MESSAGE_TYPE_STROKE_BEGIN :int = 1;
    public static const MESSAGE_TYPE_STROKE_EXTEND :int = 2;
    public static const MESSAGE_TYPE_STROKE_END :int = 3;

    /** Only access the control to retrieve information.  Let Throttle handle all sends! */
    public var control :FurniControl;

    public function Throttle (control :FurniControl) 
    {
        this.control = control;
    }

    public function pushMessage (message :ThrottleMessage) :void
    {
        _pendingMessages.push(message);
    }

    protected var _pendingMessages :Array = [];
}
}
