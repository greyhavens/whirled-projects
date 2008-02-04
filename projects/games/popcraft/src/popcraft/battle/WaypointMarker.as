package popcraft.battle {

import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.*;
import com.whirled.contrib.core.tasks.*;
import com.whirled.contrib.core.util.*;

import flash.geom.Point;
import flash.geom.Rectangle;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.filters.ColorMatrixFilter;

import popcraft.*;
import popcraft.util.*;

public class WaypointMarker extends SceneObject
{
    public function WaypointMarker (owningPlayerId :uint)
    {
        _owningPlayerId = owningPlayerId;

        _sprite = new Sprite();

         // add a tinted flag image
        var image :Bitmap = createTintedBitmap(
            new Constants.IMAGE_WAYPOINT(),
            Constants.PLAYER_COLORS[owningPlayerId]);

        image.y = -image.height;
        _sprite.addChild(image);

        //_sprite.alpha = 0.3;
    }

    // from SceneObject
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }
    
    protected static function createTintedBitmap (srcBitmap :Bitmap, rgbTint :uint, amount :Number = 1.0) :Bitmap
    {
        var colorMatrix :ColorMatrix = new ColorMatrix();
        colorMatrix.colorize(rgbTint);
        var tintFilter :ColorMatrixFilter = colorMatrix.createFilter();

        var tintData :BitmapData = new BitmapData(srcBitmap.width, srcBitmap.height, true, 0);
        
        tintData.applyFilter(
            srcBitmap.bitmapData,
            new Rectangle(0, 0, srcBitmap.width, srcBitmap.height),
            new Point(0, 0),
            tintFilter);

        return new Bitmap(tintData);
    }

    public var _sprite :Sprite;
    public var _owningPlayerId :uint;
}

}
