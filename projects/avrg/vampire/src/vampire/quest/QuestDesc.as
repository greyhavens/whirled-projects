package vampire.quest {

import com.threerings.util.ArrayUtil;
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

    // A list of quest props that this quest cares about
    public var relevantProps :Array = [];

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

    public function get id () :int
    {
        return Util.getStringHash(name);
    }

    public function isRelevantProp (propName :String) :Boolean
    {
        return ArrayUtil.contains(this.relevantProps, propName);
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
