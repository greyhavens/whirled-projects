package redrover.game.view {

import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.resource.ImageResource;

import flash.display.Bitmap;
import flash.display.DisplayObject;

public class GemFactory
{
    public static function createGem (teamId :int = -1) :DisplayObject
    {
        var bm :Bitmap = ImageResource.instantiateBitmap("gem");
        if (teamId >= 0) {
            bm.filters = [ new ColorMatrix().colorize(TEAM_COLORS[teamId]).createFilter() ];
        }

        return bm;
    }

    protected static const TEAM_COLORS :Array = [ 0x78bdff, 0xff9898 ];
}

}
