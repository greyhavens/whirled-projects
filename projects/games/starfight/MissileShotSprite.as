package {

import mx.core.MovieClipAsset;

public class MissileShotSprite extends ShotSprite {

    /** Velocity. */
    public var xVel :Number;
    public var yVel :Number;

    public function MissileShotSprite (x :Number, y :Number, vel :Number, angle :Number,
            shipId :int, damage :Number, ttl :Number, shipType :int, game :StarFight) :void
    {
        super(x, y, shipId, damage, ttl, shipType, game);

        this.xVel = vel * Math.cos(angle);
        this.yVel = vel * Math.sin(angle);

        _shotMovie = MovieClipAsset(new Codes.SHIP_TYPES[shipType].SHOT_ANIM);

        _shotMovie.gotoAndStop(1);
        _shotMovie.x = -_shotMovie.width/2;
        _shotMovie.y = 0;
        rotation = Codes.RADS_TO_DEGS*Math.atan2(xVel, -yVel);
        addChild(_shotMovie);
    }

    /**
     * Allow our shot to update itself.
     */
    override public function tick (board :BoardSprite, time :Number) :void
    {
        time /= 1000;
        // Update our time to live and destroy if appropriate.
        ttl -= time;
        if (ttl < 0) {
            complete = true;
            return;
        }

        // See if we're already inside an obstacle, since we could potentially have
        //  been shot just inside the edge of one - if so, explode immediately.
        var inObs :Obstacle = board.getObstacleAt(int(boardX), int(boardY));
        if (inObs != null) {
            _game.hitObs(inObs, boardX,boardY);
            complete = true;
            return;
        }

        var coll :Collision = board.getCollision(boardX, boardY, boardX + xVel*time,
                boardY + yVel*time, Codes.SHIP_TYPES[shipType].primaryShotSize, shipId);
        if (coll == null) {
            boardX += xVel*time;
            boardY += yVel*time;
        } else {
            if (coll.hit is ShipSprite) {
                var ship :ShipSprite = ShipSprite(coll.hit);
                _game.hitShip(ship, boardX + (xVel*coll.time*time),
                    boardY + (yVel*coll.time*time), shipId, damage);

            } else {
                var obs :Obstacle = Obstacle(coll.hit);
                _game.hitObs(obs, boardX + (xVel*coll.time*time),
                    boardY + (yVel*coll.time*time));
            }
            complete = true;
        }
    }

    /** Our shot animation. */
    protected var _shotMovie :MovieClipAsset;
}
}
