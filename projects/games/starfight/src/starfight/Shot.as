package starfight {

import flash.events.EventDispatcher;

public class Shot extends EventDispatcher
{
    public static const NORMAL :int = 0;
    public static const SUPER :int = 1;

    public static const HIT :String = "Hit";

    /** Position. */
    public var boardX :Number;
    public var boardY :Number;

    public var complete :Boolean;

    public var shipId :int;

    public var shipType :int;

    public var ttl :Number;

    public var damage :Number;

    public function Shot (boardX :Number, boardY :Number, shipId :int, damage :Number,
        ttl :Number, shipType :int) :void
    {
        this.boardX = boardX;
        this.boardY = boardY;
        this.shipId = shipId;
        this.damage = damage;
        this.ttl = ttl;
        this.shipType = shipType;
        complete = false;
    }

    /**
     * Allow our shot to update itself.
     */
    public function update (board :BoardController, time :Number) :void
    {
    }

    protected function hit (hitBoardX :int, hitBoardY :int) :void
    {
        dispatchEvent(new ShotHitEvent(hitBoardX, hitBoardY));
    }
}
}
