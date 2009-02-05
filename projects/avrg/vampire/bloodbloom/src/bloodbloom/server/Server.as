package bloodbloom.server {

import bloodbloom.*;

import com.whirled.ServerObject;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.game.GameControl;
import com.whirled.game.NetSubControl;
import com.whirled.game.StateChangedEvent;
import com.whirled.net.MessageReceivedEvent;

import flash.events.TimerEvent;
import flash.utils.Timer;

public class Server extends ServerObject
{
    public function Server ()
    {
        ServerCtx.gameCtrl = new GameControl(this, false);
        _events.registerListener(ServerCtx.gameCtrl.net, MessageReceivedEvent.MESSAGE_RECEIVED,
            onMsgReceived);

        // set up our heartbeat timer.
        _events.registerListener(_heartbeatTimer, TimerEvent.TIMER,
            function (...ignored) :void {
                ServerCtx.gameCtrl.net.sendMessage(Constants.MSG_S_HEARTBEAT, null);
            });

        _events.registerListener(ServerCtx.gameCtrl.game, StateChangedEvent.GAME_STARTED,
            function (...ignored) :void {
                _playing = true;

                // init properties
                ServerCtx.gameCtrl.net.doBatch(function () :void {
                    ServerCtx.gameCtrl.net.set(
                        Constants.PROP_RAND_SEED,
                        uint(Math.random() * uint.MAX_VALUE));
                    ServerCtx.gameCtrl.net.set(Constants.PROP_INITED, true);
                });

                // start the heartbeat ticker
                _heartbeatTimer.start();
            });

        _events.registerListener(ServerCtx.gameCtrl.game, StateChangedEvent.GAME_ENDED,
            function (...ignored) :void {
                _playing = false;
                _heartbeatTimer.stop();
                ServerCtx.gameCtrl.net.set(Constants.PROP_INITED, false);
            });
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {

    }

    protected var _playing :Boolean;
    protected var _heartbeatTimer :Timer = new Timer(Constants.HEARTBEAT_TIME * 1000);
    protected var _events :EventHandlerManager = new EventHandlerManager();
}

}
