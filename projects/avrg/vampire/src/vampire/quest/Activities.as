package vampire.quest {

import com.threerings.util.HashMap;
import com.threerings.util.Log;

import vampire.feeding.variant.*;
import vampire.quest.activity.*;

public class Activities
{
    public static const LILITH_TALK_ACTIVITY :String = "lilith_activity";
    public static const PANDORA_FEEDING_ACTIVITY :String = "pandora_activity";
    public static const REBEKAH_FEEDING_ACTIVITY :String = "rebekah_activity";

    public static function init () :void
    {
        if (_inited) {
            throw new Error("already inited");
        }

        _inited = true;

        // Lilith activities
        var lilithArea :LocationDesc = Locations.getLocationByName("lilith_area");
        addActivity(createLilithTalk(lilithArea));
        addActivity(createPandoraActivity(lilithArea));
        addActivity(createRebekahActivity(lilithArea));
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

    public static function getAllActivities () :Array
    {
        return _activities.values();
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

    /** Activities */

    protected static function createLilithTalk (loc :LocationDesc) :ActivityDesc
    {
        return new ActivityDesc(
            loc,
            ActivityDesc.TYPE_NPC_TALK,
            LILITH_TALK_ACTIVITY,
            "site_lilith",
            "Lilith's Penthouse",
            0,  // no juice
            false, // always unlocked
            new NpcTalkActivityParams("LilithDialog"));
    }

    protected static function createPandoraActivity (loc :LocationDesc) :ActivityDesc
    {
        var variantSettings :VariantSettings = Variant.normal();
        variantSettings.gameTime = 45;
        variantSettings.heartbeatTime = 1;
        variantSettings.cursorSpeed = 100;
        variantSettings.customInstructionsName = "instructions_appetizer";

        var params :BloodBloomActivityParams = new BloodBloomActivityParams(
            1, 1,
            "Partying Vampire",
            -1,
            125,
            variantSettings,
            QuestProps.PANDORA_FEEDINGS, 1);

        return new ActivityDesc(
            loc,
            ActivityDesc.TYPE_FEEDING,
            PANDORA_FEEDING_ACTIVITY,
            "site_pandora",
            "Pandora's Box",
            0,  // no juice
            true, // locked
            params);
    }

    protected static function createRebekahActivity (loc :LocationDesc) :ActivityDesc
    {
        /*var variantSettings :VariantSettings = Variant.normal();
        variantSettings.boardWhiteCellCreationTime = new NumRange(2, 2, Rand.STREAM_GAME);
        variantSettings.boardWhiteCellCreationCount = new IntRange(1, 2, Rand.STREAM_GAME);*/
        var variantSettings :VariantSettings = Variant.corruption();

        var params :BloodBloomActivityParams = new BloodBloomActivityParams(
            1, 1,
            "Rebekah",
            -1,
            250,
            variantSettings,
            QuestProps.REBEKAH_FEEDINGS, 1);

        return new ActivityDesc(
            loc,
            ActivityDesc.TYPE_FEEDING,
            REBEKAH_FEEDING_ACTIVITY,
            "site_rebekah",
            "Rebekah's",
            0,  // no juice
            true, // locked
            params);
    }

    protected static var _inited :Boolean;
    protected static var _activities :HashMap = new HashMap(); // Map<id:int, ActivityDesc>

    protected static var log :Log = Log.getLog(Activities);
}

}
