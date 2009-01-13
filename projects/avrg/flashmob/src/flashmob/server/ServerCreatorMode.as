package flashmob.server {

import com.threerings.util.Log;

import flashmob.*;
import flashmob.data.*;

public class ServerCreatorMode extends ServerMode
{
    public function ServerCreatorMode (ctx :ServerGameContext)
    {
        _ctx = ctx;

        _dataBindings.bindMessage(Constants.MSG_C_DONECREATING, handleDone, Spectacle.fromBytes);
        _dataBindings.bindMessage(Constants.MSG_C_CHOSEAVATAR, handleChoseAvatar);
    }

    protected function handleDone (spectacle :Spectacle) :void
    {
        _ctx.spectacle = spectacle;
        _ctx.game.gameState = Constants.STATE_PLAYER;
        log.info("Snapshot completed");
    }

    protected function handleChoseAvatar (avatarId :int) :void
    {
        if (_chosenAvatar) {
            log.warning("Received multiple CHOSE AVATAR messages");
            return;
        }

        _chosenAvatar = true;
        _chosenAvatarId = avatarId;

        checkAvatars();
    }

    protected function checkAvatars () :void
    {

    }

    protected static function get log () :Log
    {
        return FlashMobServer.log;
    }

    protected var _spectacle :Spectacle = new Spectacle();
    protected var _ctx :ServerGameContext;
    protected var _chosenAvatar :Boolean;
    protected var _chosenAvatarId :int;

    protected var _lastSnapshotTime :Number = 0;
}

}
