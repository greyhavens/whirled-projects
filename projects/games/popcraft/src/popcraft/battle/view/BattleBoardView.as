package popcraft.battle.view {

import com.threerings.flash.DisplayUtil;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;

import popcraft.*;
import popcraft.net.*;

public class BattleBoardView extends SceneObject
{
    public static const TILE_GROUND :uint = 0;
    public static const TILE_TREE :uint = 1;
    public static const TILE_BASE :uint = 2;

    public function BattleBoardView (width :int, height :int)
    {
        _width = width;
        _height = height;

        _view = new Sprite();

        // board units will attach to _unitDisplayParent, which is drawn above
        // the background and below the foreground
        _unitDisplayParent = new Sprite();

        var bg :Bitmap = (PopCraft.resourceManager.getResource("battle_bg") as ImageResourceLoader).createBitmap();
        bg.scaleX = (_width / bg.width);
        bg.scaleY = (_height / bg.height);

        var fg :Bitmap = (PopCraft.resourceManager.getResource("battle_fg") as ImageResourceLoader).createBitmap();
        fg.scaleX = (_width / fg.width);
        fg.y = bg.height - fg.height; // fg is aligned to the bottom of the board

        _view.addChild(bg);
        _view.addChild(_unitDisplayParent);
        _view.addChild(fg);
    }

    override public function get displayObject () :DisplayObject
    {
        return _view;
    }

    public function get unitDisplayParent () :DisplayObjectContainer
    {
        return _unitDisplayParent;
    }

    public function sortUnitDisplayChildren () :void
    {
        DisplayUtil.sortDisplayChildren(_unitDisplayParent, displayObjectYSort);
    }

    protected static function displayObjectYSort (a :DisplayObject, b :DisplayObject) :int
    {
        var ay :Number = a.y;
        var by :Number = b.y;

        if (ay < by) {
            return -1;
        } else if (ay > by) {
            return 1;
        } else {
            return 0;
        }
    }

    protected var _width :int;
    protected var _height :int;
    protected var _view :Sprite;
    protected var _unitDisplayParent :Sprite;
}

}
