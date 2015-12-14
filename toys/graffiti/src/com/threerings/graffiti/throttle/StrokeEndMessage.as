// $Id$

package com.threerings.graffiti.throttle {

import flash.utils.ByteArray;

import com.threerings.graffiti.model.Stroke;

public class StrokeEndMessage implements ThrottleStrokeMessage
{
    public static function deserialize (bytes :ByteArray) :StrokeEndMessage
    {
        var message :StrokeEndMessage = new StrokeEndMessage(null);
        message._stroke = Stroke.createStrokeFromBytes(bytes);
        return message;
    }

    public function StrokeEndMessage (stroke :Stroke)
    {
        _stroke = stroke;
    }

    // from ThrottleStrokeMessage
    public function get strokeId () :String
    {
        return _stroke.id;
    }

    public function get stroke () :Stroke 
    {
        return _stroke;
    }

    // from ThrottleMessage
    public function serialize (bytes :ByteArray) :void
    {
        _stroke.serialize(bytes);
    }

    protected var _stroke :Stroke;
}
}
