package vampire.feeding.server {

import com.threerings.util.Log;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.TimerManager;
import com.whirled.contrib.simplegame.net.Message;

public class ServerMode
{
    public function ServerMode (ctx :ServerCtx)
    {
        _ctx = ctx;
    }

    public function run () :void
    {
    }

    public function shutdown () :void
    {
        _events.freeAllHandlers();
        _timerMgr.shutdown();
    }

    public function playerLeft (playerId :int) :void
    {
    }

    public function onMsgReceived (senderId :int, msg :Message) :Boolean
    {
        return false;
    }

    protected var _ctx :ServerCtx;
    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _timerMgr :TimerManager = new TimerManager();

    protected var log :Log = Log.getLog(this);
    protected const foo :Foo = new Foo();
}

}

class Foo
{
}
