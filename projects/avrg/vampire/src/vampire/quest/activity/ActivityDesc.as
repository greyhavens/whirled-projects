package vampire.quest.activity {

import com.threerings.util.StringUtil;

public class ActivityDesc
{
    public static const TYPE_CORRUPTION :int = 0;
    public static const TYPE_NPC_TALK :int = 1;

    public var type :int;
    public var params :ActivityParams;

    public var displayName :String;

    public function ActivityDesc (type :int, displayName :String, params :ActivityParams)
    {
        this.type = type;
        this.displayName = displayName;
        this.params = params;
    }

    public function toString () :String
    {
        return StringUtil.simpleToString(this, [ "type", "displayName" ]);
    }
}

}
