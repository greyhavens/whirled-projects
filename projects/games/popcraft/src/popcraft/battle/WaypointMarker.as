package popcraft.battle {

import popcraft.*;

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.tasks.*;
import com.whirled.contrib.core.objects.*;
import com.whirled.contrib.core.util.*;

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.filters.ColorMatrixFilter;
import flash.display.Bitmap;

public class WaypointMarker extends AppObject
{
    public function WaypointMarker (owningPlayerId :uint)
    {
        _owningPlayerId = owningPlayerId;

        _sprite = new Sprite();

         // add a tinted flag image
        var image :Bitmap = Util.createTintedBitmap(
            new Constants.IMAGE_WAYPOINT(),
            Constants.PLAYER_COLORS[owningPlayerId]);

        image.y = -image.height;
        _sprite.addChild(image);

        //_sprite.alpha = 0.3;
    }

    // from AppObject
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    public var _sprite :Sprite;
    public var _owningPlayerId :uint;
}

}
