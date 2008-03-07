// $Id$

package com.threerings.graffiti.throttle {

import flash.utils.ByteArray;

import com.threerings.graffiti.model.Stroke;

public class StrokeBeginMessage implements ThrottleStrokeMessage
{
    public static function deserialize (bytes :ByteArray) :StrokeBeginMessage
    {
        var message :StrokeBeginMessage = new StrokeBeginMessage(null, null);
        message._id = bytes.readObject() as String;
        message._stroke = Stroke.createStrokeFromBytes(bytes);
        return message;
    }

    public function StrokeBeginMessage (id :String, stroke :Stroke) 
    {
        _id = id;
        _stroke = stroke;
    }

    // from ThrottleStrokeMessage
    public function get strokeId () :String 
    {
        return _id;
    }

    public function get stroke () :Stroke
    {
        return _stroke;
    }

    // from ThrottleMessage
    public function serialize (bytes :ByteArray) :void
    {
        bytes.writeObject(_id);
        _stroke.serialize(bytes);
    }

    protected var _id :String;
    protected var _stroke :Stroke;
}
}
