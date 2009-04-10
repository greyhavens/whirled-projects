package vampire.quest {

import flash.events.Event;

public class PlayerStatEvent extends Event
{
    public static const STAT_CHANGED :String = "StatChanged";

    public var statName :String;

    public function PlayerStatEvent (type :String, statName :String) :void
    {
        super(type);
        this.statName = statName;
    }
}

}
