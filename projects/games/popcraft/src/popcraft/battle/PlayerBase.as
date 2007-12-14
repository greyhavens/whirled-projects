package popcraft.battle {

import core.AppObject;
import core.AppMode;
import core.objects.RectMeter;
import core.MainLoop;

import popcraft.*;

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.display.Bitmap;
import core.tasks.MeterValueTask;
import flash.geom.Point;

public class PlayerBase extends AppObject
{
    public function PlayerBase (owningPlayer :uint, loc :Vector2, maxHealth :uint)
    {
        _owningPlayer = owningPlayer;
        _unitSpawnLoc = loc;
        _maxHealth = maxHealth;
        _health = maxHealth;

        _sprite = new Sprite();
        _sprite.x = loc.x;
        _sprite.y = loc.y;

        var baseImage :Bitmap = new Constants.IMAGE_BASE();
        baseImage.x = -(baseImage.width / 2);
        baseImage.y = -(baseImage.height / 2);

        _sprite.addChild(baseImage);

        _sprite.addChild(Util.createGlowBitmap(baseImage, Constants.PLAYER_COLORS[_owningPlayer] as uint));

        // health meter
        _healthMeter = new RectMeter();
        _healthMeter.minValue = 0;
        _healthMeter.maxValue = maxHealth;
        _healthMeter.value = maxHealth;
        _healthMeter.foregroundColor = 0xFF0000;
        _healthMeter.backgroundColor = 0x888888;
        _healthMeter.outlineColor = 0x000000;
        _healthMeter.width = 50;
        _healthMeter.height = 10;
        _healthMeter.displayObject.x = baseImage.x;
        _healthMeter.displayObject.y = baseImage.y - _healthMeter.height;
    }

    override protected function addedToMode (mode :AppMode) :void
    {
        // @TODO - this is probably bad practice right here.
        MainLoop.instance.topMode.addObject(_healthMeter, _sprite);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    public function get maxHealth() :uint
    {
        return _maxHealth;
    }

    public function get health () :uint
    {
        return _health;
    }

    public function get owningPlayer () :uint
    {
        return _owningPlayer;
    }

    public function get unitSpawnLoc () :Vector2
    {
        return _unitSpawnLoc;
    }

    public function doDamage (damage :uint) :void
    {
        _health -= Math.min(damage, _health);
        _healthMeter.removeAllTasks();
        _healthMeter.addTask(MeterValueTask.CreateSmooth(_health, 0.25));
    }

    protected var _owningPlayer :uint;
    protected var _unitSpawnLoc :Vector2 = new Vector2();

    protected var _sprite :Sprite;
    protected var _healthMeter :RectMeter;
    protected var _maxHealth :uint;
    protected var _health :uint;
}

}
