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
        var newBounds :Rectangle = SpaceUtil.paintableToRoomRect(_local.getPaintableArea(false));
        if (newBounds.x != _paintableBounds.x || newBounds.y != _paintableBounds.y ||
            newBounds.width != _paintableBounds.width ||
            newBounds.height != _paintableBounds.height) {
            _paintableBounds = newBounds;
            log.info("Room bounds changed", _paintableBounds);
            dispatchEvent(new GameEvent(GameEvent.ROOM_BOUNDS_CHANGED));
        }
    }

    protected var _local :LocalSubControl;
    protected var _paintableBounds :Rectangle = new Rectangle();

    protected static var log :Log = Log.getLog(RoomBoundsMonitor);
}

}
