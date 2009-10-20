package equip
{
import com.threerings.flashbang.FlashbangApp;
import com.threerings.flashbang.resource.ResourceManager;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Point;

public class EquipCtx
{
    public static var playerId :int;
    public static var game :FlashbangApp;
    public static var rsrcs :ResourceManager;

    public static var itemLayer :Sprite;

    public static var playerEquipData :PlayerEquipData;

    public static const BOX_SIZE :int = 60;

    public static function drawOutlineBox (g :Graphics, xPos :int = 0, yPos :int = 0) :void
    {
        g.lineStyle(5, 0);
        g.drawRect(xPos-BOX_SIZE / 2, yPos-BOX_SIZE / 2, BOX_SIZE, BOX_SIZE);
    }

    public static function transferMaintainingGlobalLocation (d :DisplayObject,
        newParent :DisplayObjectContainer) :void
    {
        var global :Point = d.parent.localToGlobal(new Point(d.x, d.y));
        var localPoint :Point = newParent.globalToLocal(global);
        newParent.addChild(d);
        d.x = localPoint.x;
        d.y = localPoint.y;
    }

    public static function localToLocal (x :int, y :int, from :DisplayObject, newLocal :DisplayObject) :Point
    {
        var global :Point = from.localToGlobal(new Point(x, y));
        var localPoint :Point = newLocal.globalToLocal(global);
        return localPoint;
    }

}
}
