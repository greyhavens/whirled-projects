package redrover.game {

import flash.events.Event;

public class GameEvent extends Event
{
    public static const GEMS_REDEEMED :String = "GemsRedeemed";
    public static const ATE_PLAYER :String = "AtePlayer";
    public static const WAS_EATEN :String = "WasEaten";

    public static function createGemsRedeemed (player :Player, gems :Array, boardCell :BoardCell)
        :GameEvent
    {
        return new GameEvent(GEMS_REDEEMED, { player: player, gems: gems, boardCell: boardCell });
    }

    public static function createAtePlayer (eatingPlayer :Player, eatenPlayer :Player) :GameEvent
    {
        return new GameEvent(ATE_PLAYER, { eatingPlayer: eatingPlayer, eatenPlayer: eatenPlayer });
    }

    public static function createWasEaten (eatingPlayer :Player, eatenPlayer :Player) :GameEvent
    {
        return new GameEvent(WAS_EATEN, { eatingPlayer: eatingPlayer, eatenPlayer: eatenPlayer });
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
