package {

import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.media.Sound;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.ByteArray;
import flash.utils.Timer;

import mx.effects.easing.Linear;

import view.GameView;
import view.ShipChooser;

/**
 * Represents a single ships (ours or opponent's) in the world.
 */
public class ShipSprite extends Sprite
{
    /** Some useful key codes. */
    public static const KV_LEFT :uint = 37;
    public static const KV_UP :uint = 38;
    public static const KV_RIGHT :uint = 39;
    public static const KV_DOWN :uint = 40;
    public static const KV_SPACE :uint = 32;
    public static const KV_ENTER :uint = 13;
    public static const KV_A :uint = 65;
    public static const KV_B :uint = 66;
    public static const KV_D :uint = 68;
    public static const KV_S :uint = 83;
    public static const KV_W :uint = 87;
    public static const KV_X :uint = 88;
    public static const KV_SHIFT :uint = 16;

    /** The size of the ship. */
    public static const WIDTH :int = 40;
    public static const HEIGHT :int = 40;
    public static const COLLISION_RAD :Number = 0.9;

    /** Powerup flags. */
    public static const SPEED_MASK :int = 1 << Powerup.SPEED;
    public static const SPREAD_MASK :int = 1 << Powerup.SPREAD;
    public static const SHIELDS_MASK :int = 1 << Powerup.SHIELDS;

    /** "frames" within the actionscript for movement animations. */
    public static const IDLE :int = 0;
    public static const FORWARD :int = 2;
    public static const REVERSE :int = 1;
    public static const FORWARD_FAST :int = 3;
    public static const REVERSE_FAST :int = 4;
    public static const SELECT :int = 5;
    public static const WARP_BEGIN :int = 6;
    public static const WARP_END :int = 7;

    /** How fast the ship is accelerating. */
    public var accel :Number;

    /** The ship's instantaneous velocity. */
    public var xVel :Number;
    public var yVel :Number;

    /** The location of the ship on the board. */
    public var boardX :Number;
    public var boardY :Number;

    /** How fast are we currently turning. */
    public var turnRate :Number;
    public var turnAccelRate :Number;

    /** Our current health */
    public var power :Number;

    /** All the powerups we've got. */
    public var powerups :int;

    /** our id. */
    public var shipId :int;

    /** Type of ship we're using. */
    public var shipType :int;

    /** The sprite with our ship graphics in it. */
    public var ship :Sprite;

    /** The player name for the ship. */
    public var playerName :String;

    /** The ship's current score. */
    public var score :int;

    /** Shield health. */
    public var shieldPower :Number;

    /** Engine bonus remaining. */
    public var enginePower :Number;

    /** Weapons bonus remaining. */
    public var weaponPower :Number;

    /** Primary shot power. */
    public var primaryPower :Number;

    /** Secondary shot power. */
    public var secondaryPower :Number;

    public var aShape :Shape, dShape :Shape, vShape :Shape;

    /**
     * Constructs a new ship.  If skipStartingPos, don't bother finding an
     *  empty space to start in.
     */
    public function ShipSprite (board :BoardController,
        skipStartingPos :Boolean, shipId :int, name :String,
        isOwnShip :Boolean)
    {
        visible = skipStartingPos;
        accel = 0.0;
        turnRate = 0.0;
        turnAccelRate = 0;
        xVel = 0.0;
        yVel = 0.0;
        power = 1.0; // full
        powerups = 0;
        score = 0;
        shieldPower = 0.0;
        enginePower = 0.0;
        weaponPower = 0.0;
        primaryPower = 1.0;
        secondaryPower = 0.0;
        this.shipId = shipId;
        playerName = name;
        _isOwnShip = isOwnShip;
        shipType = 0;

        if (isOwnShip) {
            _shieldSound = new SoundLoop(Resources.getSound("shields.wav"));
            _thrusterForward = new SoundLoop(Resources.getSound("thruster.wav"));
            _thrusterReverse = new SoundLoop(Resources.getSound("thruster_retro2.wav"));
        }

        if (!skipStartingPos) {
            var pt :Point = board.getStartingPos();
            boardX = pt.x;
            boardY = pt.y;
        }

        _board = board;

        /** Used to rotate our ship itself without touching associated info. */
        ship = new Sprite();
        addChild(ship);

        /* Show acceleration, drag and velocity vectors for debugging
        aShape = new Shape();
        aShape.graphics.clear();
        aShape.graphics.beginFill(0XFF0000);
        aShape.graphics.drawRect(0, 0, 1, 1);
        aShape.graphics.endFill();
        //addChild(aShape);
        dShape = new Shape();
        dShape.graphics.clear();
        dShape.graphics.beginFill(0X00FF00);
        dShape.graphics.drawRect(0, 0, 1, 1);
        dShape.graphics.endFill();
        //addChild(dShape);
        vShape = new Shape();
        vShape.graphics.clear();
        vShape.graphics.beginFill(0X4444FF);
        vShape.graphics.drawRect(0, 0, 1, 1);
        vShape.graphics.endFill();
        //addChild(vShape);
        */

        setShipType(shipType);

        // Add our name as a textfield
        var nameText :TextField = new TextField();
        nameText.autoSize = TextFieldAutoSize.CENTER;
        nameText.selectable = false;
        nameText.x = 0;
        nameText.y = TEXT_OFFSET;

        var format:TextFormat = new TextFormat();
        format.font = GameView.gameFont.fontName;
        format.color = (isOwnShip || shipId < 0) ? Codes.CYAN : Codes.RED;
        format.size = 10;
        format.rightMargin = 3;
        nameText.defaultTextFormat = format;
        nameText.embedFonts = true;
        nameText.antiAliasType = AntiAliasType.ADVANCED;
        nameText.text = playerName;
        addChild(nameText);
    }

    /**
     * Move one tick's worth of distance on its current heading.
     */
    public function move (time :Number) :void
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

            var xComp :Number = Math.cos(ship.rotation * Codes.DEGS_TO_RADS);
            var yComp :Number = Math.sin(ship.rotation * Codes.DEGS_TO_RADS);
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

        if (_isOwnShip && accel != 0 && powerups & SPEED_MASK) {
            enginePower -= time / 30000;
            if (enginePower <= 0) {
                powerups &= ~SPEED_MASK;
                accel = Math.min(accel, _shipType.forwardAccel);
                accel = Math.max(accel, _shipType.backwardAccel);
                AppContext.game.playSoundAt(Resources.getSound("powerup_empty.wav"), boardX, boardY);
            }
        }
    }

    public function get isOwnShip () :Boolean
    {
        return _isOwnShip;
    }

    /**
     * Returns true if the ship is alive.
     */
    public function isAlive () :Boolean
    {
        return power > DEAD && AppContext.game.gameState != Codes.POST_ROUND;
    }

    /**
     * Try to move the ship between the specified points, reacting to any
     *  collisions along the way.  This function calls itself recursively
     *  to resolve collisions created in the rebound from earlier collisions.
     */
    public function resolveMove (startX :Number, startY :Number,
        endX :Number, endY :Number, colType :int = 0) :void
    {
        var coll :Collision = _board.getCollision(
                startX, startY, endX, endY, _shipType.size, -1, colType);
        if (coll != null && coll.hit is Obstacle) {
            var obstacle :Obstacle = Obstacle(coll.hit);
            var bounce :Number = obstacle.getElasticity();
            var dx :Number = endX - startX;
            var dy :Number = endY - startY;

            if (!_moveSound) {
                AppContext.game.playSoundAt(obstacle.collisionSound(), startX + dx * coll.time,
                    startY + dy * coll.time);
                _moveSound = true;
            }
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
        _moveSound = false;
    }

    /**
     * Registers that the ship was hit.
     */
    public function hit (shooterId :int, damage :Number) :void
    {
        // Already dead, don't bother.
        if (!isAlive()) {
            return;
        }

        var hitPower :Number = damage / _shipType.armor;

        if (powerups & SHIELDS_MASK) {
            // shields always have an armor of 0.5
            hitPower = damage * 2;
            shieldPower -= hitPower;
            if (shieldPower <= DEAD) {
                powerups ^= SHIELDS_MASK;
                if (_isOwnShip) {
                    _shieldSound.stop();
                    AppContext.game.playSoundAt(Resources.getSound("powerup_empty.wav"), boardX, boardY);
                }
            }
            return;
        }

        power -= hitPower;
        if (!isAlive()) {
            AppContext.game.explode(boardX, boardY, ship.rotation, shooterId, shipId);
            checkAwards();

            // Stop moving and firing.
            xVel = 0;
            yVel = 0;
            turnRate = 0;
            turnAccelRate = 0;
            accel = 0;
            _firing = false;
            _secondary = false;
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
        stopSounds();
        setVisible(false);

        if (_isOwnShip) {
            // After a 5 second interval, reposition & reset.
            var timer :Timer = new Timer(RESPAWN_DELAY, 1);
            timer.addEventListener(TimerEvent.TIMER, newShip);
            timer.start();
        }
    }

    public function newShip (event :TimerEvent) :void
    {
        event.target.removeEventListener(TimerEvent.TIMER, newShip);
        if (AppContext.game.gameState != Codes.POST_ROUND) {
            AppContext.mainSprite.addChild(new ShipChooser(false));
        }
    }

    /**
     * Positions the ship at a brand new spot after exploding and resets its
     *  dynamics.
     */
    public function restart () :void
    {
        power = 1.0; //full
        powerups = 0;
        var pt :Point = _board.getStartingPos();
        boardX = pt.x;
        boardY = pt.y;
        xVel = 0;
        yVel = 0;
        turnRate = 0;
        turnAccelRate = 0;
        accel = 0;
        ship.rotation = 0;
        shieldPower = 0.0;
        weaponPower = 0.0;
        enginePower = 0.0;
        primaryPower = 1.0;
        secondaryPower = 0.0;
        _killsThisLife = 0;
        _killsThisLife3 = 0;
        _powerupsThisLife = false;

        _engineSound.loop();

        AppContext.game.forceStatusUpdate();
        setVisible(true);
    }

    public function roundEnded () :void
    {
        stopSounds();
        setAnimMode(IDLE, true);
        checkAwards(true);
    }

    protected function setVisible (visible :Boolean) :void
    {
        if (this.visible != visible) {
            this.visible = visible;

            if (visible) {
                var sound :Sound = _shipType.spawnSound;
                AppContext.game.playSoundAt(sound, boardX, boardY);
                var spawnClip :MovieClip = MovieClip(new (Resources.getClass("ship_spawn"))());
                addChild(spawnClip);
                spawnClip.addEventListener(Event.COMPLETE, function complete (event :Event) :void {
                    spawnClip.removeEventListener(Event.COMPLETE, arguments.callee);
                    removeChild(event.target as MovieClip);
                });
            }
        }
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
    public function tick (time :int) :void
    {
        if (_reportShip != null) {
            if (_reportTime == 0) {
                _reportShip = null;
            } else {
                _reportTime = Math.max(0, _reportTime - time);
                _reportShip.tick(time);
            }
        }
        primaryPower = Math.min(1.0, primaryPower + time / (1000 * _shipType.primaryPowerRecharge));
        secondaryPower = Math.min(1.0,
            secondaryPower + time / (1000 * _shipType.secondaryPowerRecharge));

        if (_animMode != WARP_BEGIN && _animMode != WARP_END) {
            turn(time);
            move(time);
            if (accel > 0.0) {
                setAnimMode((powerups & SPEED_MASK) ? FORWARD_FAST : FORWARD, false);
            } else if (accel < 0.0) {
                setAnimMode((powerups & SPEED_MASK) ? REVERSE_FAST : REVERSE, false);
            } else {
                setAnimMode(IDLE, false);
            }
        }

        if (powerups & SHIELDS_MASK) {
            _shieldMovie.alpha = 1.0;
        } else {
            _shieldMovie.alpha = 0.0;
        }

        if (_ticksToFire > 0) {
            _ticksToFire -= time;
        }
        if (_firing && (_ticksToFire <= 0) &&
                (primaryPower >= _shipType.getPrimaryShotCost(this))) {
            fire();
        }

        if (_ticksToSecondary > 0) {
            _ticksToSecondary -= time;
        }
        if (_secondary && (_ticksToSecondary <= 0) &&
                (secondaryPower >= _shipType.secondaryShotCost)) {
            secondaryFire();
        }
    }

    /**
     * Sets our animation to show forward/idle/reverse
     */
    public function setAnimMode (mode :int, force :Boolean) :MovieClip
    {
        if (force || _animMode != mode) {
            _shipMovie.gotoAndPlay(ANIM_MODES[mode]);
            _animMode = mode;
            return _shipMovie;
        }
        return null;
    }

    /**
     * Turns the ship based on the current turn acceleration over time.
     */
    public function turn (time :Number) :void
    {
        var turn :Number = 0;
        for (var etime :Number = time; etime > 0; etime -= 10) {
            var dtime :Number = Math.min(etime / 1000, 0.01);
            var turnSign :Number = (turnRate > 0 ? 1 : -1) * dtime;
            if (turnAccelRate == 0 &&
                    Math.abs(turnRate) < Codes.SHIP_TYPES[shipType].turnThreshold) {
                turnRate = 0;
                break;
            }
            turnRate += dtime * turnAccelRate -
                    turnSign * Codes.SHIP_TYPES[shipType].turnFriction * (turnRate * turnRate);
            turn += turnRate * dtime;
        }
        ship.rotation = (ship.rotation + turn * 5) % 360;
        if (_reportShip != null) {
            var delta :Number = _reportShip.ship.rotation - ship.rotation;
            if (delta > 180) {
                delta -= 360;
            } else if (delta < -180) {
                delta += 360;
            }
            ship.rotation = Linear.easeNone(INTERPOLATION_TIME - _reportTime, ship.rotation,
                delta, INTERPOLATION_TIME);
        }
    }

    /**
     * Sets the sprite position for this ship based on its board pos and
     *  another pos which will be the center of the screen.
     */
    public function setPosRelTo (otherX :Number, otherY: Number) :void
    {
        x = ((boardX - otherX) * Codes.PIXELS_PER_TILE) + Codes.GAME_WIDTH/2;
        y = ((boardY - otherY) * Codes.PIXELS_PER_TILE) + Codes.GAME_HEIGHT/2;
    }

    /**
     * Register that a key was pressed.  We only care about arrows.
     */
    public function keyPressed (event :KeyboardEvent) :void
    {
        // Can't do squat while dead.
        if (!isAlive()) {
            return;
        }

        if (event.keyCode == KV_LEFT || event.keyCode == KV_A) {
            turnAccelRate = -_shipType.turnAccel;
        } else if (event.keyCode == KV_RIGHT || event.keyCode == KV_D) {
            turnAccelRate = _shipType.turnAccel;
        } else if (event.keyCode == KV_UP || event.keyCode == KV_W) {
            accel = ((powerups & SPEED_MASK) ?
                    _shipType.forwardAccel*SPEED_BOOST_FACTOR : _shipType.forwardAccel);

            if (_isOwnShip) {
                _thrusterReverse.stop();
                if (accel != 0) {
                    _thrusterForward.loop();
                }
            }

        } else if (event.keyCode == KV_DOWN || event.keyCode == KV_S) {
            accel = ((powerups & SPEED_MASK) ?
                _shipType.backwardAccel*SPEED_BOOST_FACTOR : _shipType.backwardAccel);

            if (_isOwnShip) {
                _thrusterForward.stop();
                if (accel != 0) {
                    _thrusterReverse.loop();
                }
            }

        } else if (event.keyCode == KV_SPACE) {
            _firing = true;
        } else if (event.keyCode == KV_B || event.keyCode == KV_SHIFT) {
            _secondary = true;
        }
    }

    /**
     * Sets up our sprites and such for our given shiptype.
     */
    public function setShipType (type :int) :void
    {
        if (type != shipType || _shipMovie == null) {
            shipType = type;
            _shipType = Codes.SHIP_TYPES[shipType];

            // Remove any old movies of other types of ship.
            if (_shipMovie != null) {
                ship.removeChild(_shipMovie);
                ship.removeChild(_shieldMovie);
            }

            // Set up our animation.
            _shipMovie = MovieClip(new _shipType.shipAnim());
            _shieldMovie = MovieClip(new _shipType.shieldAnim());

            setAnimMode(IDLE, true);
            _shipMovie.x = _shipMovie.width/2;
            _shipMovie.y = -_shipMovie.height/2;
            _shipMovie.rotation = 90;
            ship.addChild(_shipMovie);

            _shieldMovie.gotoAndStop(1);
            _shieldMovie.rotation = 90;
            if (powerups & SHIELDS_MASK) {
                _shieldMovie.alpha = 1.0;
            } else {
                _shieldMovie.alpha = 0.0;
            }
            ship.addChild(_shieldMovie);

            if (_isOwnShip) {
                // Start the engine sound...
                if (_engineSound != null) {
                    _engineSound.stop();
                }

                // Play the engine sound forever til we stop.
                _engineSound = new SoundLoop(_shipType.engineSound);
                _engineSound.loop();
            }
            ship.scaleX = _shipType.size + 0.1;
            ship.scaleY = _shipType.size + 0.1;
        }
    }

    public function fire () :void
    {
        _shipType.primaryShotMessage(this);
        if (powerups & SPREAD_MASK) {
            weaponPower -= 0.03;
            if (weaponPower <= 0.0) {
                powerups ^= SPREAD_MASK;
                AppContext.game.playSoundAt(Resources.getSound("powerup_empty.wav"), boardX, boardY);
            }
        }

        _ticksToFire = _shipType.primaryShotRecharge * 1000;
        primaryPower -= _shipType.getPrimaryShotCost(this);
    }

    public function secondaryFire () :void
    {
        if (_shipType.secondaryShotMessage(this)) {
            _ticksToSecondary = _shipType.secondaryShotRecharge * 1000;
            secondaryPower -= _shipType.secondaryShotCost;
        }
    }

    /**
     * Register that a key was released - we only care about the arrows.
     */
    public function keyReleased (event :KeyboardEvent) :void
    {
        // Can't do squat while dead.
        if (!isAlive()) {
            return;
        }

        if (event.keyCode == KV_LEFT || event.keyCode == KV_A) {
            turnAccelRate = Math.max(turnAccelRate, 0);
        } else if (event.keyCode == KV_RIGHT || event.keyCode == KV_D) {
            turnAccelRate = Math.min(turnAccelRate, 0);
        } else if (event.keyCode == KV_UP || event.keyCode == KV_W) {
            accel = Math.min(accel, 0);

            if (_isOwnShip) {
                _thrusterForward.stop();
            }
        } else if (event.keyCode == KV_DOWN || event.keyCode == KV_S) {
            accel = Math.max(accel, 0);

            if (_isOwnShip) {
                _thrusterReverse.stop();
            }
        } else if (event.keyCode == KV_SPACE) {
            _firing = false;
        } else if (event.keyCode == KV_B || event.keyCode == KV_SHIFT) {
            _secondary = false;
        } else if (event.keyCode == KV_X) {
            hit(shipId, 5.0);
        }
    }

    /**
     * Give a powerup to the ship.
     */
    public function awardPowerup (powerup :Powerup) :void
    {
        _powerupsThisLife = true;
        AppContext.game.addScore(shipId, POWERUP_PTS);
        AppContext.game.playSoundAt(powerup.sound(), powerup.bX, powerup.bY);
        if (powerup.type == Powerup.HEALTH) {
            power = Math.min(1.0, power + 0.5);
            return;
        }
        powerups |= (1 << powerup.type);
        switch (powerup.type) {
        case Powerup.SHIELDS:
            shieldPower = 1.0;
            if (_isOwnShip) {
                _shieldSound.loop();
            }
            break;
        case Powerup.SPEED:
            enginePower = 1.0;
            break;
        case Powerup.SPREAD:
            weaponPower = 1.0;
            break;
        }
    }

    /**
     * Increase the ship's score.
     */
    public function addScore (score :int) :void
    {
        this.score += score;
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
        ship.rotation = bytes.readShort();
        power = bytes.readFloat();
        powerups = bytes.readInt();
        setShipType(bytes.readInt());
        score = bytes.readInt();
        setVisible(bytes.readBoolean());
    }

    /**
     * Forces the ship to point upwards (for display purposes).
     */
    public function pointUp () :void
    {
        ship.rotation = -90;
    }

    public function canHit () :Boolean
    {
        return isAlive() && _animMode != WARP_BEGIN && _animMode != WARP_END;
    }

    /**
     * Update our ship to the reported position, BUT if possible try to
     *  set ourselves up to make up for any discrepancy smoothly.
     */
    public function updateForReport (report :ShipSprite) :void
    {
        _reportShip = report;
        _reportTime = INTERPOLATION_TIME;
        if (_animMode == WARP_BEGIN || _animMode == WARP_END) {
            return;
        }

        accel = report.accel;
        xVel = report.xVel;
        yVel = report.yVel;
        turnRate = report.turnRate;
        // These we always update exactly as reported.
        power = report.power;
        powerups = report.powerups;
        score = report.score;
        if (shipType != report.shipType || visible != report.visible) {
            boardX = report.boardX;
            boardY = report.boardY;
            ship.rotation = report.ship.rotation;
        }
        setShipType(report.shipType);
        setVisible(report.visible);
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
        bytes.writeShort(ship.rotation);
        bytes.writeFloat(power);
        bytes.writeInt(powerups);
        bytes.writeInt(shipType);
        bytes.writeInt(score);
        bytes.writeBoolean(visible);

        return bytes;
    }

    protected function handleUnload (... ignored) :void
    {
        stopSounds();
    }

    protected function stopSounds () :void
    {
        // Turn off sound loops.
        if (_thrusterForward != null) {
            _thrusterForward.stop();
        }
        if (_thrusterReverse != null) {
            _thrusterReverse.stop();
        }

        if (_shieldSound != null) {
            _shieldSound.stop();
        }

        if (_engineSound != null) {
            _engineSound.stop();
        }

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

        if (score >= 500) {
            AppContext.game.awardTrophy("score1");
        }
        if (score >= 1000) {
            AppContext.game.awardTrophy("score2");
        }
        if (score >= 1500) {
            AppContext.game.awardTrophy("score3");
        }
    }

    /** The board we inhabit. */
    protected var _board :BoardController;

    protected var _firing :Boolean;
    protected var _ticksToFire :int = 0;
    protected var _secondary :Boolean;
    protected var _ticksToSecondary :int = 0;

    /** Ship performance characteristics. */
    protected static const SHOT_SPD :Number = 1;
    protected static const TIME_PER_SHOT :int = 330;
    protected static const SPEED_BOOST_FACTOR :Number = 1.5;
    protected static const RESPAWN_DELAY :int = 3000;
    protected static const DEAD :Number = 0.001;

    /** Sounds currently being played - only play sounds for ownship. Note
     * that due to stupid looping behavior these need to be MovieClips to keep
     * from getting gaps between loops. */
    protected var _engineSound :SoundLoop;
    protected var _thrusterForward :SoundLoop;
    protected var _thrusterReverse :SoundLoop;
    protected var _shieldSound :SoundLoop;

    /** Animations. */
    protected var _shipMovie :MovieClip;
    protected var _shieldMovie :MovieClip;

    /** State of thurster sounds. */
    protected var _thrusterRev :Boolean;

    /** Whether this is ourselves. */
    protected var _isOwnShip :Boolean;

    /** A reference to the ship type class. */
    protected var _shipType :ShipType;
    protected var _animMode :int;

    protected var _reportShip :ShipSprite;
    protected var _reportTime :int;

    protected var _moveSound :Boolean;

    /** Trophy stats. */
    protected var _killsThisLife :int;
    protected var _killsThisLife3 :int;
    protected var _enemiesKilled :Object = new Object();
    protected var _powerupsThisLife :Boolean = false;
    protected var _kills :int;
    protected var _deaths :int;

    protected static const FUDGE_FACT :Number = 0.98;

    protected static const INTERPOLATION_TIME :int = 500;

    protected static const TEXT_OFFSET :int = 25;

    protected static const POWERUP_PTS :int = 2;

    protected static const ANIM_MODES :Array = [
        "ship", "retro", "thrust", "super_thrust", "super_retro", "select", "warp_begin", "warp_end"
    ];
}
}
