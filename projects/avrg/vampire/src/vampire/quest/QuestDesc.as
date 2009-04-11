package vampire.quest {

import com.threerings.util.StringUtil;

public class QuestDesc
{
    // Unique id
    public var id :String;

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

    public function get hashCode () :int
    {
        return hashForId(id);
    }

    public function toString () :String
    {
        return StringUtil.simpleToString(this, [ "id", "hashCode", "displayName" ]);
    }

    public static function hashForId (questId :String) :int
    {
        // examine at most 32 characters of the id
        var hash :int;
        var inc :int = int(Math.max(1, Math.ceil(questId.length / 32)));
        for (var ii :int = 0; ii < questId.length; ii += inc) {
            hash = ((hash << 5) + hash) ^ int(questId.charCodeAt(ii));
        }

        return hash;
    }
}

}
