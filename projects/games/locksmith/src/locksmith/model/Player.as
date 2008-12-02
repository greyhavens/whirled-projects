//
// $Id$

package drift.model {

import com.threerings.util.Enum;

public final class Player extends Enum
{
    public static const SUN :Player = new Player("SUN", [0, 2, 14], [6, 7, 8, 9, 10]);
    public static const MOON :Player = new Player("MOON", [6, 8, 10], [0, 1, 2, 14, 15]);
    finishedEnumerating(Player);

    public static function values () :Array
    {
        return Enum.values(Player);
    }

    public static function valueOf (name :String) :Player
    {
        return Enum.valueOf(Player, name) as Player;
    }

    public function get launchers () :Array 
    {
        return _launchers.concat();
    }

    public function get goals () :Array
    {
        return _goals.concat();
    }

    // @private
    public function Player (name :String, launchers :Array, goals :Array)
    {
        super(name);
        _launchers = launchers;
        _goals = goals;
    }

    protected var _launchers :Array;
    protected var _goals :Array;
}
}
