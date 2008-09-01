package {

import flash.display.MovieClip;

public class MissileShot extends Shot
{
    /** Velocity. */
    public var xVel :Number;
    public var yVel :Number;

    // @TSC: remove post-refactor
    public var shotClip :Class;
    public var explodeClip :Class;

    public function MissileShot (x :Number, y :Number, vel :Number, angle :Number,
            shipId :int, damage :Number, ttl :Number, shipType :int,
            shotClip :Class = null, explodeClip :Class = null) :void
    {
        super(x, y, shipId, damage, ttl, shipType);

        this.xVel = vel * Math.cos(angle);
        this.yVel = vel * Math.sin(angle);
        this.shotClip = shotClip;
        this.explodeClip = explodeClip;
    }

    /**
     * Allow our shot to update itself.
     */
    override public function tick (board :BoardController, time :Number) :void
    {
        time /= 1000;
        // Update our time to live and destroy if appropriate.
        ttl -= time;
        if (ttl < 0) {
            complete = true;
            // perform the rest of the collision detection for the remaining time of the shot
            time += ttl;
        }

        // See if we're already inside an obstacle, since we could potentially have
        //  been shot just inside the edge of one - if so, explode immediately.
        var inObs :Obstacle = board.getObstacleAt(int(boardX), int(boardY));
        if (inObs != null) {
            AppContext.game.hitObs(inObs, boardX, boardY, shipId, damage);
            complete = true;
            return;
        }

        var coll :Collision = board.getCollision(boardX, boardY, boardX + xVel*time,
                boardY + yVel*time, Codes.getShipType(shipType).primaryShotSize, shipId, 0);
        if (coll == null) {
            boardX += xVel*time;
            boardY += yVel*time;
        } else {
            var hitX :Number = boardX + xVel * coll.time * time;
            var hitY :Number = boardY + yVel * coll.time * time;
            if (coll.hit is Ship) {
                var ship :Ship = Ship(coll.hit);
                AppContext.game.hitShip(ship, hitX, hitY, shipId, damage);

            } else {
                var obj :BoardObject = BoardObject(coll.hit);
                AppContext.game.hitObs(obj, hitX, hitY, shipId, damage)
            }

            complete = true;
        }
    }
}

}