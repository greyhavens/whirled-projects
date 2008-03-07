// $Id$

package com.threerings.graffiti.throttle {

import flash.geom.Point;

import flash.utils.ByteArray;

import com.threerings.graffiti.model.OnlineModel;

public class StrokeExtendMessage implements ThrottleMessage
{
    public static function deserialize (bytes :ByteArray) :StrokeExtendMessage
    {
        // TODO
        return new StrokeExtendMessage(null, null);
    }

    public function StrokeExtendMessage (id :String, to :Point) 
    {
        _id = id;
        _to = to;
    }

    // from ThrottleMessage
    public function serialize (bytes :ByteArray) :void
    {
        // TODO
    }
    
    // from ThrottleMessage
    public function apply (model :OnlineModel) :void
    {
        // TODO
    }

    protected var _id :String;
    protected var _to :Point;
}
}
