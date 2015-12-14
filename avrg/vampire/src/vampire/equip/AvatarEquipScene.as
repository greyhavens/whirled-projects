package equip
{
import com.threerings.flashbang.objects.SceneObject;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;

public class AvatarEquipScene extends SceneObject
{
    public static const BOX_SIZE :int = 60;

    public function AvatarEquipScene()
    {
        super();
        var b :Bitmap = EquipFactory.instantiateBitmap("body");
        _displaySprite.addChild(b);

        _displaySprite.addChild(_hand1Panel);
        _displaySprite.addChild(_pantPanel);
        _displaySprite.addChild(_mindPanel);

        _hand1Panel.x = -40;
        _hand1Panel.y = 40;

        _pantPanel.x = 0 + b.width / 2;
        _pantPanel.y = 150;

        _mindPanel.x = b.width + 40;
        _mindPanel.y = 40;

//        drawOutlineBox(_hand1Panel.graphics, 0, 0);
//        drawOutlineBox(_pantPanel.graphics, 0, 0);
    }

    protected function drawOutlineBox (g :Graphics, xPos :int, yPos :int) :void
    {
        g.lineStyle(5, 0);
        g.drawRect(xPos-BOX_SIZE / 2, yPos-BOX_SIZE / 2, BOX_SIZE, BOX_SIZE);
    }

    override public function get displayObject () :DisplayObject
    {
        return _displaySprite;
    }

    public function getBoxOverlapping (item :ItemObject) :EquipBox
    {
        for each (var equipBox :EquipBox in _boxes) {
            if (equipBox.isItemOverBox(item)) {
                return equipBox;
            }
        }
        return null;
    }

    public function isHoldingItem (item :ItemObject) :Boolean
    {
        return getBox(item) != null;
    }

    public function getBox (item :ItemObject) :EquipBox
    {
        for each (var box :EquipBox in _boxes) {
            if (box.item == item) {
                return box;
            }
        }
        return null;
    }

    public function addItem (item :ItemObject, box :EquipBox, items :ItemsDisplay) :void
    {
        if (item == null) {
            return;
        }
        var itembox :EquipBox = items.getBox(item);
        if (box == null) {
            if (items.isHoldingItem(item)) {
                itembox.moveItemToBox();
            }
//            items.moveItemToBox(item);
            return;
        }
        if (items.isHoldingItem(item)) {
            itembox.removeItem();
        }

        box.addItem(item);
    }


    public var _hand1Panel :EquipBox = new EquipBox();
    public var _pantPanel :EquipBox = new EquipBox();
    public var _mindPanel :EquipBox = new EquipBox();

    protected var _boxes :Array = [_hand1Panel, _pantPanel, _mindPanel];

    protected var _displaySprite :Sprite = new Sprite();
}
}
