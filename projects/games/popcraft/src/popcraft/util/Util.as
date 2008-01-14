package popcraft.util {

import flash.display.BitmapData
import flash.display.Bitmap;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.filters.ColorMatrixFilter;

public class Util
{
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

    public static function createTintedBitmap (srcBitmap :Bitmap, argbTint :uint) :Bitmap
    {
        var tintData :BitmapData = new BitmapData(srcBitmap.width, srcBitmap.height, true, 0);

        // separate tintColor into its ARGB components
        var a :Number = Number((argbTint >> 24) & 0x000000FF) / Number(255);
        var r :Number = Number((argbTint >> 16) & 0x000000FF) / Number(255);
        var g :Number = Number((argbTint >> 8) & 0x000000FF) / Number(255);
        var b :Number = Number(argbTint & 0x000000FF) / Number(255);

        // build the matrix
        var mat :Array = [
            r, 0, 0, 0, 0,
            0, g, 0, 0, 0,
            0, 0, b, 0, 0,
            0, 0, 0, a, 0
        ];

        tintData.applyFilter(
            srcBitmap.bitmapData,
            new Rectangle(0, 0, srcBitmap.width, srcBitmap.height),
            new Point(0, 0),
            new ColorMatrixFilter(mat));

        var out :Bitmap = new Bitmap(tintData);
        return out;
    }

    protected static const GLOW_BUFFER :int = 7;
}

}
