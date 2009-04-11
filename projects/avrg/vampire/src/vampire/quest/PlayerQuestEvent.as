package vampire.quest {

import flash.events.Event;

public class PlayerQuestEvent extends Event
{
    public static const QUEST_ADDED :String = "QuestAdded";
    public static const QUEST_COMPLETED :String = "QuestCompleted";

    public var questId :int;

    public function PlayerQuestEvent (type :String, questId :int)
    {
        super(type);
        this.questId = questId;
    }

    public function get quest () :QuestDesc
    {
        return Quests.getQuest(questId);
    }

    override public function clone () :Event
    {
        return new PlayerQuestEvent(type, questId);
    }
}

}
