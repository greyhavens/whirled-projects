package redrover.game {

import flash.events.Event;

public class GameEvent extends Event
{
    public static const GEMS_REDEEMED :String = "GemsRedeemed";

    public function GameEvent (type :String, data :Object)
    {
        super(type, false, false);
        _data = data;
    }

    public function get data () :Object
    {
        return _data;
    }

    protected var _data :Object;

}

}
