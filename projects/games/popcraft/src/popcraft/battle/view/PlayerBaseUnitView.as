package popcraft.battle.view {

import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;

import popcraft.*;
import popcraft.battle.*;
import popcraft.util.*;

public class PlayerBaseUnitView extends BattlefieldSprite
{
    public static function getAll () :Array
    {
        return MainLoop.instance.topMode.getObjectsInGroup(GROUP_NAME);
    }

    public static function getForPlayer (playerIndex :int) :PlayerBaseUnitView
    {
        return MainLoop.instance.topMode.getObjectNamed("BaseView_" + playerIndex) as PlayerBaseUnitView;
    }

    public function PlayerBaseUnitView (unit :PlayerBaseUnit)
    {
        _unit = unit;

        _movie = SwfResource.instantiateMovieClip("workshop", "base");
        _workshop = _movie["workshop"];
        // is the workshop already burning?
        if (_unit.health / _unit.maxHealth <= BURNING_HEALTH_PERCENT) {
            this.setBurning();
        } else {
            this.recolorWorkshop(_workshop);
        }

        // remove the "target" badge - we'll re-add it when necessary
        _targetBadge = _movie["target"];
        _targetBadgeIndex = _movie.getChildIndex(_targetBadge);
        _targetBadgeVisible = false;
        _movie.removeChild(_targetBadge);

        _sprite.addChild(_movie);

        // create health meters
        var playerColor :uint = GameContext.gameData.playerColors[_unit.owningPlayerIndex];
        var yOffset :Number = -_sprite.height - HEALTH_METER_SIZE.y;
        var remainingMaxMeterValue :Number = _unit.maxHealth;
        var remainingMeterValue :Number = _unit.health;
        while (remainingMaxMeterValue > 0) {
            var thisMeterMaxValue :Number = Math.min(remainingMaxMeterValue, HEALTH_METER_MAX_MAX_VALUE);
            var thisMeterValue :Number = Math.min(remainingMeterValue, thisMeterMaxValue);

            var healthMeter :RectMeter = new RectMeter();
            healthMeter.minValue = 0;
            healthMeter.maxValue = thisMeterMaxValue;
            healthMeter.value = thisMeterValue;
            healthMeter.foregroundColor = playerColor;
            healthMeter.backgroundColor = 0x888888;
            healthMeter.outlineColor = 0x000000;
            healthMeter.width = HEALTH_METER_SIZE.x * (thisMeterMaxValue / HEALTH_METER_MAX_MAX_VALUE);
            healthMeter.height = HEALTH_METER_SIZE.y;
            healthMeter.x = -(healthMeter.width * 0.5);
            healthMeter.y = yOffset;

            _healthMeters.push(healthMeter);

            yOffset -= (HEALTH_METER_SIZE.y + 1);
            remainingMaxMeterValue -= thisMeterMaxValue;
            remainingMeterValue -= thisMeterValue;
        }

        // player name
        var owningPlayer :PlayerInfo = _unit.owningPlayerInfo;
        var nameText :TextField = _movie["player_name"];
        nameText.text = owningPlayer.playerName;

        // clickable sprite
        _clickableSprite.graphics.beginFill(0, 0);
        _clickableSprite.graphics.drawRect(
            CLICKABLE_SPRITE_SIZE.x,
            CLICKABLE_SPRITE_SIZE.y,
            CLICKABLE_SPRITE_SIZE.width,
            CLICKABLE_SPRITE_SIZE.height);
        _clickableSprite.graphics.endFill();

        GameContext.battleBoardView.clickableObjectParent.addChild(_clickableSprite);

        this.targetEnemyBadgeVisible = false;
    }

    protected function setBurning () :void
    {
        this.setWorkshopMovie(SwfResource.instantiateMovieClip("workshop", "workshop_fire"));
    }

    protected function setWorkshopMovie (workshop :MovieClip) :void
    {
        this.recolorWorkshop(workshop);
        var index :int = _movie.getChildIndex(_workshop);
        _movie.removeChildAt(index);
        _movie.addChildAt(workshop, index);
        _workshop = workshop;
        _needsLocationUpdate = true;

        // flip the movie if we're on the left side of the board
        _workshop.scaleX = (_unit.x < Constants.BATTLE_WIDTH * 0.5 ? -1 : 1);
    }

    protected function recolorWorkshop (workshop :MovieClip) :void
    {
        var playerColor :uint = GameContext.gameData.playerColors[_unit.owningPlayerIndex];
        var recolor :MovieClip = workshop["recolor"];
        recolor.filters = [ ColorMatrix.create().colorize(playerColor).createFilter() ];
    }

    override public function get objectName () :String
    {
        return "BaseView_" + _unit.owningPlayerIndex;
    }

    public function unitCreated () :void
    {
        _workshop.gotoAndPlay("flash");
    }

    override protected function addedToDB () :void
    {
        for each (var healthMeter :RectMeter in _healthMeters) {
            this.db.addObject(healthMeter, _sprite);
        }

        _unit.addEventListener(UnitEvent.ATTACKED, handleAttacked, false, 0, true);

        super.addedToDB();
    }

    override protected function scaleSprites () :void
    {
        super.scaleSprites();
        _clickableSprite.scaleX = _spriteScale;
        _clickableSprite.scaleY = _spriteScale;
    }

    override protected function removedFromDB () :void
    {
        for each (var healthMeter :RectMeter in _healthMeters) {
            healthMeter.destroySelf();
        }

        _unit.removeEventListener(UnitEvent.ATTACKED, handleAttacked);
        _clickableSprite.parent.removeChild(_clickableSprite);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    public function get clickableObject () :InteractiveObject
    {
        return _clickableSprite;
    }

    override protected function update (dt :Number) :void
    {
        if (_needsLocationUpdate) {
            this.updateLoc(_unit.x, _unit.y);

            _clickableSprite.x = this.x;
            _clickableSprite.y = this.y;

            // flip the movie if we're on the left side of the board
            _workshop.scaleX = (_unit.x < Constants.BATTLE_WIDTH * 0.5 ? -1 : 1);

            _needsLocationUpdate = false;
        }

        var health :Number = _unit.health;
        if (health != _lastHealth) {
            if (health <= 0) {
                GameContext.playGameSound("sfx_death_base");
                this.destroySelf();

                // create the rubble sprite
                GameContext.gameMode.addObject(
                    new DeadPlayerBaseUnitView(_unit),
                    GameContext.battleBoardView.unitViewParent);

            } else {
                // update all health meters
                var remainingValue :Number = health;
                for each (var healthMeter :RectMeter in _healthMeters) {
                    var meterValue :Number = Math.min(remainingValue, healthMeter.maxValue);
                    healthMeter.value = meterValue;
                    remainingValue -= meterValue;
                }

                // swap in the burning workshop
                if ((health / _unit.maxHealth) <= BURNING_HEALTH_PERCENT &&
                    (_lastHealth / _unit.maxHealth) > BURNING_HEALTH_PERCENT) {
                    this.setBurning();
                }
            }

            _lastHealth = health;
        }
    }

    protected function handleAttacked (...ignored) :void
    {
        // show a "debris" effect
        if (null == g_debrisClass) {
            var swf :SwfResource = ResourceManager.instance.getResource("splatter") as SwfResource;
            g_debrisClass = swf.getClass("debris");
        }

        var debrisObj :SimpleSceneObject = new SimpleSceneObject(new g_debrisClass());
        debrisObj.addTask(After(0.3, new SelfDestructTask()));

        // pick a random location for the blood
        var x :Number = Rand.nextNumberRange(DEBRIS_RECT.left, DEBRIS_RECT.right, Rand.STREAM_COSMETIC);
        var y :Number = Rand.nextNumberRange(DEBRIS_RECT.top, DEBRIS_RECT.bottom, Rand.STREAM_COSMETIC);
        debrisObj.x = x;
        debrisObj.y = y;

        this.db.addObject(debrisObj, _sprite);

        // play a sound
        var soundName :String = Rand.nextElement(HIT_SOUND_NAMES, Rand.STREAM_COSMETIC);
        GameContext.playGameSound(soundName);
    }

    public function set targetEnemyBadgeVisible (val :Boolean) :void
    {
        if (val && !_targetBadgeVisible) {
            _movie.addChildAt(_targetBadge, _targetBadgeIndex);
        } else if (!val && _targetBadgeVisible) {
            _movie.removeChild(_targetBadge);
        }

        _targetBadgeVisible = val;
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        switch (groupNum) {
        case 0: return GROUP_NAME;
        default: return super.getObjectGroup(groupNum - 1);
        }
    }

    public function get baseUnit () :PlayerBaseUnit
    {
        return _unit;
    }

    protected var _sprite :Sprite = new Sprite();
    protected var _clickableSprite :Sprite = new Sprite();
    protected var _movie :MovieClip;
    protected var _workshop :MovieClip;
    protected var _targetBadge :MovieClip;
    protected var _targetBadgeIndex :int;
    protected var _targetBadgeVisible :Boolean;
    protected var _unit :PlayerBaseUnit;
    protected var _healthMeters :Array = [];
    protected var _needsLocationUpdate :Boolean = true;
    protected var _lastHealth :Number;

    protected static var g_debrisClass :Class;

    protected static const HEALTH_METER_MAX_MAX_VALUE :Number = 150;
    protected static const HEALTH_METER_SIZE :Point = new Point(50, 5);
    protected static const GROUP_NAME :String = "PlayerBaseUnitView";
    protected static const HIT_SOUND_NAMES :Array = [ "sfx_basehit1", "sfx_basehit2", "sfx_basehit3" ];

    protected static const CLICKABLE_SPRITE_SIZE :Rectangle = new Rectangle(-27, -74, 55, 74);
    protected static const DEBRIS_RECT :Rectangle = new Rectangle(-27, -74, 55, 74);

    protected static const BURNING_HEALTH_PERCENT :Number = 0.5;

}

}
