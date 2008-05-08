package popcraft.battle.view {

import com.threerings.flash.Vector2;
import com.threerings.util.Assert;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;

import popcraft.*;
import popcraft.battle.*;
import popcraft.data.*;
import popcraft.util.*;

public class CreatureUnitView extends SceneObject
{
    public function CreatureUnitView (unit :CreatureUnit)
    {
        _unit = unit;
    }

    override protected function addedToDB () :void
    {
        _sprite.mouseEnabled = false;
        _sprite.mouseChildren = false;

        var playerColor :uint = Constants.PLAYER_COLORS[_unit.owningPlayerId];

        // @TODO - remove this when all units have animations
        if (Constants.UNIT_TYPE_GRUNT == _unit.unitType || Constants.UNIT_TYPE_SAPPER == _unit.unitType || Constants.UNIT_TYPE_HEAVY == _unit.unitType) {
            this.setupAnimations(playerColor);
            _hasAnimations = true;
        } else {
            // add the image, aligned by its foot position
            var image :Bitmap = (AppContext.resources.getResource(_unit.unitData.name + "_icon") as ImageResourceLoader).createBitmap();
            image.x = -(image.width * 0.5);
            image.y = -image.height;
            _sprite.addChild(image);

            // add a glow around the image
            _sprite.addChild(ImageUtil.createGlowBitmap(image, playerColor));
        }

        // health meter
        _healthMeter = new RectMeter();
        _healthMeter.minValue = 0;
        _healthMeter.maxValue = _unit.maxHealth;
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
        _unit.addEventListener(UnitEvent.ATTACKED, handleUnitAttacked, false, 0, true);

        var spellSet :SpellSet = GameContext.playerUnitSpellSets[_unit.owningPlayerId];
        spellSet.addEventListener(SpellSet.SET_MODIFIED, handleSpellSetModified);

        this.updateUnitSpellIcons();
    }

    override protected function removedFromDB () :void
    {
        if (null != _healthMeter) {
            _healthMeter.destroySelf();
        }

        _unit.removeEventListener(UnitEvent.ATTACKING, handleUnitAttacking);
        _unit.removeEventListener(UnitEvent.ATTACKED, handleUnitAttacked);

        var spellSet :SpellSet = GameContext.playerUnitSpellSets[_unit.owningPlayerId];
        spellSet.removeEventListener(SpellSet.SET_MODIFIED, handleSpellSetModified);

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

        var spellSet :SpellSet = GameContext.playerUnitSpellSets[_unit.owningPlayerId];
        var spells :Array = spellSet.spells;
        if (spells.length == 0) {
            return;
        }

        _unitSpellIconParent = new Sprite();
        _unitSpellIconParent.x = -_healthMeter.height;
        _sprite.addChild(_unitSpellIconParent);

        // create new spell icons, arranged above the health meter
        var icons :Array = [];
        var totalWidth :Number = 0;
        for each (var spell :SpellData in spellSet.spells) {
            var icon :DisplayObject = AppContext.instantiateBitmap(spell.name + "_icon");
            if (null != icon) {
                totalWidth += icon.width;
                icons.push(icon);
            }
        }

        var yLoc :Number = -_sprite.height - _healthMeter.height;
        var xLoc :Number = -(totalWidth * 0.5);
        for each (icon in icons) {
            icon.x = xLoc;
            icon.y = yLoc - icon.height;
            xLoc += icon.width;
            _unitSpellIconParent.addChild(icon);
        }
    }

    protected function handleUnitAttacking (e :UnitEvent) :void
    {
        var weapon :UnitWeaponData = e.data as UnitWeaponData;

        if (weapon.isAOE) {
            // @TODO - duration is a temporary, arbitrary value
            this.createAOEAttackAnimation(weapon, _unit.unitLoc, 0.5);
        }
    }

    protected function handleUnitAttacked (...ignored) :void
    {
        // play a sound
        var soundName :String = HIT_SOUND_NAMES[Rand.nextIntRange(0, HIT_SOUND_NAMES.length, Rand.STREAM_COSMETIC)];
        AppContext.playSound(soundName);
    }

    protected function createAOEAttackAnimation (weapon :UnitWeaponData, loc :Vector2, duration :Number) :void
    {
        if (null != weapon.aoeAnimationName) {

            // create an attack animation object that will play and self-destruct

            var anim :MovieClip = AppContext.instantiateMovieClip(_unit.unitData.name, weapon.aoeAnimationName);

            if (null == anim) {
                log.info("Missing AOE attack animation '" + weapon.aoeAnimationName + "' for " + _unit.unitData.name);
            } else {
                var animObj :SceneObject = new SimpleSceneObject(anim);
                animObj.x = loc.x;
                animObj.y = loc.y;

                animObj.addTask(After(duration, new SelfDestructTask()));

                GameContext.gameMode.addObject(animObj, GameContext.battleBoardView.unitViewParent);
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

            GameContext.gameMode.addObject(aoeObj, GameContext.battleBoardView.unitViewParent);
        }
    }

    protected function setupAnimations (playerColor :uint) :void
    {
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

                var anim :MovieClip = UnitAnimationFactory.instantiateUnitAnimation(
                    _unit.unitData, playerColor, animName);

                if (null != anim) {
                    animArray.push(anim);
                }
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

        var newFacing :int = -1;

        if (newViewState.moving) {
            newFacing = getFacingDirectionFromAngle(_unit.movementDirection.angle);
        } else if (newViewState.attacking) {
            // if we're attacking, we should be facing our attack target
            var attackTarget :Unit = _unit.attackTarget;
            if (null != attackTarget) {
                newFacing = getFacingDirectionFromAngle(attackTarget.unitLoc.subtract(_unit.unitLoc).angle);
            }
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

            // play a sound if the creature died during battle, and not
            // as a result of the night-day switch
            if (GameContext.diurnalCycle.isNight) {
                AppContext.playSound("sfx_death_" + _unit.unitData.name);
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

            // @TODO - remove this
            if (_hasAnimations) {
                this.updateAnimations();
            }

            if (!_unit.isMoving || Constants.DEBUG_DISABLE_MOVEMENT_SMOOTHING) {
                this.x = _unit.x;
                this.y = _unit.y;
            } else {

                // estimate a new location for the CreatureUnit,
                // based on its last location and its velocity

                var distanceDelta :Number = Math.min(_unit.movementSpeed * _unitUpdateTimeDelta, _unit.distanceToDestination);
                var movementDelta :Vector2 = _unit.movementDirection.scale(distanceDelta);

                this.x = _unit.x + movementDelta.x;
                this.y = _unit.y + movementDelta.y;
            }

            if (null != _healthMeter) {
                _healthMeter.value = _unit.health;
            }
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

    protected var _unitSpellIconParent :Sprite;

    protected var _lastUnitUpdateTimestamp :Number = 0;
    protected var _unitUpdateTimeDelta :Number = 0;

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
    protected static const HIT_SOUND_NAMES :Array = [ "sfx_hit1", "sfx_hit2", "sfx_hit3" ];
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
