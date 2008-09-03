package {

import flash.events.EventDispatcher;
import flash.utils.ByteArray;

/**
 * Represents an entity that exists on the board.
 */
public class BoardObject extends EventDispatcher
{
    public var bX :int;
    public var bY :int;
    public var type :int;
    public var index :int;

    public function BoardObject (type :int, bX :int, bY :int) :void
    {
        this.type = type;
        this.bX = bX;
        this.bY = bY;
    }

    public function damage (damage :Number) :Boolean
    {
        return false;
    }

    public function get arrayName () :String
    {
        return "object";
    }

    public function get hitSoundName () :String
    {
        return null;
    }

    public function get radius () :Number
    {
        return 0.8;
    }

    /**
     * Unserialize our data from a byte array.
     */
    public function readFrom (bytes :ByteArray) :void
    {
        type = bytes.readInt();
        bX = bytes.readInt();
        bY = bytes.readInt();
    }

    public function reload (bytes :ByteArray) :void
    {
        readFrom(bytes);
    }

    /**
     * Serialize our data to a byte array.
     */
    public function writeTo (bytes :ByteArray) :ByteArray
    {
        bytes.writeInt(type);
        bytes.writeInt(bX);
        bytes.writeInt(bY);

        return bytes;
    }
}
}
