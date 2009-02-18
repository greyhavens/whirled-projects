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

    // documentation inherited
    override protected function didInit (state :Object) :void
    {
        super.didInit(state);

        // initialize the scale
        _clip.scaleX = 1 / scaleX;
        _clip.scaleY = 1 / scaleX;

        // initialize the type and level
        _weapon = state.weapon;
        _level = state.level;
        _clip.cn.gotoAndStop(label);
    }

    // documentation inherited
    override protected function get clipClass () :String
    {
        return "WeaponDrop";
    }

    // documentation inherited
    override protected function encode () :Object
    {
        var state :Object = super.encode();
        state.weapon = _weapon;
        state.level = _level;
        return state;
    }

    // documentation inherited
    override protected function get available () :Boolean
    {
        return _age > 1.2;
    }

    // documentation inherited
    override protected function hit (player :Player) :void
    {
        if(player.blocking || player.weapon == _weapon || player.weapon == FISTS){
            super.hit(player);
            _ctrl.weaponsCollected += 1;
            var sparks :MovieClip = _ctrl.create("WeaponSparks");
            sparks.cn.gotoAndStop(label);
            _view.addTransient(sparks, x, y, true);
        }else{
            var self :Player = _ctrl.self;
            if(self == player){
                _view.hud.showPickUp(x);
            }
        }
    }

    /**
     * Returns the weapon's animation label.
     */
    protected function get label () :String
    {
        return WEAPON_NAMES[_weapon] + _level;
    }

    // documentation inherited
    override protected function award () :void
    {
        // set the weapon
        super.award();
        _ctrl.self.setWeapon(_weapon, _level);
    }

    // documentation inherited
    override protected function get points () :int
    {
        return 100;
    }

    /** The index of the weapon. */
    protected var _weapon :int;

    /** The level of the weapon. */
    protected var _level :int;

    /** The base names of the weapons. */
    protected static const WEAPON_NAMES :Array = [ "fists", "sword", "hammer", "bow" ];
}
}
