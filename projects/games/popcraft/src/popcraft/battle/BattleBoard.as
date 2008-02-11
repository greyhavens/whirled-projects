package popcraft.battle {

import com.whirled.contrib.core.objects.*;
import com.whirled.contrib.core.resource.*;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;

import popcraft.*;
import popcraft.net.*;

public class BattleBoard extends SceneObject
{
    public static const TILE_GROUND :uint = 0;
    public static const TILE_TREE :uint = 1;
    public static const TILE_BASE :uint = 2;

    public function BattleBoard (width :int, height :int)
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

    protected var _width :int;
    protected var _height :int;
    protected var _view :Sprite;
    protected var _unitDisplayParent :Sprite;
}

}
