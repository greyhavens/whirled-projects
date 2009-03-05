package vampire.feeding.client {

import flash.events.Event;

public class GameEvent extends Event
{
    public static const HEARTBEAT :String = "Heartbeat";
    public static const SPECIAL_CELL_SPAWNED :String = "SpecialCellSpawned"; // data = cell
    public static const WHITE_CELL_BURST :String = "WhiteCellBurst";

    public var data :*;

    public function GameEvent (type :String, data :* = undefined)
    {
        super(type, false, false);
        this.data = data;
    }

}

}
