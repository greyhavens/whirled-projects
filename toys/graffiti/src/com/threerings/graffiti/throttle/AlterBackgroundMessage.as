// $Id$

package com.threerings.graffiti.throttle {

import flash.utils.ByteArray;

import com.threerings.util.Log;

public class AlterBackgroundMessage implements ThrottleMessage
{
    public static const COLOR :int = 1;
    public static const TRANSPARENCY :int = 2;

    public static function deserialize (bytes :ByteArray) :AlterBackgroundMessage
    {
        var message :AlterBackgroundMessage = new AlterBackgroundMessage(0, null);
        message._type = bytes.readInt();
        switch (message._type) {
        case COLOR:
            message._value = bytes.readUnsignedInt();
            break;

        case TRANSPARENCY:
            message._value = bytes.readBoolean();
            break;

        default:
            log.warning("unknown type [" + message._type + "]");
        }
        return message;
    }

    public function AlterBackgroundMessage (type :int, value :*)
    {
        _type = type;
        _value = value;
    }

    public function get type () :int
    {
        return _type;
    }

    public function get value () :*
    {
        return _value;
    }

    // from ThrottleMessage
    public function serialize (bytes :ByteArray) :void
    {
        bytes.writeInt(_type);
        switch (_type) {
        case COLOR:
            bytes.writeUnsignedInt(_value as uint);
            break;

        case TRANSPARENCY:
            bytes.writeBoolean(_value as Boolean);
            break;
            
        default:
            log.warning("unknown type [" + _type + "]");
        }
    }

    private static const log :Log = Log.getLog(AlterBackgroundMessage);

    protected var _type :int;
    protected var _value :*;
}
}
