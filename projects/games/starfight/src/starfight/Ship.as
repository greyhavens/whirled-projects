package starfight {

import com.threerings.util.ClassUtil;
import com.whirled.contrib.TimerManager;

/**
 * Represents a single ships (ours or opponent's) in the world.
 */
public class Ship
{
    public static const RESPAWN_DELAY :int = 3000;

    /** The size of the ship. */
    public static const WIDTH :int = 40;
    public static const HEIGHT :int = 40;
    public static const COLLISION_RAD :Number = 0.9;

    /** Ship states. */
    public static const STATE_DEFAULT :int = 0;
    public static const STATE_SPAWN :int = 1;
    public static const STATE_WARP_BEGIN :int = 2;
    public static const STATE_WARP_END :int = 3;
    public static const STATE_DEAD :int = 4;

    public function Ship (shipId :int, playerName :String, clientData :ClientShipData = null)
    {
        if (ClassUtil.getClass(this) == Ship) {
            throw new Error("Ship is abstract");
        }

        _shipId = shipId;
        _playerName = playerName;
        _clientData = (clientData != null ? clientData : new ClientShipData());
        setShipType(_clientData.shipTypeId);

        initTimers();
    }

    public function get isAlive () :Boolean
    {
        return _serverData.health > DEAD && _clientData.state != STATE_DEAD;
    }

    public function killed () :void
    {
        _clientData.state = STATE_DEAD;
    }

    public function roundEnded () :void
    {
        _clientData.state = STATE_DEFAULT;
    }

    public function getFriction () :Number
    {
        return _shipType.friction;
    }

    /**
     * Process the movement of the ship for this timestep.
     */
    public function update (time :int) :void
    {
        if (!isAlive) {
            return;
        }

        // update our own movement
        updateMovement(time, _clientData);

        if (_reportShip != null) {
            if (_reportTime == 0) {
                _reportShip = null;

            } else {
                // update _reportShip's movement
                _reportTime = Math.max(0, _reportTime - time);
                updateMovement(time, _reportShip);

                // interpolate _reportShip's movement into our own movement
                interpolateMovement(_clientData, _reportShip, _reportTime);
            }
        }
    }

    protected static function interpolateMovement (data :ClientShipData,
        reportData :ClientShipData, reportTime :Number) :void
    {
        // rotation
        var delta :Number = reportData.rotation - data.rotation;
        if (delta > 180) {
            delta -= 360;
        } else if (delta < -180) {
            delta += 360;
        }
        data.rotation = Linear.easeNone(INTERPOLATION_TIME - reportTime, data.rotation, delta,
            INTERPOLATION_TIME);

        // location
        data.boardX = Linear.easeNone(INTERPOLATION_TIME - reportTime, data.boardX,
            reportData.boardX - data.boardX, INTERPOLATION_TIME);
        data.boardY = Linear.easeNone(INTERPOLATION_TIME - reportTime, data.boardY,
            reportData.boardY - data.boardY, INTERPOLATION_TIME);
    }

    protected static function updateMovement (time :Number, data :ClientShipData) :void
    {
        if (data.state != STATE_WARP_BEGIN && data.state != STATE_WARP_END) {
            handleTurn(time, data);
            handleMove(time, data);
        }
    }

    /**
     * Turns the ship based on the current turn acceleration over time.
     */
    protected static function handleTurn (time :Number, data :ClientShipData) :void
    {
        var shipType :ShipType = Constants.getShipType(data.shipTypeId);
        var turn :Number = 0;
        for (var etime :Number = time; etime > 0; etime -= 10) {
            var dtime :Number = Math.min(etime / 1000, 0.01);
            var turnSign :Number = (data.turnRate > 0 ? 1 : -1) * dtime;
            if (data.turnAccelRate == 0 && Math.abs(data.turnRate) < shipType.turnThreshold) {
                data.turnRate = 0;
                break;
            }

            data.turnRate += (dtime * data.turnAccelRate) -
                turnSign * shipType.turnFriction * (data.turnRate * data.turnRate);
            turn += data.turnRate * dtime;
        }

        data.rotation = (data.rotation + turn * 5) % 360;
    }

    /**
     * Move one tick's worth of distance on its current heading.
     */
    protected static function handleMove (time :Number, data :ClientShipData) :void
    {
        var shipType :ShipType = Constants.getShipType(data.shipTypeId);

        var newBoardX :Number = data.boardX;
        var newBoardY :Number = data.boardY;
        var drag :Number = shipType.friction;
        var threshold :Number = shipType.velThreshold;

        for (var etime :Number = time; etime > 0; etime -= 100) {
            var oldVel2 :Number = data.xVel*data.xVel + data.yVel*data.yVel;

            // if we're not data.accelerating and our speed is under the minimum threshold, just stop
            if (data.accel == 0 && oldVel2 < threshold*threshold) {
                data.xVel = 0;
                data.yVel = 0;
                break;
            }

            var xComp :Number = Math.cos(data.rotation * Constants.DEGS_TO_RADS);
            var yComp :Number = Math.sin(data.rotation * Constants.DEGS_TO_RADS);
            var dtime :Number = Math.min(etime / 1000, 0.1);
            var velDir :Number = Math.atan2(data.yVel, data.xVel);
            var fricFact :Number = drag*oldVel2;

            /*
            if (dtime < 0.1) {
                dShape.scaleX = fricFact*10;
                dShape.data.rotation = velDir * Codes.RADS_TO_DEGS + 180;
                aShape.scaleX = data.accel*10;
                aShape.data.rotation = ship.data.rotation;
            }*/
            data.xVel = data.xVel + dtime * ((data.accel * xComp) - (fricFact * Math.cos(velDir)));
            data.yVel = data.yVel + dtime * ((data.accel * yComp) - (fricFact * Math.sin(velDir)));
            /*
            if (dtime < 0.1) {
                vShape.scaleX = Math.sqrt(data.xVel*data.xVel + data.yVel*data.yVel)*10;
                vShape.data.rotation = Math.atan2(data.yVel, data.xVel)*Codes.RADS_TO_DEGS;
            }*/
            newBoardX += data.xVel * dtime;
            newBoardY += data.yVel * dtime;
        }

        resolveMove(data, data.boardX, data.boardY, newBoardX, newBoardY);
    }

    /**
     * Try to move the ship between the specified points, reacting to any
     *  collisions along the way.  This function calls itself recursively
     *  to resolve collisions created in the rebound from earlier collisions.
     */
    public static function resolveMove (data :ClientShipData, startX :Number, startY :Number,
        endX :Number, endY :Number, colType :int = 0) :void
    {
        var shipType :ShipType = Constants.getShipType(data.shipTypeId);
        var coll :Collision = AppContext.board.getCollision(startX, startY, endX, endY,
            shipType.size, -1, colType);

        if (coll != null && coll.hit is Obstacle) {
            var obstacle :Obstacle = Obstacle(coll.hit);
            obstacle.shipCollided();
            var bounce :Number = obstacle.getElasticity();
            var dx :Number = endX - startX;
            var dy :Number = endY - startY;

            if (colType == 1) {
                // we're going to fudge these a bit so we don't end up in a wall
                data.boardX = startX + dx * coll.time * FUDGE_FACT;
                data.boardY = startY + dy * coll.time * FUDGE_FACT;
                return;
            }

            if (coll.isHoriz) {
                data.xVel = -data.xVel * bounce;
                if (coll.time < 0.1) {
                    data.boardX = startX;
                    data.boardY = startY;
                } else {
                    resolveMove(data,
                        startX + dx * coll.time * FUDGE_FACT, startY + dy * coll.time * FUDGE_FACT,
                        startX + dx * coll.time - dx * (1.0-coll.time) * bounce, endY);
                }
            } else { // vertical bounce
                data.yVel = -data.yVel * bounce;
                if (coll.time < 0.1) {
                    data.boardX = startX;
                    data.boardY = startY;
                } else {
                    resolveMove(data,
                        startX + dx * coll.time * FUDGE_FACT, startY + dy * coll.time * FUDGE_FACT,
                        endX, startY + dy * coll.time - dy * (1.0-coll.time) * bounce);
                }
            }
        } else {
            // Everything's happy - no collisions.
            data.boardX = endX;
            data.boardY = endY;
        }
    }

    public function setShipType (type :int) :void
    {
        _clientData.shipTypeId = type;
        _shipType = Constants.getShipType(_clientData.shipTypeId);
    }

    public static function hasPowerup (powerups :int, powerupType :int) :Boolean
    {
        return Boolean(powerups & (1 << powerupType));
    }

    public function hasPowerup (type :int) :Boolean
    {
        return Ship.hasPowerup(_clientData.powerups, type);
    }

    public function canHit () :Boolean
    {
        return isAlive && _clientData.state != STATE_WARP_BEGIN && _clientData.state != STATE_WARP_END;
    }

    /**
     * Update our ship to the reported position, BUT if possible try to
     *  set ourselves up to make up for any discrepancy smoothly.
     */
    public function updateForReport (report :ClientShipData) :void
    {
        // if the ship is dead, and it receives an update that changes its _clientData.state to alive
        // without incrementing _numLives, it means the ship has been exploded by the server,
        // but the client in charge of it has not yet gotten that message and is sending old data
        // that should be ignored
        if (_clientData.state == STATE_DEAD && report.state != STATE_DEAD &&
            _clientData.numLives >= report.numLives) {
            return;
        }

        _reportShip = report;
        _reportTime = INTERPOLATION_TIME;
        if (_clientData.state == STATE_WARP_BEGIN || _clientData.state == STATE_WARP_END) {
            return;
        }

        // Copy certain _clientData.state from the report ship to the local ship. Other _clientData.state
        // (position, _clientData.rotation) will be interpolated into local ship over time.
        _clientData.accel = report.accel;
        _clientData.xVel = report.xVel;
        _clientData.yVel = report.yVel;
        _clientData.turnRate = report.turnRate;
        _clientData.turnAccelRate = report.turnAccelRate;
        _clientData.powerups = report.powerups;

        // if the ship has been re-spawned, copy all _clientData.state over
        if (_clientData.numLives < report.numLives) {
            _clientData.boardX = report.boardX;
            _clientData.boardY = report.boardY;
            _clientData.rotation = report.rotation;
            _clientData.numLives = report.numLives;
            setShipType(report.shipTypeId);

            // And re-init our server data.
            // NB - this might be a bit fragile if ShipData ever needs to be initialized
            // with different default values...
            _serverData = new ServerShipData();

            // re-init our timers
            initTimers();
        }

        _clientData.state = report.state;
    }

    public function get serverData () :ServerShipData
    {
        return _serverData;
    }

    public function get clientData () :ClientShipData
    {
        return _clientData;
    }

    public function get isOwnShip () :Boolean
    {
        return false; // overridden by ClientShip
    }

    public function runOnce (delay :Number, callback :Function) :void
    {
        _timers.runOnce(delay, callback);
    }

    protected function initTimers () :void
    {
        shutdownTimers();
        _timers = new TimerManager(AppContext.game.timers);
    }

    protected function shutdownTimers () :void
    {
        if (_timers != null) {
            _timers.shutdown();
            _timers = null;
        }
    }

    public function get shipId () :int
    {
        return _shipId;
    }

    public function get playerName () :String
    {
        return _playerName;
    }

    public function get score () :int
    {
        return AppContext.scores.getScore(_shipId);
    }

    public function get health () :Number
    {
        return _serverData.health;
    }

    public function get shieldHealth () :Number
    {
        return _serverData.shieldHealth;
    }

    public function get shipType () :ShipType
    {
        return _shipType;
    }

    public function get powerups () :int
    {
        return _clientData.powerups;
    }

    public function get accel () :Number
    {
        return _clientData.accel;
    }

    public function get xVel () :Number
    {
        return _clientData.xVel
    }

    public function get yVel () :Number
    {
        return _clientData.yVel;
    }

    public function get boardX () :Number
    {
        return _clientData.boardX;
    }

    public function get boardY () :Number
    {
        return _clientData.boardY;
    }

    public function get rotation () :Number
    {
        return _clientData.rotation;
    }

    public function get state () :int
    {
        return _clientData.state;
    }

    public function get shipTypeId () :int
    {
        return _clientData.shipTypeId;
    }

    protected var _shipId :int;
    protected var _playerName :String;

    protected var _clientData :ClientShipData;
    protected var _serverData :ServerShipData = new ServerShipData();

    protected var _reportShip :ClientShipData;
    protected var _reportTime :int;

    protected var _shipType :ShipType;

    protected var _timers :TimerManager;

    /** Ship performance characteristics. */
    protected static const SHOT_SPD :Number = 1;
    protected static const TIME_PER_SHOT :int = 330;
    protected static const SPEED_BOOST_FACTOR :Number = 1.5;
    protected static const DEAD :Number = 0.001;

    protected static const FUDGE_FACT :Number = 0.98;

    protected static const INTERPOLATION_TIME :int = 500;

    protected static const POWERUP_PTS :int = 2;

    protected static const SPAWN_TIME :Number = 0.5;
}
}
