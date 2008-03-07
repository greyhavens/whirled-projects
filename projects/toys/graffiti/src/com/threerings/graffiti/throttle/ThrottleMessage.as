// $Id$

package com.threerings.graffiti.throttle {

import flash.utils.ByteArray;

import com.threerings.graffiti.model.OnlineModel;

public interface ThrottleMessage 
{
    function serialize (bytes :ByteArray) :void;
    function apply (model :OnlineModel) :void;
}
}
