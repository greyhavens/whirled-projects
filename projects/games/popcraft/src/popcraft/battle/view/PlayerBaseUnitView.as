package popcraft.battle.view {

import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
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

public class PlayerBaseUnitView extends SceneObject
{
    public static function getAll () :Array
    {
        return MainLoop.instance.topMode.getObjectsInGroup(GROUP_NAME);
    }

    public static function getForPlayer (playerId :int) :PlayerBaseUnitView
    {
        return MainLoop.instance.topMode.getObjectNamed("BaseView_" + playerId) as PlayerBaseUnitView;
    }

    public function PlayerBaseUnitView (unit :PlayerBaseUnit)
    {
        _unit = unit;

        _movie = SwfResource.instantiateMovieClip("workshop", "base");
        _workshop = _movie["workshop"];

        var playerColor :uint = GameContext.gameData.playerColors[_unit.owningPlayerId];
        var recolor :MovieClip = _workshop["recolor"];
        recolor.filters = [ ColorMatrix.create().colorize(playerColor).createFilter() ];

        _sprite.addChild(_movie);

        // create health meters
        var yOffset :Number = -_sprite.height - HEALTH_METER_SIZE.y;
        var remainingMeterValue :Number = _unit.maxHealth;
        while (remainingMeterValue > 0) {
            var thisMeterValue :Number = Math.min(remainingMeterValue, HEALTH_METER_MAX_MAX_VALUE);

            var healthMeter :RectMeter = new RectMeter();
            healthMeter.minValue = 0;
            healthMeter.maxValue = thisMeterValue;
            healthMeter.value = thisMeterValue;
            healthMeter.foregroundColor = playerColor;
            healthMeter.backgroundColor = 0x888888;
            healthMeter.outlineColor = 0x000000;
            healthMeter.width = HEALTH_METER_SIZE.x * (thisMeterValue / HEALTH_METER_MAX_MAX_VALUE);
            healthMeter.height = HEALTH_METER_SIZE.y;
            healthMeter.x = -(healthMeter.width * 0.5);
            healthMeter.y = yOffset;

            _healthMeters.push(healthMeter);

            yOffset -= (HEALTH_METER_SIZE.y + 1);
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

    override public function get objectName () :String
    {
        return "BaseView_" + _unit.owningPlayerId;
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
            this.x = _unit.x;
            this.y = _unit.y;

            _clickableSprite.x = _unit.x;
            _clickableSprite.y = _unit.y;

            // flip the movie if we're on the left side of the board
            if (_unit.x < Constants.BATTLE_WIDTH * 0.5) {
                DisplayObject(_movie["workshop"]).scaleX = -1;
            }

            _needsLocationUpdate = false;
        }

        var health :Number = _unit.health;
        if (health != _lastHealth) {
            // update all health meters
            var remainingValue :Number = health;
            for each (var healthMeter :RectMeter in _healthMeters) {
                var meterValue :Number = Math.min(remainingValue, healthMeter.maxValue);
                healthMeter.value = meterValue;
                remainingValue -= meterValue;
            }

            _lastHealth = health;
        }

        if (health <= 0) {
            GameContext.playGameSound("sfx_death_base");
            this.destroySelf();
        }
    }

    protected function handleAttacked (...ignored) :void
    {
        // play a sound
        var soundName :String = HIT_SOUND_NAMES[Rand.nextIntRange(0, HIT_SOUND_NAMES.length, Rand.STREAM_COSMETIC)];
        GameContext.playGameSound(soundName);
    }

    public function set targetEnemyBadgeVisible (val :Boolean) :void
    {
        DisplayObject(_movie["target"]).visible = val;
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
    protected var _unit :PlayerBaseUnit;
    protected var _healthMeters :Array = [];
    protected var _needsLocationUpdate :Boolean = true;
    protected var _lastHealth :Number;

    protected static const HEALTH_METER_MAX_MAX_VALUE :Number = 150;
    protected static const HEALTH_METER_SIZE :Point = new Point(50, 5);
    protected static const GROUP_NAME :String = "PlayerBaseUnitView";
    protected static const HIT_SOUND_NAMES :Array = [ "sfx_basehit1", "sfx_basehit2", "sfx_basehit3" ];

    protected static const CLICKABLE_SPRITE_SIZE :Rectangle = new Rectangle(-27, -74, 55, 74);

}

}
