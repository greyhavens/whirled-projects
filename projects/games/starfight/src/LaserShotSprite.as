package {

import flash.display.MovieClip;

public class LaserShotSprite extends ShotSprite
{
    /** Position. */
    public var angle :Number;
    public var length :Number;
    public var tShipId :int;

    public function LaserShotSprite (x :Number, y :Number, angle :Number, length :Number,
            shipId :int, damage :Number, ttl :Number, shipType :int, tShipId :int) :void
    {
        super(x, y, shipId, damage, ttl, shipType);
        this.angle = angle;
        this.length = length;
        this.tShipId = tShipId;
        _hit = false;
    }

    override public function tick (board :BoardController, time :Number) :void
    {
        time /= 1000;
        if (!_hit && tShipId != -1) {
            var ship :Ship = AppContext.game.getShip(tShipId);
            if (ship != null) {
                AppContext.game.hitShip(ship, ship.boardX, ship.boardY, shipId, damage);
                _hit = true;
            }
        }
        // Update our time to live and destroy if appropriate.
        ttl -= time;
        if (ttl < 0) {
            complete = true;
            return;
        }
    }

    protected var _hit :Boolean;
}
}
