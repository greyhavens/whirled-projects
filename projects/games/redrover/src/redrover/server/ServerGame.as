package redrover.server {

import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.TimerManager;

import redrover.data.LevelData;

public class ServerGame
{
    public function ServerGame (level :LevelData)
    {
        _level = level;
        _timerMgr.createTimer(_level.endValue * 1000, 1, onLevelTimeUp).start();
    }

    public function shutdown () :void
    {
        _events.freeAllHandlers();
        _events = null;

        _timerMgr.shutdown();
        _timerMgr = null;
    }
    
    protected function onLevelTimeUp (...ignored) :void
    {
        
    }

    protected var _level :LevelData;
    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _timerMgr :TimerManager = new TimerManager();
}

}
