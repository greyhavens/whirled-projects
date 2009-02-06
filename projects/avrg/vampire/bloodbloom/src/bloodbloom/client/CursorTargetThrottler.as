package bloodbloom.client {

import bloodbloom.*;
import bloodbloom.net.*;

import com.threerings.util.Throttle;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.net.TickedMessageManager;

public class CursorTargetThrottler extends SimObject
{
    public function CursorTargetThrottler (playerId :int, msgMgr :TickedMessageManager)
    {
        _msgMgr = msgMgr;
        _playerId = playerId;
    }

    override protected function update (dt :Number) :void
    {
        var newX :int = GameCtx.cursorLayer.mouseX;
        var newY :int = GameCtx.cursorLayer.mouseY;
        if (_x != newX || _y != newY) {
            _x = newX;
            _y = newY;
            _dirty = true;
        }

        // If the cursor has moved, and the message won't be throttled, send it!
        if (_dirty && !_throttle.throttleOp()) {
            _msgMgr.sendMessage(CursorTargetMsg.create(_playerId, _x, _y));
            _dirty = false;
        }
    }

    protected var _msgMgr :TickedMessageManager;
    protected var _playerId :int;

    protected var _x :int;
    protected var _y :int;
    protected var _dirty :Boolean;

    protected var _throttle :Throttle = new Throttle(10, 1 * 1000); // 10 ops/sec
}

}
