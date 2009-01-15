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
        _dataBindings.bindMessage(Constants.MSG_C_AVATARCHANGED, handleAvatarChanged);
    }

    protected function handleDone (spectacle :Spectacle) :void
    {
        if (!_chosenAvatar || _waitingForAllSameAvatar) {
            log.warning("Received bad DONE CREATING message", "_chosenAvatar", _chosenAvatar,
                "_waitingForAllSameAvatar", _waitingForAllSameAvatar);
            return;
        }

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

        _ctx.outMsg.sendMessage(Constants.MSG_S_STARTCREATING, _chosenAvatarId);
    }

    protected function handleAvatarChanged () :void
    {
        // called when anyone's avatar changes
        checkAvatars();
    }

    protected function checkAvatars () :void
    {
        if (_chosenAvatar) {
            _waitingForAllSameAvatar = !_ctx.players.allWearingAvatar(_chosenAvatarId);
        }
    }

    protected var _spectacle :Spectacle = new Spectacle();
    protected var _ctx :ServerGameContext;
    protected var _chosenAvatar :Boolean;
    protected var _chosenAvatarId :int;
    protected var _waitingForAllSameAvatar :Boolean;

    protected var _lastSnapshotTime :Number = 0;

    protected static var log :Log = Log.getLog(ServerCreatorMode);
}

}
