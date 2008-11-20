package redrover.game {

import flash.events.Event;

public class GameEvent extends Event
{
    public static const GEMS_REDEEMED :String = "GemsRedeemed";

    public static function createGemsRedeemed (playerIndex :int, gems :Array, boardCell :BoardCell)
        :GameEvent
    {
        return new GameEvent(GEMS_REDEEMED,
            { playerIndex: playerIndex, gems: gems, boardCell: boardCell });
    }

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
