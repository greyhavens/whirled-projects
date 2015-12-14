package vampire.quest {

import com.threerings.util.StringUtil;

import vampire.Util;
import vampire.quest.activity.ActivityParams;

public class ActivityDesc
{
    public static const TYPE_FEEDING :int = 0;
    public static const TYPE_NPC_TALK :int = 1;

    public static function getId (name :String) :int
    {
        return Util.getStringHash(name);
    }

    // the location that contains the activity
    public var loc :LocationDesc;

    public var type :int;

    // Unique Name
    public var name :String;

    // Name of icon in the location panel
    public var iconName :String;

    public var displayName :String;

    // the amount of quest juice it takes to do this activity
    public var juiceCost :int;

    // Does this activity need to be unlocked, or is it available to anyone?
    public var requiresUnlock :Boolean;

    public var params :ActivityParams;

    public function ActivityDesc (loc :LocationDesc, type :int, name :String, iconName :String,
        displayName :String, juiceCost :int, requiresUnlock :Boolean, params :ActivityParams)
    {
        this.loc = loc;
        this.type = type;
        this.name = name;
        this.iconName = iconName;
        this.displayName = displayName;
        this.juiceCost = juiceCost;
        this.requiresUnlock = requiresUnlock;
        this.params = params;

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
}

}
