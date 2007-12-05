package ui {

import flash.display.BitmapData;
import flash.filters.BlurFilter;
import flash.geom.Matrix;
import flash.geom.Rectangle;

import mx.core.BitmapAsset;

import game.Board;
import maps.Map;

/** Graphical representation of a Map object's data, with a high-res bitmap store. */
public class GroundOverlay extends Overlay
{
    override protected function createChildren () :void
    {
        super.createChildren();

        _scalingMatrix = new Matrix();
        _scalingMatrix.scale(_board.tileWidth, _board.tileHeight);

        var blur :BlurFilter = new BlurFilter(10, 5, 1);
        
//        this.source = new BitmapAsset(_hires);
        this.scaleX = this.scaleY = 1;
        this.visible = true;
        this.alpha = 0.3;
        this.filters = [ blur ];
        this.cacheAsBitmap = true;
    }

    override public function update () :void
    {
        // note: no call to super, this is a complete replacement

        var refreshed :Boolean = refreshFromMap();
        
        if (refreshed) {
            _hires.draw(_bitmap, _scalingMatrix);
        }
    }

    override public function init (board :Board, map :Map, player :int) :void
    {
        super.init(board, map, player);

        // we have to recreate the bitmap on every round, because there's no easy way to tell flash
        // "just fill the bitmap with transparent pixels" - because it tries to be "smart" and
        // do pixel blending with any previous pixel values.
        _hires = new BitmapData(_board.boardWidth, _board.boardHeight, true);
        _hires.fillRect(new Rectangle(0, 0, _hires.width, _hires.height), 0x00000000);
        this.source = new BitmapAsset(_hires);
    }
    
    protected var _hires :BitmapData;
    protected var _scalingMatrix :Matrix;
}
}
