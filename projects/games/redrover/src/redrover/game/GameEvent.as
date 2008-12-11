package redrover.game {

import flash.events.Event;

public class GameEvent extends Event
{
    public static const GEM_GRABBED :String = "GemPickup";
    public static const GEMS_REDEEMED :String = "GemsRedeemed";
    public static const ATE_PLAYER :String = "AtePlayer";
    public static const WAS_EATEN :String = "WasEaten";

    public static function createGemGrabbed () :GameEvent
    {
        return new GameEvent(GEM_GRABBED);
    }

    public static function createGemsRedeemed (gems :Array, boardCell :BoardCell)
        :GameEvent
    {
        return new GameEvent(GEMS_REDEEMED, { gems: gems, boardCell: boardCell });
    }

    public static function createAtePlayer (eatenPlayer :Player) :GameEvent
    {
        return new GameEvent(ATE_PLAYER, { eatenPlayer: eatenPlayer });
    }

    public static function createWasEaten (eatingPlayer :Player) :GameEvent
    {
        return new GameEvent(WAS_EATEN, { eatingPlayer: eatingPlayer });
    }

    public function GameEvent (type :String, data :Object = null)
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
