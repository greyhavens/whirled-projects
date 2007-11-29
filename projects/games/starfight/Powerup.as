package {

import flash.display.MovieClip;
import flash.display.Sprite;

import flash.utils.ByteArray;

public class Powerup extends BoardObject
{
    public static const SHIELDS :int = 0;
    public static const SPEED :int = 1;
    public static const SPREAD :int = 2;
    public static const HEALTH :int = 3;
    public static const COUNT :int = 3;

    public static const SOUNDS :Array = [
        "powerup_shield.wav", "powerup_engine.wav", "powerup_shot.wav"
    ];

    public static function readPowerup (bytes :ByteArray) :Powerup
    {
        var powerup :Powerup = new Powerup(0, 0, 0, false);
        powerup.readFrom(bytes);
        return powerup;
    }

    public function Powerup (type :int, boardX :int, boardY :int, graphics :Boolean = true) :void
    {
        super(type, boardX, boardY, graphics);
    }

    override protected function setupGraphics () :void
    {
        if (numChildren > 0) {
            removeChildAt(0);
        }
        var powMovie :MovieClip = MovieClip(new (Resources.getClass(MOVIES[type]))());
        addChild(powMovie);
    }

    protected static const MOVIES :Array = [
        "powerup_shield", "powerup_engine", "powerup_gun", "powerup_health"
    ];
}
}
