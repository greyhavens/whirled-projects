package com.threerings.brawler.actor {

import flash.display.Sprite;

import com.threerings.util.ArrayUtil;

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

    // documentation inherited
    override public function wasDestroyed () :void
    {
        super.wasDestroyed();
        _ctrl.enemyWasDestroyed(this);
    }

    // documentation inherited
    override public function hurt (
        attacker :Pawn, damage :Number, knockback :Number, stun :Number) :void
    {
        // perhaps release a coin
        super.hurt(attacker, damage, knockback, stun);
        if (Math.random() < COIN_DROP_PROBABILITY) {
            _ctrl.createCoin(x, y);
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
    override public function decode (state :Object) :void
    {
        super.decode(state);
        _respawns = state.respawns;
    }

    // documentation inherited
    override public function enterFrame (elapsed :Number) :void
    {
        // hide the health bar if the player is far enough away
        super.enterFrame(elapsed);
        _health.visible = (Math.abs(x - _ctrl.self.x) < HIDE_HEALTH_DISTANCE);
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
        _cooldown = parseFloat(config.fst.text) * COOLDOWN_MULTIPLIERS[difficulty];
        _min = parseFloat(config.min.text) * MINMAX_MULTIPLIERS[difficulty];
        _max = parseFloat(config.max.text) * MINMAX_MULTIPLIERS[difficulty];
        _knockback = parseFloat(config.knockback.text) * KNOCKBACK_MULTIPLIERS[difficulty];
        _stun = parseFloat(config.stun.text) * STUN_MULTIPLIERS[difficulty];
        _respawns = state.respawns;

        // remove various unnecessary bits
        _psprite.removeChild(_dmgbox);
        _psprite.removeChild(_bounds);
        _psprite.removeChild(_plate);

        // swap in the character corresponding to the variant
        _psprite.removeChild(_character);
        _psprite.addChild(_character = new VARIANT_CLASSES[_variant]);

        // reposition the health bar above the character
        _health.y = -_character.height;
    }

    // documentation inherited
    override protected function disappeared () :void
    {
        super.disappeared();
        if (!_master) {
            return;
        }
        if (_respawns-- > 0 || (_ctrl.bossPresent && !boss)) {
            respawn();
        } else {
            destroy();
        }
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
        return new EnemyBlip();
    }

    // documentation inherited
    override protected function encode () :Object
    {
        var state :Object = super.encode();
        state.config = _config;
        state.respawns = _respawns;
        return state;
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

    /** The enemy's remaining respawns. */
    protected var _respawns :Number;

    /** The peon character class. */
    [Embed(source="../../../../../rsrc/raw.swf", symbol="mob1")]
    protected static const Peon :Class;

    /** The grunt character class. */
    [Embed(source="../../../../../rsrc/raw.swf", symbol="mob2")]
    protected static const Grunt :Class;

    /** The brute character class. */
    [Embed(source="../../../../../rsrc/raw.swf", symbol="mob3")]
    protected static const Brute :Class;

    /** The midboss character class. */
    [Embed(source="../../../../../rsrc/raw.swf", symbol="midboss")]
    protected static const Midboss :Class;

    /** The boss character class. */
    [Embed(source="../../../../../rsrc/raw.swf", symbol="boss")]
    protected static const Boss :Class;

    /** The enemy blip class. */
    [Embed(source="../../../../../rsrc/raw.swf", symbol="blip_npc")]
    protected static const EnemyBlip :Class;

    /** The ghost class. */
    [Embed(source="../../../../../rsrc/raw.swf", symbol="death_effect")]
    protected static const Ghost :Class;

    /** Character classes for the enemy variants. */
    protected static const VARIANT_CLASSES :Array = [ Peon, Grunt, Brute, Midboss, Boss ];

    /** The names of the enemy variants. */
    protected static const VARIANT_NAMES :Array = [ "Peon", "Grunt", "Brute", "Midboss", "BOSS" ];

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
    protected static const COIN_DROP_PROBABILITY :Number = 0.25;

    /** Hide the health bar when the local player is this far away from the enemy. */
    protected static const HIDE_HEALTH_DISTANCE :Number = 210;
}
}
