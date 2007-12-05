package ui {

import flash.display.BitmapData;

import mx.controls.Image;
import mx.core.BitmapAsset;

import game.Board;
import maps.Map;
import maps.MapFactory;

/** Graphical representation of a Map object's data, with a low res bitmap where each pixel
 *  corresponds to a single board cell. */
public class Overlay extends Image
{
    public function init (board :Board, map :Map, player :int) :void
    {
        _board = board;
        _map = map;
        _player = player;
    }

    public function ready () :Boolean
    {
        return (_map != null);
    }

    override protected function createChildren () :void
    {
        super.createChildren();
        
        _bitmap = MapFactory.makeBlankOverlay();
        trace("GOT BITMAP: " + _bitmap + " : " + _bitmap.width + " x " + _bitmap.height);
        trace("GOT BOARD: " + _board);
        this.source = _bitmap;
        this.scaleX = _board.boardWidth / _bitmap.width;
        this.scaleY = _board.boardHeight / _bitmap.height;

        this.visible = false;
        this.cacheAsBitmap = true;
    }

    public function update () :void
    {
        refreshFromMap(); // try to refresh on every iteration
    }

    public function refreshFromMap () :Boolean
    {
        if (ready() && visible) {
            return _map.maybeRefreshOverlay(_bitmap.bitmapData, _player);
        }
        return false;
    }

    protected var _board :Board;
    protected var _map :Map;
    protected var _player :int;
    protected var _bitmap :BitmapAsset;
}
}
