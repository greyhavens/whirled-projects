package vampire.feeding.client {

import flash.events.Event;

public class GameEvent extends Event
{
    public static const HEARTBEAT :String = "Heartbeat";
    public static const WHITE_CELL_DELIVERED :String = "WhiteCellDelivered";

    public var data :*;

    public function GameEvent (type :String, data :* = undefined)
    {
        super(type, false, false);
        this.data = data;
    }

}

}
