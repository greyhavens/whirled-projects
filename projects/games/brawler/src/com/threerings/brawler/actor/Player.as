package com.threerings.brawler.actor {

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextFormat;
import flash.utils.getTimer;

import com.threerings.flash.MathUtil;

/**
 * Represents a player character.
 */
public class Player extends Pawn
{
    /** The maximum amount of experience the player can have. */
    public static const MAX_EXPERIENCE :Number = 300;

    /** The number of experience levels. */
    public static const EXPERIENCE_LEVELS :Number = 3;

    /** The amount of experience within one level. */
    public static const EXPERIENCE_PER_LEVEL :Number = MAX_EXPERIENCE / EXPERIENCE_LEVELS;

    /**
     * Creates an initial player state.
     */
    public static function createState (x :Number, y :Number) :Object
    {
        var state :Object = new Object();
        state.type = "Player";
        state.x = x;
        state.y = y;
        state.motion = SNAP;
        state.hp = 1500;
        state.weapon = Weapon.SWORD;
        state.blocking = false;
        state.stunCountdown = 0;
        state.invulnerableCountdown = 0;
        return state;
    }

    /**
     * Returns the player's energy level.
     */
    public function get energy () :Number
    {
        return _energy;
    }

    /**
     * Checks whether the energy level is being ramped up after depletion.
     */
    public function get depleted () :Boolean
    {
        return _depleted;
    }

    /**
     * Returns the type of weapon being used by the player.
     */
    public function get weapon () :int
    {
        return _weapon;
    }

    /**
     * Sets the weapon being used by the player.
     */
    public function set weapon (index :int) :void
    {
        if (_weapon == index) {
            return;
        }
        _character.weapon.gotoAndStop(Weapon.FRAME_LABELS[_weapon = index]);
        maybePublish();
    }

    /**
     * Returns the player's experience amount.
     */
    public function get experience () :Number
    {
        return _experience;
    }

    /**
     * Returns the player's experience level (from one to {@link #EXPERIENCE_LEVELS}, inclusive).
     */
    public function get level () :int
    {
        var level :Number = Math.floor(_experience / EXPERIENCE_PER_LEVEL) + 1;
        return Math.min(level, EXPERIENCE_LEVELS);
    }

    /**
     * Returns the player's attack level.
     */
    public function get attackLevel () :int
    {
        return _attackLevel;
    }

    /**
     * Performs an attack.
     *
     * @param secondary if true, use the secondary ("kick") attack mode.
     * @param level the attack level, or -1 if initiating the attack locally.
     * @param dir the direction being faced, or -1 to use the current direction.
     */
    public function attack (secondary :Boolean, level :int = -1, dir :int = -1) :void
    {
        if (_master) {
            // make sure we can attack
            if (_action != "idle" && _action != "walk") {
                return;
            }
            // make sure we have enough energy to attack (and aren't recharging)
            if (_energy < ATTACK_ENERGY || _depleted) {
                return;
            }
            _energy -= ATTACK_ENERGY;

            // use and adjust the player's attack level (primary attacks increment it;
            // secondary attacks bring it back to zero)
            level = _attackLevel;
            _attackLevel = secondary ? 0 : Math.min(_attackLevel + 1, Attack.MAX_LEVEL);
            _attackResetCountdown = ATTACK_RESET_INTERVAL;

            // attacking delays the health tick
            _healthTickCountdown = HEALTH_TICK_INTERVAL;

            // use the current orientation
            dir = _character.scaleX;
        }

        // play the attack animations
        var attacks :Array = secondary ? Attack.SECONDARY_ATTACKS : Attack.PRIMARY_ATTACKS;
        _attack = attacks[_weapon][level];
        setAction("attack", false, _attack.animation, _attack.name);
        orient(dir);

        if (_master) {
            // stop the pawn and announce the attack
            stop();
            send({ type: ATTACK, secondary: secondary, level: level, dir: dir });

            // run the camera effect, if any
            if (_attack.effect != null) {
                _view.playCameraEffect(_attack.effect);
            }
        }
    }

    /**
     * Lands an attack.
     */
    public function hit (target :Enemy, damage :Number, knockback :Number, stun :Number) :void
    {
        if (target.master) {
            // let the target know it was hurt
            target.hurt(this, damage, knockback, stun);

        } else if (_master) {
            // announce the hit
            send({ type: HIT, target: target.name, damage: damage,
                knockback: knockback, stun: stun });
        }
    }

    // documentation inherited
    override public function set blocking (value :Boolean) :void
    {
        // make sure we have enough energy to block
        if (!(_master && value && (_energy <= 0 || _depleted))) {
            super.blocking = value;
        }
    }

    // documentation inherited
    override public function move (
        x :Number, y :Number, motion :int = SNAP, publish :Boolean = true) :void
    {
        // make sure we have enough energy to sprint
        if (!(_master && motion == SPRINT && (_energy <= 0 || _depleted))) {
            super.move(x, y, motion, publish);
        }
    }

    // documentation inherited
    override public function receive (message :Object) :void
    {
        if (message.type == ATTACK) {
            attack(message.secondary, message.level, message.dir);
        } else if (message.type == HIT) {
            hit(_ctrl.actors[message.target], message.damage, message.knockback, message.stun);
        }
    }

    // documentation inherited
    override protected function didInit (state :Object) :void
    {
        super.didInit(state);

        // extract the id of the player from the actor name
        var playerId :int = parseInt(name.substring(5, name.indexOf("_")));

        // configure the name plate
        var format :TextFormat = new TextFormat();
        format.font = "Arial";
        format.size = 12;
        format.bold = true;
        format.color = 0x99BFFF;
        _plate.name_plate.defaultTextFormat = format;
        _plate.name_plate.text = _ctrl.control.getOccupantName(playerId);

        // set the weapon
        weapon = state.weapon;

        // remove the health bar if it's the local player
        if (_master) {
            _psprite.removeChild(_health);
        }
    }

    // documentation inherited
    override public function decode (state :Object) :void
    {
        super.decode(state);
        weapon = state.weapon;
    }

    // documentation inherited
    override public function enterFrame (elapsed :Number) :void
    {
        super.enterFrame(elapsed);
        if (!_master) {
            return;
        }
        // blocking and sprinting deplete energy
        var rate :Number;
        if (sprinting) {
            rate = SPRINT_ENERGY_RATE;
        } else if (blocking) {
            rate = BLOCK_ENERGY_RATE;
        } else if (_depleted) {
            rate = DEPLETED_ENERGY_RATE;
        } else {
            rate = NORMAL_ENERGY_RATE;
        }
        _energy = MathUtil.clamp(_energy + rate*elapsed, 0, 100);
        if (_energy == 0) {
            _depleted = true;
            if (blocking) {
                blocking = false;
            } else if (sprinting) {
                stop();
            }
        } else if (_energy == 100) {
            _depleted = false;
        }

        // check for collision of damage box with enemies when attacking
        hitTestEnemies();

        // reset the attack level if enough time has passed
        if ((_attackResetCountdown -= elapsed) <= 0) {
            _attackLevel = 0;
        }

        // increment the player's health over time
        if ((_healthTickCountdown -= elapsed) <= 0) {
            var ohp :Number = _hp;
            var amount :Number = maxhp * HEALTH_TICK_AMOUNTS[_ctrl.difficulty];
            _hp = Math.min(_hp + amount, maxhp);
            if (_hp != ohp) {
                publish();
            }
            _healthTickCountdown = HEALTH_TICK_INTERVAL;
        }

        // if he isn't moving, have him face the cursor
        if (_action == "idle") {
            face(_view.cursor.x);
        }
        // if he's on the door, notify the controller
        if (_view.door.hitTestObject(_bounds)) {
            _ctrl.playerOnDoor();
        }
    }

    /**
     * Checks for hits against pickups.
     */
    protected function hitTestPickups () :void
    {

    }

    /**
     * Checks for hits against enemies.
     */
    protected function hitTestEnemies () :void
    {
        if (_action != "attack") {
            return;
        }
        for each (var actor :Actor in _ctrl.actors) {
            if (!(actor is Enemy)) {
                continue;
            }
            var enemy :Enemy = actor as Enemy;
            if (!(enemy.hittable && _dmgbox.dmg_box.hitTestObject(enemy.bounds))) {
                continue;
            }
            // we've scored a hit
            var damage :Number = _attack.damage;
            var knockback :Number = _attack.knockback;
            if (sliding) {
                // if sliding, our slide speed increases the knockback amount
                var distance :Number = Point.distance(new Point(x, y), _goal);
                var slide :Number = getSlideSpeed(distance) / 30; // fps
                if (slide > 1) {
                    knockback += (slide * 2);
                }
            }
            var stun :Number = _attack.stun;

            // announce the hit
            hit(enemy, damage, knockback, stun);

            // notify the controller to update the hit count and score
            _ctrl.playerScoredHit(damage);
        }
    }

    // documentation inherited
    override protected function stopped () :void
    {
        // make sure the goal sprite is hidden
        super.stopped();
        if (_master) {
            _view.hideGoal();
        }
    }

    // documentation inherited
    override protected function respawned () :void
    {
        super.respawned();
        invulnerableCountdown = RESPAWN_INVULNERABILITY;
    }

    // documentation inherited
    override protected function knockEnded () :void
    {
        super.knockEnded();
        invulnerableCountdown = POST_KNOCK_INVULNERABILITY;
    }

    // documentation inherited
    override protected function stunEnded () :void
    {
        super.stunEnded();
        invulnerableCountdown = POST_STUN_INVULNERABILITY;
    }

    // documentation inherited
    override protected function createRadarBlip () :Sprite
    {
        return new PlayerBlip();
    }

    // documentation inherited
    override protected function encode () :Object
    {
        var state :Object = super.encode();
        state.weapon = _weapon;
        return state;
    }

    // documentation inherited
    override protected function createDamageNumber (critical :Boolean) :MovieClip
    {
        return critical ? new PlayerCriticalDamageNumber() : new PlayerDamageNumber();
    }

    // documentation inherited
    override protected function createDamageSnap () :MovieClip
    {
        return new PlayerDamageSnap();
    }

    /** The player's current energy level. */
    protected var _energy :Number = 100;

    /** Whether or not the player's energy has just been depleted. */
    protected var _depleted :Boolean = false;

    /** The type of weapon held by the player. */
    protected var _weapon :int;

    /** The player's experience amount. */
    protected var _experience :Number = 100;

    /** The player's attack level. */
    protected var _attackLevel :int = 0;

    /** The attack that the pawn is executing, if any. */
    protected var _attack :Attack;

    /** The countdown until the attack level is reset. */
    protected var _attackResetCountdown :Number = 0;

    /** The countdown until the next health tick. */
    protected var _healthTickCountdown :Number = 0;

    /** The player blip class. */
    [Embed(source="../../../../../rsrc/raw.swf", symbol="blip_pc")]
    protected static const PlayerBlip :Class;

    /** The block effect class. */
    [Embed(source="../../../../../rsrc/raw.swf", symbol="block")]
    protected static const Block :Class;

    /** The player damage number effect class. */
    [Embed(source="../../../../../rsrc/raw.swf", symbol="dmg_num_player")]
    protected static const PlayerDamageNumber :Class;

    /** The player critical damage number effect class. */
    [Embed(source="../../../../../rsrc/raw.swf", symbol="dmg_crit_num_player")]
    protected static const PlayerCriticalDamageNumber :Class;

    /** The player damage snap sprite class. */
    [Embed(source="../../../../../rsrc/raw.swf", symbol="dmg_snap_player")]
    protected static const PlayerDamageSnap :Class;

    /** The rate (u/s) at which players lose energy when blocking. */
    protected static const BLOCK_ENERGY_RATE :Number = -20;

    /** The rate at which players lose energy when sprinting. */
    protected static const SPRINT_ENERGY_RATE :Number = -100;

    /** The rate at which players regain energy (normally). */
    protected static const NORMAL_ENERGY_RATE :Number = +100;

    /** The rate at which players regain energy after depletion. */
    protected static const DEPLETED_ENERGY_RATE :Number = +50;

    /** The amount of energy required to attack. */
    protected static const ATTACK_ENERGY :Number = 25;

    /** The amount of time after the last attack at which the attack level is cleared (s). */
    protected static const ATTACK_RESET_INTERVAL :Number = 2;

    /** The (default) amount of time between health ticks (s). */
    protected static const HEALTH_TICK_INTERVAL :Number = 3;

    /** For each difficulty level, the health proportion regained at regular intervals. */
    protected static const HEALTH_TICK_AMOUNTS :Array = [ 1/10, 1/20, 1/20, 0 ];

    /** The number of seconds of invulnerability players experience after a respawn. */
    protected static const RESPAWN_INVULNERABILITY :Number = 2;

    /** The number of seconds of invulnerability players experience after being stunned. */
    protected static const POST_STUN_INVULNERABILITY :Number = 1.3;
}
}
