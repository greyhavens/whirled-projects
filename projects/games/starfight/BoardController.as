package {

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Point;
import flash.media.Sound;
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
            boardBytes.position = 0;
            readBoard(boardBytes);
        } else if (_gameCtrl.amInControl()) {
            create();
        }
    }

    protected function readBoard (boardBytes :ByteArray) :void
    {
        readFrom(boardBytes);
        var obs :Array = (_gameCtrl.get("obstacles") as Array);
        _obstacles = new Array(obs.length);
        for (var ii :int; ii < _obstacles.length; ii++) {
            if (obs[ii] == null) {
                continue;
            }
            obs[ii].position = 0;
            _obstacles[ii] = Obstacle.readObstacle(ByteArray(obs[ii]));
            _obstacles[ii].index = ii;
        }
        var pups :Array = (_gameCtrl.get("powerup") as Array);
        _powerups = new Array(pups.length);
        for (ii = 0; ii < pups.length; ii++) {
            if (pups[ii] == null) {
                continue;
            }
            pups.position = 0;
            _powerups[ii] = Powerup.readPowerup(ByteArray(pups[ii]));
        }
        _callback();
    }

    public function create () :void
    {
        this.width = 100;
        this.height = 100;

        loadObstacles();
        var maxPowerups :int = Math.max(1, width * height / MIN_TILES_PER_POWERUP);
        _powerups = new Array(maxPowerups);

        if (_gameCtrl.isConnected()) {
            _gameCtrl.doBatch(function () :void {
                _gameCtrl.setImmediate("obstacles", new Array(_obstacles.length));
                for (var ii :int; ii < _obstacles.length; ii++) {
                    _gameCtrl.setImmediate("obstacles",
                            _obstacles[ii].writeTo(new ByteArray()), ii);
                }
                _gameCtrl.setImmediate("powerup", new Array(_powerups.length));
                _gameCtrl.setImmediate("board", writeTo(new ByteArray()));
            });
        }
        _callback();
    }

    public function createSprite (boardLayer :Sprite, ships :HashMap, status :StatusOverlay) :void
    {
        _ships = ships;
        _status = status;
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

        } else if ((event.name == "powerup") && (event.index >= 0)) {
            if (_powerups == null) {
                return;
            }
            if (event.newValue == null) {
                if (_powerups[event.index] != null) {
                    powerupLayer.removeChild(_powerups[event.index]);
                    _powerups[event.index] = null;
                    _status.removePowerup(event.index);
                }
                return;
            }

            var pow :Powerup = _powerups[event.index];
            if (pow == null) {
                _powerups[event.index] = pow = new Powerup(0, 0, 0, false);
                powerupLayer.addChild(pow);
                _status.addPowerup(event.index);
            }
            var pBytes :ByteArray = ByteArray(event.newValue);
            pBytes.position = 0;
            pow.readFrom(pBytes);
        } else if ((event.name == "obstacles") && (event.index >= 0)) {
            if (_obstacles == null) {
                return;
            }
            if (event.newValue == null) {
                if (_obstacles[event.index] != null) {
                    var obs :Obstacle = _obstacles[event.index];
                    _obstacles[event.index] = null;
                    obs.explode(function () :void {
                        _board.removeChild(obs);
                    });
                }
            }
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
        _status.updateRadar(_ships, _powerups, boardX, boardY);
    }

    /**
     * Adds a new random powerup to the board.
     */
    public function addRandomPowerup () :void
    {
        for (var ii :int = 0; ii < _powerups.length; ii++) {
            if (_powerups[ii] == null) {
                var x :int = Math.random() * width;
                var y :int = Math.random() * height;

                var repCt :int = 0;

                while (getObstacleAt(x, y) ||
                        (getPowerupIdx(x+0.5, y+0.5, x+0.5, y+0.5, 0.1) != -1)) {
                    x = Math.random() * width;
                    y = Math.random() * height;

                    // Safety valve - if we can't find anything after 100
                    //  tries, bail.
                    if (repCt++ > 100) {
                        return;
                    }
                }

                _powerups[ii] = new Powerup(Math.random()*Powerup.COUNT, x, y);

                _gameCtrl.setImmediate("powerup", _powerups[ii].writeTo(new ByteArray()), ii);
                powerupLayer.addChild(_powerups[ii]);
                _status.addPowerup(ii);
                return;
            }
        }
    }

    /**
     * Removes a powerup from the board.
     */
    public function removePowerup (idx :int) :void
    {
        _gameCtrl.setImmediate("powerup", null, idx);
        powerupLayer.removeChild(_powerups[idx]);
        _powerups[idx] = null;
        _status.removePowerup(idx);
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
        for each (var obs :Obstacle in _obstacles) {
            if (obs == null || (ignoreObs == 1 && obs.type != Obstacle.WALL)) {
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
        for each (var obs :Obstacle in _obstacles) {
            if (obs == null) {
                continue;
            }
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

    public function hitObs (
            obs :Obstacle, x :Number, y :Number, owner :Boolean, damage :Number) :Sound
    {
        explode(x, y, 0, true, 0);
        if (owner) {
            if (obs.damage(damage)) {
                _gameCtrl.setImmediate("obstacles", null, obs.index);
            }
        }

        var sound :Sound;
        switch (obs.type) {
        case Obstacle.ASTEROID_1:
        case Obstacle.ASTEROID_2:
            sound = Resources.getSound("asteroid_hit.wav");
            break;
        case Obstacle.JUNK:
            sound = Resources.getSound("junk_hit.wav");
            break;
        case Obstacle.WALL:
        default:
            sound = Resources.getSound("metal_hit.wav");
            break;
        }
        return sound;
    }


    /**
     * Draw the board.
     */
    public function setupGraphics () :void
    {
        for each (var obs :Obstacle in _obstacles) {
            if (obs != null) {
                _board.addChild(obs);
            }
        }

        _board.addChild(powerupLayer = new Sprite());
        for (var ii :int; ii < _powerups.length; ii++) {
            if (_powerups[ii] != null) {
                powerupLayer.addChild(_powerups[ii]);
                _status.addPowerup(ii);
            }
        }
    }

    public function collectPowerups (ownShip :ShipSprite, oldX :Number, oldY :Number) :void
    {
        do {
            var powIdx :int = getPowerupIdx(oldX, oldY, ownShip.boardX, ownShip.boardY,
                    Codes.SHIP_TYPES[ownShip.shipType].size);
            if (powIdx == -1) {
                break;
            }
            ownShip.awardPowerup(_powerups[powIdx]);
            removePowerup(powIdx);
        } while (powIdx != -1);
    }

    public function tick (time :int) :void
    {
        for each (var obs :Obstacle in _obstacles) {
            if (obs != null) {
                obs.tick(time);
            }
        }
    }

    /**
     * Unserialize our data from a byte array.
     */
    public function readFrom (bytes :ByteArray) :void
    {
        width = bytes.readInt();
        height = bytes.readInt();
    }

    /**
     * Serialize our data to a byte array.
     */
    public function writeTo (bytes :ByteArray) :ByteArray
    {
        bytes.writeInt(width);
        bytes.writeInt(height);

        return bytes;
    }

    /**
     * Loads all the obstacles in the world.
     */
    protected function loadObstacles () :void
    {
        _obstacles = [];

        var ii :int;
        var index :int;

        // TODO Load obstacles from a file instead of random.
        var numAsteroids :int = width*height/100;
        for (ii = 0; ii < numAsteroids; ii++) {
            var type :int = 0;
            switch (int(Math.floor(Math.random()*2.0))) {
            case 0: type = Obstacle.ASTEROID_1; break;
            case 1: type = Obstacle.ASTEROID_2; break;
            }
            _obstacles.push(new Obstacle(type, Math.random()*width, Math.random()*height));
            _obstacles[_obstacles.length - 1].index = index++;
        }

        // Place a wall around the outside of the board.

        for (ii = 0; ii < height; ii++) {
            _obstacles.push(new Obstacle(Obstacle.WALL, 0, ii));
            _obstacles[_obstacles.length - 1].index = index++;
            _obstacles.push(new Obstacle(Obstacle.WALL, width-1, ii));
            _obstacles[_obstacles.length - 1].index = index++;
        }

        for (ii = 0; ii < width; ii++) {
            _obstacles.push(new Obstacle(Obstacle.WALL, ii, 0));
            _obstacles[_obstacles.length - 1].index = index++;
            _obstacles.push(new Obstacle(Obstacle.WALL, ii, height-1));
            _obstacles[_obstacles.length - 1].index = index++;
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

    /** All the obstacles on the board. */
    protected var _obstacles :Array;

    /** Reference to the status overlay. */
    protected var _status :StatusOverlay;

    /** This could be more dynamic. */
    protected static const MIN_TILES_PER_POWERUP :int = 250;
}
}
