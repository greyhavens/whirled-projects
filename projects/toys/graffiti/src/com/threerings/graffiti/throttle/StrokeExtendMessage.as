// $Id$

package com.threerings.graffiti.throttle {

import flash.geom.Point;

import flash.utils.ByteArray;

public class StrokeExtendMessage implements ThrottleStrokeMessage
{
    public static function deserialize (bytes :ByteArray) :StrokeExtendMessage
    {
        var message :StrokeExtendMessage = new StrokeExtendMessage(null, null);
        message._id = bytes.readObject() as String;
        var x :int = bytes.readInt();
        var y :int = bytes.readInt();
        message._to = new Point(x, y);
        return message;
    }

    public function StrokeExtendMessage (id :String, to :Point) 
    {
        _id = id;
        _to = to;
    }

    // from ThrottleStrokeMessage
    public function get strokeId () :String
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
        bytes.writeObject(_id);
        bytes.writeInt(Math.round(_to.x));
        bytes.writeInt(Math.round(_to.y));
    }
    
    protected var _id :String;
    protected var _to :Point;
}
}
