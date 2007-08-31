package {

import flash.display.BitmapData;

import mx.controls.Image;
import mx.core.BitmapAsset;

public class Overlay extends Image
{
    public function Overlay ()
    {
    }

    public function init (map :Map) :void
    {
        _map = map;
    }

    override protected function createChildren () :void
    {
        super.createChildren();
        
        _bitmap = MapFactory.makeBlankOverlay();
        this.source = _bitmap;
        this.scaleX = Board.PIXEL_WIDTH / source.width;
        this.scaleY = Board.PIXEL_HEIGHT / source.height;
    }

    public function update (player :int) :void
    {
        _map.fillOverlay(_bitmap.bitmapData, player);
    }

    protected var _map :Map;
    protected var _bitmap :BitmapAsset;
}
}
    
