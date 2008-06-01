package popcraft.battle.view {

import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

import popcraft.*;
import popcraft.battle.*;
import popcraft.data.*;

public class SpellDropView extends SceneObject
{
    public function SpellDropView (spellDrop :SpellDropObject)
    {
        _spellObjRef = spellDrop.ref;

        var spellData :CreatureSpellData = spellDrop.creatureSpellData;

        var bitmap :Bitmap = ImageResource.instantiateBitmap(spellData.iconName);
        var scale :Number = Math.min(SpellDropObject.RADIUS / bitmap.width, SpellDropObject.RADIUS / bitmap.height);
        bitmap.scaleX = scale;
        bitmap.scaleY = scale;
        bitmap.x = -(bitmap.width * 0.5);
        bitmap.y = -(bitmap.height * 0.5);

        _sprite = new Sprite();
        _sprite.addChild(bitmap);

        _sprite.x = spellDrop.x;
        _sprite.y = spellDrop.y;
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
