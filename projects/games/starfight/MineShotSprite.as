package {

import flash.display.MovieClip;

public class MineShotSprite extends ShotSprite {
    public function MineShotSprite (x :Number, y :Number, shipId :int, damage :Number, ttl :Number,
            shipType :int, game :StarFight) :void
    {
        super(x, y, shipId, damage, ttl, shipType, game);

        _shotMovie = MovieClip(new (game.myId == shipId ? Codes.SHIP_TYPES[shipType].mineFriendly :
                        Codes.SHIP_TYPES[shipType].mineEnemy)());
        addChild(_shotMovie);
    }

    override public function tick (board :BoardController, time :Number) :void
    {
        time /= 1000;
        ttl -= time;
        if (ttl < 0) {
            complete = true;
            return;
        }

        var coll :Collision = board.getCollision(boardX, boardY, boardX, boardY,
                Codes.SHIP_TYPES[shipType].secondaryShotSize, shipId, 0);
        if (coll != null) {
            if (coll.hit is ShipSprite) {
                var ship :ShipSprite = ShipSprite(coll.hit);
                _game.hitShip(ship, boardX, boardY, shipId, damage);

            } else {
                var obs :Obstacle = Obstacle(coll.hit);
                _game.hitObs(obs, boardX, boardY);
            }
            complete = true;
        }
    }
}
}
