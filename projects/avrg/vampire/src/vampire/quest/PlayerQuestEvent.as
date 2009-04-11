package vampire.quest {

import flash.events.Event;

public class PlayerQuestEvent extends Event
{
    public static const QUEST_ADDED :String = "QuestAdded";
    public static const QUEST_COMPLETED :String = "QuestCompleted";

    public var questHash :int;

    public function PlayerQuestEvent (type :String, questHash :int)
    {
        super(type);
        this.questHash = questHash;
    }

    public function get quest () :QuestDesc
    {
        return Quests.getQuest(questHash);
    }

    override public function clone () :Event
    {
        return new PlayerQuestEvent(type, questHash);
    }
}

}
