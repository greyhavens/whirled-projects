//
// $Id$

package locksmith.view {

import com.threerings.util.Enum;

import locksmith.model.Player;

public final class Launcher extends Enum
{
    public static const UP :Launcher = new Launcher("UP", 45, 135);
    public static const MID :Launcher = new Launcher("MID", 0, 180);
    public static const LOW :Launcher = new Launcher("LOW", 315, 225);
    finishedEnumerating(Launcher);

    public static function values () :Array
    {
        return Enum.values(Launcher);
    }

    public static function valueOf (name :String) :Launcher
    {
        return Enum.valueOf(Launcher, name) as Launcher;
    }

    public function getAngle (player :Player) :int
    {
        return _angles[player.name()] as int;
    }

    // @private
    public function Launcher (name :String, sunAngle :int, moonAngle :int)
    {
        super(name);
        _angles[Player.SUN.name()] = sunAngle;
        _angles[Player.MOON.name()] = moonAngle;
    }

    protected var _angles :Object = {};
}
}
