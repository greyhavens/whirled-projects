//
// $Id$

package drift.model {

import com.threerings.util.Enum;

public final class Player extends Enum
{
    public static const SUN :Player = new Player("SUN");
    public static const MOON :Player = new Player("MOON");
    finishedEnumerating(Player);

    public static function values () :Array
    {
        return Enum.values(Player);
    }

    public static function valueOf (name :String) :Player
    {
        return Enum.valueOf(Player, name) as Player;
    }

    // @private
    public function Player (name :String)
    {
        super(name);
    }
}
}
