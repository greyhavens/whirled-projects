package vampire.quest {

import com.threerings.util.StringUtil;

import vampire.Util;

public class LocationDesc
{
    public static function getId (name :String) :int
    {
        return Util.getStringHash(name);
    }

    // Unique name
    public var name :String;

    // flavor
    public var displayName :String;

    // the set of activities available at this Location
    public var activities :Array = []; // Array<ActivityDesc>

    public function LocationDesc (name :String, displayName :String)
    {
        this.name = name;
        this.displayName = displayName;
    }

    public function get id () :int
    {
        return Util.getStringHash(name);
    }

    public function toString () :String
    {
        return StringUtil.simpleToString(this, [ "name", "id", "displayName" ]);
    }
}

}
