package equip
{
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Sprite;

//Shows all items in the players inventory
public class ItemsDisplay extends SceneObject
{

    public static const BOXES :int = 5;

    public function ItemsDisplay()
    {
        super();

//        for (var ii :int = 0; ii < BOXES; ++ii) {
//            EquipCtx.drawOutlineBox(_displaySprite.graphics, getItemX(ii), 0)
//        }

        for (var ii :int = 0; ii < BOXES; ++ii) {
            var box :EquipBox = new EquipBox();
            _itemBoxes.push(box);
            _displaySprite.addChild(box);
            box.x = getItemX(ii);
        }

    }

    public function isHoldingItem (item :ItemObject) :Boolean
    {
        return getBox(item) != null;
    }

    override protected function addedToDB () :void
    {
        for (var ii :int = 0; ii < EquipCtx.playerEquipData.allItems.length; ++ii) {
            var itemId :int = EquipCtx.playerEquipData.allItems[ii];
            var itemObj :ItemObject = EquipFactory.createItemObject(itemId);
            db.addObject(itemObj);
            EquipCtx.itemLayer.addChild(itemObj.displayObject);

            var box :EquipBox = getFirstUnOccupiedBox();

            box.addItem(itemObj);

//
//
//            _items[ii] = itemObj;
//            EquipCtx.itemLayer.addChild(itemObj.displayObject);
//            var p :Point = EquipCtx.localToLocal(getItemX(ii), 0, displayObject, EquipCtx.itemLayer);
//            itemObj.x = p.x;
//            itemObj.y = p.y;
        }
    }

    public function getBoxOverlapping (item :ItemObject) :EquipBox
    {
        for each (var equipBox :EquipBox in _itemBoxes) {
            if (equipBox.isItemOverBox(item)) {
                return equipBox;
            }
        }
        return null;
    }

    public function getFirstUnOccupiedBox () :EquipBox
    {
        for each (var box :EquipBox in _itemBoxes) {
            if (box.item == null) {
                return box;
            }
        }
        return null;
    }

    public function getBox (item :ItemObject) :EquipBox
    {
        for each (var box :EquipBox in _itemBoxes) {
            if (box.item == item) {
                return box;
            }
        }
        return null;
    }

    public function moveItemToBox (item :ItemObject) :void
    {
        var box :EquipBox = getBox(item);
        if (box != null) {
            box.moveItemToBox();
        }
//        var index :int = ArrayUtil.indexOf(_items, item);
//        if (index == -1) {
//            index = ArrayUtil.indexOf(_items, null);
//        }
//        if (index == -1) {
//            index = ArrayUtil.indexOf(_items, null);
//        }
//        var p :Point = EquipCtx.localToLocal(getItemX(index), 0, displayObject, EquipCtx.itemLayer);
//        item.addTask(LocationTask.CreateEaseIn(p.x, p.y, 0.2));
//        _items[index] = item;

    }



//    public function removeFromList (item :ItemObject) :void
//    {
//        var index :int = ArrayUtil.indexOf(_items, item);
//        _items[index] = null;
//    }



    public function getItemX (index :int) :int
    {
        return EquipCtx.BOX_SIZE * index + EquipCtx.BOX_SIZE / 2;
    }

    override public function get displayObject () :DisplayObject
    {
        return _displaySprite;
    }

    protected var _itemBoxes :Array = [];
    protected var _items :Array = [];
    protected var _displaySprite :Sprite = new Sprite();

}
}