package flashmob.server {

import com.threerings.util.Log;
import com.whirled.net.MessageReceivedEvent;

import flash.utils.ByteArray;

import flashmob.*;
import flashmob.data.*;

public class ServerSpectacleCreatorMode extends ServerMode
{
    public function ServerSpectacleCreatorMode (ctx :ServerGameContext)
    {
        _ctx = ctx;
    }

    override public function onMsgReceived (e :MessageReceivedEvent) :void
    {
        if (e.name == Constants.MSG_DONECREATING) {
            handleDone(new Spectacle().fromBytes(e.value as ByteArray));
        }
    }

    protected function handleDone (spectacle :Spectacle) :void
    {
        _ctx.spectacle = spectacle;
        _ctx.game.gameState = Constants.STATE_SPECTACLE_PLAY;
        log.info("Snapshot completed");
    }

    protected static function get log () :Log
    {
        return FlashMobServer.log;
    }

    protected var _spectacle :Spectacle = new Spectacle();
    protected var _ctx :ServerGameContext;

    protected var _lastSnapshotTime :Number = 0;
}

}
