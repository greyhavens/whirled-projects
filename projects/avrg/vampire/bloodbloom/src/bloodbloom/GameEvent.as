package bloodbloom {

import flash.events.Event;

public class GameEvent extends Event
{
    public static const HEARTBEAT :String = "Heartbeat";

    public var data :*;

    public function GameEvent (type :String, data :* = undefined)
    {
        super(type, false, false);
        this.data = data;
    }

}

}
