package bloodbloom.server {

import com.whirled.ServerObject;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.game.GameControl;
import com.whirled.game.StateChangedEvent;

import bloodbloom.*;

public class Server extends ServerObject
{
    public function Server ()
    {
        ServerCtx.gameCtrl = new GameControl(this, false);
        _events.registerListener(ServerCtx.gameCtrl.game, StateChangedEvent.GAME_STARTED,
            function (...ignored) :void {
                _playing = true;
                ServerCtx.gameCtrl.services.startTicker(NetCodes.MSG_S_HEARTBEAT,
            });
            
        _events.registerListener(ServerCtx.gameCtrl.game, StateChangedEvent.GAME_ENDED,
            function (...ignored) :void {
                _playing = false;
            });
    }
    
    protected var _playing :Boolean;
    protected var _events :EventHandlerManager = new EventHandlerManager();
}

}
