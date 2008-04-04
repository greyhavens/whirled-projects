package popcraft.battle {

import com.threerings.flash.Vector2;
import com.threerings.util.Assert;
import com.threerings.util.Log;
import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;

import popcraft.*;
import popcraft.util.*;

public class CreatureUnitView extends SceneObject
{
    public static const GROUP_NAME :String = "CreatureUnitView";

    public function CreatureUnitView (unit :CreatureUnit)
    {
        _unit = unit;
    }

    override protected function addedToDB () :void
    {
        var playerColor :uint = Constants.PLAYER_COLORS[_unit.owningPlayerId];

        // @TODO - remove this when all units have animations
        if (Constants.UNIT_TYPE_GRUNT == _unit.unitType || Constants.UNIT_TYPE_SAPPER == _unit.unitType) {
            this.setupAnimations(playerColor);
            _hasAnimations = true;
        } else {
            // add the image, aligned by its foot position
            var image :Bitmap = (PopCraft.resourceManager.getResource(_unit.unitData.name + "_icon") as ImageResourceLoader).createBitmap();
            image.x = -(image.width * 0.5);
            image.y = -image.height;
            _sprite.addChild(image);

            // add a glow around the image
            _sprite.addChild(ImageUtil.createGlowBitmap(image, playerColor));
        }

        // health meter
        _healthMeter = new RectMeter();
        _healthMeter.minValue = 0;
        _healthMeter.maxValue = _unit.unitData.maxHealth;
        _healthMeter.value = _unit.health;
        _healthMeter.foregroundColor = playerColor;
        _healthMeter.backgroundColor = 0x888888;
        _healthMeter.outlineColor = 0x000000;
        _healthMeter.width = 30;
        _healthMeter.height = 3;
        _healthMeter.x = -(_healthMeter.width * 0.5);
        _healthMeter.y = -_sprite.height - _healthMeter.height;

        this.db.addObject(_healthMeter, _sprite);

        // draw some debugging circles
        if (Constants.DEBUG_DRAW_UNIT_DATA_CIRCLES) {

            // unit-detect circle
            if (_unit.unitData.detectRadius != _unit.unitData.collisionRadius) {
                _sprite.graphics.lineStyle(1, 0x00FF00);
                _sprite.graphics.drawCircle(0, 0, _unit.unitData.detectRadius);
            }

            // collision circle
            _sprite.graphics.lineStyle(1, 0xFF0000);
            _sprite.graphics.drawCircle(0, 0, _unit.unitData.collisionRadius);
        }

        _unit.addEventListener(UnitEvent.ATTACKING, handleUnitAttacking, false, 0, true);
    }

    override protected function removedFromDB () :void
    {
        _healthMeter.destroySelf();
        _unit.removeEventListener(UnitEvent.ATTACKING, handleUnitAttacking);
    }

    protected function handleUnitAttacking (e :UnitEvent) :void
    {
        var weapon :UnitWeapon = e.data as UnitWeapon;

        if (weapon.isAOE) {
            // @TODO - duration is a temporary, arbitrary value
            this.createAOEAttackAnimation(weapon, _unit.unitLoc, 0.5);
        }
    }

    protected function createAOEAttackAnimation (weapon :UnitWeapon, loc :Vector2, duration :Number) :void
    {
        if (null != weapon.aoeAnimationName) {

            // create an attack animation object that will play and self-destruct

            var anim :MovieClip = PopCraft.resourceManager.instantiateMovieClip(_unit.unitData.name, weapon.aoeAnimationName);

            if (null == anim) {
                log.info("Missing AOE attack animation '" + weapon.aoeAnimationName + "' for " + _unit.unitData.name);
            } else {
                var animObj :SceneObject = new SimpleSceneObject(anim);
                animObj.x = loc.x;
                animObj.y = loc.y;

                animObj.addTask(After(duration, new SelfDestructTask()));

                GameMode.instance.addObject(animObj, GameMode.instance.battleUnitDisplayParent);
            }
        }

        if (Constants.DEBUG_DRAW_AOE_ATTACK_RADIUS) {

            // visualize the blast radius

            var aoeCircle :Shape = new Shape();
            var g :Graphics = aoeCircle.graphics;
            g.beginFill(0xFF0000, 0.5);
            g.drawCircle(0, 0, weapon.aoeRadius);
            g.endFill();

            var aoeObj :SceneObject = new SimpleSceneObject(aoeCircle);
            aoeObj.x = loc.x;
            aoeObj.y = loc.y;

            // fade out and die
            aoeObj.addTask(After(0.3, new SerialTask(new AlphaTask(0, 0.3), new SelfDestructTask())));

            GameMode.instance.addObject(aoeObj, GameMode.instance.battleUnitDisplayParent);
        }
    }

    // from SimObject
    override public function get objectGroups () :Array
    {
        if (null == g_groups) {
            g_groups = [ GROUP_NAME ];
        }

        return g_groups;
    }

    protected function setupAnimations (playerColor :uint) :void
    {
        var tintFilterMatrix :ColorMatrix = new ColorMatrix();
        tintFilterMatrix.colorize(playerColor);

        // load our animations
        var swf :SwfResourceLoader = (PopCraft.resourceManager.getResource(_unit.unitData.name) as SwfResourceLoader);

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
                var animName :String = animNamePrefix + FACING_STRINGS[facing];

                var animClass :Class = swf.getClass(animName);

                if (null == animClass) {
                    break;
                }

                var anim :MovieClip = new animClass();

                // colorize
                var color :MovieClip = anim.recolor;
                if (null != color && null != color.recolor) {
                    color = color.recolor;
                }

                if (null != color) {
                    color.filters = [ tintFilterMatrix.createFilter() ];
                } else {
                    log.info("Missing recolor symbol for " + _unit.unitData.name + "." + animName);
                }

                animArray.push(anim);
            }
        }

        // if we don't have any "moving" animations, just use our standing animations
        if (_animMoving.length == 0) {
            _animMoving = _animStanding;
        }

        _sprite.addChildAt(_animStanding[0], 0);
    }

    protected function updateAnimations () :void
    {
        // determine our view state
        var newViewState :ViewState = new ViewState();

        newViewState.moving = _unit.isMoving;
        newViewState.attacking = _unit.isAttacking;

        if (newViewState.moving) {
            newViewState.facing = getFacingDirectionFromAngle(_unit.movementDirection.angle);
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

            // if the character is facing NE or SE,
            // we use the NW/SW animations and flip
            if (FACING_NE == animIndex) {
                animIndex = FACING_NW;
            } else if (FACING_SE == animIndex) {
                animIndex = FACING_SW;
            }

            var anim :MovieClip = animArray[animIndex];

            // flip if we need to
            anim.scaleX = ((newViewState.facing == FACING_NE || newViewState.facing == FACING_SE) ? -1 : 1);

            _sprite.removeChildAt(0);
            _sprite.addChildAt(anim, 0);

            _lastViewState = newViewState;
        }
    }

    override protected function update (dt :Number) :void
    {
        if (_unit.isDead) {
            // when the unit gets destroyed, its view does too
            this.destroySelf();

        } else {
            // @TODO - remove this
            if (_hasAnimations) {
                this.updateAnimations();
            }

            this.x = _unit.x;
            this.y = _unit.y;

            _healthMeter.value = _unit.health;
        }
    }

    protected static function getFacingDirectionFromAngle (angleRadians :Number) :int
    {
        Assert.isTrue(angleRadians >= 0 && angleRadians < (Math.PI * 2), "bad angle: " + angleRadians);

        // where does the angle land on the unit circle?
        // since we're dealing with screen coordinates, south is "up" on the unit circle

        if (angleRadians < Math.PI * (3/8)) {
            return FACING_SE;
        } else if (angleRadians < Math.PI * (5/8)) {
            return FACING_S;
        } else if (angleRadians < Math.PI) {
            return FACING_SW;
        } else if (angleRadians < Math.PI * (11/8)) {
            return FACING_NW;
        } else if (angleRadians < Math.PI * (13/8)) {
            return FACING_N;
        } else {
            return FACING_NE;
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    // Retain a pointer to the CreatureUnit rather than a SimObjectRef to
    // prevent a bunch of irritating checks against null. This isn't a big deal
    // here - the CreatureUnitView's lifespan is almost exactly that of its
    // associated CreatureUnit.
    protected var _unit :CreatureUnit;

    protected var _lastViewState :ViewState = new ViewState();
    protected var _sprite :Sprite = new Sprite();
    protected var _healthMeter :RectMeter;

    protected var _animStanding :Array = [];
    protected var _animAttacking :Array = [];
    protected var _animMoving :Array = [];

    // @TODO - remove this when all units have animations
    protected var _hasAnimations :Boolean;

    protected static var g_groups :Array;

    protected static const log :Log = Log.getLog(CreatureUnitView);

    protected static const FACING_N :int = 0;
    protected static const FACING_NW :int = 1;
    protected static const FACING_SW :int = 2;
    protected static const FACING_S :int = 3;
    protected static const FACING_SE :int = 4;
    protected static const FACING_NE :int = 5;

    protected static const FACING_STRINGS :Array = [ "N", "NW", "SW", "S", "SE", "NE" ];
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
