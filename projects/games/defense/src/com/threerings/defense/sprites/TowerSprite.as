package com.threerings.defense.sprites {

import com.threerings.defense.Level;
import com.threerings.defense.units.Tower;

public class TowerSprite extends UnitSprite
{
    public static const STATE_REST :int = 0;
    public static const STATE_FIRE :int = 1;
    public static const ALL_STATES :Array = [ STATE_REST ]; // <-- incomplete, testing only
    
    public function TowerSprite (tower :Tower, level :Level)
    {
        super(tower, level);
    }

    public function get tower () :Tower
    {
        return _unit as Tower;
    }

    public function updateTower (value :Tower) :void
    {
        throw new Error("TODO!");
        /*
        if (value != null && ! value.equals(tower)) {
            _unit = value;
            update();
            }
        */
    }

    public function setValid (valid :Boolean) :void
    {
        this.alpha = valid ? 1.0 : 0.3;
    }

    override public function recomputeCurrentState () :int
    {
        return STATE_REST;
    }
}
}
