package starfight {

import flash.events.EventDispatcher;
import flash.utils.ByteArray;

/**
 * Represents an entity that exists on the board.
 */
public class BoardObject extends EventDispatcher
{
    public var bX :int;
    public var bY :int;
    public var index :int;

    public function BoardObject (bX :int, bY :int) :void
    {
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

    public function reload (bytes :ByteArray) :void
    {
        fromBytes(bytes);
    }

    /**
     * Unserialize our data from a byte array.
     */
    public function fromBytes (bytes :ByteArray) :void
    {
        bX = bytes.readInt();
        bY = bytes.readInt();
    }

    /**
     * Serialize our data to a byte array.
     */
    public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        bytes = (bytes != null ? bytes : new ByteArray());
        bytes.writeInt(bX);
        bytes.writeInt(bY);

        return bytes;
    }
}
}
