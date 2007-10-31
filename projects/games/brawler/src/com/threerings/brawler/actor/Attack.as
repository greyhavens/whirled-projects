package com.threerings.brawler.actor {

import com.threerings.brawler.util.BrawlerUtil;

/**
 * Contains information on the various weapon attacks.
 */
public class Attack
{
    /** The maximum attack level. */
    public static const MAX_LEVEL :int = 2;

    /** The primary fist attacks for each level. */
    public static const PRIMARY_FIST_ATTACKS :Array = [
        new Attack("left hook", "punch2", 100, 120),
        new Attack("right hook", "punch2", 120, 150),
        new Attack("left hook", "punch2", 100, 120) ];

    /** The secondary fist attacks for each level. */
    public static const SECONDARY_FIST_ATTACKS :Array = [
        new Attack("straight fist", "punch2", 150, 200, 5, 5),
        new Attack("straight fist", "punch2", 150, 200, 5, 5),
        new Attack("straight fist", "punch2", 150, 200, 5, 5) ];

    /** The primary sword attacks for each level. */
    public static const PRIMARY_SWORD_ATTACKS :Array = [
        new Attack("sword_lt_1", "sword_lt_1", 90, 120),
        new Attack("sword_lt_2", "sword_lt_2", 100, 135),
        new Attack("sword_lt_3", "sword_lt_3", 120, 150, 2, 6, 0, 2) ];

    /** The secondary sword attacks for each level. */
    public static const SECONDARY_SWORD_ATTACKS :Array = [
        new Attack("sword_hv_1", "sword_hv_1", 120, 150, 0, 15, 0, 0),		//Upper Cut
        new Attack("sword_hv_2", "sword_hv_2", 150, 240, 15, 30, 0, 0),		//Dash
        new Attack("sword_hv_3", "sword_hv_3", 300, 510, 0, 0, 2, 3) ];		//Final Smash

    /** The primary hammer attacks for each level. */
    public static const PRIMARY_HAMMER_ATTACKS :Array = [
        new Attack("hammer_lt_1", "hammer_lt_1", 120, 165),					//Swing
        new Attack("hammer_lt_2", "hammer_lt_2", 200, 255, 0, 0, 1, 2),		//Sledge
        new Attack("hammer_lt_3", "hammer_lt_3", 240, 300, 40, 60) ]; 		//Golf

    /** The secondary hammer attacks for each level. */
    public static const SECONDARY_HAMMER_ATTACKS :Array = [
        new Attack("hammer_hv_1", "hammer_hv_1", 210, 240, 70, 85, 0, 0),	// Home Run
        new Attack("hammer_hv_2", "hammer_hv_2", 120, 150, 0, 6, 2, 3),		// Stun
        new Attack("hammer_hv_3", "hammer_hv_3", 300, 420, 25, 40, 0, 0) ];		// Round House

    /** The primary bow attacks for each level. */
    public static const PRIMARY_BOW_ATTACKS :Array = [
        new Attack("bow_lt_1", "bow_lt_1", 75, 90),
        new Attack("bow_lt_2", "bow_lt_2", 85, 110),
        new Attack("bow_lt_3", "bow_lt_3", 100, 120, 2, 20) ];

    /** The secondary bow attacks for each level. */
    public static const SECONDARY_BOW_ATTACKS :Array = [
        new Attack("power shot", "bow2", 300, 400),
        new Attack("tri shot", "bow2", 200, 300),
        new Attack("arrow rain", "bow2", 200, 400) ];

    /** Primary attack arrays for each weapon. */
    public static const PRIMARY_ATTACKS :Array = [
        PRIMARY_FIST_ATTACKS, PRIMARY_SWORD_ATTACKS, PRIMARY_HAMMER_ATTACKS, PRIMARY_BOW_ATTACKS ];

    /** Secondary attack arrays for each weapon. */
    public static const SECONDARY_ATTACKS :Array = [
        SECONDARY_FIST_ATTACKS, SECONDARY_SWORD_ATTACKS, SECONDARY_HAMMER_ATTACKS,
        SECONDARY_BOW_ATTACKS ];

    /** The name of the attack (and of the damage box animation). */
    public var name :String;

    /** The name of the character attack animation. */
    public var animation :String;

    /** The name of the camera effect, if any. */
    public var effect :String;

    public function Attack (
        name :String, animation :String, minDamage :Number, maxDamage :Number,
        minKnockback :Number = 0, maxKnockback :Number = 0,
        minStun :Number = 0, maxStun :Number = 0, effect :String = null)
    {
        this.name = name;
        this.animation = animation;
        _minDamage = minDamage;
        _maxDamage = maxDamage;
        _minKnockback = minKnockback;
        _maxKnockback = maxKnockback;
        _minStun = minStun;
        _maxStun = maxStun;
        this.effect = effect;
    }

    /**
     * Returns the amount of (base) damage caused by this attack.
     */
    public function get damage () :Number
    {
        return BrawlerUtil.random(_maxDamage, _minDamage);
    }

    /**
     * Returns the amount of knockback caused by this attack.
     */
    public function get knockback () :Number
    {
        return BrawlerUtil.random(_maxKnockback, _minKnockback);
    }

    /**
     * Returns the amount of stun caused by this attack.
     */
    public function get stun () :Number
    {
        return BrawlerUtil.random(_maxStun, _minStun);
    }

    /** The range of (base) damage caused by this attack. */
    public var _minDamage :Number, _maxDamage :Number;

    /** The range of knockback caused by this attack. */
    public var _minKnockback :Number, _maxKnockback :Number;

    /** The range of stun caused by this attack. */
    public var _minStun :Number, _maxStun :Number;
}
}
