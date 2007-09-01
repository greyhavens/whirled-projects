package com.threerings.brawler.actor {

import flash.display.MovieClip;

/**
 * Represents a weapon pickup.
 */
public class Weapon extends Pickup
{
    /** The fist weapon (never used as a pickup). */
    public static const FISTS :int = 0;

    /** The sword weapon. */
    public static const SWORD :int = 1;

    /** The hammer weapon. */
    public static const HAMMER :int = 2;

    /** The bow weapon. */
    public static const BOW :int = 3;

    /** The labels of the animation frames for each weapon type (used in the character display as
     * well as the HUD. */
    public static const FRAME_LABELS :Array = [ "fists", "sword1", "hammer1", "bow1" ];

    /**
     * Creates an initial weapon pickup state.
     */
    public static function createState (x :Number, y :Number, weapon :int, level :int) :Object
    {
        return { type: "Weapon", x: x, y: y, weapon: weapon, level: level };
    }

    public function Weapon ()
    {
        addChild(_clip = new WeaponDrop());
    }

    // documentation inherited
    override public function decode (state :Object) :void
    {
        super.decode(state);
        _weapon = state.weapon;
        _level = state.level;
        _clip.gotoAndStop(WEAPON_NAMES[_weapon] + _level);
    }

    // documentation inherited
    override protected function encode () :Object
    {
        var state :Object = super.encode();
        state.weapon = _weapon;
        state.level = _level;
        return state;
    }

    /** The weapon drop clip. */
    protected var _clip :MovieClip;

    /** The index of the weapon. */
    protected var _weapon :int;

    /** The level of the weapon. */
    protected var _level :int;

    /** The weapon drop sprite class. */
    [Embed(source="../../../../../rsrc/raw.swf", symbol="weapon_drop")]
    protected static const WeaponDrop :Class;

    /** The base names of the weapons. */
    protected static const WEAPON_NAMES :Array = [ "fists", "sword", "hammer", "bow" ];
}
}
