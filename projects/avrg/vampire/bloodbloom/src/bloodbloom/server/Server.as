package bloodbloom.server {

import bloodbloom.*;

import com.whirled.ServerObject;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.game.GameControl;
import com.whirled.game.StateChangedEvent;
import com.whirled.net.MessageReceivedEvent;

public class Server extends ServerObject
{
    public function Server ()
    {
        ServerCtx.gameCtrl = new GameControl(this, false);
        _events.registerListener(ServerCtx.gameCtrl.net, MessageReceivedEvent.MESSAGE_RECEIVED,
            onMsgReceived);

        _events.registerListener(ServerCtx.gameCtrl.game, StateChangedEvent.GAME_STARTED,
            function (...ignored) :void {
                _playing = true;
                ServerCtx.gameCtrl.services.startTicker(
                    Constants.MSG_S_HEARTBEAT,
                    Constants.HEARTBEAT_TIME * 1000);
            });

        _events.registerListener(ServerCtx.gameCtrl.game, StateChangedEvent.GAME_ENDED,
            function (...ignored) :void {
                _playing = false;
                ServerCtx.gameCtrl.services.stopTicker(Constants.MSG_S_HEARTBEAT);
            });
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {

    }

    protected var _playing :Boolean;
    protected var _events :EventHandlerManager = new EventHandlerManager();
}

}
