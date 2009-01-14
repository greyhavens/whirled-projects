package flashmob.client {

import com.threerings.util.Log;
import com.whirled.avrg.LocalSubControl;
import com.whirled.contrib.simplegame.Updatable;

import flash.events.EventDispatcher;
import flash.geom.Point;
import flash.geom.Rectangle;

public class RoomBoundsMonitor extends EventDispatcher
    implements Updatable
{
    public function RoomBoundsMonitor ()
    {
        _local = ClientContext.gameCtrl.local;
    }

    public function update (dt :Number) :void
    {
        var newBounds :Rectangle = paintableToRoom(_local.getPaintableArea(false));
        if (newBounds.x != _paintableBounds.x || newBounds.y != _paintableBounds.y ||
            newBounds.width != _paintableBounds.width ||
            newBounds.height != _paintableBounds.height) {
            _paintableBounds = newBounds;
            log.info("Room bounds changed", _paintableBounds);
            dispatchEvent(new GameEvent(GameEvent.ROOM_BOUNDS_CHANGED));
        }
    }

    public function paintableToRoom (r :Rectangle) :Rectangle
    {
        var topLeft :Point = _local.paintableToRoom(r.topLeft);
        var bottomRight :Point = _local.paintableToRoom(r.bottomRight);
        var width :Number = bottomRight.x - topLeft.x;
        var height :Number = bottomRight.y - topLeft.y;
        r.x = topLeft.x;
        r.y = topLeft.y;
        r.width = width;
        r.height = height;

        return r;
    }

    public function roomToPaintable (r :Rectangle) :Rectangle
    {
        var topLeft :Point = _local.roomToPaintable(r.topLeft);
        var bottomRight :Point = _local.roomToPaintable(r.bottomRight);
        var width :Number = bottomRight.x - topLeft.x;
        var height :Number = bottomRight.y - topLeft.y;
        r.x = topLeft.x;
        r.y = topLeft.y;
        r.width = width;
        r.height = height;

        return r;
    }

    protected function get log () :Log
    {
        return FlashMobClient.log;
    }

    protected var _local :LocalSubControl;
    protected var _paintableBounds :Rectangle = new Rectangle();
}

}
