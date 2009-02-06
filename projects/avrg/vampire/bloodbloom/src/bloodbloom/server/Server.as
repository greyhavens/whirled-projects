package bloodbloom.server {

import bloodbloom.*;
import bloodbloom.net.*;

import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.whirled.ServerObject;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.game.GameControl;
import com.whirled.game.StateChangedEvent;
import com.whirled.net.MessageReceivedEvent;

import flash.events.TimerEvent;
import flash.utils.Timer;

public class Server extends ServerObject
{
    public function Server ()
    {
        ServerCtx.gameCtrl = new GameControl(this, false);
        /*_events.registerListener(ServerCtx.gameCtrl.net, MessageReceivedEvent.MESSAGE_RECEIVED,
            onMsgReceived);

        _events.registerListener(_tickTimer, TimerEvent.TIMER, onTick);*/

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
                _cursorTargetMsgs.clear();
                //_tickTimer.start();
                ServerCtx.gameCtrl.services.startTicker(Constants.MSG_S_HEARTBEAT,
                    Constants.HEARTBEAT_TIME * 1000);
            });

        _events.registerListener(ServerCtx.gameCtrl.game, StateChangedEvent.GAME_ENDED,
            function (...ignored) :void {
                _playing = false;
                ServerCtx.gameCtrl.services.stopTicker(Constants.MSG_S_HEARTBEAT);
                //_tickTimer.stop();
                ServerCtx.gameCtrl.net.set(Constants.PROP_INITED, false);
            });
    }

    protected function onTick (...ignored) :void
    {
        // on every tick, send all clients a tick message as well as the
        // latest value of everyone's CursorTarget
        ServerCtx.gameCtrl.net.doBatch(function () :void {
            ServerCtx.gameCtrl.net.sendMessage(Constants.MSG_S_HEARTBEAT, null);
            _cursorTargetMsgs.forEach(
                function (key :Object, value :Object) :void {
                    ServerCtx.gameCtrl.net.sendMessage(CursorTargetMsg.NAME, value);
                });
        });

        _cursorTargetMsgs.clear();
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {
        // Aggregate all CursorTargetMsgs received between ticks, and send each player's
        // latest message on the next tick
        if (!e.isFromServer() && e.name == CursorTargetMsg.NAME) {
            _cursorTargetMsgs.put(e.senderId, e.value);
        }
    }

    protected var _playing :Boolean;
    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _tickTimer :Timer = new Timer(Constants.HEARTBEAT_TIME * 1000);
    protected var _cursorTargetMsgs :HashMap = new HashMap();

    protected static var log :Log = Log.getLog(Server);
}

}
