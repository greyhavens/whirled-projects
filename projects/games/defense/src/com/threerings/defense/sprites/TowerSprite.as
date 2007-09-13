package com.threerings.defense.sprites {

import flash.display.MovieClip;
import flash.geom.Point;

import com.threerings.defense.Level;
import com.threerings.defense.units.Tower;

public class TowerSprite extends UnitSprite
{
    public static const STATE_REST       :int = 0;
    public static const STATE_FIRE_RIGHT :int = 1;
    public static const STATE_FIRE_UP    :int = 2;
    public static const STATE_FIRE_LEFT  :int = 3;
    public static const STATE_FIRE_DOWN  :int = 4;
    
    public static const ALL_STATES :Array =
        [ STATE_REST, STATE_FIRE_RIGHT, STATE_FIRE_UP, STATE_FIRE_LEFT, STATE_FIRE_DOWN ];

    public var firingTarget :Point = null;
    
    public function TowerSprite (tower :Tower, level :Level)
    {
        super(tower, level);
    }

    public function get tower () :Tower
    {
        return _unit as Tower;
    }

    override public function recomputeCurrentState () :int
    {
        if (_currentAsset == null) {
            return STATE_REST; // initialize first!
        }

        // this is a silly way to implement an FSM, but right now we only have two states:
        // rest, and everything else. :)
        
        if (firingTarget != null) {

            // the tower just fired at a critter! figure out the correct animation
            var newstate :int = STATE_REST;
            var dx :Number = firingTarget.x - tower.pos.x;
            var dy :Number = firingTarget.y - tower.pos.y;
            if (Math.abs(dy) > Math.abs(dx)) {
                newstate = (dy < 0) ? STATE_FIRE_UP : STATE_FIRE_DOWN;
            } else {
                newstate = (dx >= 0) ? STATE_FIRE_RIGHT : STATE_FIRE_LEFT;
            }

            firingTarget = null;
            return newstate;
            
        } else {
            // firing already happened. wait for current asset to finish animating, and revert
            if (isAssetDoneAnimating(_currentAsset)) {
                return STATE_REST;
            } else {
                return _currentState;
            }
        }
    }

    protected function isAssetDoneAnimating (asset :*) :Boolean
    {
        // i think what's going on is that once one movie clip reaches the end, they all do.
        // we probably need to restart the clip somewhere.
        var clip :MovieClip = asset as MovieClip;
        return (clip != null) && (clip.currentFrame == clip.totalFrames);
    }
}
}
