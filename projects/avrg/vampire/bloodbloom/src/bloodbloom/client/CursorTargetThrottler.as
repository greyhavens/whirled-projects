package bloodbloom.client {

import bloodbloom.*;
import bloodbloom.net.*;

import com.threerings.util.Throttle;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.net.TickedMessageManager;
import com.whirled.game.NetSubControl;

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

        // If the cursor has moved, and the message won't be throttled, send it!
        if ((newX != _lastX || newY != _lastY) && !_throttle.throttleOp()) {
            var toPlayer :int = (Constants.DEBUG_SERVER_AGGREGATES_MESSAGES ?
                NetSubControl.TO_SERVER_AGENT :
                NetSubControl.TO_ALL);

            _msgMgr.sendMessage(CursorTargetMsg.create(_playerId, newX, newY), toPlayer);
            _lastX = newX;
            _lastY = newY;
        }
    }

    protected var _msgMgr :TickedMessageManager;
    protected var _playerId :int;

    protected var _lastX :int;
    protected var _lastY :int;

    protected var _throttle :Throttle = new Throttle(10, 1.1 * 1000); // 10 ops/sec
}

}
