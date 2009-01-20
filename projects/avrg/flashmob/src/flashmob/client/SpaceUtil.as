package flashmob.client {

import com.whirled.avrg.AVRGameAvatar;

import flash.geom.Point;
import flash.geom.Rectangle;

import flashmob.*;
import flashmob.client.*;
import flashmob.data.*;

public class SpaceUtil
{
    public static function get fullDisplayBounds () :Rectangle
    {
        return ClientContext.gameCtrl.local.getPaintableArea(true);
    }

    public static function get roomDisplayBounds () :Rectangle
    {
        return ClientContext.gameCtrl.local.getPaintableArea(false);
    }

    public static function getAvatarLogicalLoc (playerId :int) :Vec3D
    {
        var avInfo :AVRGameAvatar = ClientContext.gameCtrl.room.getAvatarInfo(playerId);
        return (avInfo != null ? new Vec3D(avInfo.x, avInfo.y, avInfo.z) : null);
    }

    public static function getAvatarRoomLoc (playerId :int) :Point
    {
        var v :Vec3D = getAvatarLogicalLoc(playerId);
        return (v != null ? ClientContext.gameCtrl.local.locationToRoom(v.x, v.y, v.z) : null);
    }

    public static function logicalToPaintable (v :Vec3D) :Point
    {
        return ClientContext.gameCtrl.local.locationToPaintable(v.x, v.y, v.z);
    }

    public static function logicalToRoom (v :Vec3D) :Point
    {
        return ClientContext.gameCtrl.local.locationToRoom(v.x, v.y, v.z);
    }

    public static function roomToLogicalAtDepth (p :Point, depth :Number) :Vec3D
    {
        var loc :Array = ClientContext.gameCtrl.local.roomToLocationAtDepth(p, depth);
        return (loc != null ? new Vec3D(loc[0], loc[1], loc[2]) : null);
    }

    public static function roomToPaintable (p :Point) :Point
    {
        return ClientContext.gameCtrl.local.roomToPaintable(p);
    }

    public static function paintableToRoom (p :Point) :Point
    {
        return ClientContext.gameCtrl.local.paintableToRoom(p);
    }

    public static function paintableToLogicalAtDepth (p :Point, depth :Number) :Vec3D
    {
        p = ClientContext.gameCtrl.local.paintableToRoom(p);
        return (p != null ? roomToLogicalAtDepth(p, depth) : null);
    }

    public static function paintableToRoomRect (r :Rectangle) :Rectangle
    {
        if (r == null) {
            return null;
        }

        var topLeft :Point = ClientContext.gameCtrl.local.paintableToRoom(r.topLeft);
        var bottomRight :Point = ClientContext.gameCtrl.local.paintableToRoom(r.bottomRight);
        var width :Number = bottomRight.x - topLeft.x;
        var height :Number = bottomRight.y - topLeft.y;
        r.x = topLeft.x;
        r.y = topLeft.y;
        r.width = width;
        r.height = height;

        return r;
    }

    public static function roomToPaintableRect (r :Rectangle) :Rectangle
    {
        if (r == null) {
            return null;
        }

        var topLeft :Point = ClientContext.gameCtrl.local.roomToPaintable(r.topLeft);
        var bottomRight :Point = ClientContext.gameCtrl.local.roomToPaintable(r.bottomRight);
        var width :Number = bottomRight.x - topLeft.x;
        var height :Number = bottomRight.y - topLeft.y;
        r.x = topLeft.x;
        r.y = topLeft.y;
        r.width = width;
        r.height = height;

        return r;
    }

    /*public static function logicalToPaintableRect (r :Rect3D) :Rectangle
    {
        // get top-left and bottom-right coords
        var tl :Point = ClientContext.gameCtrl.local.locationToPaintable(r.x, r.y, r.z);
        var br :Point = ClientContext.gameCtrl.local.locationToPaintable(
            r.x + r.width, r.y + r.height, r.z + r.depth);

        return (tl != null && br != null ? new Rectangle(tl.x, tl.y, br.x - tl.x, br.y - tl.y) :
                null);
    }*/
}

}
