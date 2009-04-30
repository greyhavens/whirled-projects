package vampire.quest {

import com.threerings.util.HashMap;
import com.threerings.util.Log;

import vampire.quest.client.PlayerQuestProps;

public class Quests
{
    public static function init () :void
    {
        if (_inited) {
            throw new Error("already inited");
        }

        _inited = true;

        /* Lilith Quests */
        var pandorasBox :QuestDesc = new QuestDesc();
        pandorasBox.npc = Npc.LILITH;
        pandorasBox.name = "pandora_quest";
        pandorasBox.displayName = "Open the Box";
        pandorasBox.description = "Drain 5 partiers at the Pandora's Box nightclub";
        makeCollectionRequirement(pandorasBox, "pandora_feedings", 5);
        addQuest(pandorasBox);

        var theHunger :QuestDesc = new QuestDesc();
        pandorasBox.npc = Npc.LILITH;
        theHunger.name = "hunger_quest";
        theHunger.displayName = "The Hunger";
        theHunger.description = "(placeholder)";
        makeCollectionRequirement(theHunger, "hunger_feedings", 10);
        addQuest(theHunger);
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

    public static function getAllQuests () :Array
    {
        return _quests.values();
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
        desc.relevantProps.push(statName);
        desc.isCompletedFn = function (props :PlayerQuestProps) :Boolean {
            return props.getIntProp(statName) >= num;
        };
        desc.getProgressTextFn = function (props :PlayerQuestProps) :String {
            var cur :int = props.getIntProp(statName);
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
