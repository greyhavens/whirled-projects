package ui {

import flash.display.BitmapData;

import mx.controls.Image;
import mx.core.BitmapAsset;

import maps.Map;
import maps.MapFactory;

/**
 * Graphical representation of a Map object's data.
 */
public class Overlay extends Image
{
    public function Overlay ()
    {
    }

    public function init (map :Map, player :int) :void
    {
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
        this.source = _bitmap;
        this.scaleX = Board.PIXEL_WIDTH / source.width;
        this.scaleY = Board.PIXEL_HEIGHT / source.height;
    }

    public function update () :void
    {
        if (ready() && visible) {
            _map.maybeRefreshOverlay(_bitmap.bitmapData, _player);
        }
    }

    protected var _map :Map;
    protected var _player :int;
    protected var _bitmap :BitmapAsset;
}
}
    
