package {

import flash.display.Bitmap;
import flash.display.BitmapData;

import flash.geom.Rectangle;
import flash.geom.Point;

public class Doll extends Bitmap
{
    public static const SIZE :int = 32; // Pixel dimensions of each sprite

    function Doll ()
    {
        _sheet = (new SHEET() as Bitmap).bitmapData;
    }

    public function layer (sprites :Array) :void
    {
        bitmapData = new BitmapData(SIZE, SIZE, true, 0);

        var w :int = _sheet.width/SIZE;
        var h :int = _sheet.height/SIZE;

        for each (var sprite :int in sprites) {
            bitmapData.copyPixels(_sheet,
                new Rectangle(
                    SIZE*(sprite%w), SIZE*(Math.floor(sprite/w)), SIZE, SIZE),
                new Point(0, 0), null, null, true);
        }

        smoothing = true;
    }

    [Embed(source="sheet.png")]
    protected static const SHEET :Class;

    protected var _sheet :BitmapData;
}

}
