package redrover.server {

import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.TimerManager;

public class ServerGame
{
    public function ServerGame()
    {
    }

    public function shutdown () :void
    {
        _events.freeAllHandlers();
        _events = null;

        _timerMgr.shutdown();
        _timerMgr = null;
    }

    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _timerMgr :TimerManager = new TimerManager();
}

}
