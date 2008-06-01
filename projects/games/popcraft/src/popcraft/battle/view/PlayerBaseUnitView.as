package popcraft.battle.view {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

import popcraft.*;
import popcraft.battle.*;
import popcraft.util.*;

public class PlayerBaseUnitView extends SceneObject
{
    public static function getAll () :Array
    {
        return MainLoop.instance.topMode.getObjectsInGroup(GROUP_NAME);
    }

    public function PlayerBaseUnitView (unit :PlayerBaseUnit)
    {
        _unit = unit;

        var playerColor :uint = GameContext.gameData.playerColors[_unit.owningPlayerId];

        // add the image, aligned by its foot position
        var image :Bitmap = ImageResource.instantiateBitmap(_unit.unitData.name);
        image.x = -(image.width * 0.5);
        image.y = -image.height;
        _sprite.addChild(image);

        // add a glow around the image
        _sprite.addChild(ImageUtil.createGlowBitmap(image, playerColor));

        // health meter
        _healthMeter = new RectMeter();
        _healthMeter.minValue = 0;
        _healthMeter.maxValue = _unit.maxHealth;
        _healthMeter.value = _unit.health;
        _healthMeter.foregroundColor = playerColor;
        _healthMeter.backgroundColor = 0x888888;
        _healthMeter.outlineColor = 0x000000;
        _healthMeter.width = 50;
        _healthMeter.height = 5;
        _healthMeter.x = -(_healthMeter.width * 0.5);
        _healthMeter.y = -_sprite.height - _healthMeter.height;

        // target enemy badge
        _targetEnemyBadge = ImageResource.instantiateBitmap("targetBaseBadge");
        _targetEnemyBadge.visible = false;
        _targetEnemyBadge.x = -(_targetEnemyBadge.width * 0.5);
        _targetEnemyBadge.y = -(_targetEnemyBadge.height);
        _sprite.addChild(_targetEnemyBadge);

        // friendly badge
        _friendlyBadge = ImageResource.instantiateBitmap("friendlyBaseBadge");
        _friendlyBadge.visible = false;
        _friendlyBadge.x = -(_friendlyBadge.width * 0.5);
        _friendlyBadge.y = -(_friendlyBadge.height);
        _sprite.addChild(_friendlyBadge);
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
        this.x = _unit.x;
        this.y = _unit.y;

        var health :Number = _unit.health;

        _healthMeter.value = health;

        if (health <= 0) {
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

    public function set friendlyBadgeVisible (val :Boolean) :void
    {
        _friendlyBadge.visible = val;
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

    protected var _sprite: Sprite = new Sprite();
    protected var _targetEnemyBadge :Bitmap;
    protected var _friendlyBadge :Bitmap;
    protected var _unit :PlayerBaseUnit;
    protected var _healthMeter :RectMeter;

    protected static const GROUP_NAME :String = "PlayerBaseUnitView";
    protected static const HIT_SOUND_NAMES :Array = [ "sfx_basehit1", "sfx_basehit2", "sfx_basehit3" ];

}

}
