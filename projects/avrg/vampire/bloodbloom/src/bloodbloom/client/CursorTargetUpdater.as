package bloodbloom.client {

import bloodbloom.*;
import bloodbloom.net.*;

import com.threerings.util.Throttle;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.net.TickedMessageManager;
import com.whirled.game.NetSubControl;

import flash.events.MouseEvent;

public class CursorTargetUpdater extends SimObject
{
    public function CursorTargetUpdater (playerId :int, msgMgr :TickedMessageManager)
    {
        _msgMgr = msgMgr;
        _playerId = playerId;

        if (Constants.CLICK_TO_MOVE) {
            registerListener(GameCtx.gameMode.modeSprite, MouseEvent.CLICK,
                function (...ignored) :void {
                    readCursorLoc();
                });
        }
    }

    override protected function update (dt :Number) :void
    {
        if (!Constants.CLICK_TO_MOVE) {
            readCursorLoc();
        }

        // If the cursor has moved, and the message won't be throttled, send it!
        if ((_newX != _lastX || _newY != _lastY) && !_throttle.throttleOp()) {
            var toPlayer :int = (Constants.DEBUG_SERVER_AGGREGATES_MESSAGES ?
                NetSubControl.TO_SERVER_AGENT :
                NetSubControl.TO_ALL);

            _msgMgr.sendMessage(CursorTargetMsg.create(_playerId, _newX, _newY), toPlayer);
            _lastX = _newX;
            _lastY = _newY;
        }
    }

    protected function readCursorLoc () :void
    {
        _newX = GameCtx.cursorLayer.mouseX;
        _newY = GameCtx.cursorLayer.mouseY;
    }

    protected var _msgMgr :TickedMessageManager;
    protected var _playerId :int;

    protected var _newX :int;
    protected var _newY :int;
    protected var _lastX :int;
    protected var _lastY :int;

    protected var _throttle :Throttle = new Throttle(10, 1.1 * 1000); // 10 ops/sec
}

}
