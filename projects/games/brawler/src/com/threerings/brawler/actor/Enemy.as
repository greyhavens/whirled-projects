package com.threerings.brawler.actor {

import flash.display.Sprite;
import flash.geom.Point;

import com.threerings.util.ArrayUtil;

import com.threerings.brawler.util.BrawlerUtil;

/**
 * Represents an enemy.
 */
public class Enemy extends Pawn
{
    /**
     * Creates the initial state of an enemy from its configuration.
     */
    public static function createState (
        index: int, config :Object, difficulty :int, players :int) :Object
    {
        var state :Object = new Object();
        state.type = "Enemy";
        state.config = index;
        state.x = config.x;
        state.y = config.y;
        state.motion = SNAP;
        state.hp = parseFloat(config.hp.text) * HP_MULTIPLIERS[difficulty];
        state.blocking = false;
        state.stunCountdown = 0;
        state.invulnerableCountdown = 0;
        if (ArrayUtil.contains(BOSS_NAMES, config.mt.text)) {
            state.respawns = 0;
        } else {
            state.respawns = BASE_RESPAWNS[difficulty] +
                Math.round(RESPAWNS_PER_PLAYER[difficulty] * players) - 1;
        }
        return state;
    }

    /**
     * Checks whether this enemy is a boss (midboss or otherwise).
     */
    public function get boss () :Boolean
    {
        return ArrayUtil.contains(BOSS_NAMES, VARIANT_NAMES[_variant]);
    }

    /**
     * Checks whether this enemy is the final boss.
     */
    public function get finalBoss () :Boolean
    {
        return VARIANT_NAMES[_variant] == "BOSS";
    }

    /**
     * Determines whether this enemy can be knocked back by another enemy.
     */
    public function get knockable () :Boolean
    {
        return !(dead || knocked || _action == "hurt");
    }

    /**
     * Sets the target of the enemy.
     */
    public function set target (player :Player) :void
    {
        if (_target == player) {
            return;
        }
        if (_target != null) {
            _target.attackers--;
        }
        _target = player;
        if (_target != null) {
            _target.attackers++;
        }
    }

    /**
     * Initiates an attack.
     */
    public function attack (level :int = -1, dir :int = -1) :void
    {
        if (amOwner) {
            // make sure we can attack
            if (_action != "idle" && _action != "walk") {
                return;
            }
            // use the current orientation
            dir = _character.scaleX;

            // use and update the attack level
            level = _attackLevel;
            _attackLevel = (_attackLevel + 1) % (Attack.MAX_LEVEL + 1);

            // push out the attack countdown
            _attackCountdown = _cooldown;
        }

        // play the attack animation (for the boss, append the attack level)
        setAction("attack", "punch" + (boss  ? (level + 1) : ""));
        orient(dir);

        if (amOwner) {
            // stop the pawn and announce the attack
            stop();
            send({ type: ATTACK, level: level, dir: dir });
        }
    }

    // documentation inherited
    override public function wasBlocked (hurt :Boolean) :void
    {
        super.wasBlocked(hurt);
        if (amOwner && hurt) {
            _attackCountdown = Math.max(_attackCountdown, 0) + 2;
        }
    }

    // documentation inherited
    override public function wasDestroyed () :void
    {
        super.wasDestroyed();
        _ctrl.enemyWasDestroyed(this);
        target = null;
        if (!dead) {
            // strangely enough, the ghost appears when we're *not* dead
            _view.addTransient(_ctrl.create("Ghost"), x, y, true);
        }
    }

    // documentation inherited
    override public function hurt (
        attacker :Pawn, damage :Number, knockback :Number, stun :Number) :void
    {
        // perhaps release a coin
		if(knockback > 0){
			var temp_kb:Number = knockback - _weight;
			if(temp_kb < 0){
				temp_kb = 0;
			}
		}
        super.hurt(attacker, damage, temp_kb, stun);
        if (Math.random() < COIN_DROP_PROBABILITY) {
            _ctrl.createPickup(Coin.createState(_view, x, y));
        }
    }

    // documentation inherited
    override public function wasHit (attacker :Pawn, damage :Number) :void
    {
        super.wasHit(attacker, damage);
        _ctrl.incrementStat("enemyDamage", damage);
        if (amOwner && attacker is Player) {
            // target the attacker
            target = attacker as Player;
        }
    }

    // documentation inherited
    override public function get bounds () :Sprite
    {
        return _character.boundbox;
    }

    // documentation inherited
    override public function get maxhp () :Number
    {
        return _maxhp;
    }

    // documentation inherited
    override public function receive (message :Object) :void
    {
        if (message.type == ATTACK) {
            attack(message.level, message.dir);
        } else {
            super.receive(message);
        }
    }

    // documentation inherited
    override public function decode (state :Object) :void
    {
        super.decode(state);
        _respawns = state.respawns;
        target = (state.target == null) ? null : _ctrl.actors[state.target];
        if (_target != null) {
            _owner = _target.owner;
        }
    }

    // documentation inherited
    override public function enterFrame (elapsed :Number) :void
    {
        super.enterFrame(elapsed);

        // hide the health bar if the player is far enough away
        _health.visible = (Math.abs(x - _ctrl.cameraTarget.x) < HIDE_HEALTH_DISTANCE);

        // check for collisions against players
        hitTestPlayers();

        // check for collisions against other enemies being knocked back
        hitTestEnemies();

        // update ai behavior
        _attackCountdown -= elapsed;
        if (!(amOwner && canMove)) {
            return;
        }
        var ground :Sprite = _view.ground;
        if (_target != null) {
            if (_target.parent == null || _target.dead) {
                // target died/disappeared: flee back to spawn point
                target = null;
                move(_spawnX, _spawnY, WALK);
                return;
            }
            var tdist :Number = distance(_target);
            if (!moving) {
                var dx :Number, dy :Number;
                if (_attackCountdown > 0) {
                    // evade (stay out of player's reach)
                    if (tdist >= SIGHT_RANGE && tdist <= SIGHT_RANGE * 1.5) {
                        return;
                    }
                    dx = getRandomLocation(
                        _target.x, SIGHT_RANGE * 0.25, SIGHT_RANGE * 1.25,
                        0, ground.width, x);
                    dy = getRandomLocation(
                        _target.y, 0, 125, ground.y - ground.height, ground.y,
                        _view.groundCenterY);
                } else {
                    // approach (get within attack range)
                    dx = getRandomLocation(
                        _target.x, _range * scaleX * 0.85, _range * scaleX,
                        0, ground.width, x);
                    dy = getRandomLocation(
                        _target.y, 0, 5, ground.y - ground.height, ground.y,
                        _target.y);
                }
                move(dx, dy, WALK);
            }
            if (_attackCountdown <= 0 && distance(_target) <= _range*scaleX &&
                    Math.abs(y - _target.y) <= 5) {
                attack();
                return; // don't fall through to random movement
            }
        } else {
            // choose the best player based on distance and current number of attackers
            var bplayer :Player = null;
            var bscore :Number = Number.MAX_VALUE;
            for each (var actor :Actor in _ctrl.actors) {
                if (!(actor is Player)) {
                    continue;
                }
                var player :Player = actor as Player;
                var dist :Number = distance(player);
                var score :Number = dist + player.attackers*1000;
                if (!player.dead && dist <= SIGHT_RANGE && score < bscore) {
                    bplayer = player;
                    bscore = score;
                }
            }
            if ((target = bplayer) != null) {
                return; // approach target next go-round
            }
        }
        if (!moving) {
            // if we have nothing else to do, move to a random destination on the ground
            move(
                BrawlerUtil.random(ground.width),
                BrawlerUtil.random(ground.y, ground.y - ground.height),
                WALK);
        }
    }

    // documentation inherited
    override protected function didInit (state :Object) :void
    {
        super.didInit(state);

        // extract the configuration
        var config :Object = _ctrl.getEnemyConfig(_config = state.config);
        _variant = VARIANT_NAMES.indexOf(config.mt.text);
        var difficulty :int = _ctrl.difficulty;
        _spawnX = config.x;
        _spawnY = config.y;
        _speed = parseFloat(config.spd.text) * SPEED_MULTIPLIERS[difficulty];
        _maxhp = parseFloat(config.hp.text) * HP_MULTIPLIERS[difficulty];
        _range = parseFloat(config.rng.text);
        _cooldown = (parseFloat(config.fst.text) * COOLDOWN_MULTIPLIERS[difficulty]) / 1000;
        _min = parseFloat(config.min.text) * MINMAX_MULTIPLIERS[difficulty];
        _max = parseFloat(config.max.text) * MINMAX_MULTIPLIERS[difficulty];
        _knockback = parseFloat(config.knockback.text) * KNOCKBACK_MULTIPLIERS[difficulty];
        _stun = parseFloat(config.stun.text) * STUN_MULTIPLIERS[difficulty];
		_weight = parseFloat(config.weight.text);
		_def = parseFloat(config.def.text);
        _respawns = state.respawns;

        // remove various unnecessary bits
        _psprite.removeChild(_dmgbox);
        _psprite.removeChild(_bounds);
        _psprite.removeChild(_plate);

        // swap in the character corresponding to the variant
        _psprite.removeChild(_character);
        _psprite.addChild(_character = _ctrl.create(VARIANT_CLASSES[_variant]));
        _character.addEventListener("animationComplete", handleAnimationComplete);
        _dmgbox = null;

        // reposition the health bar above the character
        _health.y = -_character.height;

        // initialize the attack countdown
        _attackCountdown = _cooldown;

        // play the spawn animation
        setAction("spawn");

		// add to total Monster HP
		_ctrl._mobHpTotal += _maxhp;
    }

    /**
     * Checks for hits against players.
     */
    protected function hitTestPlayers () :void
    {
        if (_action != "attack") {
            return;
        }
        for each (var actor :Actor in _ctrl.actors) {
            if (!(actor is Player && actor.amOwner)) {
                continue;
            }
            var player :Player = actor as Player;
            if (!(player.hittable && _character.dmgbox.hitTestObject(player.bounds))) {
                continue;
            }
            player.hurt(this, BrawlerUtil.random(_max, _min), _knockback, _stun);
        }
    }

    /**
     * Checks for hits against enemies.
     */
    protected function hitTestEnemies () :void
    {
        if (!knocked) {
            return;
        }
        var distance :Number = Point.distance(new Point(x, y), _goal);
        var slide :Number = getSlideSpeed(distance) / 30; // fps
        if (slide <= 1) {
            return;
        }
        for each (var actor :Actor in _ctrl.actors) {
            if (!(actor is Enemy && actor.amOwner && actor != this)) {
                continue;
            }
            var enemy :Enemy = actor as Enemy;
            if (!(enemy.knockable && bounds.hitTestObject(enemy.bounds))) {
                continue;
            }
            enemy.hurt(this, 0, slide, 0);
        }
    }

    // documentation inherited
    override protected function died () :void
    {
        super.died();
        if (!amOwner) {
            return;
        }
        // clear out the target
        target = null;

        // perhaps drop a pickup
        var prob :Number = Math.random();
        var state :Object;
		if (prob < PET_DROP_PROBABILITY && !boss && _ctrl.difficulty_setting != "Easy") {
		    // TODO: this class is not in SVN
            // _ctrl.createPickup(Loot.createState(x, y, _variant));
        } else if (prob < PET_DROP_PROBABILITY + HEALTH_DROP_PROBABILITY) {
            _ctrl.createPickup(Health.createState(x, y));
        } else if (prob < PET_DROP_PROBABILITY + HEALTH_DROP_PROBABILITY + WEAPON_DROP_PROBABILITY) {
            var weapon :int = WEAPON_TYPES[_variant];
            if (weapon == -1) {
                return;
            }
            var level :int = BrawlerUtil.pickRandomIndex(WEAPON_LEVEL_PROBABILITIES) + 1;
            _ctrl.createPickup(Weapon.createState(x, y, weapon, level));
        }
    }

    // documentation inherited
    override protected function disappeared () :void
    {
        super.disappeared();
        if (!amOwner) {
            return;
        }
        if (_respawns-- > 0 || (_ctrl.bossPresent && !boss)) {
            respawn();
        } else {
            destroy();
        }
    }

    // documentation inherited
    override protected function respawn () :void
    {
        super.respawn();
		// add to total Monster HP
		_ctrl._mobHpTotal += _maxhp;
        _attackCountdown = _cooldown;
    }

    // documentation inherited
    override protected function knockEnded () :void
    {
        super.knockEnded();
        if (boss) {
            invulnerableCountdown = POST_KNOCK_INVULNERABILITY;
        }
    }

    // documentation inherited
    override protected function createRadarBlip () :Sprite
    {
        return _ctrl.create("EnemyBlip");
    }

    // documentation inherited
    override protected function publish () :void
    {
        // update the owner immediately after publishing
        super.publish();
        if (_target != null) {
            _owner = _target.owner;
        }
    }

    // documentation inherited
    override protected function encode () :Object
    {
        var state :Object = super.encode();
        state.config = _config;
        state.respawns = _respawns;
        state.target = (_target == null) ? null : _target.name;
        return state;
    }

    // documentation inherited
    override protected function updateDirection () :void
    {
        // the enemy should normal face the target
        if (_target != null && (_action == "idle" || _action == "walk")) {
            face(_target.x);
        } else if (knocked) {
            super.updateDirection();
        }
    }

    // documentation inherited
    override protected function get spawnX () :Number
    {
        return _spawnX;
    }

    // documentation inherited
    override protected function get spawnY () :Number
    {
        return _spawnY;
    }

    // documentation inherited
    override protected function get baseSpeed () :Number
    {
        return _speed;
    }

    /**
     * Finds a random location that lies within a distance range from a center position,
     * subject to upper and lower bounds, and preferring locations on the same side as
     * a reference position.
     *
     * @param center the center position (assumed to lie between the upper and lower bounds).
     * @param minDist the minimum distance from the reference position.
     * @param maxDist the maximum distance from the reference position.
     * @param lowerBound the minimum value that positions may take.
     * @param upperBound the maximum value that positions may take.
     * @param reference a reference position used to determine the preferred side.
     */
    protected static function getRandomLocation (
        center :Number, minDist :Number, maxDist :Number,
        lowerBound :Number, upperBound :Number, reference :Number) :Number
    {
        var lmin :Number = Math.max(center - maxDist, lowerBound);
        var lmax :Number = Math.max(center - minDist, lowerBound);
        var rmin :Number = Math.min(center + minDist, upperBound);
        var rmax :Number = Math.min(center + maxDist, upperBound);
        var llen :Number = lmax - lmin, rlen :Number = rmax - rmin;
        if (reference < center && llen > 0) { // use values left of center
            return BrawlerUtil.random(lmax, lmin);
        } else if (reference > center && rlen > 0) { // use right
            return BrawlerUtil.random(rmax, rmin);
        } else { // use both
            var loc :Number = BrawlerUtil.random(llen + rlen);
            return (loc < llen) ? (lmin + loc) : rmin + (loc - llen);
        }
    }

    /** The enemy's configuration index. */
    protected var _config :int;

    /** The index of the enemy variant. */
    protected var _variant :int;

    /** The enemy's spawn location. */
    protected var _spawnX :Number, _spawnY :Number;

    /** The enemy's speed. */
    protected var _speed :Number;

    /** The enemy's maximum hit points. */
    protected var _maxhp :Number;

    /** The enemy's range. */
    protected var _range :Number;

    /** The enemy's cooldown time. */
    protected var _cooldown :Number;

    /** The enemy's minimum damage. */
    protected var _min :Number;

    /** The enemy's maximum damage. */
    protected var _max :Number;

    /** The enemy's knockback amount. */
    protected var _knockback :Number;

    /** The enemy's stun amount. */
    protected var _stun :Number;

	/** The enemy's knockback dampening. */
    protected var _weight :Number;

	/** The enemy's chance to block attacks. */
    protected var _def :Number;

    /** The enemy's remaining respawns. */
    protected var _respawns :Number;

    /** The enemy's current target. */
    protected var _target :Player;

    /** The enemy's attack level. */
    protected var _attackLevel :int = 0;

    /** The countdown until the enemy can attack. */
    protected var _attackCountdown :Number;

    /** Character classes for the enemy variants. */
    protected static const VARIANT_CLASSES :Array =
        [ "Peon", "Grunt", "Brute", "Midboss", "Boss" ];

    /** The names of the enemy variants. */
    protected static const VARIANT_NAMES :Array =
        [ "Peon", "Grunt", "Brute", "Midboss", "BOSS" ];

    /** The names of the boss variants. */
    protected static const BOSS_NAMES :Array = [ "Midboss", "BOSS" ];

    /** Hit point multipliers for the various difficulty levels. */
    protected static const HP_MULTIPLIERS :Array = [ 0.5, 1.0, 1.5, 2.0 ];

    /** Speed multipliers per difficulty level. */
    protected static const SPEED_MULTIPLIERS :Array = [ 0.8, 1.0, 1.5, 2.0 ];

    /** Cooldown multipliers per difficulty level. */
    protected static const COOLDOWN_MULTIPLIERS :Array = [ 2.0, 1.0, 0.75, 0.5 ];

    /** Min/max multipliers per difficulty level. */
    protected static const MINMAX_MULTIPLIERS :Array = [ 0.5, 1.0, 1.75, 2.5 ];

    /** Knockback multipliers per difficulty level. */
    protected static const KNOCKBACK_MULTIPLIERS :Array = [ 0.5, 1.0, 1.0, 1.0 ];

    /** Stun multipliers per difficulty level. */
    protected static const STUN_MULTIPLIERS :Array = [ 0.0, 1.0, 1.0, 1.0 ];

    /** Constant respawns per difficulty level. */
    protected static const BASE_RESPAWNS :Array = [ 1, 0, 2, 4 ];

    /** Respawns per player per difficulty level. */
    protected static const RESPAWNS_PER_PLAYER :Array = [ 0, 1.75, 2.25, 2.5 ];

    /** The chance that the enemy will drop a coin each time it's hit. */
    protected static const COIN_DROP_PROBABILITY :Number = 0.20;

    /** The chance that the enemy will drop a health pickup when it dies. */
    protected static const HEALTH_DROP_PROBABILITY :Number = 0.15;

    /** The chance that the enemy will drop a weapon pickup when it dies. */
    protected static const WEAPON_DROP_PROBABILITY :Number = 0.65;

	/** The chance that the enemy will drop a Pet of itself when it dies. */
    protected static const PET_DROP_PROBABILITY :Number = 0.005;

    /** The weapon types carried by each enemy variant. */
    protected static const WEAPON_TYPES :Array =
        [ Weapon.SWORD, Weapon.BOW, Weapon.HAMMER, -1, -1 ];

    /** The probabilities for each weapon level. */
    protected static const WEAPON_LEVEL_PROBABILITIES :Array = [ 0.80, 0.15, 0.05 ];

    /** Hide the health bar when the local player is this far away from the enemy. */
    protected static const HIDE_HEALTH_DISTANCE :Number = 210;

    /** The distance within which enemies can "see." */
    protected static const SIGHT_RANGE :Number = 1500;
}
}
