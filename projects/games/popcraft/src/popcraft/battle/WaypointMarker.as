package popcraft.battle {

import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.*;
import com.whirled.contrib.core.resource.*;
import com.whirled.contrib.core.tasks.*;
import com.whirled.contrib.core.util.*;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.filters.ColorMatrixFilter;
import flash.geom.Point;
import flash.geom.Rectangle;

import popcraft.*;
import popcraft.util.*;

public class WaypointMarker extends SceneObject
{
    public function WaypointMarker (owningPlayerId :uint)
    {
        _owningPlayerId = owningPlayerId;

        _sprite = new Sprite();

        // add a tinted flag image
        var waypointBMD :BitmapData = (ResourceManager.instance.getResource("waypoint") as ImageResourceLoader).bitmapData;
        
        var image :Bitmap = createTintedBitmap(waypointBMD, Constants.PLAYER_COLORS[owningPlayerId]);

        image.y = -image.height;
        _sprite.addChild(image);

        //_sprite.alpha = 0.3;
    }

    // from SceneObject
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }
    
    protected static function createTintedBitmap (srcData :BitmapData, rgbTint :uint, amount :Number = 1.0) :Bitmap
    {
        var colorMatrix :ColorMatrix = new ColorMatrix();
        colorMatrix.colorize(rgbTint);
        var tintFilter :ColorMatrixFilter = colorMatrix.createFilter();

        var tintData :BitmapData = new BitmapData(srcData.width, srcData.height, true, 0);
        
        tintData.applyFilter(
            srcData,
            new Rectangle(0, 0, srcData.width, srcData.height),
            new Point(0, 0),
            tintFilter);

        return new Bitmap(tintData);
    }

    public var _sprite :Sprite;
    public var _owningPlayerId :uint;
}

}
