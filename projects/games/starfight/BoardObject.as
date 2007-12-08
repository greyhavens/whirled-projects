package {

import flash.display.Sprite;
import flash.media.Sound;
import flash.utils.ByteArray;

/**
 * Represents an entity that exists on the board.
 */
public class BoardObject extends Sprite
{
    public var bX :int;
    public var bY :int;
    public var type :int;
    public var index :int;

    public function BoardObject (type :int, bX :int, bY :int, graphics :Boolean) :void
    {
        this.type = type;
        this.bX = bX;
        this.bY = bY;

        setPosition();
        if (graphics) {
            setupGraphics();
        }
    }

    public function damage (damage :Number) :Boolean
    {
        return false;
    }

    public function arrayName () :String
    {
        return "object";
    }

    public function hitSound () :Sound
    {
        return null;
    }

    public function getRad () :Number
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

        setPosition();
        setupGraphics();
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

    protected function setupGraphics () :void
    {
    }

    protected function setPosition () :void
    {
        x = bX * Codes.PIXELS_PER_TILE;
        y = bY * Codes.PIXELS_PER_TILE;
    }
}
}
