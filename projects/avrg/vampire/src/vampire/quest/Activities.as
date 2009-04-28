package vampire.quest {

import com.threerings.util.HashMap;
import com.threerings.util.Log;

import vampire.quest.activity.*;

public class Activities
{
    public static function init () :void
    {
        if (_inited) {
            throw new Error("already inited");
        }

        _inited = true;

        // Home Base activities
        var homeBase :LocationDesc = Locations.getLocationByName("HomeBase");
        addActivity(new ActivityDesc(
            homeBase,
            ActivityDesc.TYPE_NPC_TALK,
            "talk_lilith",
            "Talk to Lilith",
            0,  // no juice
            false, // always unlocked
            new NpcTalkActivityParams("LilithDialog")));

        addActivity(new ActivityDesc(
            homeBase,
            ActivityDesc.TYPE_FEEDING,
            "pandora_activity",
            "Pandora's Box",
            0,  // no juice
            true, // locked
            new BloodBloomActivityParams(1, 1, "Pandora's Box Partier", 100, "pandora_feedings", 1)));

        addActivity(new ActivityDesc(
            homeBase,
            ActivityDesc.TYPE_CORRUPTION,
            "temp_corruption",
            "Playtest Corruption",
            0,
            false,
            new BloodBloomActivityParams(1, 1, "Corrupted Human", 100)));
    }

    public static function getActivity (id :int) :ActivityDesc
    {
        checkInited();
        return _activities.get(id) as ActivityDesc;
    }

    public static function getActivityByName (name :String) :ActivityDesc
    {
        return getActivity(ActivityDesc.getId(name));
    }

    protected static function addActivity (desc :ActivityDesc) :void
    {
        checkInited();

        validate(desc, true);
        _activities.put(desc.id, desc);
    }

    protected static function checkInited () :void
    {
        if (!_inited) {
            throw new Error("Activities.init has not been called");
        }
    }

    protected static function validate (desc :ActivityDesc, validateNotDuplicate :Boolean) :Boolean
    {
        if (desc == null) {
            log.error("Invalid ActivityDesc (null)", new Error());
            return false;
        } else if (desc.name == null) {
            log.error("Invalid ActivityDesc (name is null)", "desc", desc, new Error());
            return false;
        } else if (validateNotDuplicate && _activities.containsKey(desc.id)) {
            log.error("Invalid ActivityDesc (id already exists)", "desc", desc, new Error());
            return false;
        }

        return true;
    }

    protected static var _inited :Boolean;
    protected static var _activities :HashMap = new HashMap(); // Map<id:int, ActivityDesc>

    protected static var log :Log = Log.getLog(Activities);
}

}
