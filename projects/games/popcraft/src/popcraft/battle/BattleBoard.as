package popcraft.battle {

import popcraft.*;

import core.AppObject;
import flash.display.Shape;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import popcraft.net.PlaceWaypointMessage;
import flash.geom.Point;
import flash.display.Bitmap;
import flash.display.DisplayObjectContainer;

public class BattleBoard extends AppObject
{
    public static const TILE_GROUND :uint = 0;
    public static const TILE_TREE :uint = 1;
    public static const TILE_BASE :uint = 2;

    public function BattleBoard (cols: int, rows :int, tileSize :int)
    {
        _cols = cols;
        _rows = rows;
        _tileSize = tileSize;

        _tileGrid = new Array(_cols * _rows);
        for (var i :int = 0; i < _tileGrid.length; ++i) {
            _tileGrid[i] = TILE_GROUND;
        }

        _view = new Sprite();

        // board units will attach to _unitDisplayParent, which is drawn above
        // the background and below the foreground
        _unitDisplayParent = new Sprite();

        var bg :Bitmap = new Constants.IMAGE_BATTLE_BG();
        var fg :Bitmap = new Constants.IMAGE_BATTLE_FG();
        fg.y = bg.height - fg.height; // fg is aligned to the bottom of the board

        _view.addChild(bg);
        _view.addChild(_unitDisplayParent);
        _view.addChild(fg);

        _view.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false);
    }

    override public function get displayObject () :DisplayObject
    {
        return _view;
    }

    public function get unitDisplayParent () :DisplayObjectContainer
    {
        return _unitDisplayParent;
    }

    protected function handleMouseDown (e :MouseEvent) :void
    {
        // translate the mouse coordinates to local coordinates
        // (the click may have originated on a display descendent)
        var loc :Point = _view.globalToLocal(new Point(e.stageX, e.stageY));

        GameMode.instance.placeWaypoint(loc.x, loc.y);
    }

    protected var _tileGrid :Array;
    protected var _view :Sprite;
    protected var _unitDisplayParent :Sprite;
    protected var _cols :int;
    protected var _rows :int;
    protected var _tileSize :int;
}

}
