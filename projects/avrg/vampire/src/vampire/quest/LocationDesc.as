package vampire.quest {

import com.threerings.util.StringUtil;

import vampire.Util;

public class LocationDesc
{
    // Unique name
    public var name :String;

    // the set of locations connected to this one
    public var connectedLocs :Array = [];

    // the set of activities available at this Location
    public var activities :Array = [];

    // flavor
    public var displayName :String;

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
