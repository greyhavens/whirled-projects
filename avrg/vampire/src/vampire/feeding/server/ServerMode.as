package vampire.feeding.server {

import com.threerings.util.Log;
import com.threerings.util.EventHandlerManager;
import com.whirled.contrib.TimerManager;
import com.whirled.contrib.messagemgr.Message;

import vampire.feeding.*;
import vampire.feeding.net.*;

public class ServerMode
{
    public function ServerMode (ctx :ServerCtx)
    {
        _ctx = ctx;
    }

    public function run () :void
    {
        _ctx.modeName = this.modeName;
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

    public function get modeName () :String
    {
        throw new Error("not implemented");
    }

    protected var _ctx :ServerCtx;
    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _timerMgr :TimerManager = new TimerManager();

    protected var log :Log = Log.getLog(this);
}

}
