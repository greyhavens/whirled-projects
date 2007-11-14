package {

import mx.core.MovieClipAsset;

public class LaserShotSprite extends ShotSprite {

    /** Position. */
    public var angle :Number;
    public var length :Number;
    public var tShipId :int;

    public function LaserShotSprite (x :Number, y :Number, angle :Number, length :Number,
            shipId :int, damage :Number, ttl :Number, shipType :int, tShipId :int,
            game :StarFight) :void
    {
        super(x, y, shipId, damage, ttl, shipType, game);
        this.tShipId = tShipId;

        _shotMovie = MovieClipAsset(new Codes.SHIP_TYPES[shipType].SHOT_ANIM);

        _shotMovie.gotoAndStop(1);
        _shotMovie.scaleY = Codes.PIXELS_PER_TILE * length / _shotMovie.height;
        rotation = angle - 90;
        _hit = false;
        addChild(_shotMovie);
    }

    override public function tick (board :BoardSprite, time :Number) :void
    {
        if (!_hit && tShipId != -1) {
            var ship :ShipSprite = _game.getShip(tShipId);
            _game.hitShip(ship, ship.boardX, ship.boardY, shipId, damage);
            _hit = true;
        }
        // Update our time to live and destroy if appropriate.
        ttl -= time;
        if (ttl < 0) {
            complete = true;
            return;
        }
    }

    /** Our shot animation. */
    protected var _shotMovie :MovieClipAsset;

    protected var _hit :Boolean;
}
}
