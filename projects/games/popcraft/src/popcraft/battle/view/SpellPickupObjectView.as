package popcraft.battle.view {

import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

import popcraft.*;
import popcraft.battle.*;
import popcraft.data.*;

public class SpellPickupObjectView extends SceneObject
{
    public function SpellPickupObjectView (spellPickup :SpellPickupObject)
    {
        _spellObjRef = spellPickup.ref;

        var spellData :SpellData = spellPickup.spellData;

        var bitmap :Bitmap = AppContext.instantiateBitmap(spellData.name + "_icon");
        var scale :Number = Math.min(SpellPickupObject.RADIUS / bitmap.width, SpellPickupObject.RADIUS / bitmap.height);
        bitmap.scaleX = scale;
        bitmap.scaleY = scale;
        bitmap.x = -(bitmap.width * 0.5);
        bitmap.y = -(bitmap.height * 0.5);

        _sprite = new Sprite();
        _sprite.addChild(bitmap);

        _sprite.x = spellPickup.x;
        _sprite.y = spellPickup.y;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        if (_spellObjRef.isNull) {
            this.destroySelf();
        }
    }

    protected var _spellObjRef :SimObjectRef;
    protected var _sprite :Sprite
}

}
