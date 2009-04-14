package vampire.quest {

import com.threerings.util.ArrayUtil;
import com.threerings.util.StringUtil;

import vampire.Util;

public class LocationDesc
{
    // Unique name
    public var name :String;

    // the set of locations connected to this one, and the costs to move to
    // each of those locations
    public var connectedLocs :Array = []; // Array<LocationConnection>

    // the set of activities available at this Location
    public var activities :Array = []; // Array<ActivityDesc>

    // flavor
    public var displayName :String;

    public function isConnectedLocation (loc :LocationDesc) :Boolean
    {
        return (getMovementCost(loc) >= 0);
    }

    public function getMovementCost (dest :LocationDesc) :int
    {
        var lc :LocationConnection = ArrayUtil.findIf(connectedLocs,
            function (lc :LocationConnection) :Boolean {
                return lc.loc == dest;
            });
        return (lc != null ? lc.cost : -1);
    }

    public function get id () :int
    {
        return Util.getStringHash(name);
    }

    public function toString () :String
    {
        return StringUtil.simpleToString(this, [ "name", "id", "displayName" ]);
    }

    public static function getId (name :String) :int
    {
        return Util.getStringHash(name);
    }
}

}
