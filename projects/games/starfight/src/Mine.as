package {

import flash.display.MovieClip;
import flash.events.Event;
import flash.media.Sound;
import flash.utils.ByteArray;

public class Mine extends BoardObject
{
    public var health :Number;
    public var active :Boolean;
    public var dmg :Number;

    public static function readMine (bytes :ByteArray) :Mine
    {
        var mine :Mine = new Mine(0, 0, 0, true, 0.0, false);
        mine.reload(bytes);
        return mine;
    }

    public function Mine (
            type :int, x :int, y :int, active :Boolean, damage :Number, anim :Boolean = true) :void
    {
        super(type, x, y, false);
        health = 1.0;
        this.active = active;
        dmg = damage;

        if (anim) {
            setupGraphics();
        }
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

    public function explode (callback :Function) :void
    {
        removeChildAt(0);
        var expMovie :MovieClip = MovieClip(new Codes.SHIP_TYPES[2].mineExplode());
        expMovie.addEventListener(Event.COMPLETE, function (event :Event) :void
            {
                expMovie.removeEventListener(Event.COMPLETE, arguments.callee);
                callback();
            });
        addChild(expMovie);
        AppContext.starfight.playSoundAt(Codes.SHIP_TYPES[2].mineExplodeSound, bX, bY);
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

    override protected function setPosition () :void
    {
        super.setPosition();
        x += Codes.PIXELS_PER_TILE/2;
        y += Codes.PIXELS_PER_TILE/2;
    }

    override protected function setupGraphics () :void
    {
        addChild(MovieClip(new (active ? Codes.SHIP_TYPES[2].mineEnemy :
                Codes.SHIP_TYPES[2].mineFriendly)()));
    }
}
}
