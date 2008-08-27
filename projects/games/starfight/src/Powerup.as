package {

import flash.events.Event;
import flash.utils.ByteArray;

public class Powerup extends BoardObject
{
    public static const CONSUMED :String = "Consumed";
    public static const DESTROYED :String = "Destroyed";

    public static const SHIELDS :int = 0;
    public static const SPEED :int = 1;
    public static const SPREAD :int = 2;
    public static const HEALTH :int = 3;
    public static const COUNT :int = 3;

    public static function readPowerup (bytes :ByteArray) :Powerup
    {
        var powerup :Powerup = new Powerup(0, 0, 0, false);
        powerup.reload(bytes);
        return powerup;
    }

    public function Powerup (type :int, boardX :int, boardY :int, graphics :Boolean = true) :void
    {
        super(type, boardX, boardY, graphics);
    }

    public function consume () :void
    {
        dispatchEvent(new Event(CONSUMED));
    }

    public function destroyed () :void
    {
        dispatchEvent(new Event(DESTROYED));
    }

    protected static const MOVIES :Array = [
        "powerup_shield", "powerup_engine", "powerup_gun", "powerup_health"
    ];
}
}
