package popcraft {

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

public class BitmapAnimFrame
{
    public static const EMPTY :BitmapAnimFrame = new BitmapAnimFrame(new BitmapData(1, 1, true, 0));

    public var bitmapData :BitmapData;
    public var offset :Point;

    public function BitmapAnimFrame (bitmapData :BitmapData, offset :Point = null)
    {
        this.bitmapData = bitmapData;
        this.offset = (offset != null ? offset : new Point(0, 0));
    }

    public static function fromDisplayObject (src :DisplayObject) :BitmapAnimFrame
    {
        var bounds :Rectangle = src.getBounds(src);
        var bd :BitmapData = new BitmapData(bounds.width, bounds.height, true, 0);
        bd.draw(src, new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y));

        return new BitmapAnimFrame(bd, new Point(bounds.x, bounds.y));
    }

}

}
