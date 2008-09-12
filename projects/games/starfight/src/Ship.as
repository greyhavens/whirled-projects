package {

import com.threerings.util.ClassUtil;

import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.ByteArray;
import flash.utils.Timer;

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

    public var state :int;

    public var accel :Number = 0;
    public var xVel :Number = 0;
    public var yVel :Number = 0;
    public var boardX :Number = 0;
    public var boardY :Number = 0;
    public var turnRate :Number = 0;
    public var turnAccelRate :Number = 0;
    public var rotation :Number = 0;

    public var shipId :int;
    public var shipTypeId :int;
    public var playerName :String;
    public var engineBonusPower :Number = 0;
    public var weaponBonusPower :Number = 0;
    public var primaryShotPower :Number = 1;
    public var secondaryShotPower :Number = 0;

    public function Ship (shipId :int, playerName :String)
    {
        if (ClassUtil.getClass(this) == Ship) {
            throw new Error("Ship is abstract");
        }

        this.shipId = shipId;
        this.playerName = playerName;
        setShipType(0);
    }

    public function get score () :int
    {
        return AppContext.scores.getScore(shipId);
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
        return _powerups;
    }

    /**
     * Returns true if the ship is alive.
     */
    public function get isAlive () :Boolean
    {
        return _serverData.health > DEAD && state != STATE_DEAD;
    }

    /**
     * Try to move the ship between the specified points, reacting to any
     *  collisions along the way.  This function calls itself recursively
     *  to resolve collisions created in the rebound from earlier collisions.
     */
    public function resolveMove (startX :Number, startY :Number, endX :Number, endY :Number,
        colType :int = 0) :void
    {
        var coll :Collision = AppContext.board.getCollision(startX, startY, endX, endY,
            _shipType.size, -1, colType);

        if (coll != null && coll.hit is Obstacle) {
            var obstacle :Obstacle = Obstacle(coll.hit);
            obstacle.shipCollided();
            var bounce :Number = obstacle.getElasticity();
            var dx :Number = endX - startX;
            var dy :Number = endY - startY;

            if (colType == 1) {
                // we're going to fudge these a bit so we don't end up in a wall
                boardX = startX + dx * coll.time * FUDGE_FACT;
                boardY = startY + dy * coll.time * FUDGE_FACT;
                return;
            }

            if (coll.isHoriz) {
                xVel = -xVel * bounce;
                if (coll.time < 0.1) {
                    boardX = startX;
                    boardY = startY;
                } else {
                    resolveMove(
                        startX + dx * coll.time * FUDGE_FACT, startY + dy * coll.time * FUDGE_FACT,
                        startX + dx * coll.time - dx * (1.0-coll.time) * bounce, endY);
                }
            } else { // vertical bounce
                yVel = -yVel * bounce;
                if (coll.time < 0.1) {
                    boardX = startX;
                    boardY = startY;
                } else {
                    resolveMove(
                        startX + dx * coll.time * FUDGE_FACT, startY + dy * coll.time * FUDGE_FACT,
                        endX, startY + dy * coll.time - dy * (1.0-coll.time) * bounce);
                }
            }
        } else {
            // Everything's happy - no collisions.
            boardX = endX;
            boardY = endY;
        }
    }

    public function killed () :void
    {
        state = STATE_DEAD;
    }

    public function roundEnded () :void
    {
        state = STATE_DEFAULT;
    }

    protected function spawn () :void
    {
        state = STATE_SPAWN;
        var thisShip :Ship = this;
        var timer :Timer = new Timer(SPAWN_TIME, 1);
        timer.addEventListener(TimerEvent.TIMER, function (...ignored) :void {
            thisShip.state = STATE_DEFAULT;
        });
        timer.start();
    }

    /**
     * Returns the ship's friction factor.
     */
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

        if (_reportShip != null) {
            if (_reportTime == 0) {
                _reportShip = null;
            } else {
                _reportTime = Math.max(0, _reportTime - time);
                _reportShip.update(time);
            }
        }
        primaryShotPower = Math.min(1.0, primaryShotPower + time / (1000 * _shipType.primaryPowerRecharge));
        secondaryShotPower = Math.min(1.0,
            secondaryShotPower + time / (1000 * _shipType.secondaryPowerRecharge));

        if (state != STATE_WARP_BEGIN && state != STATE_WARP_END) {
            handleTurn(time);
            handleMove(time);
        }
    }

    /**
     * Turns the ship based on the current turn acceleration over time.
     */
    protected function handleTurn (time :Number) :void
    {
        var turn :Number = 0;
        for (var etime :Number = time; etime > 0; etime -= 10) {
            var dtime :Number = Math.min(etime / 1000, 0.01);
            var turnSign :Number = (turnRate > 0 ? 1 : -1) * dtime;
            if (turnAccelRate == 0 &&
                    Math.abs(turnRate) < Constants.getShipType(shipTypeId).turnThreshold) {
                turnRate = 0;
                break;
            }
            turnRate += dtime * turnAccelRate -
                    turnSign * Constants.getShipType(shipTypeId).turnFriction * (turnRate * turnRate);
            turn += turnRate * dtime;
        }
        rotation = (rotation + turn * 5) % 360;
        if (_reportShip != null) {
            var delta :Number = _reportShip.rotation - rotation;
            if (delta > 180) {
                delta -= 360;
            } else if (delta < -180) {
                delta += 360;
            }
            rotation = Linear.easeNone(INTERPOLATION_TIME - _reportTime, rotation,
                delta, INTERPOLATION_TIME);
        }
    }

    /**
     * Move one tick's worth of distance on its current heading.
     */
    protected function handleMove (time :Number) :void
    {
        var newBoardX :Number = boardX;
        var newBoardY :Number = boardY;
        var drag :Number = _shipType.friction;
        var threshold :Number = _shipType.velThreshold;

        for (var etime :Number = time; etime > 0; etime -= 100) {
            var oldVel2 :Number = xVel*xVel + yVel*yVel;

            // if we're not accelerating and our speed is under the minimum threshold, just stop
            if (accel == 0 && oldVel2 < threshold*threshold) {
                xVel = 0;
                yVel = 0;
                break;
            }

            var xComp :Number = Math.cos(rotation * Constants.DEGS_TO_RADS);
            var yComp :Number = Math.sin(rotation * Constants.DEGS_TO_RADS);
            var dtime :Number = Math.min(etime / 1000, 0.1);
            var velDir :Number = Math.atan2(yVel, xVel);
            var fricFact :Number = drag*oldVel2;

            /*
            if (dtime < 0.1) {
                dShape.scaleX = fricFact*10;
                dShape.rotation = velDir * Codes.RADS_TO_DEGS + 180;
                aShape.scaleX = accel*10;
                aShape.rotation = ship.rotation;
            }*/
            xVel = xVel + dtime * ((accel * xComp) - (fricFact * Math.cos(velDir)));
            yVel = yVel + dtime * ((accel * yComp) - (fricFact * Math.sin(velDir)));
            /*
            if (dtime < 0.1) {
                vShape.scaleX = Math.sqrt(xVel*xVel + yVel*yVel)*10;
                vShape.rotation = Math.atan2(yVel, xVel)*Codes.RADS_TO_DEGS;
            }*/
            newBoardX += xVel * dtime;
            newBoardY += yVel * dtime;
        }

        resolveMove(boardX, boardY, newBoardX, newBoardY);

        if (_reportShip != null) {
            boardX = Linear.easeNone(INTERPOLATION_TIME - _reportTime, boardX,
                _reportShip.boardX - boardX, INTERPOLATION_TIME);
            boardY = Linear.easeNone(INTERPOLATION_TIME - _reportTime, boardY,
                _reportShip.boardY - boardY, INTERPOLATION_TIME);
        }
    }

    public function setShipType (type :int) :void
    {
        shipTypeId = type;
        _shipType = Constants.getShipType(shipTypeId);
    }

    public static function hasPowerup (powerups :int, powerupType :int) :Boolean
    {
        return Boolean(powerups & (1 << powerupType));
    }

    public function hasPowerup (type :int) :Boolean
    {
        return Ship.hasPowerup(_powerups, type);
    }

    public function canHit () :Boolean
    {
        return isAlive && state != STATE_WARP_BEGIN && state != STATE_WARP_END;
    }

    /**
     * Update our ship to the reported position, BUT if possible try to
     *  set ourselves up to make up for any discrepancy smoothly.
     */
    public function updateForReport (report :Ship) :void
    {
        _reportShip = report;
        _reportTime = INTERPOLATION_TIME;
        if (state == STATE_WARP_BEGIN || state == STATE_WARP_END) {
            return;
        }

        // Copy certain state from the report ship to the local ship. Other state
        // (position, rotation) will be interpolated into local ship over time.
        accel = report.accel;
        xVel = report.xVel;
        yVel = report.yVel;
        turnRate = report.turnRate;
        turnAccelRate = report.turnAccelRate;

        // if the ship has been re-spawned, copy all state over
        if (state == STATE_DEAD && report.state != STATE_DEAD) {
            boardX = report.boardX;
            boardY = report.boardY;
            rotation = report.rotation;
            setShipType(report.shipTypeId);

            // And re-init our server data.
            // NB - this might be a bit fragile if ShipData ever needs to be initialized
            // with different default values...
            _serverData = new ShipData();
        }

        state = report.state;
    }

    /**
     * Unserialize our data from a byte array.
     */
    public function fromBytes (bytes :ByteArray) :void
    {
        accel = bytes.readFloat();
        xVel = bytes.readFloat();
        yVel = bytes.readFloat();
        boardX = bytes.readFloat();
        boardY = bytes.readFloat();
        turnRate = bytes.readFloat();
        turnAccelRate = bytes.readFloat();
        rotation = bytes.readShort();
        setShipType(bytes.readByte());
        state = bytes.readByte();
        _powerups = bytes.readByte();
    }

    /**
     * Serialize our data to a byte array.
     */
    public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        bytes = (bytes != null ? bytes : new ByteArray());

        bytes.writeFloat(accel);
        bytes.writeFloat(xVel);
        bytes.writeFloat(yVel);
        bytes.writeFloat(boardX);
        bytes.writeFloat(boardY);
        bytes.writeFloat(turnRate);
        bytes.writeFloat(turnAccelRate);
        bytes.writeShort(rotation);
        bytes.writeByte(shipTypeId);
        bytes.writeByte(state);
        bytes.writeByte(_powerups);

        return bytes;
    }

    public function get serverData () :ShipData
    {
        return _serverData;
    }

    public function get isOwnShip () :Boolean
    {
        return false; // overridden by ClientShip
    }

    protected var _shipType :ShipType;

    protected var _reportShip :Ship;
    protected var _reportTime :int;

    protected var _powerups :int;

    protected var _serverData :ShipData = new ShipData();

    /** Ship performance characteristics. */
    protected static const SHOT_SPD :Number = 1;
    protected static const TIME_PER_SHOT :int = 330;
    protected static const SPEED_BOOST_FACTOR :Number = 1.5;
    protected static const DEAD :Number = 0.001;

    protected static const FUDGE_FACT :Number = 0.98;

    protected static const INTERPOLATION_TIME :int = 500;

    protected static const TEXT_OFFSET :int = 25;

    protected static const POWERUP_PTS :int = 2;

    protected static const SPAWN_TIME :Number = 0.5;

    protected static const ANIM_MODES :Array = [
        "ship", "retro", "thrust", "super_thrust", "super_retro", "select", "warp_begin", "warp_end"
    ];
}
}
