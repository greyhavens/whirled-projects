package vampire.quest {

import com.threerings.util.StringUtil;

import vampire.Util;
import vampire.quest.activity.ActivityParams;

public class ActivityDesc
{
    public static const TYPE_CORRUPTION :int = 0;
    public static const TYPE_NPC_TALK :int = 1;

    // Unique Name
    public var name :String;

    // the location that contains the activity
    public var loc :LocationDesc;

    public var type :int;

    public var displayName :String;
    public var params :ActivityParams;

    // the amount of quest juice it takes to do this activity
    public var juiceCost :int;

    public function ActivityDesc (loc :LocationDesc, type :int, name :String, displayName :String,
        params :ActivityParams, juiceCost :int = 0)
    {
        this.loc = loc;
        this.type = type;
        this.name = name;
        this.displayName = displayName;
        this.params = params;
        this.juiceCost = juiceCost;

        loc.activities.push(this);
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
