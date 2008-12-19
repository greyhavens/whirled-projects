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
        if (_weapon == Weapon.FISTS) {
            // show the break effect
            _view.addTransient(_ctrl.create("WeaponBreak"), x, y, true);
			if (amOwner) {
				_ctrl.weaponsBroken += 1;
			}
        }
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
     * Sets the player's experience amount.
     */
    public function set experience (amount :Number) :void
    {
        if (_experience == amount) {
            return;
        }
        _experience = amount;
        if (_experience == 0 && _weapon != Weapon.FISTS) {
            // break the weapon
            setWeapon(Weapon.FISTS);
        }
    }

    /**
     * Returns the player's experience level (from one to {@link #EXPERIENCE_LEVELS}, inclusive).
     */
    public function get level () :int
    {
        var level :Number = Math.ceil(_experience / EXPERIENCE_PER_LEVEL);
        return Math.max(level, 1);
    }

	// documentation inherited
    override public function get bounds () :Sprite
    {
        return _dmgbox.boundbox;
    }

    /**
     * Returns the player's attack level.
     */
    public function get attackLevel () :int
    {
        return _attackLevel;
    }

    /**
     * Returns the current value of the hit counter.
     */
    public function get hits () :int
    {
        return _hits;
    }

    /**
     * Returns the number of seconds remaining until respawn.
     */
    public function get respawnCountdown () :int
    {
        return dead ? Math.round(RESPAWN_INTERVAL - _deathClock) : 0;
    }

    /**
     * Returns the number of enemies targeting this player.
     */
    public function get attackers () :int
    {
        return _attackers;
    }

    /**
     * Sets the number of enemies targeting this player.
     */
    public function set attackers (number :int) :void
    {
        _attackers = number;
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
        if (amOwner) {
            // make sure we can attack
            if (_action != "idle" && _action != "walk" && _action != "sprint") {
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
            _attackLevel = secondary ? 0 : (_attackLevel + 1) % (Attack.MAX_LEVEL + 1);
            _attackResetCountdown = ATTACK_RESET_INTERVAL;

            // attacking delays the health tick
            _healthTickCountdown = HEALTH_TICK_INTERVAL;

            // use the current orientation
            dir = _character.scaleX;
        }

        // play the attack animations
        var attacks :Array = secondary ? Attack.SECONDARY_ATTACKS : Attack.PRIMARY_ATTACKS;
        _attack = attacks[_weapon][level];
        setAction("attack", _attack.animation, _attack.name);
        orient(dir);

        if (amOwner) {
            // stop the pawn and announce the attack
            stop();
            send({ type: ATTACK, secondary: secondary, level: level, dir: dir });

            // run the camera effect, if any
            if (_attack.effect != null) {
                _view.playCameraEffect(_attack.effect);
            }
        }
    }

    // documentation inherited
    override public function wasHit (attacker :Pawn, damage :Number) :void
    {
		var points :int = Math.round(damage * 4);
        _ctrl.score -= points;
        super.wasHit(attacker, damage);
        _ctrl.incrementStat("playerDamage", damage);
		if (amOwner) {
			_ctrl.damageTaken += damage;
		}
    }

    // documentation inherited
    override public function didHit (target :Pawn, damage :Number) :void
    {
        // update the hit count and score
        var points :int = Math.round((damage/4) * ((++_hits)/2));
        _ctrl.score += points;
        _hitResetCountdown = HIT_RESET_INTERVAL;
        _view.hud.updateHits();

		if(damage >= 1500){
			_ctrl.control.player.awardTrophy("hax");
		}

        // damage the weapon for hits after the first
        if (_hits > 1) {
            damageWeapon();
        }
    }

    // documentation inherited
    override public function block (attacker :Pawn, damage :Number, knockback :Number) :void
    {
        super.block(attacker, damage, knockback);

        // damage weapon, reduce energy
        var amount :Number = damage / 30;
        _energy = Math.max(0, _energy - amount);
        damageWeapon(amount);

        // slide
        var slide :Number = amount + knockback*0.15;
        var pt :Point = getSlideLocation(x, y, x - attacker.x, 0, slide * 30);
        move(pt.x, pt.y, SLIDE);

        // delay the health tick
        _healthTickCountdown = HEALTH_TICK_INTERVAL;
    }

    // documentation inherited
    override public function get maxhp () :Number
    {
        return special ? 9999 : 1500;
    }

    // documentation inherited
    override public function set blocking (value :Boolean) :void
    {
        // make sure we have enough energy to block
        if (!(amOwner && value && (_energy <= 0 || _depleted))) {
            super.blocking = value;
        }
    }

    // documentation inherited
    override public function move (
        x :Number, y :Number, motion :int = SNAP, publish :Boolean = true) :void
    {
        // make sure we have enough energy to sprint
        if (!(amOwner && motion == SPRINT && (_energy <= 0 || _depleted))) {
            super.move(x, y, motion, publish);
        }
    }

    // documentation inherited
    override public function receive (message :Object) :void
    {
        if (message.type == ATTACK) {
            attack(message.secondary, message.level, message.dir);
        } else {
            super.receive(message);
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
		if(_ctrl._disableControls != true){
			// check for collision of damage box with enemies when attacking
			hitTestEnemies();

			// if he's on the door, notify the controller
			if (!dead && _view.door.hitTestObject(_bounds)) {
				_ctrl.playerOnDoor();
			}
			if (!amOwner) {
				return;
			}

			// respawn if enough time has passed since death
			if (dead) {
				if (_deathClock > RESPAWN_INTERVAL) {
					respawn();
				}
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

			// reset the attack level if enough time has passed
			if ((_attackResetCountdown -= elapsed) <= 0) {
				_attackLevel = 0;
			}

			// reset the hit count if enough time has passed
			if ((_hitResetCountdown -= elapsed) <= 0) {
				_hits = 0;
			}

			// increment the player's health over time
			if ((_healthTickCountdown -= elapsed) <= 0) {
				heal(maxhp * HEALTH_TICK_AMOUNTS[_ctrl.difficulty]);
				_healthTickCountdown = HEALTH_TICK_INTERVAL;
			}

			// if he isn't moving, have him face the cursor
			if (_action == "idle") {
				face(_view.cursor.x);
			}
		}
    }

    /**
     * Heals the local player by the specified amount.
     */
    public function heal (amount :Number) :void
    {
        var ohp :Number = _hp;
        if ((_hp = Math.min(_hp + amount, maxhp)) != ohp) {
            publish();
        }
    }

    /**
     * Sets or boosts the local player's weapon.
     */
    public function setWeapon (weapon :int, level :int = 0) :void
    {
        // setting the same weapon increments the experience
        var exp :Number = level*EXPERIENCE_PER_LEVEL;
        if (_weapon == weapon) {
            _experience = Math.min(_experience + exp, MAX_EXPERIENCE);
            return;
        }
        // drop the current weapon, if any (and it's not broken)
        if (_weapon != Weapon.FISTS && _experience > 0) {
            _ctrl.createPickup(Weapon.createState(x+80, y+50, _weapon, this.level));
        }
        _experience = exp;
        this.weapon = weapon;
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
        _plate.name_plate.text = _ctrl.control.game.getOccupantName(playerId);

		// Configure appearance based on name
		var ta: String = _plate.name_plate.text; //Grab the name
		var face: int = 0; //Which hair/face to use
		var appearance: int = 1; //Which Frame to use
		var gender: Boolean = false; //False = male, True = female
		if ((ta.length % 2) == 0) { gender = false; } else { gender = true; }
		ta = ta.toLowerCase(); //convert to lower case
		switch (ta.charAt()) {
			case "a":
			case "d":
			case "g":
			case "j":
			case "m":
			case "p":
			case "s":
			case "v":
			case "y":
				face = 1;
				break;
			case "c":
			case "f":
			case "i":
			case "l":
			case "o":
			case "r":
			case "u":
			case "x":
				face = 1;
				break;
			default :
				face = 0;
				break;
		}
		if(gender){
			if(face == 2){
				appearance = 5;
			}else if(face == 1){
				appearance = 3;
			}else{
				appearance = 1;
			}
		}else{
			if(face == 2){
				appearance = 6;
			}else if(face == 1){
				appearance = 4;
			}else{
				appearance = 2;
			}
		}

		//Special Cases
		if(ta == "cherub"){ //Myself
			appearance = 7;
		}else if(ta == "jes"){ //My dearest
			appearance = 8;
		}else if(ta == "tester_1"){ //Testing
			appearance = 2;
		}
		_character.hat.gotoAndStop(appearance);
		_character.face.gotoAndStop(appearance);
		_character.f_hair.gotoAndStop(appearance);
		_character.f_ear.gotoAndStop(appearance);
		_character.skull.gotoAndStop(appearance);
		_character.r_ear.gotoAndStop(appearance);
		_character.r_hair.gotoAndStop(appearance);

        // set the weapon
        weapon = state.weapon;

        // remove the health bar if it's the local player
        if (amOwner) {
            _psprite.removeChild(_health);
            if (special) {
                _hp = maxhp; // handle special maximum
                _experience = MAX_EXPERIENCE;
            }
        }
    }

    /**
     * Checks whether this is a special player.
     */
    public function get special () :Boolean
    {
        return false; // _plate.name_plate.text == "Jes";
    }

    /**
     * Damages the player's weapon.
     */
    protected function damageWeapon (amount :Number = 4.5) :void
    {
        amount *= DIFFICULTY_DAMAGE_MULTIPLIERS[_ctrl.difficulty];
        amount *= LEVEL_DAMAGE_MULTIPLIERS[level-1];
        experience = Math.max(0, experience - amount);
        _view.hud.weaponDamaged();
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
            if (!(actor is Enemy && actor.amOwner)) {
                continue;
            }
            var enemy :Enemy = actor as Enemy;
            if (!(enemy.hittable && _dmgbox.dmg_box.hitTestObject(enemy.bounds))) {
                continue;
            }
            // we've scored a hit
            var damage :Number = special ? 9999 : _attack.damage*ATTACK_LEVEL_MULTIPLIERS[level];
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
            enemy.hurt(this, damage, knockback, stun);
        }
    }

    // documentation inherited
    override protected function updateDirection () :void
    {
        // have the player's character face the cursor when idle
        if (amOwner && _action == "idle") {
            face(_view.cursor.x);
        } else {
            super.updateDirection();
        }
    }

    // documentation inherited
    override protected function stopped () :void
    {
        // make sure the goal sprite is hidden
        super.stopped();
        if (amOwner) {
            _view.hideGoal();
        }
    }

    // documentation inherited
    override protected function died () :void
    {
        super.died();
        _ctrl.incrementStat("koCount");
        if (amOwner) {
            experience = 0;
			_ctrl.lemmingCount += 1;
        }
    }

    // documentation inherited
    override protected function respawn () :void
    {
        invulnerableCountdown = RESPAWN_INVULNERABILITY;
        _energy = 100;
        _depleted = false;
		if (amOwner) {
            setWeapon(1,1);
			_experience = 100;
        }
        super.respawn(); // publishes the state
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
        return _ctrl.create("PlayerBlip");
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
        return _ctrl.create(critical ? "PlayerCriticalDamageNumber" : "PlayerDamageNumber");
    }

    // documentation inherited
    override protected function createDamageSnap () :MovieClip
    {
        return _ctrl.create("PlayerDamageSnap");
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

    /** The attack that the player is executing, if any. */
    protected var _attack :Attack;

    /** The hit counter. */
    protected var _hits :int = 0;

    /** The countdown until the attack level is reset. */
    protected var _attackResetCountdown :Number = 0;

    /** The countdown until the next health tick. */
    protected var _healthTickCountdown :Number = 0;

    /** The countdown until the hit count is reset. */
    protected var _hitResetCountdown :Number = 0;

    /** The number of enemies targeting this player. */
    protected var _attackers :int = 0;

    /** The rate (u/s) at which players lose energy when blocking. */
    protected static const BLOCK_ENERGY_RATE :Number = -20;

    /** The rate at which players lose energy when sprinting. */
    protected static const SPRINT_ENERGY_RATE :Number = -100;

    /** The rate at which players regain energy (normally). */
    protected static const NORMAL_ENERGY_RATE :Number = +50;

    /** The rate at which players regain energy after depletion. */
    protected static const DEPLETED_ENERGY_RATE :Number = +50;

    /** The amount of energy required to attack. */
    protected static const ATTACK_ENERGY :Number = 33;

    /** The amount of time after the last attack at which the attack level is cleared (s). */
    protected static const ATTACK_RESET_INTERVAL :Number = 1.50;

    /** The amount of time after the last hit at which the hit count is cleared (s). */
    protected static const HIT_RESET_INTERVAL :Number = 2;

    /** The (default) amount of time between health ticks (s). */
    protected static const HEALTH_TICK_INTERVAL :Number = 3;

    /** For each difficulty level, the health proportion regained at regular intervals. */
    protected static const HEALTH_TICK_AMOUNTS :Array = [ 1/10, 1/20, 1/20, 0 ];

	/** Attack damage multipliers for each weapon level. */
    protected static const ATTACK_LEVEL_MULTIPLIERS :Array = [ 1.00, 1.50, 2.00, 2.50 ];

    /** Weapon damage multipliers for each difficulty level. */
    protected static const DIFFICULTY_DAMAGE_MULTIPLIERS :Array = [ 1.00, 0.75, 0.60, 0.45 ];

    /** Weapon damage multipliers for each weapon level (starting at one). */
    protected static const LEVEL_DAMAGE_MULTIPLIERS :Array = [ 1, 1.5, 2 ];
	//protected static const LEVEL_DAMAGE_MULTIPLIERS :Array = [ 0, 0, 0 ]; //<---Weapon decay disabled for testing

    /** The number of seconds to wait before respawning the player. */
    protected static const RESPAWN_INTERVAL :Number = 10;

    /** The number of seconds of invulnerability players experience after a respawn. */
    protected static const RESPAWN_INVULNERABILITY :Number = 2;

    /** The number of seconds of invulnerability players experience after being stunned. */
    protected static const POST_STUN_INVULNERABILITY :Number = 1.3;
}
}
