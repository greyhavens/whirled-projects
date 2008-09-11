package {

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.utils.ByteArray;
import flash.utils.Timer;

import net.ShipExplodedMessage;

/**
 * Represents a single ships (ours or opponent's) in the world.
 */
public class Ship extends EventDispatcher
{
    public static const COLLIDED :String = "Collided";

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

    public var accel :Number;
    public var xVel :Number;
    public var yVel :Number;
    public var boardX :Number;
    public var boardY :Number;
    public var turnRate :Number;
    public var turnAccelRate :Number;
    public var rotation :Number;

    public var shipId :int;
    public var shipTypeId :int;
    public var playerName :String;
    public var shieldHealth :Number;
    public var engineBonusPower :Number;
    public var weaponBonusPower :Number;
    public var primaryShotPower :Number;
    public var secondaryShotPower :Number;

    public function Ship ()
    {
    }

    public function init (skipStartingPos :Boolean, shipId :int, name :String, isOwnShip :Boolean)
        :void
    {
        accel = 0.0;
        turnRate = 0.0;
        turnAccelRate = 0;
        xVel = 0.0;
        yVel = 0.0;
        _health = 1.0; // full
        _powerups = 0;
        shieldHealth = 0.0;
        engineBonusPower = 0.0;
        weaponBonusPower = 0.0;
        primaryShotPower = 1.0;
        secondaryShotPower = 0.0;
        this.shipId = shipId;
        playerName = name;
        _isOwnShip = isOwnShip;
        shipTypeId = 0;

        if (!skipStartingPos) {
            var pt :Point = AppContext.board.getStartingPos();
            boardX = pt.x;
            boardY = pt.y;
        }

        setShipType(shipTypeId);
    }

    public function get score () :int
    {
        return AppContext.scores.getScore(shipId);
    }

    public function get health () :Number
    {
        return _health;
    }

    public function get shipType () :ShipType
    {
        return _shipType;
    }

    public function set firing (val :Boolean) :void
    {
        _firing = val;
    }

    public function get powerups () :int
    {
        return _powerups;
    }

    public function set secondaryFiring (val :Boolean) :void
    {
        _secondaryFiring = val;
    }

    public function turnLeft () :void
    {
        _turning = -1;
    }

    public function turnRight () :void
    {
        _turning = 1;
    }

    public function stopTurning () :void
    {
        _turning = 0;
    }

    public function moveForward () :void
    {
        _moving = 1;
    }

    public function moveBackward () :void
    {
        _moving = -1;
    }

    public function stopMoving () :void
    {
        _moving = 0;
    }

    public static function hasPowerup (powerups :int, powerupType :int) :Boolean
    {
        return Boolean(powerups & (1 << powerupType));
    }

    public function hasPowerup (type :int) :Boolean
    {
        return Ship.hasPowerup(_powerups, type);
    }

    public function addPowerup (type :int) :void
    {
        _powerups |= (1 << type);
    }

    public function removePowerup (type :int) :void
    {
        _powerups &= ~(1 << type);
    }

    public function get isOwnShip () :Boolean
    {
        return _isOwnShip;
    }

    /**
     * Returns true if the ship is alive.
     */
    public function get isAlive () :Boolean
    {
        return _health > DEAD && state != STATE_DEAD;
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

    /**
     * Registers that the ship was hit.
     */
    public function hit (shooterId :int, damage :Number) :void
    {
        // Already dead, don't bother.
        if (!isAlive) {
            return;
        }

        var hitPower :Number = damage / _shipType.armor;

        if (hasPowerup(Powerup.SHIELDS)) {
            // shields always have an armor of 0.5
            hitPower = damage * 2;
            shieldHealth -= hitPower;
            if (shieldHealth <= DEAD) {
                removePowerup(Powerup.SHIELDS);
            }
            return;
        }

        _health -= hitPower;
        if (_health <= DEAD) {
            AppContext.msgs.sendMessage(ShipExplodedMessage.create(shipId, shooterId, boardX,
                boardY, rotation));
            checkAwards();

            // Stop moving and firing.
            xVel = 0;
            yVel = 0;
            turnRate = 0;
            turnAccelRate = 0;
            accel = 0;
            _firing = false;
            _secondaryFiring = false;
            stopTurning();
            stopMoving();
            _deaths++;
        }
    }

    /**
     * Called when we kill someone.
     */
    public function registerKill (shipId :int) :void
    {
        _kills++;
        _killsThisLife++;
        if (AppContext.game.numShips() >= 3) {
            _killsThisLife3++;
        }
        _enemiesKilled[shipId] = true;
    }

    public function kill () :void
    {
        state = STATE_DEAD;
    }

    /**
     * Positions the ship at a brand new spot after exploding and resets its dynamics.
     */
    public function restart () :void
    {
        _health = 1.0; //full
        _powerups = 0;
        var pt :Point = AppContext.board.getStartingPos();
        boardX = pt.x;
        boardY = pt.y;
        xVel = 0;
        yVel = 0;
        turnRate = 0;
        turnAccelRate = 0;
        accel = 0;
        rotation = 0;
        shieldHealth = 0.0;
        weaponBonusPower = 0.0;
        engineBonusPower = 0.0;
        primaryShotPower = 1.0;
        secondaryShotPower = 0.0;
        _killsThisLife = 0;
        _killsThisLife3 = 0;
        _powerupsThisLife = false;

        spawn();
    }

    public function roundEnded () :void
    {
        state = STATE_DEFAULT;
        checkAwards(true);
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
            if (_isOwnShip) {
                // update move and turn acceleration if this ship is under our control
                if (_turning < 0) {
                    turnAccelRate = -_shipType.turnAccel;
                } else if (_turning > 0) {
                    turnAccelRate = _shipType.turnAccel;
                } else {
                    turnAccelRate = 0;
                }

                if (_moving < 0) {
                    accel = _shipType.backwardAccel;
                } else if (_moving > 0) {
                    accel = _shipType.forwardAccel;
                } else {
                    accel = 0;
                }

                if (hasPowerup(Powerup.SPEED)) {
                    accel *= SPEED_BOOST_FACTOR;
                }
            }

            handleTurn(time);
            handleMove(time);
        }

        if (_ticksToFire > 0) {
            _ticksToFire -= time;
        }
        if (_firing && (_ticksToFire <= 0) &&
                (primaryShotPower >= _shipType.getPrimaryShotCost(this))) {
            handleFire();
        }

        if (_ticksToSecondary > 0) {
            _ticksToSecondary -= time;
        }
        if (_secondaryFiring && (_ticksToSecondary <= 0) &&
                (secondaryShotPower >= _shipType.secondaryShotCost)) {
            handleSecondaryFire();
        }
    }

    protected function handleFire () :void
    {
        _shipType.sendPrimaryShotMessage(this);
        if (hasPowerup(Powerup.SPREAD)) {
            weaponBonusPower -= 0.03;
            if (weaponBonusPower <= 0.0) {
                removePowerup(Powerup.SPREAD);
            }
        }

        _ticksToFire = _shipType.primaryShotRecharge * 1000;
        primaryShotPower -= _shipType.getPrimaryShotCost(this);
    }

    protected function handleSecondaryFire () :void
    {
        if (_shipType.sendSecondaryShotMessage(this)) {
            _ticksToSecondary = _shipType.secondaryShotRecharge * 1000;
            secondaryShotPower -= _shipType.secondaryShotCost;
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

        if (_isOwnShip && accel != 0 && hasPowerup(Powerup.SPEED)) {
            engineBonusPower -= time / 30000;
            if (engineBonusPower <= 0) {
                removePowerup(Powerup.SPEED);
                accel = Math.min(accel, _shipType.forwardAccel);
                accel = Math.max(accel, _shipType.backwardAccel);
            }
        }
    }

    public function setShipType (type :int) :void
    {
        shipTypeId = type;
        _shipType = Constants.getShipType(shipTypeId);
    }

    /**
     * Give a powerup to the ship.
     */
    public function awardPowerup (powerup :Powerup) :void
    {
        _powerupsThisLife = true;
        AppContext.scores.addToScore(shipId, POWERUP_PTS);
        powerup.consume();
        if (powerup.type == Powerup.HEALTH) {
            _health = Math.min(1.0, _health + 0.5);
            return;
        }
        _powerups |= (1 << powerup.type);
        switch (powerup.type) {
        case Powerup.SHIELDS:
            shieldHealth = 1.0;
            break;
        case Powerup.SPEED:
            engineBonusPower = 1.0;
            break;
        case Powerup.SPREAD:
            weaponBonusPower = 1.0;
            break;
        }
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
        //_power = report._power;
        _powerups = report._powerups;

        if (state != report.state) {
            state = report.state;
            _health = report._health;
        }

        // if our ship type has changed, copy all state over
        if (shipTypeId != report.shipTypeId) {
            boardX = report.boardX;
            boardY = report.boardY;
            rotation = report.rotation;
            setShipType(report.shipTypeId);
        }
    }

    /**
     * Unserialize our data from a byte array.
     */
    public function readFrom (bytes :ByteArray) :void
    {
        accel = bytes.readFloat();
        xVel = bytes.readFloat();
        yVel = bytes.readFloat();
        boardX = bytes.readFloat();
        boardY = bytes.readFloat();
        turnRate = bytes.readFloat();
        turnAccelRate = bytes.readFloat();
        rotation = bytes.readShort();
        _health = bytes.readFloat();
        _powerups = bytes.readInt();
        setShipType(bytes.readInt());
        state = bytes.readByte();
    }

    /**
     * Serialize our data to a byte array.
     */
    public function writeTo (bytes :ByteArray) :ByteArray
    {
        bytes.writeFloat(accel);
        bytes.writeFloat(xVel);
        bytes.writeFloat(yVel);
        bytes.writeFloat(boardX);
        bytes.writeFloat(boardY);
        bytes.writeFloat(turnRate);
        bytes.writeFloat(turnAccelRate);
        bytes.writeShort(rotation);
        bytes.writeFloat(_health);
        bytes.writeInt(_powerups);
        bytes.writeInt(shipTypeId);
        bytes.writeByte(state);

        return bytes;
    }

    protected function checkAwards (gameOver :Boolean = false) :void
    {
        if (!isOwnShip) {
            return;
        }

        if (_killsThisLife >= 10 && !_powerupsThisLife) {
            AppContext.game.awardTrophy("fly_by_wire");
        }
        if (_killsThisLife3 >= 10) {
            AppContext.game.awardTrophy(_shipType.name + "_pilot");
        }

        // see if we've killed 7 other poeple currently playing
        var bogey :int = 0;
        for (var id :String in _enemiesKilled) {
            if (AppContext.game.getShip(int(_enemiesKilled[id])) != null) {
                bogey++;
            }
        }
        if (bogey >= 7) {
            AppContext.game.awardTrophy("bogey_hunter");
        }

        if (gameOver && AppContext.game.numShips() >= 8 && _kills / _deaths >= 4) {
            AppContext.game.awardTrophy("space_ace");
        }

        if (AppContext.game.numShips() < 3) {
            return;
        }

        var myScore :int = this.score;
        if (myScore >= 500) {
            AppContext.game.awardTrophy("score1");
        }
        if (myScore >= 1000) {
            AppContext.game.awardTrophy("score2");
        }
        if (myScore >= 1500) {
            AppContext.game.awardTrophy("score3");
        }
    }

    protected var _firing :Boolean;
    protected var _ticksToFire :int = 0;
    protected var _secondaryFiring :Boolean;
    protected var _ticksToSecondary :int = 0;
    protected var _turning :int; // < 0 = left, > 0 = right, 0 = not turning
    protected var _moving :int;  // < 0 = backwards, > 0 = forwards, 0 = not moving

    /** Whether this is ourselves. */
    protected var _isOwnShip :Boolean;

    /** A reference to the ship type class. */
    protected var _shipType :ShipType;

    protected var _reportShip :Ship;
    protected var _reportTime :int;

    /** All the powerups we've got. */
    protected var _powerups :int;

    /** Our current health */
    protected var _health :Number;

    /** Trophy stats. */
    protected var _killsThisLife :int;
    protected var _killsThisLife3 :int;
    protected var _enemiesKilled :Object = new Object();
    protected var _powerupsThisLife :Boolean = false;
    protected var _kills :int;
    protected var _deaths :int;

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
