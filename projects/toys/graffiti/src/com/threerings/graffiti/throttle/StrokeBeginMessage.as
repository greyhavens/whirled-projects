// $Id$

package com.threerings.graffiti.throttle {

import flash.utils.ByteArray;

import com.threerings.graffiti.model.Stroke;

public class StrokeBeginMessage implements ThrottleMessage
{
    public static function deserialize (bytes :ByteArray) :StrokeBeginMessage
    {
        // TODO
        return new StrokeBeginMessage (null, null);
    }

    public function StrokeBeginMessage (id :String, stroke :Stroke) 
    {
        _id = id;
        _stroke = stroke;
    }

    public function get id () :String 
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
        // TODO    
    }

    protected var _id :String;
    protected var _stroke :Stroke;
}
}
