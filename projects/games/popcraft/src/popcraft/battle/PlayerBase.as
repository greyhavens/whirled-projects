package popcraft.battle {

import core.AppObject;
import core.AppMode;
import core.objects.RectMeter;
import core.MainLoop;

import popcraft.*;

import flash.display.Sprite;
import flash.display.DisplayObject;
import core.tasks.MeterValueTask;

public class PlayerBase extends AppObject
{
    public function PlayerBase (maxHealth :uint)
    {
        _maxHealth = maxHealth;
        _health = maxHealth;

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
        _healthMeter.displayObject.y = -_healthMeter.height;

        _sprite = new Sprite();
        _sprite.addChild(new Constants.IMAGE_BASE());
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

    public function get health () :int
    {
        return _health;
    }

    public function doDamage (damage :uint) :void
    {
        _health -= Math.min(damage, _health);
        _healthMeter.removeAllTasks();
        _healthMeter.addTask(MeterValueTask.CreateSmooth(_health, 0.25));
    }

    protected var _sprite :Sprite;
    protected var _healthMeter :RectMeter;
    protected var _maxHealth :uint;
    protected var _health :uint;
}

}
