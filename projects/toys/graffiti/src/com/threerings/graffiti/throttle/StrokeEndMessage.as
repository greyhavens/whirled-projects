// $Id$

package com.threerings.graffiti.throttle {

import flash.utils.ByteArray;

import com.threerings.graffiti.model.Stroke;
import com.threerings.graffiti.model.OnlineModel;

public class StrokeEndMessage implements ThrottleMessage
{
    public static function deserialize (bytes :ByteArray) :StrokeEndMessage
    {
        // TODO
        return new StrokeEndMessage(null, null);
    }

    public function StrokeEndMessage (id :String, stroke :Stroke)
    {
        _id = id;
        _stroke = stroke;
    }

    // from ThrottleMessage
    public function serialize (bytes :ByteArray) :void
    {
        // TODO
    }

    // from ThrottleMessage
    public function apply (model :OnlineModel) :void
    {
    }

    protected var _id :String;
    protected var _stroke :Stroke;
}
}
