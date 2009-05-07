package vampire.fightproto.fight {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

import vampire.fightproto.*;

public class PlayerView extends SceneObject
{
    public function PlayerView ()
    {
        _sprite = new Sprite();

        var bitmap :Bitmap = ClientCtx.instantiateBitmap("player");
        bitmap.x = -bitmap.width * 0.5;
        bitmap.y = -bitmap.height;
        _sprite.addChild(bitmap);

        _energyMeter = new RectMeterView();
        _energyMeter.minValue = 0;
        _energyMeter.maxValue = ClientCtx.player.maxEnergy;
        _energyMeter.value = ClientCtx.player.energy;
        _energyMeter.foregroundColor = 0x0000ff;
        _energyMeter.backgroundColor = 0xffffff;
        _energyMeter.outlineColor = 0;
        _energyMeter.meterWidth = 100;
        _energyMeter.meterHeight = 15;
        _energyMeter.updateDisplay();

        _energyMeter.x = -_energyMeter.width * 0.5;
        _energyMeter.y = bitmap.y - _energyMeter.height - 3;
        _sprite.addChild(_energyMeter);

        _healthMeter = new RectMeterView();
        _healthMeter.minValue = 0;
        _healthMeter.maxValue = ClientCtx.player.maxHealth;
        _healthMeter.value = ClientCtx.player.health;
        _healthMeter.foregroundColor = 0xff0000;
        _healthMeter.backgroundColor = 0xffffff;
        _healthMeter.outlineColor = 0;
        _healthMeter.meterWidth = 100;
        _healthMeter.meterHeight = 15;
        _healthMeter.updateDisplay();

        _healthMeter.x = -_healthMeter.width * 0.5;
        _healthMeter.y = _energyMeter.y - _healthMeter.height - 3;
        _sprite.addChild(_healthMeter);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        ClientCtx.player.offsetEnergy(dt * ClientCtx.player.energyReplenishRate);

        _healthMeter.value = Math.max(ClientCtx.player.health, 0);
        if (_healthMeter.needsDisplayUpdate) {
            _healthMeter.updateDisplay();
        }

        _energyMeter.value = Math.max(ClientCtx.player.energy, 0);
        if (_energyMeter.needsDisplayUpdate) {
            _energyMeter.updateDisplay();
        }
    }

    protected var _sprite :Sprite;
    protected var _healthMeter :RectMeterView;
    protected var _energyMeter :RectMeterView;
}

}
