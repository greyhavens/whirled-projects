package popcraft
{

import core.AppObject;
import flash.display.Shape;
import flash.display.DisplayObject;
import flash.display.Sprite;

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

        // draw the board

        var width :int = _cols * _tileSize;
        var height :int = _rows * _tileSize;

        _view = new Sprite();
        _view.graphics.beginFill(0xFFFFFF);
        _view.graphics.drawRect(0, 0, width, height);
        _view.graphics.endFill();

        _view.graphics.lineStyle(1, 0);

        for (var col :int = 0; col < _cols; ++col) {
            _view.graphics.moveTo(col * _tileSize, 0);
            _view.graphics.lineTo(col * _tileSize, height);
        }

        for (var row :int = 0; row < _rows; ++row) {
            _view.graphics.moveTo(0, row * _tileSize);
            _view.graphics.lineTo(width, row * _tileSize);
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _view;
    }

    protected var _tileGrid :Array;
    protected var _view :Sprite;
    protected var _cols :int;
    protected var _rows :int;
    protected var _tileSize :int;
}

}
