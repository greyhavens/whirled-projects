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
        var intro :QuestDesc = new QuestDesc();
        intro.npc = Npc.LILITH;
        intro.name = "intro_quest";
        intro.displayName =  "Aranea Park";
        intro.description = "Travel to Aranea Park and speak to Lilith";
        intro.usePropValDifferences = true;
        makeCollectionRequirement(intro, QuestProps.LILITH_VISITS, 1);
        addQuest(intro);

        var pandorasBox :QuestDesc = new QuestDesc();
        pandorasBox.npc = Npc.LILITH;
        pandorasBox.name = "pandora_quest";
        pandorasBox.displayName = "Appetizer";
        pandorasBox.description = "Allow 2 vampires to feed on you at Pandora's Box";
        pandorasBox.usePropValDifferences = true;
        makeCollectionRequirement(pandorasBox, QuestProps.PANDORA_FEEDINGS, 2);
        addQuest(pandorasBox);

        var theHunger :QuestDesc = new QuestDesc();
        theHunger.npc = Npc.LILITH;
        theHunger.name = "hunger_quest";
        theHunger.displayName = "The Hunger";
        theHunger.description = "Feed on 2 of your fellow vampires";
        theHunger.usePropValDifferences = true;
        makeCollectionRequirement(theHunger, QuestProps.NORMAL_FEEDINGS, 2);
        addQuest(theHunger);

        var rebekah :QuestDesc = new QuestDesc();
        rebekah.npc = Npc.LILITH;
        rebekah.name = "rebekah_quest";
        rebekah.displayName = "Conflict";
        rebekah.description = "(Placeholder) Feed on Rebekah";
        rebekah.usePropValDifferences = true;
        makeCollectionRequirement(rebekah, QuestProps.REBEKAH_FEEDINGS, 1);
        addQuest(rebekah);
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

    protected static function makeCollectionRequirement (desc :QuestDesc, propName :String,
        num :int) :void
    {
        desc.relevantProps.push(propName);

        function getCurValue (props :PlayerQuestProps) :int {
            var initialValue :int;
            if (desc.usePropValDifferences) {
                initialValue = props.getIntProp(desc.getPropInitName(propName));
            }

            return props.getIntProp(propName) - initialValue;
        }

        desc.isCompletedFn = function (props :PlayerQuestProps) :Boolean {
            return (getCurValue(props) >= num);
        };

        desc.getProgressFn = function (props :PlayerQuestProps) :Number {
            return Math.min(Number(getCurValue(props)) / Number(num), 1);
        };

        desc.getProgressTextFn = function (props :PlayerQuestProps) :String {
            var cur :int = getCurValue(props);
            var remaining :int = Math.max(num - cur, 0);
            return "(" + remaining + " remaining)";
        };
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
