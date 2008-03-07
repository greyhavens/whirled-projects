// $Id$

package com.threerings.graffiti.throttle {

import flash.utils.ByteArray;

public interface ThrottleMessage 
{
    function serialize (bytes :ByteArray) :void;
}
}
