package redrover.game.view {

import com.threerings.display.ColorMatrix;
import com.threerings.flashbang.resource.ImageResource;

import flash.display.Bitmap;
import flash.display.DisplayObject;

import redrover.*;

public class GemViewFactory
{
    public static function createGem (width :Number, gemType :int) :DisplayObject
    {
        var bm :Bitmap = ImageResource.instantiateBitmap(ClientCtx.rsrcs, "gem");
        if (gemType >= 0) {
            bm.filters = [ new ColorMatrix().colorize(GEM_COLORS[gemType]).createFilter() ];
        }

        var scale :Number = width / bm.width;
        bm.scaleX = scale;
        bm.scaleY = scale;

        return bm;
    }

    protected static const GEM_COLORS :Array = [ 0x00FF00, 0xFF00FF, 0xFFFF00 ];
}

}
