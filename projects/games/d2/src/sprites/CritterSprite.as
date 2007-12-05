package sprites {

import flash.display.Graphics;
import flash.geom.Point;

import mx.controls.Image;

import game.Board;
import units.Critter;

import com.threerings.util.Assert;

public class CritterSprite extends UnitSprite
{
    public static const STATE_RIGHT :int = 0;
    public static const STATE_UP    :int = 1;
    public static const STATE_LEFT  :int = 2;
    public static const STATE_DOWN  :int = 3;
    
    public static const ALL_STATES :Array = [ STATE_RIGHT, STATE_UP, STATE_LEFT, STATE_DOWN ];
    
    public function CritterSprite (critter :Critter, board :Board, mine :Boolean)
    {
        Assert.isNotNull(critter);
        super(critter, board);
        
        // shift tiles over some random number of pixels from the tile center
        _tileOffset = new Point(Math.random() * 10 - 5, Math.random() * 6 - 3);

        _health = new Image();
        _mine = mine;
    }

    public function get critter () :Critter
    {
        return _unit as Critter;
    }

    public function updateHealth () :void
    {
        var color :uint = _mine ? Globals.MY_COLOR : Globals.THEIR_COLOR;
                           
        var g :Graphics = _health.graphics;
        var w :Number = _board.tileWidth - 2;
        var h :Number = 5;

        var health :Number = critter.health / critter.maxhealth;

        g.clear();
        
        g.beginFill(0x000000, 0.3);
        g.drawRoundRect(- w / 2, 0, w, h, 3, 3);
        g.endFill();

        g.beginFill(color, 0.8);
        g.drawRect(- w / 2 + 1, 1, (w - 2) * health, h - 2);
        g.endFill();
    }
    
    override protected function loadStateAssets () :Array // of DisplayObject
    {
        // the position of these corresponds to values of STATE_* constants
        return [ new critter.cdef.animationRight(),
                 new critter.cdef.animationUp(),
                 new critter.cdef.animationLeft(),
                 new critter.cdef.animationDown()
            ];
    }

    override protected function createChildren () :void
    {
        super.createChildren();
        
        _health.cacheAsBitmap = true;
        addChild(_health);
    }

    override public function recomputeCurrentState () :int
    {
        var walkDir :int = -1;
        var vel :Point = critter.vel;

        if (vel.x == 0 && vel.y == 0) {
            // we're stopped - just return the last known state
            return _currentState;
        }

        // we're moving! let's figure out where.
        if (Math.abs(vel.y) > Math.abs(vel.x)) {
            walkDir = (vel.y >= 0) ? STATE_DOWN : STATE_UP;
        } else {
            walkDir = (vel.x >= 0) ? STATE_RIGHT : STATE_LEFT;
        }

        return walkDir;
    }

    // from UnitSprite
    override protected function getMyZOrder (isFlying :Boolean = false) :Number
    {
        // the critter flag overrides any arguments
        return super.getMyZOrder(critter.isFlying);
    }

    protected var _health :Image;
    protected var _mine :Boolean;
}
}
    
