package vampire.quest {

import flash.events.Event;

public class PlayerLocationEvent extends Event
{
    public static const MOVED_TO_LOCATION :String = "MovedToLocation";

    public var location :LocationDesc;

    public function PlayerLocationEvent (type :String, location :LocationDesc)
    {
        super(type);
        this.location = location;
    }

    override public function clone () :Event
    {
        return new PlayerLocationEvent(type, location);
    }

}

}
