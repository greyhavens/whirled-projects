package vampire.quest {

import com.threerings.util.HashMap;
import com.threerings.util.Log;

public class Quests
{
    public static function init () :void
    {
        _inited = true;

        // create a test quest
        public var testQuest :QuestDesc = new QuestDesc();
        testQuest.id = "TestQuest";
        makeCollectionRequirement(testQuest, "Frob", 3); // Collect 3 Frobs!
        createQuest(testQuest);
    }

    public static function getQuest (id :String) :QuestDesc
    {
        checkInited();

        return _quests.get(id) as QuestDesc;
    }

    protected static function createQuest (desc :QuestDesc) :void
    {
        checkInited();

        validateQuest(desc, true);
        _quests.put(desc.id, desc);
    }

    protected static function makeCollectionRequirement (desc :QuestDesc, statName :String,
        num :int) :void
    {
        desc.relevantStats.push(statName);
        desc.isCompletedFn = function (stats :PlayerQuestStats) :Boolean {
            return stats.getIntStat(statName) >= num;
        };
        desc.getProgressTextFn = function (stats :PlayerQuestStats) :String {
            var remaining :int = Math.max(num - stats.getIntStat(statName), 0);
            return "Collect " + remaining + " more " + statName + (remaining == 1 ? "." : "s.");
        }
    }

    protected static function checkInited () :void
    {
        if (!_inited) {
            throw new Error("Quests.init has not been called");
        }
    }

    protected static function validateQuest (desc :QuestDesc, validateNotDuplicate :Boolean) :void
    {
        if (desc == null) {
            log.error("Invalid quest (quest is null)", new Error());
        } else if (desc.id == null) {
            log.error("Invalid quest (id is null)", "desc", desc, new Error();
        } else if (desc.isCompletedFn == null) {
            log.error("Invalid quest (isCompletedFn is null)", "desc", desc, new Error());
        } else if (desc.getProgressTextFn == null) {
            log.error("Invalid quest (getProgressTextFn is null)", "desc", desc, new Error());
        } else if (validateNotDuplicate && _quests.containsKey(desc.id)) {
            log.error("Invalid quest (id already exists)", "desc", desc, new Error());
        }
    }

    protected static var _inited :Boolean;
    protected static var _quests :HashMap = new HashMap();

    protected static var log :Log = Log.getLog(Quests);
}

}
