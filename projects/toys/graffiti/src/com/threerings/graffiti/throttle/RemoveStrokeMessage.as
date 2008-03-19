// $Id$

package com.threerings.graffiti.throttle {

import flash.utils.ByteArray;

public class RemoveStrokeMessage implements ThrottleStrokeMessage
{
    public static function deserialize (bytes :ByteArray) :RemoveStrokeMessage
    {
        var message :RemoveStrokeMessage = new RemoveStrokeMessage(null);
        message._id = bytes.readObject() as String;
        return message;
    }

    public function RemoveStrokeMessage (id :String)
    {
        _id = id;
    }

    // from ThrottleStrokeMessage
    public function get strokeId () :String
    {
        return _id;
    }

    // from ThrottleMessage
    public function serialize (bytes :ByteArray) :void
    {
        bytes.writeObject(_id);
    }
    
    protected var _id :String;
}
}
