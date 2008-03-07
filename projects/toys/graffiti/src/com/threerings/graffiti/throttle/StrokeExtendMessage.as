// $Id$

package com.threerings.graffiti.throttle {

import flash.geom.Point;

import flash.utils.ByteArray;

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

    public function get id () :String
    {
        return _id;
    }

    public function get to () :Point
    {
        return _to;
    }

    // from ThrottleMessage
    public function serialize (bytes :ByteArray) :void
    {
        // TODO
    }
    
    protected var _id :String;
    protected var _to :Point;
}
}
