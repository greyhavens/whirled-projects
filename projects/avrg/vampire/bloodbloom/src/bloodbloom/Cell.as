package bloodbloom {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

public class Cell extends SceneObject
{
    public static function getCellCount (type :int) :int
    {
        return ClientCtx.mainLoop.topMode.getObjectRefsInGroup("Cell_" + type).length;
    }

    public function Cell (type :int)
    {
        _type = type;

        _sprite = new Sprite();
        var bitmap :Bitmap =
            ClientCtx.instantiateBitmap(_type == Constants.CELL_WHITE ? "white_cell" : "red_cell");
        bitmap.x = -bitmap.width * 0.5;
        bitmap.y = -bitmap.height * 0.5;
        _sprite.addChild(bitmap);
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        if (groupNum == 0) {
            return "Cell_" + _type;
        } else {
            return super.getObjectGroup(groupNum - 1);
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _type :int;
    protected var _sprite :Sprite;
}

}
