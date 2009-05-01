package vampire.quest {

import com.threerings.util.StringUtil;

import vampire.Util;
import vampire.quest.client.PlayerQuestProps;

public class QuestDesc
{
    public static function getId (name :String) :int
    {
        return Util.getStringHash(name);
    }

    // Unique name
    public var name :String;

    // The NPC that grants the quest
    public var npc :int;

    // A list of quest props that this quest cares about
    public var relevantProps :Array = [];

    // If true, the values of the quest's relevant properties are stored when the quest
    // is added, and the difference between the props' initial values and their current
    // values are used in calculating quest progress
    public var usePropValDifferences :Boolean;

    // Requirements for quest availability
    public var requiredQuests :Array = []; // list of ids
    public var minLevel :int;
    public var maxLevel :int = int.MAX_VALUE;

    // A function that returns true if the quest is completed
    // function isCompleted (questProps :PlayerQuestProps) :Boolean
    public var isCompletedFn :Function;

    // Rewards
    public var favorReward :int;

    // Flavor
    public var displayName :String = "";
    public var description :String = "";

    // A function that returns flavor text describing the progress that has been made on the quest
    // function getProgressText (questProps :PlayerQuestProps) :String
    public var getProgressTextFn :Function;

    public function get npcName () :String
    {
        return Npc.getName(npc);
    }

    public function get npcPortraitName () :String
    {
        return Npc.getPortraitName(npc);
    }

    public function get id () :int
    {
        return Util.getStringHash(name);
    }

    public function getPropInitName (propName :String) :String
    {
        return String(this.id) + "_init_" + QuestProps.makeTransient(propName)
    }

    public function isRelevantProp (propName :String) :Boolean
    {
        for each (var relevantPropName :String in this.relevantProps) {
            if ((propName == relevantPropName) ||
                (this.usePropValDifferences && propName == getPropInitName(relevantPropName))) {
                return true;
            }
        }

        return false;
    }

    public function isComplete (props :PlayerQuestProps) :Boolean
    {
        return this.isCompletedFn(props);
    }

    public function getProgressText (props :PlayerQuestProps) :String
    {
        return this.getProgressTextFn(props);
    }

    public function toString () :String
    {
        return StringUtil.simpleToString(this, [ "name", "id", "displayName" ]);
    }
}

}
