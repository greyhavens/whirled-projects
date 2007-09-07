package com.threerings.defense.sprites {

import com.threerings.defense.Board;
import com.threerings.defense.Level;
import com.threerings.defense.units.Missile;

public class MissileSprite extends UnitSprite
{
    public static const STATE_ACTIVE :int = 0;
    
    public function MissileSprite (missile :Missile, level :Level)
    {
        super(missile, level);
    }

    public function get missile () :Missile
    {
        return _unit as Missile;
    }

    override public function recomputeCurrentState () :int
    {
        return STATE_ACTIVE;
    }

    // from UnitSprite
    override public function update () :void
    {
        super.update();

        // now update sprite rotation
        var theta :Number = Math.atan2(missile.vel.y, missile.vel.x);
        this.rotation = theta * 180 / Math.PI;
    }

    // from UnitSprite
    override protected function getMyZOrder () :Number
    {
        // missiles are on top of everything else -
        // but among themselves, they're ordered in the same way as other sprites

        return Board.BOARD_WIDTH * Board.BOARD_HEIGHT +  // offset to put them in front of all else
            _unit.centroidy * Board.BOARD_WIDTH + _unit.centroidx;
    }
}
}
