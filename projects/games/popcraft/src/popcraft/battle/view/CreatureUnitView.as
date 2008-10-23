package popcraft.battle.view {

import com.threerings.flash.Vector2;
import com.threerings.util.Assert;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Rectangle;

import popcraft.*;
import popcraft.battle.*;
import popcraft.data.*;
import popcraft.ui.HealthMeters;
import popcraft.ui.RectMeterView;
import popcraft.util.*;

public class CreatureUnitView extends BattlefieldSprite
{
    public function CreatureUnitView (unit :CreatureUnit)
    {
        _unit = unit;
    }

    override protected function addedToDB () :void
    {
        _sprite.mouseEnabled = false;
        _sprite.mouseChildren = false;

        var playerColor :uint = _unit.owningPlayerInfo.color;

        this.setupAnimations(playerColor);

        // health meter
        _healthMeter = HealthMeters.createCreatureMeter(playerColor, _unit.maxHealth, _unit.health);
        _healthMeter.x = -(_healthMeter.width * 0.5);
        _healthMeter.y = -_sprite.height - _healthMeter.height;
        _sprite.addChild(_healthMeter);

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

        this.registerListener(_unit, UnitEvent.ATTACKED, handleUnitAttacked);

        var spellSet :CreatureSpellSet = GameContext.getActiveSpellSet(_unit.owningPlayerIndex);
        this.registerListener(spellSet, CreatureSpellSet.SET_MODIFIED, handleSpellSetModified);

        this.updateUnitSpellIcons();

        super.addedToDB();
    }

    override protected function removedFromDB () :void
    {
        if (_bitmapAnimView != null) {
            _bitmapAnimView.destroySelf();
        }

        super.removedFromDB();
    }

    protected function handleSpellSetModified (...ignored) :void
    {
        this.updateUnitSpellIcons();
    }

    protected function updateUnitSpellIcons () :void
    {
        // remove old spell icons
        if (null != _unitSpellIconParent) {
            _sprite.removeChild(_unitSpellIconParent);
            _unitSpellIconParent = null;
        }

        var spellSet :CreatureSpellSet = GameContext.getActiveSpellSet(_unit.owningPlayerIndex);
        var spells :Array = spellSet.spells;
        if (spells.length == 0) {
            return;
        }

        _unitSpellIconParent = SpriteUtil.createSprite();
        _unitSpellIconParent.x = -_healthMeter.height;
        _sprite.addChild(_unitSpellIconParent);

        // create new spell icons, arranged above the health meter
        var yOffset :Number = -_sprite.height - _healthMeter.height;
        for each (var spell :SpellData in spellSet.spells) {
            var icon :MovieClip =
                SwfResource.instantiateMovieClip("infusions", "unit_" + spell.name);
            icon.x = 0;
            icon.y = yOffset;
            icon.cacheAsBitmap = true;
            _unitSpellIconParent.addChild(icon);

            yOffset -= 10;
        }
    }

    protected function handleUnitAttacked (...ignored) :void
    {
        var timeNow :Number = AppContext.mainLoop.elapsedSeconds;
        if (timeNow - _lastBloodTime >= BLOOD_INTERVAL_MIN) {
            // show a blood splatter
            if (null == g_bloodClass) {
                var swf :SwfResource =
                    SwfResource(ResourceManager.instance.getResource("splatter"));
                g_bloodClass = swf.getClass("blood");
            }

            var bloodObj :SimpleSceneObject = new SimpleSceneObject(new g_bloodClass());
            bloodObj.addTask(After(0.3, new SelfDestructTask()));

            // pick a random location for the blood
            var bounds :Rectangle = _sprite.getBounds(_sprite);
            var x :Number = Rand.nextNumberRange(bounds.left, bounds.right, Rand.STREAM_COSMETIC);
            var y :Number = Rand.nextNumberRange(bounds.top, bounds.bottom, Rand.STREAM_COSMETIC);
            bloodObj.x = x;
            bloodObj.y = y;

            this.db.addObject(bloodObj, _sprite);

            _lastBloodTime = timeNow;
        }

        // play a sound
        var soundName :String = Rand.nextElement(HIT_SOUND_NAMES, Rand.STREAM_COSMETIC);
        GameContext.playGameSound(soundName);
    }

    protected function setupAnimations (playerColor :uint) :void
    {
        var useBitmapAnims :Boolean =
            PerfMonitor.framerate < Constants.BITMAP_LIVE_ANIM_THRESHOLDS[_unit.unitType];

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
            for (var facing :int = Constants.FACING_N; facing <= Constants.FACING_S; ++facing) {
                var animName :String = animNamePrefix + Constants.FACING_STRINGS[facing];

                if (useBitmapAnims) {
                    var bitmapAnim :BitmapAnim = CreatureAnimFactory.getBitmapAnim(
                        _unit.unitType, playerColor, animName);
                    if (null != bitmapAnim) {
                        animArray.push(bitmapAnim);
                    }

                } else {
                    var anim :MovieClip = CreatureAnimFactory.instantiateUnitAnimation(
                        _unit.unitType, playerColor, animName);

                    if (null != anim) {
                        animArray.push(anim);
                    }
                }
            }
        }

        // substitute animations
        if (_animMoving.length == 0 && _animStanding.length > 0) {
            _animMoving = _animStanding;
        } else if (_animStanding.length == 0 && _animMoving.length > 0) {
            _animStanding = _animMoving;
        }

        if (_animAttacking.length == 0) {
            _animAttacking = _animStanding;
        }

        if (useBitmapAnims) {
            _bitmapAnimView = new BitmapAnimView(_animStanding[0]);
            GameContext.gameMode.addObject(_bitmapAnimView);
            _sprite.addChildAt(_bitmapAnimView.displayObject, 0);

        } else {
            _sprite.addChildAt(_animStanding[0], 0);
        }
    }

    protected function updateAnimations () :void
    {
        // determine our view state
        var newViewState :CreatureUnitViewState = new CreatureUnitViewState();

        newViewState.moving = _unit.isMoving;

        // are we attacking?
        var attackTarget :Unit;
        var attacking :Boolean;
        if (_unit.inAttackCooldown) {
            attackTarget = _unit.attackTarget;
            if (null != attackTarget) {
                attacking = true;
            }
        }

        newViewState.attacking = attacking;

        // determine facing direction
        var newFacing :int = -1;
        if (newViewState.attacking) {
            // if we're attacking, we should be facing our attack target
            attackTarget = _unit.attackTarget;
            if (null != attackTarget) {
                newFacing = getFacingDirectionFromAngle(attackTarget.unitLoc.subtract(_unit.unitLoc).angle);
            }
        } else if (newViewState.moving) {
            // if we're moving, we should be facing our movement direction
            newFacing = getFacingDirectionFromAngle(_unit.movementDirection.angle);
        }

        if (newFacing == -1) {
            newFacing = _lastViewState.facing;
        }

        newViewState.facing = newFacing;

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
            if (Constants.FACING_NE == animIndex) {
                animIndex = Constants.FACING_NW;
            } else if (Constants.FACING_SE == animIndex) {
                animIndex = Constants.FACING_SW;
            }

            // if only our facing direction has changed, start this new animation
            // on the same frame that the old one left off
            var initialFrame :int = 0;
            if (!this.usingBitmapAnimation && newViewState.equalsExceptFacing(_lastViewState)) {
                var oldAnim :MovieClip = MovieClip(_sprite.getChildAt(0));
                initialFrame = oldAnim.currentFrame;
            }

            this.setNewAnimation(animArray, animIndex, newViewState);
        }
    }

    protected function setNewAnimation (animArray :Array, animIndex :int,
        newViewState :CreatureUnitViewState, initialFrame :int = 0) :void
    {
        // flip if we need to
        var scaleX :Number = ((newViewState.facing == Constants.FACING_NE || newViewState.facing == Constants.FACING_SE) ? -1 : 1);

        if (this.usingBitmapAnimation) {
            var newBitmapAnim :BitmapAnim = animArray[animIndex];
            _bitmapAnimView.scaleX = scaleX;

            var oldBitmapAnim :BitmapAnim = _bitmapAnimView.anim;
            if (oldBitmapAnim != newBitmapAnim) {
                _bitmapAnimView.anim = newBitmapAnim;
            }

        } else {
            var newAnim :MovieClip = animArray[animIndex];
            newAnim.scaleX = scaleX;

            var oldAnim :MovieClip = MovieClip(_sprite.getChildAt(0));
            if (newAnim != oldAnim) {
                // only reset the animation if it's actually changed
                _sprite.removeChildAt(0);
                _sprite.addChildAt(newAnim, 0);

                // we're not playing Handy-Man's idle animation for performance reasons
                // @TODO - move this logic somewhere more appropriate!
                if (_unit.unitType == Constants.UNIT_TYPE_HEAVY && newViewState.idle) {
                    newAnim.gotoAndStop(initialFrame);
                    newAnim.cacheAsBitmap = true;
                } else {
                    newAnim.gotoAndPlay(initialFrame);
                }
            }
        }

        _lastViewState = newViewState;
    }

    override protected function update (dt :Number) :void
    {
        if (_unit.isDead) {
            // when the unit gets destroyed, its view does too
            this.destroySelf();

            // show a death animation (will self-destruct when animation is complete)
            if (!_unit.preventDeathAnimation) {
                GameContext.gameMode.addObject(
                    new DeadCreatureUnitView(_unit, _lastViewState.facing),
                    GameContext.battleBoardView.unitViewParent);
            }

        } else {

            // estimate the amount of time that's elapsed since
            // the creature's last update
            var unitUpdateTimestamp :Number = _unit.lastUpdateTimestamp;
            if (unitUpdateTimestamp == _lastUnitUpdateTimestamp) {
                _unitUpdateTimeDelta += dt;
            } else {
                _lastUnitUpdateTimestamp = unitUpdateTimestamp;
                _unitUpdateTimeDelta = 0;
            }

            this.updateAnimations();

            var x :Number;
            var y :Number;

            if (!_unit.isMoving || Constants.DEBUG_DISABLE_MOVEMENT_SMOOTHING) {
                x = _unit.x;
                y = _unit.y;
            } else {

                // estimate a new location for the CreatureUnit,
                // based on its last location and its velocity

                var distanceDelta :Number = Math.min(_unit.movementSpeed * _unitUpdateTimeDelta, _unit.distanceToDestination);
                var movementDelta :Vector2 = _unit.movementDirection.scale(distanceDelta);

                x = _unit.x + movementDelta.x;
                y = _unit.y + movementDelta.y;
            }

            this.updateLoc(x, y);

            if (null != _healthMeter) {
                _healthMeter.value = _unit.health;
                if (_healthMeter.needsDisplayUpdate) {
                    _healthMeter.updateDisplay();
                }
            }
        }
    }

    protected static function getFacingDirectionFromAngle (angleRadians :Number) :int
    {
        Assert.isTrue(angleRadians >= 0 && angleRadians < (Math.PI * 2), "bad angle: " + angleRadians);

        // where does the angle land on the unit circle?
        // since we're dealing with screen coordinates, south is "up" on the unit circle

        if (angleRadians < Math.PI * (3/8)) {
            return Constants.FACING_SE;
        } else if (angleRadians < Math.PI * (5/8)) {
            return Constants.FACING_S;
        } else if (angleRadians < Math.PI) {
            return Constants.FACING_SW;
        } else if (angleRadians < Math.PI * (11/8)) {
            return Constants.FACING_NW;
        } else if (angleRadians < Math.PI * (13/8)) {
            return Constants.FACING_N;
        } else {
            return Constants.FACING_NE;
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected function get usingBitmapAnimation () :Boolean
    {
        return (_bitmapAnimView != null);
    }

    // Retain a pointer to the CreatureUnit rather than a SimObjectRef to
    // prevent a bunch of irritating checks against null. This isn't a big deal
    // here - the CreatureUnitView's lifespan is almost exactly that of its
    // associated CreatureUnit.
    protected var _unit :CreatureUnit;

    protected var _lastViewState :CreatureUnitViewState = new CreatureUnitViewState();
    protected var _sprite :Sprite = SpriteUtil.createSprite();
    protected var _healthMeter :RectMeterView;

    protected var _animStanding :Array = [];
    protected var _animAttacking :Array = [];
    protected var _animMoving :Array = [];

    protected var _bitmapAnimView :BitmapAnimView;

    protected var _unitSpellIconParent :Sprite;

    protected var _lastUnitUpdateTimestamp :Number = 0;
    protected var _unitUpdateTimeDelta :Number = 0;
    protected var _lastBloodTime :Number = 0;

    protected static var g_bloodClass :Class;

    protected static const log :Log = Log.getLog(CreatureUnitView);
    protected static const HIT_SOUND_NAMES :Array = [ "sfx_hit1", "sfx_hit2", "sfx_hit3" ];
    protected static const BLOOD_INTERVAL_MIN :Number = 0.5;
}

}
