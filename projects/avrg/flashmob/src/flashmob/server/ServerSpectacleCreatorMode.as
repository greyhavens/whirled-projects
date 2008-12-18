package flashmob.server {

import com.threerings.util.Log;
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.net.MessageReceivedEvent;

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
        if (e.name == Constants.MSG_SNAPSHOT) {
            handleSnapshot();
        } else if (e.name == Constants.MSG_DONECREATING) {
            handleDone(e.value as String);
        }
    }

    protected function handleSnapshot () :void
    {
        var now :Number = ServerContext.timeNow;
        var dt :Number = now - _lastSnapshotTime;
        if (_spectacle.numPatterns > 0 && dt < Constants.MIN_SNAPSHOT_TIME) {
            log.info("Discarding snapshot request (not enough time elapsed)");
            _ctx.outMsg.sendMessage(Constants.MSG_SNAPSHOTERR);
            return;
        } else if (_ctx.waitingForPlayers) {
            log.info("Discarding snapshot request (waiting for players)");
            _ctx.outMsg.sendMessage(Constants.MSG_SNAPSHOTERR);
            return;
        }

        // capture the locations of all the players
        var pattern :Pattern = new Pattern();
        pattern.timeLimit = (_spectacle.numPatterns == 0 ? 0 : Math.ceil(dt));
        for each (var playerId :int in _ctx.players) {
            var info :AVRGameAvatar = ServerContext.getAvatarInfo(playerId);
            pattern.locs.push(new PatternLoc(info.x, info.y, info.z));
        }

        _lastSnapshotTime = now;
        _ctx.outMsg.sendMessage(Constants.MSG_SNAPSHOTACK);
        log.info("Snapshot captured");
    }

    protected function handleDone (spectacleName :String) :void
    {
        _spectacle.name = spectacleName;
        _ctx.spectacle = _spectacle;
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
