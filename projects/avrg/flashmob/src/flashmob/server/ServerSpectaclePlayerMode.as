package flashmob.server {

import com.threerings.util.Log;
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.net.MessageReceivedEvent;

import flashmob.*;
import flashmob.data.*;

public class ServerSpectaclePlayerMode extends ServerMode
{
    public function ServerSpectaclePlayerMode (ctx :ServerGameContext)
    {
        _ctx = ctx;
    }

    override public function onMsgReceived (e :MessageReceivedEvent) :void
    {
        if (e.name == Constants.MSG_STARTPLAYING) {
            if (_started) {
                log.warning("Received multiple START PLAYING messages");
                return;
            }

            // tell the clients to start playing
            _started = true;
            _ctx.outMsg.sendMessage(Constants.MSG_PLAYNEXTPATTERN);
        }
    }

    protected static function get log () :Log
    {
        return FlashMobServer.log;
    }

    protected var _ctx :ServerGameContext;
    protected var _started :Boolean;
}

}
