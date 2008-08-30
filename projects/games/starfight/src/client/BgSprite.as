package client {

import flash.display.Sprite;
import flash.display.Shape;
import flash.display.Bitmap;
import flash.display.BitmapData;

public class BgSprite extends Sprite
{
    public function BgSprite (width :int, height :int)
    {
        // Our background, tiled if necessary.
        var tmpBmp :Bitmap = Resources.getBitmap("space_bg.png");

        var xRep :Number = Math.ceil((width*Codes.BG_PIXELS_PER_TILE +
                                         Codes.GAME_WIDTH)/tmpBmp.width);
        var yRep :Number = Math.ceil((height*Codes.BG_PIXELS_PER_TILE +
                                         Codes.GAME_HEIGHT)/tmpBmp.height);

        for (var x :int = 0; x < xRep; x++) {
            for (var y :int = 0; y < yRep; y++) {
                var bmp :Bitmap = Resources.getBitmap("space_bg.png");
                bmp.x = x*tmpBmp.width;
                bmp.y = y*tmpBmp.height;
                addChild(bmp);
            }
        }
    }

    /**
     * Sets the center of the screen.  We need to adjust ourselves to match.
     */
    public function setAsCenter (boardX :Number, boardY :Number) :void
    {
        x = -(boardX*Codes.BG_PIXELS_PER_TILE);
        y = -(boardY*Codes.BG_PIXELS_PER_TILE);
    }
}
}
