package com.threerings.brawler.actor {

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.utils.getTimer;

import com.threerings.util.ArrayUtil;

import com.threerings.brawler.util.BrawlerUtil;

/**
 * Represents a mobile entity (player or NPC).
 */
public class Pawn extends Actor
{
    /** The immediate snap motion. */
    public static const SNAP :int = 0;

    /** The walking motion. */
    public static const WALK :int = 1;

    /** The sprinting motion. */
    public static const SPRINT :int = 2;

    /** The sliding motion. */
    public static const SLIDE :int = 3;

    /** The knocked motion. */
    public static const KNOCK :int = 4;

    // documentation inherited
    override public function wasDestroyed () :void
    {
        // clear any animation and remove our radar blip
        super.wasDestroyed();
        _view.hud.removeRadarBlip(_blip);
    }

    /**
     * Checks whether we can move to a new location.
     */
    public function get canMove () :Boolean
    {
        return _action == "idle" || (_action == "walk" && _motion != SPRINT);
    }

    /**
     * Checks whether the pawn is currently blocking.
     */
    public function get blocking () :Boolean
    {
        return _blocking;
    }

    /**
     * Enters or leaves blocking mode.
     */
    public function set blocking (value :Boolean) :void
    {
        if (_blocking == value) {
            return;
        }
        if (amOwner && value && _action != "idle" && _action != "walk") {
            return;
        }
        _blocking = value;
        if (amOwner) {
            stop(false);
            publish();
        }
    }

    /**
     * Checks whether the pawn is currently sprinting.
     */
    public function get sprinting () :Boolean
    {
        return moving && _motion == SPRINT;
    }

    /**
     * Checks whether the pawn is sliding.
     */
    public function get sliding () :Boolean
    {
        return moving && (_motion == SLIDE || _motion == KNOCK);
    }

    /**
     * Checks whether the pawn has been knocked back.
     */
    public function get knocked () :Boolean
    {
        return moving && _motion == KNOCK;
    }

    /**
     * Checks whether the pawn is stunned.
     */
    public function get stunned () :Boolean
    {
        return _stunCountdown > 0;
    }

    /**
     * Sets the stun countdown.
     */
    public function set stunCountdown (countdown :Number) :void
    {
        _stunCountdown = countdown;
    }

    /**
     * Checks whether the pawn can be hit.
     */
    public function get hittable () :Boolean
    {
        return !(dead || invulnerable || _action == "hurt");
    }

    /**
     * Returns the action that the pawn is currently executing.
     */
    public function get action () :String
    {
        return _action;
    }

    /**
     * Checks whether or not the pawn is dead.
     */
    public function get dead () :Boolean
    {
        return _hp == 0;
    }

    /**
     * Checks whether the pawn is invulnerable.
     */
    public function get invulnerable () :Boolean
    {
        return _invulnerableCountdown > 0;
    }

    /**
     * Sets the invulnerable countdown.
     */
    public function set invulnerableCountdown (countdown :Number) :void
    {
        _invulnerableCountdown = Math.max(_invulnerableCountdown, countdown);
    }

    /**
     * Returns the pawn's hit points.
     */
    public function get hp () :Number
    {
        return _hp;
    }

    /**
     * Sets the pawn's hit points.
     */
    public function set hp (points :Number) :void
    {
        if (_hp == points) {
            return;
        }
        var ohp :Number = _hp;
        _hp = points;
        if (_hp < ohp) {
            wasHurt(ohp - _hp);
        } else if (ohp == 0 && !dead) {
            respawned();
        }
    }

    /**
     * Returns the pawn's maximum hit points.
     */
    public function get maxhp () :Number
    {
        return 1500;
    }

    /**
     * Stops the pawn if it's moving.
     *
     * @param publish if false, do not publish the movement even if this is the master pawn.
     */
    public function stop (publish :Boolean = true) :void
    {
        if (!moving || sliding) {
            return;
        }
        stopped();
        if (sprinting) {
            // slide to a stop
            var pt :Point = getSlideLocation(
                x, y, _goal.x - x, _goal.y - y, getWalkSpeed(scaleX, true));
            move(pt.x, pt.y, SLIDE, publish);
        } else {
            // stop immediately
            move(x, y, SNAP, publish);
        }
    }

    /**
     * Moves this pawn to a new location.
     *
     * @param motion the motion mode ({@link #WALK}, {@link #SPRINT}, etc.)
     * @param publish if false, do not publish the movement even if this is the master pawn.
     */
    public function move (
        x :Number, y :Number, motion :int = SNAP, publish :Boolean = true) :void
    {
        // when the player requests to sprint, tack on the slide distance
        if (amOwner && motion == SPRINT) {
            var pt :Point = getSlideLocation(
                x, y, x - this.x, y - this.y, getWalkSpeed(_view.getScale(y), true));
            x = pt.x;
            y = pt.y;
        }

        // store the new goal and motion
        _goal.x = x;
        _goal.y = y;
        _motion = motion;

        // initialize the dust countdown
        _dustCountdown = dustInterval;

        // publish our state if we are the master copy
        if (publish) {
            maybePublish();
        }
    }

    /**
     * Checks whether we're moving towards a goal.
     */
    public function get moving () :Boolean
    {
        return !locationEquals(_goal.x, _goal.y);
    }

    /**
     * Notifies the pawn that it has been hurt.
     */
    public function hurt (attacker :Pawn, damage :Number, knockback :Number, stun :Number) :void
    {
        if (blocking) {
            block(attacker, damage, knockback);
            return;
        }

        // report the hit
        wasHit(attacker, damage);

        // update hit points
        hp = Math.max(0, _hp - damage);

        // update stun countdown
        if (stun > 0) {
            stunCountdown = Math.max(0, _stunCountdown) + stun;
        } else {
            stunCountdown = 0;
        }

        // knock back (amount is initial velocity in pixels per frame)
        if (damage >= maxhp * KNOCK_DAMAGE) {
            knockback += 12;
        }
        if (knockback > 0) {
            var pt :Point = getSlideLocation(x, y, x - attacker.x, 0, knockback * 30);
            move(pt.x, pt.y, KNOCK, false);
        } else if (damage >= maxhp * STOP_DAMAGE) {
            stop(false);
        }

        // publish the updated state
        publish();
    }

    /**
     * Handles a block.
     */
    public function block (attacker :Pawn, damage :Number, knockback :Number) :void
    {
        // report the block
        didBlock(attacker, damage);
    }

    /**
     * Notes that the pawn blocked another.
     */
    public function didBlock (attacker :Pawn, damage :Number) :void
    {
        var hurt :Boolean = (damage > maxhp * 0.15);
        showBlock(hurt);
        attacker.wasBlocked(hurt);
        if (amOwner) {
            send({ type: DID_BLOCK, attacker: attacker.name, damage: damage });
        }
    }

    /**
     * Notes that the pawn was blocked by another.
     */
    public function wasBlocked (hurt :Boolean) :void
    {
        if (hurt) {
            setAction("hurt");
            if (amOwner) {
                stop();
            }
        }
    }

    /**
     * Notes that the pawn was hit by another.
     */
    public function wasHit (attacker :Pawn, damage :Number) :void
    {
        showDamage(damage);
        if (attacker.amOwner) {
            attacker.didHit(this, damage);
        }
        if (amOwner) {
            send({ type: WAS_HIT, attacker: attacker.name, damage: damage });
        }
    }

    /**
     * Notes that the pawn lost hp.
     */
    public function wasHurt (damage :Number) :void
    {
        // play the hurt animation if we're not dead
        if (dead) {
            died();
        } else if (damage >= maxhp * STOP_DAMAGE) {
            setAction("hurt");
        }
    }

    /**
     * Notes that the pawn hit another.
     */
    public function didHit (target :Pawn, damage :Number) :void
    {
    }

    // documentation inherited
    override public function decode (state :Object) :void
    {
        hp = state.hp;
        blocking = state.blocking;
        stunCountdown = state.stunCountdown;
        invulnerableCountdown = state.invulnerableCountdown;

        // move towards the new position, if we're not yet there
        if (!locationEquals(state.x, state.y)) {
            move(state.x, state.y, state.motion, false);
        }
    }

    // documentation inherited
    override public function receive (message :Object) :void
    {
        if (message.type == WAS_HIT) {
            wasHit(_ctrl.actors[message.attacker], message.damage);
        } else if (message.type == DID_BLOCK) {
            didBlock(_ctrl.actors[message.attacker], message.damage);
        }
    }

    // documentation inherited
    override public function enterFrame (elapsed :Number) :void
    {
        if (_ctrl._disableEnemies != true){
            // experimentally derived (?)
            var scale :Number = 3 - 2*scaleX;

            // update the scale of the name plate
            if (_plate.parent != null) {
                _plate.name_plate.scaleX = scale;
                _plate.name_plate.scaleY = scale;
                _plate.name_plate.x = -_plate.width/2; // recenter
            }

            // update the scale and state of the health bar
            if (_health.parent != null) {
                _health.scaleX = scale;
                _health.scaleY = scale;
                var frame :int = Math.floor((_hp / maxhp) * 100) + 1;
                _health.gotoAndStop(frame);
            }

            // update the stun countdown
            _effects.gotoAndStop((_stunCountdown -= elapsed) > 0 ? "stunned" : "normal");

            // update the invulnerability countdown
            if ((_invulnerableCountdown -= elapsed) > 0) {
                _character.alpha = (_blink++ % 2 == 0) ? 1 : 0;
            } else {
                _character.alpha = 1;
            }

            // update the death clock
            if (dead && (_deathClock += elapsed) >= 1) {
                if (_deathClock >= 2 && visible) {
                    _character.visible = false;
                    disappeared();
                } else {
                    // toggle alpha every other frame
                    _character.alpha = ((_blink++ / 2) % 2 == 0) ? 1 : 0;
                }
            }

            // move towards our goal, if we're not there yet
            if (moving) {
                var location :Point = new Point(x, y);
                var distance :Number = Point.distance(location, _goal);
                var speed :Number = getSpeed(distance);
                var wspeed :Number = getWalkSpeed(scaleX, true);
                var f :Number = (speed <= SLIDE_STOP_SPEED) ?
                    1 : Math.min(1, (speed * elapsed) / distance);

                // update the location
                location = Point.interpolate(_goal, location, f);
                _view.setPosition(this, location.x, location.y);

                // are we there yet?
                if (!moving) {
                    stopped();

                // find out if we've switched from sprinting to sliding
                } else if (_motion == SPRINT && speed < wspeed) {
                    stopped();
                    _motion = SLIDE;
                }

                // perhaps emit a dust poof
                if ((_dustCountdown -= elapsed) <= 0) {
                    _view.addTransient(_ctrl.create("Dust"), x, y);
                    _dustCountdown = dustInterval;
                }
            }

            // update the pawn's action
            updateAction();

            // update the pawn's direction
            updateDirection();

            // update the location of the radar blip
            _view.hud.updateRadarBlip(_blip, x);
        }
    }

    // documentation inherited
    override protected function didInit (state :Object) :void
    {
        // add the player sprite
        addChild(_psprite = _ctrl.create("PlayerSprite"));
        _character = _psprite["character"];
        _bounds = _psprite["boundbox"];
        _dmgbox = _psprite["dmgbox"];
        _effects = _psprite["effects"];
        _health = _psprite["health_bar"];
        _plate = _psprite["name_plate"];

        // listen for animation complete events
        _character.addEventListener("animationComplete", handleAnimationComplete);
        _dmgbox.addEventListener("animationComplete", handleAnimationComplete);

        // initialize the position and goal
        _view.setPosition(this, state.x, state.y);
        _goal = new Point(state.x, state.y);

        // extract the hit points, status
        _hp = state.hp;
        _blocking = state.blocking;
        _stunCountdown = state.stunCountdown;
        _invulnerableCountdown = state.invulnerableCountdown;

        // create and add our radar blip
        _view.hud.addRadarBlip(_blip = createRadarBlip());
    }

    /**
     * Creates and returns a radar blip for this pawn.
     */
    protected function createRadarBlip () :Sprite
    {
        return new Sprite();
    }

    // documentation inherited
    override protected function encode () :Object
    {
        // transmit our goal location
        var state :Object = super.encode();
        state.x = _goal.x;
        state.y = _goal.y;
        state.motion = _motion;
        state.hp = _hp;
        state.blocking = _blocking;
        state.stunCountdown = _stunCountdown;
        state.invulnerableCountdown = _invulnerableCountdown;
        return state;
    }

    /**
     * Updates the direction that the pawn is facing.
     */
    protected function updateDirection () :void
    {
        if (moving) {
            if (_motion == WALK || _motion == SPRINT) {
                face(_goal.x);
            } else if (_motion == KNOCK) {
                face(2*x - _goal.x); // face opposite direction
            }
        }
    }

    /**
     * Orients the character to face the specified x coordinate.
     */
    protected function face (x :Number) :void
    {
        if (x > this.x) {
            orient(+1);
        } else if (x < this.x) {
            orient(-1);
        }
    }

    /**
     * Orients the character to face right (+1) or left (-1).
     */
    protected function orient (dir :Number) :void
    {
        _character.scaleX = dir;
        if (_dmgbox != null) {
            _dmgbox.scaleX = dir;
        }
    }

    /**
     * Called when we've reached our goal or our path was cancelled for some reason.
     */
    protected function stopped () :void
    {
    }

    /**
     * Returns the the x coordinate of the pawn's spawn point.
     */
    protected function get spawnX () :Number
    {
        return 100;
    }

    /**
     * Returns the y coordinate of the pawn's spawn point.
     */
    protected function get spawnY () :Number
    {
        return _view.groundCenterY;
    }

    /**
     * Returns speed at which the pawn is moving.
     *
     * @param distance the distance to the goal.
     */
    protected function getSpeed (distance :Number) :Number
    {
        if (distance == 0) {
            return 0;
        }
        switch (_motion) {
            default:
            case SNAP: return 0;
            case WALK: return getWalkSpeed(scaleX);
            case SPRINT: return Math.min(getWalkSpeed(scaleX, true), getSlideSpeed(distance));
            case SLIDE:
            case KNOCK: return getSlideSpeed(distance);
        }
    }

    /**
     * Returns the walk or sprint speed using the provided scale.
     */
    protected function getWalkSpeed (scale :Number, sprinting :Boolean = false) :Number
    {
        return baseSpeed * scale * (sprinting ? 3.5 : 1);
    }

    /**
     * Returns the speed at which the pawn would slide towards its goal.
     */
    protected function getSlideSpeed (distance :Number) :Number
    {
        return SLIDE_STOP_SPEED - SLIDE_RATE*distance;
    }

    /**
     * Returns the pawn's base speed.
     */
    protected function get baseSpeed () :Number
    {
        return 250;
    }

    /**
     * Returns the delay (in seconds) between dust poofs.
     */
    protected function get dustInterval () :Number
    {
        if (sprinting) {
            return SPRINT_DUST_INTERVAL;
        } else if (sliding) {
            return SLIDE_DUST_INTERVAL;
        } else {
            return Number.MAX_VALUE;
        }
    }

    /**
     * Shows a damage effect.
     */
    protected function showDamage (damage :Number) :void
    {
        // create the damage display effect
        var critical :Boolean = (damage > CRITICAL_DAMAGE);
        var number :MovieClip = createDamageNumber(critical);
        if (critical) {
            _view.playCameraEffect("x_light");
        }
        if (damage > MESSAGE_DAMAGE) {
            number.txt.dmg.text = BrawlerUtil.pickRandom(DAMAGE_MESSAGES);
        } else {
            number.txt.dmg.text = "-" + Math.round(damage);
        }
        _view.addTransient(number, x + BrawlerUtil.random(50), y, true);

        // create the snap effect
        var snap :MovieClip = createDamageSnap();
        _view.addTransient(
            snap, x + BrawlerUtil.random(20), y + BrawlerUtil.random(20), true);
        var scale :Number = BrawlerUtil.random(0.1, -0.1);
        snap.scaleX += scale;
        snap.scaleY += scale;
    }

    /**
     * Shows a block effect.
     */
    protected function showBlock (hurt :Boolean) :void
    {
        if (hurt) {
            _view.playCameraEffect("light");
        }
        _view.addTransient(_ctrl.create("Block"), x + BrawlerUtil.random(50), y, true);
    }

    /**
     * Updates the pawn's action based on its current state.
     */
    protected function updateAction () :void
    {
        if (dead) {
            setAction("dead");
        } else if (knocked) {
            setAction("knockback");
        } else if (_action == "knockback") {
            knockEnded();
        } else if (stunned) {
            setAction("stun");
        } else if (_action == "stun") {
            stunEnded();
        } else if (ArrayUtil.contains(TRANSIENT_ACTIONS, _action)) {
            return; // wait for action to clear
        } else if (blocking) {
            setAction("block");
        } else if (moving && _motion == SPRINT) {
            setAction("sprint");
        } else if (moving && _motion == WALK) {
            setAction("walk");
        } else {
            setAction("idle");
        }
    }

    /**
     * Called when the pawn has died.
     */
    protected function died () :void
    {
        _stunCountdown = 0;
        _invulnerableCountdown = 0;
        _blocking = false;
        _deathClock = 0;
    }

    /**
     * Called when the pawn has disappeared after dying.
     */
    protected function disappeared () :void
    {
        _blip.visible = false;
    }

    /**
     * Respawns the pawn.
     */
    protected function respawn () :void
    {
        hp = maxhp;
        move(spawnX, spawnY, SNAP, false);
        publish();
    }

    /**
     * Called when the pawn has respawned.
     */
    protected function respawned () :void
    {
        setAction("spawn");
        _character.alpha = _blip.alpha = 1;
        _character.visible = _blip.visible = true;
    }

    /**
     * Called when the pawn emerges from being knocked back.
     */
    protected function knockEnded () :void
    {
        setAction("hurt");
    }

    /**
     * Called when the pawn emerges from the stun condition.
     */
    protected function stunEnded () :void
    {
        setAction("hurt");
    }

    /**
     * Sets the pawn's action.
     */
    protected function setAction (
        action :String, anim :String = null, danim :String = null) :void
    {
        if (_action == action) {
            return;
        }
        _action = action;
        play(anim == null ? action : anim, danim);
    }

    /**
     * Plays an animation on both the character and its damage box.
     */
    protected function play (anim :String, danim :String = null) :void
    {
        _character.gotoAndPlay(anim);
        if (_dmgbox != null) {
            _dmgbox.gotoAndPlay(danim == null ? anim : danim);
        }
    }

    /**
     * Called when an animation finishes.
     */
    protected function handleAnimationComplete (event :Event) :void
    {
        if (ArrayUtil.contains(TRANSIENT_ACTIONS, _action)) {
            _action = null;
        }
    }

    /**
     * Creates and returns a new damage number effect.
     */
    protected function createDamageNumber (critical :Boolean) :MovieClip
    {
        return _ctrl.create(critical ? "CriticalDamageNumber" : "DamageNumber");
    }

    /**
     * Creates and returns a new damage snap effect.
     */
    protected function createDamageSnap () :MovieClip
    {
        return _ctrl.create("DamageSnap");
    }

    /**
     * Determines the slide location, given the point at which sliding starts, the non-normalized
     * slide direction, and the speed at the start of the slide.
     */
    protected function getSlideLocation (
        ox :Number, oy :Number, dx :Number, dy :Number, speed :Number) :Point
    {
        var distance :Number = getSlideDistance(speed);
        var dir :Point = new Point(dx, dy);
        dir.normalize(1);
        return _view.clampToGround(ox + dir.x*distance, oy + dir.y*distance);
    }

    /**
     * Given an initial speed (pixels per second), determines how far we'll slide.
     */
    protected static function getSlideDistance (speed :Number) :Number
    {
        return (SLIDE_STOP_SPEED - speed) / SLIDE_RATE;
    }

    /** The player sprite. */
    protected var _psprite :Sprite;

    /** The character clip. */
    protected var _character :MovieClip;

    /** The damage box. */
    protected var _dmgbox :MovieClip;

    /** The effects clip. */
    protected var _effects :MovieClip;

    /** The health bar clip. */
    protected var _health :MovieClip;

    /** The name plate. */
    protected var _plate :MovieClip;

    /** Our radar blip. */
    protected var _blip :Sprite;

    /** The location of the goal towards which the pawn is walking. */
    protected var _goal :Point;

    /** The pawn's motion mode. */
    protected var _motion :int = SNAP;

    /** The pawn's current hit points. */
    protected var _hp :Number;

    /** Whether or not the pawn is blocking. */
    protected var _blocking :Boolean = false;

    /** The countdown until we are no longer stunned. */
    protected var _stunCountdown :Number = 0;

    /** The countdown until we are no longer invulnerable. */
    protected var _invulnerableCountdown :Number = 0;

    /** The pawn's current action. */
    protected var _action :String;

    /** The last time we emitted a dust poof. */
    protected var _dustCountdown :Number = 0;

    /** The amount of time elapsed since we've been dead. */
    protected var _deathClock :Number = 0;

    /** Used to blink the pawn. */
    protected var _blink :int = 0;

    /** Identifies an attack message (fired when we start an attack). */
    protected static const ATTACK :int = 0;

    /** Identifies a hit message (fired when an attack hits us). */
    protected static const WAS_HIT :int = 1;

    /** Identifies a block message (fired when we block an attack). */
    protected static const DID_BLOCK :int = 2;

    /** Actions we allow to run to completion. */
    protected static const TRANSIENT_ACTIONS :Array = [ "spawn", "hurt", "attack" ];

    /** The exponential rate at which we slide
     * (speed decreases by 1/10 every 1/30 of a second). */
    protected static const SLIDE_RATE :Number = 30 * Math.log(9/10);

    /** The speed cutoff at which we stop sliding (one half pixel per frame). */
    protected static const SLIDE_STOP_SPEED :Number = 0.5 * 30;

    /** The number of seconds of invulnerability players experience after being knocked. */
    protected static const POST_KNOCK_INVULNERABILITY :Number = 1;

    /** The interval at which we emit dust poofs when sprinting (s). */
    protected static const SPRINT_DUST_INTERVAL :Number = 1/10;

    /** The interval at which we emit dust poofs when sliding (s). */
    protected static const SLIDE_DUST_INTERVAL :Number = 3/10;

    /** The damage threshold for critical attacks. */
    protected static const CRITICAL_DAMAGE :Number = 500;

    /** The damage threshold for which we show messages. */
    protected static const MESSAGE_DAMAGE :Number = 1500;

    /** The percent damage at which we stop the hurt pawn. */
    protected static const STOP_DAMAGE :Number = 0.025;

    /** The percent damage at which we knock back the hurt pawn. */
    protected static const KNOCK_DAMAGE :Number = 0.6;

    /** The messages from which we pick randomly. */
    protected static const DAMAGE_MESSAGES :Array = [
        "CHEZBURGER!?", "HOLY *@#&!!", "OMG HAXORZ", "HAMEDO!", "CT4HOLY!?!" ];
}
}
