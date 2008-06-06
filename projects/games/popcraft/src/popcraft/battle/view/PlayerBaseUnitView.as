package popcraft.battle.view {

import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

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

        var playerColor :uint = GameContext.gameData.playerColors[_unit.owningPlayerId];

        _movie = SwfResource.instantiateMovieClip("workshop", "workshop");
        var recolor :MovieClip = _movie["recolor"];
        recolor.filters = [ ColorMatrix.create().colorize(playerColor).createFilter() ];

        _sprite.addChild(_movie);

        // health meter
        _healthMeter = new RectMeter();
        _healthMeter.minValue = 0;
        _healthMeter.maxValue = _unit.maxHealth;
        _healthMeter.value = _unit.health;
        _healthMeter.foregroundColor = playerColor;
        _healthMeter.backgroundColor = 0x888888;
        _healthMeter.outlineColor = 0x000000;
        _healthMeter.width = HEALTH_METER_SIZE.x;
        _healthMeter.height = HEALTH_METER_SIZE.y;
        _healthMeter.x = -(_healthMeter.width * 0.5);
        _healthMeter.y = -_sprite.height - _healthMeter.height;

        // target enemy badge
        _targetEnemyBadge = ImageResource.instantiateBitmap("targetBaseBadge");
        _targetEnemyBadge.visible = false;
        _targetEnemyBadge.x = -(_targetEnemyBadge.width * 0.5);
        _targetEnemyBadge.y = -(_targetEnemyBadge.height);
        _sprite.addChild(_targetEnemyBadge);

        // player name
        var owningPlayer :PlayerInfo = _unit.owningPlayerInfo;
        var isEnemyBase :Boolean = (owningPlayer.teamId != GameContext.localPlayerInfo.teamId);
        var nameText :TextField = new TextField();
        nameText.selectable = false;
        nameText.autoSize = TextFieldAutoSize.LEFT;
        nameText.background = true;
        nameText.backgroundColor = (isEnemyBase ? 0xFF0000 : 0xFFFFFF);
        nameText.textColor = (isEnemyBase ? 0xFFFFFF : 0x000000);
        nameText.text = owningPlayer.playerName;
        nameText.x =  -(nameText.width * 0.5);
        nameText.y = -(_movie.height * 0.5) - (nameText.height * 0.5);
        _sprite.addChild(nameText);
    }

    override public function get objectName () :String
    {
        return "BaseView_" + _unit.owningPlayerId;
    }

    public function unitCreated () :void
    {
        _movie.gotoAndPlay("flash");
    }

    public function scaleHealthMeter () :void
    {
        // proportionally resize the base's health meter
        var maxMaxHealth :Number = -1;
        for each (var playerInfo :PlayerInfo in GameContext.playerInfos) {
            if (playerInfo.maxHealth > maxMaxHealth) {
                maxMaxHealth = playerInfo.maxHealth;
            }
        }

        _healthMeter.width = HEALTH_METER_SIZE.x * (_unit.maxHealth / maxMaxHealth);
        _healthMeter.x = -(_healthMeter.width * 0.5);
    }

    override protected function addedToDB () :void
    {
        this.db.addObject(_healthMeter, _sprite);
        _unit.addEventListener(UnitEvent.ATTACKED, handleAttacked, false, 0, true);
    }

    override protected function removedFromDB () :void
    {
        _healthMeter.destroySelf();
        _unit.removeEventListener(UnitEvent.ATTACKED, handleAttacked);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function update (dt :Number) :void
    {
        if (_needsLocationUpdate) {
            this.x = _unit.x;
            this.y = _unit.y;

            // flip the movie if we're on the left side of the board
            if (_unit.x < Constants.BATTLE_WIDTH * 0.5) {
                _movie.scaleX = -1;
            }

            _needsLocationUpdate = false;
        }

        var health :Number = _unit.health;

        _healthMeter.value = health;

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
        _targetEnemyBadge.visible = val;
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
    protected var _movie :MovieClip;
    protected var _targetEnemyBadge :Bitmap;
    protected var _unit :PlayerBaseUnit;
    protected var _healthMeter :RectMeter;
    protected var _needsLocationUpdate :Boolean = true;

    protected static const HEALTH_METER_SIZE :Point = new Point(50, 5);
    protected static const GROUP_NAME :String = "PlayerBaseUnitView";
    protected static const HIT_SOUND_NAMES :Array = [ "sfx_basehit1", "sfx_basehit2", "sfx_basehit3" ];

}

}
