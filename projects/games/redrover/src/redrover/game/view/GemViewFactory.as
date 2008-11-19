package redrover.game.view {

import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.resource.ImageResource;

import flash.display.Bitmap;
import flash.display.DisplayObject;

public class GemViewFactory
{
    public static function createGem (gemType :int = -1) :DisplayObject
    {
        var bm :Bitmap = ImageResource.instantiateBitmap("gem");
        if (gemType >= 0) {
            bm.filters = [ new ColorMatrix().colorize(GEM_COLORS[gemType]).createFilter() ];
        }

        return bm;
    }

    protected static const GEM_COLORS :Array = [ 0x00FF00, 0xFF00FF ];
}

}
