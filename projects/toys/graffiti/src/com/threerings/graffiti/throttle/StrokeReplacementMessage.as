// $Id$

package com.threerings.graffiti.throttle {

import flash.utils.ByteArray;

import com.threerings.graffiti.model.Stroke;

public class StrokeReplacementMessage implements ThrottleStrokeMessage
{
    public static function deserialize (bytes :ByteArray) :StrokeReplacementMessage
    {
        var message :StrokeReplacementMessage = new StrokeReplacementMessage(null, 0);
        message._stroke = Stroke.createStrokeFromBytes(bytes);
        message._layer = bytes.readInt();
        return message;
    }

    public function StrokeReplacementMessage (stroke :Stroke, layer :int) 
    {
        _stroke = stroke;
        _layer = layer;
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

    public function get layer () :int
    {
        return _layer;
    }

    // from ThrottleMessage
    public function serialize (bytes :ByteArray) :void
    {
        _stroke.serialize(bytes);
        bytes.writeInt(_layer);
    }
    
    protected var _stroke :Stroke;
    protected var _layer :int;
}
}
