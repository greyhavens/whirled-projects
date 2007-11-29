package {

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Point;
import flash.utils.ByteArray;

import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.ezgame.PropertyChangedListener;
import com.threerings.ezgame.StateChangedEvent;
import com.threerings.util.HashMap;

import com.whirled.WhirledGameControl;

/**
 * Manages the board data and display sprite.
 */
public class BoardController
    implements PropertyChangedListener
{
    /** Board size in tiles. */
    public var width :int;
    public var height :int;

    /** All the obstacles on the board. */
    public var obstacles :Array;

    public var powerupLayer :Sprite;

    /**
     * Constructs a brand new board.
     */
    public function BoardController (gameCtrl :WhirledGameControl)
    {
        _gameCtrl = gameCtrl;
        _gameCtrl.registerListener(this);
    }

    public function init (callback :Function) :void
    {
        _callback = callback;

        if (!_gameCtrl.isConnected()) {
            create();
            return;
        }

        var boardBytes :ByteArray = ByteArray(_gameCtrl.get("board"));
        if (boardBytes != null) {
            readBoard(boardBytes);
        } else if (_gameCtrl.amInControl()) {
            create();
        }
    }

    protected function readBoard (boardBytes :ByteArray) :void
    {
        readFrom(boardBytes);
        obstacles = (_gameCtrl.get("obstacles") as Array);
        for (var ii :int; ii < obstacles.length; ii++) {
            obstacles[ii] = Obstacle.readObstacle(ByteArray(obstacles[ii]));
        }
        _callback();
    }

    public function create () :void
    {
        this.width = 100;
        this.height = 100;

        loadObstacles();

        if (_gameCtrl.isConnected()) {
            _gameCtrl.doBatch(function () :void {
                _gameCtrl.setImmediate("obstacles", new Array(obstacles.length));
                for (var ii :int; ii < obstacles.length; ii++) {
                    _gameCtrl.setImmediate("obstacles", obstacles[ii].writeTo(new ByteArray()), ii);
                }
                _gameCtrl.setImmediate("board", writeTo(new ByteArray()));
            });
        }
        _callback();
    }

    public function createSprite (boardLayer :Sprite, ships :HashMap, powerups :Array) :void
    {
        _ships = ships;
        _powerups = powerups;
        _bg = new BgSprite();
        _bg.setupGraphics(width, height);
        boardLayer.addChild(_bg);
        _board = new Sprite();
        setupGraphics();
        boardLayer.addChild(_board);
    }

    // from PropertyChangedListener
    public function propertyChanged (event :PropertyChangedEvent) :void
    {
        if (event.name == "board" && (_board == null)) {
            readBoard(ByteArray(_gameCtrl.get("board")));
        }
    }

    /**
     * Returns a valid starting point for a ship which is clear.
     */
    public function getStartingPos () :Point
    {
        var pt :Point;
        while (true) {
            pt = new Point(Math.random() * (width - 4) + 2, Math.random() * (height - 4) + 2);
            if (getCollision(pt.x, pt.y, pt.x, pt.y, ShipSprite.COLLISION_RAD, -1, 0) == null) {
                return pt;
            }
        }

        // Should never reach here.
        return null;
    }

    /**
     * Sets the center of the screen.  We need to adjust ourselves to match.
     */
    public function setAsCenter (boardX :Number, boardY :Number) :void
    {
        _board.x = StarFight.WIDTH/2 - boardX*Codes.PIXELS_PER_TILE;
        _board.y = StarFight.HEIGHT/2 - boardY*Codes.PIXELS_PER_TILE;
        _bg.setAsCenter(boardX, boardY);
    }

    /**
     * Returns the first collision for something of the specified radius (rad)
     *  moving along the given path.  ignoreShip is a ship ID to ignore, or
     *  we  ignore all if -1.
     */
    public function getCollision (oldX :Number, oldY :Number,
        newX :Number, newY :Number, rad :Number, ignoreShip :int, ignoreObs :int) :Collision
    {
        var hits :Array = [];

        /** The first one we've seen so far. */
        var bestTime :Number = 1.0;
        var bestHit :Collision = null;

        var dx :Number = newX - oldX;
        var dy :Number = newY - oldY;

        if (ignoreShip >= 0) {
            // Check each ship and figure out which one we hit first.
            for each (var ship :ShipSprite in _ships.values()) {
                if (ship == null) {
                    continue;
                }

                if (!ship.isAlive() || ship.shipId == ignoreShip || (dx == 0 && dy == 0)) {
                    continue;
                }

                var bX :Number = ship.boardX;
                var bY :Number = ship.boardY;
                var r :Number = ShipSprite.COLLISION_RAD + rad;
                // We approximate a ship as a circle for this...
                var a :Number = dx*dx + dy*dy;
                var b :Number = 2*(dx*(oldX-bX) + dy*(oldY-bY));
                var c :Number = bX*bX + bY*bY + oldX*oldX + oldY*oldY -
                    2*(bX*oldX + bY*oldY) - r*r;

                var determ :Number = b*b - 4*a*c;
                if (determ >= 0.0) {
                    var u :Number = (-b - Math.sqrt(determ))/(2*a);
                    if ((u >= 0.0) && (u <= 1.0)) {
                        if (u < bestTime) {
                            bestTime = u;
                            bestHit = new Collision(ship, u, false);
                        }
                    }
                }
            }
        }

        // Check each obstacle and figure out which one we hit first.
        for each (var obs :Obstacle in obstacles) {
            if (ignoreObs == 1 && obs.type != Obstacle.WALL) {
                continue;
            }

            // Find how long it is til our X coords collide.
            var timeToX :Number;
            if (dx > 0.0) {
                timeToX = (obs.bX - (oldX+rad))/dx;
            } else if (dx < 0.0) {
                timeToX = ((obs.bX+1.0) - (oldX-rad))/dx;
            } else if ((oldX+rad >= obs.bX) && (oldX-rad <= obs.bX+1.0)) {
                timeToX = -1.0; // already there.
            } else {
                timeToX = 2.0; // doesn't hit.
            }

            // Find how long it is til our Y coords collide.
            var timeToY :Number;
            if (dy > 0.0) {
                timeToY = (obs.bY - (oldY+rad))/dy;
            } else if (dy < 0.0) {
                timeToY = ((obs.bY+1.0) - (oldY-rad))/dy;
            } else if ((oldY+rad >= obs.bY) && (oldY-rad <= obs.bY+1.0)) {
                timeToY = -1.0; // already there.
            } else {
                timeToY = 2.0; // doesn't hit.
            }

            // Update our bestTime if this is a legitimate collision and is before any
            //  others we've found.
            var time :Number = Math.max(timeToX, timeToY);
            if (time >= 0.0 && time <= 1.0 && time < bestTime &&
                ((timeToX >= 0.0 || (oldX+rad >= obs.bX) && (oldX-rad <= obs.bX+1.0))) &&
                ((timeToY >= 0.0 || (oldY+rad >= obs.bY) && (oldY-rad <= obs.bY+1.0)))){
                bestTime = time;
                bestHit = new Collision(obs, time, timeToX > timeToY);
            }
        }
        return bestHit;
    }


    /** Returns any obstacle at the specified board location. */
    public function getObstacleAt (boardX :int, boardY :int) :Obstacle
    {
        // Check each obstacle and figure out which one we hit first.
        for each (var obs :Obstacle in obstacles) {
            if (obs.bX == boardX && obs.bY == boardY) {
                return obs;
            }
        }

        return null;
    }

    public function getPowerupIdx (oldX :Number, oldY :Number,
        newX :Number, newY :Number, rad :Number) :int
    {

        /** The first one we've seen so far. */
        var bestTime :Number = 1.0;
        var bestHit :int = -1;

        var dx :Number = newX - oldX;
        var dy :Number = newY - oldY;

        // Check each powerup and figure out which one we hit first.
        for (var ii :int; ii < _powerups.length; ii++) {
            var pow :Powerup = _powerups[ii];
            if (pow == null) {
                continue;
            }
            var bX :Number = pow.bX + 0.5;
            var bY :Number = pow.bY + 0.5;
            var r :Number = rad + 0.5; // Our radius...
            // We approximate a powerup as a circle for this...
            var a :Number = dx*dx + dy*dy;
            var b :Number = 2*(dx*(oldX-bX) + dy*(oldY-bY));
            var c :Number = bX*bX + bY*bY + oldX*oldX + oldY*oldY -
                2*(bX*oldX + bY*oldY) - r*r;

            var determ :Number = b*b - 4*a*c;
            if (determ >= 0.0) {
                var u :Number = (-b - Math.sqrt(determ))/(2*a);
                if ((u >= 0.0) && (u <= 1.0)) {
                    if (u < bestTime) {
                        bestTime = u;
                        bestHit = ii;
                    }
                }
            }
        }
        return bestHit;
    }

    public function explode (x :Number, y :Number, rot :int,
        isSmall :Boolean, shipType :int) :void
    {
        var exp :Explosion = Explosion.createExplosion(
            x * Codes.PIXELS_PER_TILE, y * Codes.PIXELS_PER_TILE, rot, isSmall, shipType);
        _board.addChild(exp);
    }

    public function explodeCustom (x :Number, y :Number, movie :MovieClip) :void
    {
        var exp :Explosion = new Explosion(
            x * Codes.PIXELS_PER_TILE, y * Codes.PIXELS_PER_TILE, movie);
        _board.addChild(exp);
    }

    /**
     * Draw the board.
     */
    public function setupGraphics () :void
    {
        for each (var obs :Obstacle in obstacles) {
            _board.addChild(obs);
        }

        _board.addChild(powerupLayer = new Sprite());
    }

    public function tick (time :int) :void
    {
        for each (var obs :Obstacle in obstacles) {
            obs.tick(time);
        }
    }

    /**
     * Unserialize our data from a byte array.
     */
    public function readFrom (bytes :ByteArray) :void
    {
        width = bytes.readInt();
        height = bytes.readInt();
        /*
        obstacles = [];
        while (bytes.bytesAvailable > 0) {
            var obs :Obstacle = new Obstacle(0, 0, 0, false);
            obs.readFrom(bytes);
            obstacles.push(obs);
        }
        */
    }

    /**
     * Serialize our data to a byte array.
     */
    public function writeTo (bytes :ByteArray) :ByteArray
    {
        bytes.writeInt(width);
        bytes.writeInt(height);
        /*
        for each (var obs :Obstacle in obstacles) {
            obs.writeTo(bytes);
        }
        */

        return bytes;
    }

    /**
     * Loads all the obstacles in the world.
     */
    protected function loadObstacles () :void
    {
        obstacles = [];

        var ii :int;

        // TODO Load obstacles from a file instead of random.
        var numAsteroids :int = width*height/100;
        for (ii = 0; ii < numAsteroids; ii++) {
            var type :int = 0;
            switch (int(Math.floor(Math.random()*2.0))) {
            case 0: type = Obstacle.ASTEROID_1; break;
            case 1: type = Obstacle.ASTEROID_2; break;
            }
            obstacles.push(new Obstacle(type, Math.random()*width, Math.random()*height));
        }

        // Place a wall around the outside of the board.

        for (ii = 0; ii < height; ii++) {
            obstacles.push(new Obstacle(Obstacle.WALL, 0, ii));
            obstacles.push(new Obstacle(Obstacle.WALL, width-1, ii));
        }

        for (ii = 0; ii < width; ii++) {
            obstacles.push(new Obstacle(Obstacle.WALL, ii, 0));
            obstacles.push(new Obstacle(Obstacle.WALL, ii, height-1));
        }
    }

    public function hostChanged (event :StateChangedEvent) :void
    {
        if (_gameCtrl.amInControl()) {
            if (_gameCtrl.get("board") == null) {
                create();
            }
        }
    }

    protected var _gameCtrl :WhirledGameControl;

    protected var _callback :Function;

    protected var _board :Sprite;
    protected var _bg :BgSprite;

    /** Reference to the array of ships we know about. */
    protected var _ships :HashMap;

    /** Reference to the array of powerups we know about. */
    protected var _powerups :Array;
}
}
