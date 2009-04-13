package vampire.quest {

import com.threerings.util.ArrayUtil;
import com.threerings.util.StringUtil;

import vampire.Util;

public class QuestDesc
{
    // Unique name
    public var name :String;

    // A list of stats that this quest cares about
    public var relevantStats :Array = [];

    // Requirements for quest availability
    public var requiredQuests :Array = []; // list of ids
    public var minLevel :int;
    public var maxLevel :int = int.MAX_VALUE;

    // A function that returns true if the quest is completed
    // function isCompleted (stats :PlayerQuestStats) :Boolean
    public var isCompletedFn :Function;

    // Costs
    public var completionCost :int; // pay this much quest juice to finish

    // Rewards
    public var favorReward :int;

    // Flavor
    public var displayName :String = "";
    public var description :String = "";

    // A function that returns flavor text describing the progress that has been made on the quest
    // function getProgressText (stats :PlayerQuestStats) :String
    public var getProgressTextFn :Function;

    public function get id () :int
    {
        return Util.getStringHash(name);
    }

    public function toString () :String
    {
        return StringUtil.simpleToString(this, [ "name", "id", "displayName" ]);
    }

    public function isRelevantStat (statName :String) :Boolean
    {
        return ArrayUtil.contains(this.relevantStats, statName);
    }

    public function isComplete (stats :PlayerQuestStats) :Boolean
    {
        return this.isCompletedFn(stats);
    }

    public function getProgressText (stats :PlayerQuestStats) :String
    {
        return this.getProgressTextFn(stats);
    }

    public static function getId (name :String) :int
    {
        return Util.getStringHash(name);
    }
}

}
