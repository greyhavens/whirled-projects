package vampire.quest {

import flash.events.Event;

public class PlayerQuestEvent extends Event
{
    public static const QUEST_ADDED :String = "QuestAdded";
    public static const QUEST_COMPLETED :String = "QuestCompleted";

    public var quest :QuestDesc;

    public function PlayerQuestEvent (type :String, quest :QuestDesc)
    {
        super(type);
        this.quest = quest;
    }

    override public function clone () :Event
    {
        return new PlayerQuestEvent(type, quest);
    }
}

}
