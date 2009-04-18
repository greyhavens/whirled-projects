package vampire.quest {

import com.threerings.util.StringUtil;

import vampire.Util;

public class LocationDesc
{
    // Unique name
    public var name :String;

    // Cost to enter this location
    public var cost :int;

    // flavor
    public var displayName :String;

    // the set of activities available at this Location
    public var activities :Array = []; // Array<ActivityDesc>

    public function LocationDesc (name :String, displayName :String, cost :int)
    {
        this.name = name;
        this.displayName = displayName;
        this.cost = cost;
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
