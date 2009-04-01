package vampire.feeding.client {

import flash.events.Event;

public class GameEvent extends Event
{
    public static const HIT_RED_CELL :String = "HitRedCell"; // no data

    public var data :*;

    public function GameEvent (type :String, data :* = undefined)
    {
        super(type, false, false);
        this.data = data;
    }
}

}
