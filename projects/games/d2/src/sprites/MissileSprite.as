package sprites {

import flash.display.DisplayObject;

import game.Board;
import units.Missile;

public class MissileSprite extends UnitSprite
{
    public static const STATE_WAITING :int = 0;
    public static const STATE_ACTIVE :int = 1;
    
    public function MissileSprite (missile :Missile, board :Board)
    {
        super(missile, board);
    }

    public function get missile () :Missile
    {
        return _unit as Missile;
    }

    override protected function loadStateAssets () :Array // of DisplayObject
    {
        var classes :Array = missile.source.tdef.missileAnimations;
        var c :Class = classes[uint(Math.floor(Math.random() * classes.length))];

        return [ null, new c() ];
    }

    override public function recomputeCurrentState () :int
    {
        return (missile.isActive() ? STATE_ACTIVE : STATE_WAITING);
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
    override protected function getMyZOrder (isFlying :Boolean = false) :Number
    {
        // missiles are on top of everything else -
        // but among themselves, they're ordered in the same way as other sprites
        return super.getMyZOrder(true);
    }
}
}
