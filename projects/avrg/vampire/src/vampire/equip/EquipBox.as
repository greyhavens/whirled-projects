package equip
{
import com.threerings.flashbang.tasks.LocationTask;

import flash.display.Sprite;
import flash.geom.Point;

public class EquipBox extends Sprite
{
    public function EquipBox()
    {
        super();
        EquipCtx.drawOutlineBox(this.graphics);
    }

    public function isItemOverBox (item :ItemObject) :Boolean
    {
        return this.hitTestObject(item.displayObject);
    }

    public function addItem (item :ItemObject) :void
    {
        _item = item;
        moveItemToBox();
    }

    public function moveItemToBox () :void
    {
        var p :Point = EquipCtx.localToLocal(0, 0, this, EquipCtx.itemLayer);
        item.addTask(LocationTask.CreateEaseIn(p.x, p.y, 0.2));
    }

    public function removeItem () :void
    {
        _item = null;
    }

    public function get item () :ItemObject
    {
        return _item;
    }

    protected var _item :ItemObject;

}
}
