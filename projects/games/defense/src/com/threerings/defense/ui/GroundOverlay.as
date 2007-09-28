package com.threerings.defense.ui {

import flash.display.BitmapData;
import flash.filters.BlurFilter;
import flash.geom.Matrix;
import flash.geom.Rectangle;

import mx.core.BitmapAsset;

import com.threerings.defense.Board;
import com.threerings.defense.maps.Map;

/** Graphical representation of a Map object's data, with a high-res bitmap store. */
public class GroundOverlay extends Overlay
{
    override protected function createChildren () :void
    {
        super.createChildren();

//        _hires = new BitmapData(Board.BOARD_WIDTH, Board.BOARD_HEIGHT, true);
//        _hires.fillRect(new Rectangle(0, 0, _hires.width, _hires.height), 0x00000000);

        _scalingMatrix = new Matrix();
        _scalingMatrix.scale(Board.SQUARE_WIDTH, Board.SQUARE_HEIGHT);

        var blur :BlurFilter = new BlurFilter(5, 5, 1);
        
//        this.source = new BitmapAsset(_hires);
        this.scaleX = this.scaleY = 1;
        this.visible = true;
        this.alpha = 0.3;
        this.filters = [ blur ];
    }

    override public function update () :void
    {
        // note: no call to super, this is a complete replacement

        var refreshed :Boolean = refreshFromMap();
        
        if (refreshed) {
            _hires.draw(_bitmap, _scalingMatrix);
        }
    }

    override public function init (map :Map, player :int) :void
    {
        super.init(map, player);

        // we have to recreate the bitmap on every round, because there's no easy way to tell flash
        // "just fill the bitmap with transparent pixels" - because it tries to be "smart" and
        // do pixel blending with any previous pixel values.
        _hires = new BitmapData(Board.BOARD_WIDTH, Board.BOARD_HEIGHT, true);
        _hires.fillRect(new Rectangle(0, 0, _hires.width, _hires.height), 0x00000000);
        this.source = new BitmapAsset(_hires);
    }
    
    protected var _hires :BitmapData;
    protected var _scalingMatrix :Matrix;
}
}
