// $Id$

package com.threerings.graffiti.throttle {

import flash.utils.ByteArray;

public class EditorClosedMessage implements ThrottleMessage
{
    public static function deserialize (bytes :ByteArray) :EditorClosedMessage
    {
        var message :EditorClosedMessage = new EditorClosedMessage(null);
        message._id = bytes.readObject() as String;
        return message;
    }

    public function EditorClosedMessage (editorId :String)
    {
        _id = editorId;
    }

    public function get editorId () :String
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
