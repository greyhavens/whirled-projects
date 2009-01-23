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
        _local = ClientCtx.gameCtrl.local;
    }

    public function update (dt :Number) :void
    {
        var paintableBounds :Rectangle = _local.getPaintableArea(false);
        var visibleRoomBounds :Rectangle = SpaceUtil.paintableToRoomRect(paintableBounds);

        if (visibleRoomBounds != null && !_lastBounds.equals(visibleRoomBounds)) {
            _lastBounds = visibleRoomBounds;
            log.info("Room bounds changed", "bounds", visibleRoomBounds);
            dispatchEvent(new GameEvent(GameEvent.ROOM_BOUNDS_CHANGED));
        }

        log.info("RBM", "stageToRoom", SpaceUtil.paintableToRoom(new Point(0, 0)));
    }

    protected var _local :LocalSubControl;
    protected var _lastBounds :Rectangle = new Rectangle();

    protected static var log :Log = Log.getLog(RoomBoundsMonitor);
}

}
