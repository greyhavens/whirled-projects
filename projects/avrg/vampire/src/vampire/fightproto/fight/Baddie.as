package vampire.fightproto.fight {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Sprite;

import vampire.fightproto.BaddieDesc;
import vampire.fightproto.RectMeterView;

public class Baddie extends SceneObject
{
    public function Baddie (desc :BaddieDesc)
    {
        _desc = desc;
        _curHealth = desc.health;

        _sprite = new Sprite();

        var baddieSprite :Sprite = desc.createSprite();
        baddieSprite.x = -baddieSprite.width * 0.5;
        baddieSprite.y = -baddieSprite.height;
        _sprite.addChild(baddieSprite);

        _healthMeter = new RectMeterView();
        _healthMeter.minValue = 0;
        _healthMeter.maxValue = _desc.health;
        _healthMeter.value = _curHealth;
        _healthMeter.foregroundColor = 0xff0000;
        _healthMeter.backgroundColor = 0xffffff;
        _healthMeter.outlineColor = 0;
        _healthMeter.meterWidth = 100;
        _healthMeter.meterHeight = 10;
        _healthMeter.updateDisplay();

        _healthMeter.x = -_healthMeter.width * 0.5;
        _healthMeter.y = baddieSprite.y - _healthMeter.height - 3;
        _sprite.addChild(_healthMeter);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    public function get curHealth () :int
    {
        return _curHealth;
    }

    public function set curHealth (val :int) :void
    {
        _curHealth = val;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        _healthMeter.value = Math.max(_curHealth, 0);
        if (_healthMeter.needsDisplayUpdate) {
            _healthMeter.updateDisplay();
        }
    }

    protected var _desc :BaddieDesc;
    protected var _curHealth :int;

    protected var _sprite :Sprite;
    protected var _healthMeter :RectMeterView;
}

}
