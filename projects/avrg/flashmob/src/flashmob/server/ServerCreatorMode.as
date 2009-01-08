package flashmob.server {

import com.threerings.util.Log;
import com.whirled.net.MessageReceivedEvent;

import flash.utils.ByteArray;

import flashmob.*;
import flashmob.data.*;

public class ServerCreatorMode extends ServerMode
{
    public function ServerCreatorMode (ctx :ServerGameContext)
    {
        _ctx = ctx;

        _dataBindings.bindMessage(Constants.MSG_C_DONECREATING, handleDone, Spectacle.fromBytes);
    }

    protected function handleDone (spectacle :Spectacle) :void
    {
        _ctx.spectacle = spectacle;
        _ctx.game.gameState = Constants.STATE_PLAYER;
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
