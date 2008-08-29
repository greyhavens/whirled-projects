package {

import flash.events.Event;
import flash.media.Sound;
import flash.utils.ByteArray;

import client.Resources;

public class Mine extends BoardObject
{
    public static const EXPLODED :String = "Exploded";

    public var health :Number;
    public var active :Boolean;
    public var dmg :Number;

    public static function readMine (bytes :ByteArray) :Mine
    {
        var mine :Mine = new Mine(0, 0, 0, true, 0.0);
        mine.reload(bytes);
        return mine;
    }

    public function Mine (type :int, x :int, y :int, active :Boolean, damage :Number) :void
    {
        super(type, x, y);
        health = 1.0;
        this.active = active;
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

    override public function arrayName () :String
    {
        return "mines";
    }

    override public function hitSound () :Sound
    {
        return Resources.getSound("junk_hit.wav");
    }

    override public function getRad () :Number
    {
        return 2.5;
    }

    public function explode () :void
    {
        dispatchEvent(new Event(EXPLODED));
    }

    override public function readFrom (bytes :ByteArray) :void
    {
        super.readFrom(bytes);
        dmg = bytes.readFloat();
    }

    override public function writeTo (bytes :ByteArray) :ByteArray
    {
        bytes = super.writeTo(bytes);
        bytes.writeFloat(dmg);
        return bytes;
    }
}
}
