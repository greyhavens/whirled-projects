package {

import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.whirled.game.GameControl;
import com.whirled.net.ElementChangedEvent;

import flash.geom.Point;
import flash.utils.ByteArray;

/**
 * Manages the board data and display sprite.
 */
public class BoardController
{
    /** Board size in tiles. */
    public var width :int;
    public var height :int;

    /**
     * Constructs a brand new board.
     */
    public function BoardController (gameCtrl :GameControl)
    {
        _gameCtrl = gameCtrl;
        _gameCtrl.net.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, elementChanged);
    }

    public function shutdown () :void
    {
        _gameCtrl.net.removeEventListener(ElementChangedEvent.ELEMENT_CHANGED, elementChanged);
    }

    public function loadBoard (boardLoadedCallback :Function) :void
    {
        throw new Error("subclasses must implement loadBoard()");
    }

    public function roundEnded () :void
    {
        _obstacles = null;
        _powerups = null;
        _mines = null;
    }

    protected function elementChanged (event :ElementChangedEvent) :void
    {
        if ((event.name == Constants.PROP_POWERUPS) && (event.index >= 0) && _powerups != null) {
            if (event.newValue == null) {
                if (_powerups[event.index] != null) {
                    powerupRemoved(event.index);
                }

            } else {
                if (_powerups[event.index] != null) {
                    powerupRemoved(event.index);
                }
                var pBytes :ByteArray = ByteArray(event.newValue);
                pBytes.position = 0;
                powerupAdded(Powerup.readPowerup(pBytes), event.index);
            }

        } else if ((event.name == Constants.PROP_OBSTACLES) && (event.index >= 0)) {
            if (event.newValue == null) {
                obstacleRemoved(event.index);
            }

            // obstacles are never created during game play

        } else if ((event.name == Constants.PROP_MINES) && (event.index >= 0)) {
            if (event.newValue == null) {
                mineRemoved(event.index);
            }

            // don't listen to "new mine" events (event.newValue != null) - mines will
            // be added to the board when the Saucer's secondary fire is used
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
            if (getCollision(pt.x, pt.y, pt.x, pt.y, Ship.COLLISION_RAD, -1, 0) == null) {
                return pt;
            }
        }

        // Should never reach here.
        return null;
    }

    protected function powerupAdded (powerup :Powerup, index :int) :void
    {
        _powerups[index] = powerup;
    }

    /**
     * Removes a powerup from the board.
     */
    public function removePowerup (idx :int) :void
    {
        setAtImmediate(Constants.PROP_POWERUPS, null, idx);
        powerupRemoved(idx);
    }

    protected function powerupRemoved (index :int) :void
    {
        var powerup :Powerup = _powerups[index];
        if (powerup != null) {
            _powerups[index] = null;
            powerup.destroyed();
        }
    }

    protected function obstacleAdded (obstacle :Obstacle, index :int) :void
    {
    }

    protected function obstacleRemoved (index :int) :void
    {
        if (_obstacles != null) {
            var obs :Obstacle = _obstacles[index];
            if (obs != null) {
                _obstacles[index] = null;
            }
        }
    }

    /**
     * Adds a mine to the board.
     */
    public function addMine (mine :Mine) :int
    {
        var freeIndex :int = -1;
        for (var index :int = 0; index < _mines.length; index++) {
            if (_mines[index] == null) {
                freeIndex = index;
                break;
            }
        }

        // there's no place to put this mine.
        // TODO: something more intelligent here (explode the oldest mine?)
        if (freeIndex < 0) {
            log.warning("No room for this mine! Discarding.");
            return -1;
        }

        _mines[freeIndex] = mine;
        mineAdded(mine);

        return freeIndex;
    }

    protected function mineAdded (mine :Mine) :void
    {
    }

    /**
     * Removes a mine from the board.
     */
    public function removeMine (idx :int) :void
    {
        if (_mines != null) {
            mineRemoved(idx);
        }
    }

    protected function mineRemoved (idx :int) :void
    {
        var mine :Mine = _mines[idx];
        if (mine != null) {
            _mines[idx] = null;
            mine.explode();
        }
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
            for each (var ship :Ship in AppContext.game.ships.values()) {
                if (ship == null) {
                    continue;
                }

                if (!ship.canHit() || ship.shipId == ignoreShip || (dx == 0 && dy == 0)) {
                    continue;
                }

                var bX :Number = ship.boardX;
                var bY :Number = ship.boardY;
                var r :Number = Ship.COLLISION_RAD + rad;
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
        if (ignoreObs == 2) {
            return bestHit;
        }

        // Check each obstacle and figure out which one we hit first.
        for each (var obs :Obstacle in _obstacles) {
            if (obs == null || (ignoreObs == 1 && obs.type != Obstacle.WALL)) {
                continue;
            }
            bestHit = findBestHit(oldX, oldY, dx, dy, rad, obs, bestHit);
        }

        return bestHit;
    }

    protected function findBestHit (oldX :Number, oldY :Number, dx :Number, dy :Number, rad :Number,
            obj :BoardObject, col :Collision) :Collision
    {
        // Find how long it is til our X coords collide.
        var timeToX :Number;
        if (dx > 0.0) {
            timeToX = (obj.bX - (oldX+rad))/dx;
        } else if (dx < 0.0) {
            timeToX = ((obj.bX+1.0) - (oldX-rad))/dx;
        } else if ((oldX+rad >= obj.bX) && (oldX-rad <= obj.bX+1.0)) {
            timeToX = -1.0; // already there.
        } else {
            timeToX = 2.0; // doesn't hit.
        }

        // Find how long it is til our Y coords collide.
        var timeToY :Number;
        if (dy > 0.0) {
            timeToY = (obj.bY - (oldY+rad))/dy;
        } else if (dy < 0.0) {
            timeToY = ((obj.bY+1.0) - (oldY-rad))/dy;
        } else if ((oldY+rad >= obj.bY) && (oldY-rad <= obj.bY+1.0)) {
            timeToY = -1.0; // already there.
        } else {
            timeToY = 2.0; // doesn't hit.
        }

        // Update our bestTime if this is a legitimate collision and is before any
        //  others we've found.
        var time :Number = Math.max(timeToX, timeToY);
        var bestTime :Number = (col == null ? 1.0 : col.time);
        if (time >= 0.0 && time <= 1.0 && time < bestTime &&
            ((timeToX >= 0.0 || (oldX+rad >= obj.bX) && (oldX-rad <= obj.bX+1.0))) &&
            ((timeToY >= 0.0 || (oldY+rad >= obj.bY) && (oldY-rad <= obj.bY+1.0)))){
            return new Collision(obj, time, timeToX > timeToY);
        }
        return col;
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

    public function getObjectIdx (oldX :Number, oldY :Number,
        newX :Number, newY :Number, rad :Number, array :Array) :int
    {
        /** The first one we've seen so far. */
        var bestTime :Number = 1.0;
        var bestHit :int = -1;

        var dx :Number = newX - oldX;
        var dy :Number = newY - oldY;

        // Check each powerup and figure out which one we hit first.
        for (var ii :int; ii < array.length; ii++) {
            var bo :BoardObject = BoardObject(array[ii]);
            if (bo == null) {
                continue;
            }
            var bX :Number = bo.bX + 0.5;
            var bY :Number = bo.bY + 0.5;
            var r :Number = rad + bo.radius; // Our radius...
            // We approximate a board object as a circle for this...
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

    public function shipKilled (shipId :int) :void
    {
        for each (var mineIndex :int in getShipMineIndices(shipId)) {
            removeMine(mineIndex);
        }
    }

    protected function getShipMineIndices (shipId :int) :Array
    {
        var indices :Array = [];
        for (var ii :int = 0; ii < _mines.length; ii++) {
            if (_mines[ii] != null && Mine(_mines[ii]).ownerId == shipId) {
                indices.push(ii);
            }
        }

        return indices;
    }

    public function hitObs (obj :BoardObject, x :Number, y :Number, owner :Boolean,
        damage :Number) :void
    {
        if (owner) {
            if (AppContext.game.gameState == Constants.STATE_IN_ROUND && obj.damage(damage)) {
                setAtImmediate(obj.arrayName, null, obj.index);
            }
        }
    }

    public function update (time :int) :void
    {
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
            _obstacles.push(new Obstacle(
                type, 1 + Math.random()*(width-2), 1+Math.random()*(height-2)));
            _obstacles[_obstacles.length - 1].index = index++;
        }

        // Place a wall around the outside of the board.

        for (ii = 0; ii < height; ii++) {
            if (ii == 0) {
                _obstacles.push(new Obstacle(Obstacle.WALL, 0, ii, 1, height));
            } else {
                _obstacles.push(new Obstacle(Obstacle.WALL, 0, ii));
            }
            _obstacles[_obstacles.length - 1].index = index++;
            if (ii == 0) {
                _obstacles.push(new Obstacle(Obstacle.WALL, width-1, ii, 1, height));
            } else {
                _obstacles.push(new Obstacle(Obstacle.WALL, width-1, ii));
            }
            _obstacles[_obstacles.length - 1].index = index++;
        }

        for (ii = 0; ii < width; ii++) {
            if (ii == 0) {
                _obstacles.push(new Obstacle(Obstacle.WALL, ii, 0, width, 1));
            } else {
                _obstacles.push(new Obstacle(Obstacle.WALL, ii, 0));
            }
            _obstacles[_obstacles.length - 1].index = index++;
            if (ii == 0) {
                _obstacles.push(new Obstacle(Obstacle.WALL, ii, height-1, width, 1));
            } else {
                _obstacles.push(new Obstacle(Obstacle.WALL, ii, height-1));
            }
            _obstacles[_obstacles.length - 1].index = index++;
        }
    }

    protected function setImmediate (propName :String, value :Object) :void
    {
        _gameCtrl.net.set(propName, value, true);
    }

    protected function setAtImmediate (propName :String, value :Object, index :int) :void
    {
        _gameCtrl.net.setAt(propName, index, value, true);
    }

    protected var _gameCtrl :GameControl;

    /** Reference to the array of powerups we know about. */
    protected var _powerups :Array;

    /** All the obstacles on the board. */
    protected var _obstacles :Array;

    /** All the mines on the board. */
    protected var _mines :Array;

    protected static const log :Log = Log.getLog(BoardController);

    /** This could be more dynamic. */
    protected static const MIN_TILES_PER_POWERUP :int = 250;

    protected static const MAX_MINES :int = 128;
}
}
