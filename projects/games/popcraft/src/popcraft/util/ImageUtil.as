package popcraft.util {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

public class ImageUtil
{
    public static function createSnapshot (src :DisplayObject) :BitmapData
    {
        var bounds :Rectangle = src.getBounds(src);
        var bd :BitmapData = new BitmapData(bounds.width, bounds.height, true, 0);
        bd.draw(src, new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y));
        return bd;
    }

    public static function createGlowBitmap (srcBitmap :Bitmap, color :uint) :Bitmap
    {
        // add a glow around the image
        var glowData :BitmapData = new BitmapData(
            srcBitmap.width + (GLOW_BUFFER * 2),
            srcBitmap.height + (GLOW_BUFFER * 2),
            true,
            0x00000000);

        var glowFilter :GlowFilter = new GlowFilter();
        glowFilter.color = color;
        glowFilter.alpha = 0.5;
        glowFilter.strength = 8;
        glowFilter.knockout = true;

        glowData.applyFilter(
            srcBitmap.bitmapData,
            new Rectangle(0, 0, srcBitmap.width, srcBitmap.height),
            new Point(GLOW_BUFFER, GLOW_BUFFER),
            glowFilter);

        var glowBitmap :Bitmap = new Bitmap(glowData);
        glowBitmap.x = srcBitmap.x - GLOW_BUFFER;
        glowBitmap.y = srcBitmap.y - GLOW_BUFFER;

        return glowBitmap;
    }

    protected static const GLOW_BUFFER :int = 7;
}

}
