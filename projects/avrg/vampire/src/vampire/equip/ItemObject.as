package equip
{
import com.threerings.util.Command;
import com.threerings.flashbang.objects.SimpleSceneObject;

import flash.display.DisplayObject;
import flash.events.MouseEvent;

public class ItemObject extends SimpleSceneObject
{
    public function ItemObject(itemId :int, itemGraphic :DisplayObject)
    {
        super(itemGraphic);
        _itemId = itemId;

        Command.bind(displayObject, MouseEvent.MOUSE_DOWN, EquipController.ITEM_MOUSE_DOWN, this);
    }

    public function get itemId () :int
    {
        return _itemId;
    }

    protected var _itemId :int;
}
}
