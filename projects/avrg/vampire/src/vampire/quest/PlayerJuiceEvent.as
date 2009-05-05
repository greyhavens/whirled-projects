package vampire.quest {

import flash.events.Event;

public class PlayerJuiceEvent extends Event
{
    public static const QUEST_JUICE_CHANGED :String = "QuestJuiceChanged";

    public var juice :int;

    public function PlayerJuiceEvent (type :String, juice :int)
    {
        super(type);
        this.juice = juice;
    }

    override public function clone () :Event
    {
        return new PlayerJuiceEvent(type, juice);
    }

}

}
