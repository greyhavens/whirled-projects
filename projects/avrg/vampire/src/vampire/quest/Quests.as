package vampire.quest {

import com.threerings.util.HashMap;
import com.threerings.util.Log;

import vampire.quest.client.PlayerQuestStats;

public class Quests
{
    public static function init () :void
    {
        _inited = true;

        // create a test quest
        var testQuest :QuestDesc = new QuestDesc();
        testQuest.name = "TestQuest";
        testQuest.displayName = "Monster Whacker";
        testQuest.description = "Go to the Battleground and kill 3 monsters";
        makeCollectionRequirement(testQuest, "monster_kills", 3);
        addQuest(testQuest);
    }

    public static function getQuest (questId :int) :QuestDesc
    {
        checkInited();
        return _quests.get(questId) as QuestDesc;
    }

    public static function getQuestByName (name :String) :QuestDesc
    {
        return getQuest(QuestDesc.getId(name));
    }

    protected static function addQuest (desc :QuestDesc) :void
    {
        checkInited();

        validate(desc, true);
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
            var cur :int = stats.getIntStat(statName);
            var remaining :int = Math.max(num - cur, 0);
            return "(" + remaining + " remaining)";
        }
    }

    protected static function checkInited () :void
    {
        if (!_inited) {
            throw new Error("Quests.init has not been called");
        }
    }

    protected static function validate (desc :QuestDesc, validateNotDuplicate :Boolean) :Boolean
    {
        if (desc == null) {
            log.error("Invalid Quest (Quest is null)", new Error());
            return false;
        } else if (desc.name == null) {
            log.error("Invalid Quest (id is null)", "desc", desc, new Error());
            return false;
        } else if (desc.isCompletedFn == null) {
            log.error("Invalid Quest (isCompletedFn is null)", "desc", desc, new Error());
            return false;
        } else if (desc.getProgressTextFn == null) {
            log.error("Invalid Quest (getProgressTextFn is null)", "desc", desc, new Error());
            return false;
        } else if (validateNotDuplicate && _quests.containsKey(desc.id)) {
            log.error("Invalid Quest (id already exists)", "desc", desc, new Error());
            return false;
        }

        return true;
    }

    protected static var _inited :Boolean;
    protected static var _quests :HashMap = new HashMap(); // Map<id:int, quest:QuestDesc>

    protected static var log :Log = Log.getLog(Quests);
}

}
