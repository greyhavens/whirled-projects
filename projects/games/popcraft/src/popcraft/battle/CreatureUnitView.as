package popcraft.battle {
    
import com.threerings.util.Assert;
import com.whirled.contrib.ColorMatrix;

import com.whirled.contrib.core.objects.*;
import com.whirled.contrib.core.resource.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;

public class CreatureUnitView extends SceneObject
{
    public function CreatureUnitView (unit :CreatureUnit)
    {
        _unit = unit;
        
        var tintFilterMatrix :ColorMatrix = new ColorMatrix();
        tintFilterMatrix.colorize(0xFF0000);
        
        // load our animations
        var swf :SwfResourceLoader = (PopCraft.resourceManager.getResource("streetwalker") as SwfResourceLoader);
        
        for (var i :int = 0; i < 3; ++i) {
            
            var animArray :Array;
            var animNamePrefix :String;
            
            switch (i) {
            case 0: animArray = _animStanding; animNamePrefix = "stand_"; break;
            case 1: animArray = _animAttacking; animNamePrefix = "attack_"; break;
            case 2: animArray = _animMoving; animNamePrefix = "walk_"; break;
            }
            
            // we don't have separate animations for NE and SE facing directions,
            // instead, we use the NW and SW animations and flip them.
            for (var facing :int = FACING_N; facing <= FACING_S; ++facing) {
                var animClass :Class = swf.getClass(animNamePrefix + FACING_STRINGS[facing]);
                
                if (null == animClass) {
                    break;
                }
                
                var anim :MovieClip = new animClass();
                
                // colorize
                var color :MovieClip = anim.recolor.recolor;
                color.filters = [ tintFilterMatrix.createFilter() ];
                
                animArray.push(anim);
            }
        }
        
        // if we don't have any "moving" animations, just use our standing animations
        if (_animMoving.length == 1) {
            _animMoving = _animStanding;
        }
        
        _sprite.addChildAt(_animStanding[0], 0);
    }
    
    override protected function update (dt :Number) :void
    {
        // determine our view state
        var newViewState :ViewState = new ViewState();
        
        newViewState.moving = _unit.isMoving;
        newViewState.attacking = false; // @TODO
        
        if (newViewState.moving) {
            newViewState.facing = getFacingDirectionFromAngle(_unit.movementDirection.angleRadians);
        } else {
            newViewState.facing = _lastViewState.facing;
        }
        
        // if our view state has changed, we need to update our animation
        // accordingly
        if (!(newViewState.equals(_lastViewState))) {
            
            var animArray :Array;
            
            if (newViewState.attacking) {
                animArray = _animAttacking;
            } else if (newViewState.moving) {
                animArray = _animMoving;
            } else {
                animArray = _animStanding;
            }
            
            var animIndex :int = newViewState.facing;
            
            // if the character is facing NE or NW,
            // we use the SE/SW animations and flip
            if (FACING_NE == animIndex) {
                animIndex = FACING_SE;
            } else if (FACING_NW == animIndex) {
                animIndex = FACING_SW;
            }
            
            var anim :MovieClip = animArray[animIndex];
            
            // flip if we need to
            anim.scaleX = ((newViewState.facing == FACING_SE || newViewState.facing == FACING_SW) ? -1 : 1);
            
            _sprite.removeChildAt(0);
            _sprite.addChildAt(anim, 0);
        
            _lastViewState = newViewState;
        }
    }
    
    protected static function getFacingDirectionFromAngle (angleRadians :Number) :int
    {
        Assert.isTrue(angleRadians >= 0 && angleRadians < (Math.PI * 2));
        
        if (angleRadians < Math.PI * (3/8)) {
            return FACING_NE;
        } else if (angleRadians < Math.PI * (5/8)) {
            return FACING_N;
        } else if (angleRadians < Math.PI) {
            return FACING_NW;
        } else if (angleRadians < Math.PI * (11/8)) {
            return FACING_SW;
        } else if (angleRadians < Math.PI * (13/8)) {
            return FACING_S;
        } else {
            return FACING_SE;
        }
    }
    
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }
    
    protected var _unit :CreatureUnit;
    protected var _lastViewState :ViewState = new ViewState();
    protected var _sprite = new Sprite();
    
    protected var _animStanding :Array = [];
    protected var _animAttacking :Array = [];
    protected var _animMoving :Array = [];
    
    protected static const FACING_N :int = 0;
    protected static const FACING_SW :int = 1;
    protected static const FACING_NW :int = 2;
    protected static const FACING_S :int = 3;
    protected static const FACING_SE :int = 4;
    protected static const FACING_NE :int = 5;
    
    protected static const FACING_STRINGS :Array = [ "N", "SW", "NW", "S", "SE", "NE" ];
}

}

class ViewState
{
    public var facing :int;
    public var moving :Boolean;
    public var attacking :Boolean;
    
    public function equals (rhs :ViewState) :Boolean
    {
        return (
            facing == rhs.facing &&
            moving == rhs.moving &&
            attacking == rhs.attacking
            );
    }
}