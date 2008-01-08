package popcraft.battle {

import popcraft.*;

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.tasks.*;
import com.whirled.contrib.core.objects.*;
import com.whirled.contrib.core.util.*;

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.display.Bitmap;
import com.whirled.contrib.core.tasks.MeterValueTask;
import flash.geom.Point;

public class PlayerBaseUnit extends Unit
{
    public function PlayerBaseUnit (owningPlayerId :uint, loc :Vector2)
    {
        super(Constants.UNIT_TYPE_BASE, owningPlayerId);

        _unitSpawnLoc = loc;

        _sprite = new Sprite();
        _sprite.x = loc.x;
        _sprite.y = loc.y;

        var baseImage :Bitmap = new Constants.IMAGE_BASE();
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

    override protected function removedFromDB (db :ObjectDB) :void
    {
        _healthMeter.destroySelf();
    }

    // from AppObject
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    public function get unitSpawnLoc () :Vector2
    {
        return _unitSpawnLoc;
    }

    // from Unit
    override public function receiveAttack (sourceId :uint, attack :UnitAttack) :void
    {
        super.receiveAttack(sourceId, attack);
        _healthMeter.addTask(MeterValueTask.CreateSmooth(_health, 0.25));

        // when the player base is attacked, it deals damage back to the attacker
        var source :Unit = (GameMode.instance.netObjects.getObject(sourceId) as Unit);
        if (null != source) {
            this.sendAttack(source, this.unitData.attack);
        }
    }

    protected var _unitSpawnLoc :Vector2 = new Vector2();

    protected var _sprite :Sprite;
    protected var _healthMeter :RectMeter;
}

}
