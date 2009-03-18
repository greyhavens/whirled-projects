package vampire.feeding.server {

import com.threerings.util.ArrayUtil;
import com.whirled.contrib.ManagedTimer;
import com.whirled.contrib.simplegame.net.Message;

import vampire.feeding.*;
import vampire.feeding.net.*;

public class ServerWaitForCheckinMode extends ServerMode
{
    public function ServerWaitForCheckinMode (ctx :ServerCtx)
    {
        super(ctx);
    }

    override public function run () :void
    {
        super.run();
        _playersNeedingCheckin = _ctx.playerIds.slice();
    }

    override public function playerLeft (playerId :int) :void
    {
        ArrayUtil.removeFirst(_playersNeedingCheckin, playerId);
    }

    override public function onMsgReceived (senderId :int, msg :Message) :Boolean
    {
        if (msg is ClientReadyMsg) {
            if (!ArrayUtil.removeFirst(_playersNeedingCheckin, senderId)) {
                _ctx.logBadMessage(
                    senderId,
                    msg.name,
                    "unrecognized player, or player already checked in");

            } else {
                // When at least one player has checked in, start a timer that will force
                // the game to start after a maximum amount of time has elapsed, even if
                // the rest of the players haven't joined yet.
                if (_waitForPlayersTimer == null) {
                    _waitForPlayersTimer = _timerMgr.createTimer(
                        Constants.WAIT_FOR_PLAYERS_TIMEOUT * 1000, 1, startRoundNow);
                    _waitForPlayersTimer.start();
                    _ctx.sendMessage(RoundStartingSoonMsg.create());
                }

                startRoundIfReady();
            }

            return true;
        }

        return false;
    }

    protected function startRoundIfReady () :void
    {
        if (_playersNeedingCheckin.length == 0) {
            startRoundNow();
        } else {
            log.info("Waiting for " + _playersNeedingCheckin.length + " more players to start.");
        }
    }

    protected function startRoundNow (...ignored) :void
    {
        if (_waitForPlayersTimer != null) {
            _waitForPlayersTimer.cancel();
            _waitForPlayersTimer = null;
        }

        // any players who haven't checked in when the game starts are booted from the game
        for each (var playerId :int in _playersNeedingCheckin) {
            log.info("Booting unresponsive player", "playerId", playerId);
            _ctx.server.bootPlayer(playerId);
        }

        _ctx.server.setMode(Constants.MODE_PLAYING);
    }

    protected var _playersNeedingCheckin :Array;
    protected var _waitForPlayersTimer :ManagedTimer;
}

}
