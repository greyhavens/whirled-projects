package {

import flash.events.Event;
import flash.utils.ByteArray;

public class Mine extends BoardObject
{
    public static const EXPLODED :String = "Exploded";

    public var ownerId :int;
    public var health :Number;
    public var dmg :Number;

    public static function readMine (bytes :ByteArray) :Mine
    {
        var mine :Mine = new Mine(0, 0, 0, 0);
        mine.reload(bytes);
        return mine;
    }

    public function Mine (ownerId :int, x :int, y :int, damage :Number) :void
    {
        super(x, y);
        this.ownerId = ownerId;
        health = 1.0;
        dmg = damage;
    }

    override public function damage (damage :Number) :Boolean
    {
        if (health < 0) {
            return false;
        }
        health -= damage;
        return health < 0;
    }

    override public function get arrayName () :String
    {
        return Constants.PROP_MINES;
    }

    override public function get hitSoundName () :String
    {
        return "junk_hit.wav";
    }

    override public function get radius () :Number
    {
        return 2.5;
    }

    public function explode () :void
    {
        dispatchEvent(new Event(EXPLODED));
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);
        ownerId = bytes.readInt();
        dmg = bytes.readFloat();
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        bytes = super.toBytes(bytes);
        bytes.writeInt(ownerId);
        bytes.writeFloat(dmg);
        return bytes;
    }
}
}
