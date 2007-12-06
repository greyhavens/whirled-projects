package {

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.media.Sound;

import flash.utils.ByteArray;

public class Powerup extends BoardObject
{
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

    public function sound () :Sound
    {
        return Resources.getSound(MOVIES[type] + ".wav");
    }

    override protected function setupGraphics () :void
    {
        if (numChildren > 0) {
            removeChildAt(0);
        }
        var powMovie :MovieClip = MovieClip(new (Resources.getClass(MOVIES[type]))());
        addChild(powMovie);
    }

    override protected function setPosition () :void
    {
        super.setPosition();
        x += Codes.PIXELS_PER_TILE/2;
        y += Codes.PIXELS_PER_TILE/2;
    }

    protected static const MOVIES :Array = [
        "powerup_shield", "powerup_engine", "powerup_gun", "powerup_health"
    ];
}
}
