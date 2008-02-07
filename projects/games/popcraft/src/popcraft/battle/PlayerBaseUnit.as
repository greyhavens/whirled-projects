package popcraft.battle {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.*;
import com.whirled.contrib.core.resource.*;
import com.whirled.contrib.core.tasks.*;
import com.whirled.contrib.core.util.*;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

import popcraft.*;

public class PlayerBaseUnit extends Unit
{
    public function PlayerBaseUnit (owningPlayerId :uint, loc :Vector2)
    {
        super(Constants.UNIT_TYPE_BASE, owningPlayerId);

        _unitSpawnLoc = loc;

        _sprite = new Sprite();
        _sprite.x = loc.x;
        _sprite.y = loc.y;

        var baseImage :Bitmap = (ResourceManager.instance.getResource("base") as ImageResourceLoader).createBitmap();
        baseImage.x = -(baseImage.width / 2);
        baseImage.y = -(baseImage.height / 2);

        _sprite.addChild(baseImage);
        _sprite.addChild(this.createOwningPlayerGlowForBitmap(baseImage));

        // health meter
        _healthMeter = new RectMeter();
        _healthMeter.minValue = 0;
        _healthMeter.maxValue = _unitData.maxHealth;
        _healthMeter.value = _health;
        _healthMeter.foregroundColor = 0xFF0000;
        _healthMeter.backgroundColor = 0x888888;
        _healthMeter.outlineColor = 0x000000;
        _healthMeter.width = 50;
        _healthMeter.height = 10;
        _healthMeter.displayObject.x = baseImage.x;
        _healthMeter.displayObject.y = baseImage.y - _healthMeter.height;

        // @TODO - this is probably bad practice right here.
        GameMode.instance.addObject(_healthMeter, _sprite);
    }

    override protected function destroyed () :void
    {
        _healthMeter.destroySelf();
    }

    // from SceneObject
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    public function get unitSpawnLoc () :Vector2
    {
        return _unitSpawnLoc;
    }
    
    override protected function update (dt :Number) :void
    {
        _healthMeter.value = _health;
    }

    protected var _unitSpawnLoc :Vector2 = new Vector2();

    protected var _sprite :Sprite;
    protected var _healthMeter :RectMeter;
}

}
