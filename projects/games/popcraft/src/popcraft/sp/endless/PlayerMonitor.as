package popcraft.sp.endless {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.game.OccupantChangedEvent;
import com.whirled.net.MessageReceivedEvent;

import flash.utils.ByteArray;

import popcraft.*;

public class PlayerMonitor
{
    public function PlayerMonitor (numPlayers :int)
    {
        AppContext.gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED,
            onMessageReceived);

        AppContext.gameCtrl.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT,
            onPlayerLeft);

        _playersReadyForRound = ArrayUtil.create(numPlayers, -1);
    }

    public function shutdown () :void
    {
        AppContext.gameCtrl.net.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED,
            onMessageReceived);

        AppContext.gameCtrl.game.removeEventListener(OccupantChangedEvent.OCCUPANT_LEFT,
            onPlayerLeft);
    }

    public function setLocalPlayerReadyForCurRound () :void
    {
        var bytes :ByteArray = new ByteArray();
        bytes.writeByte(GameContext.localPlayerIndex);
        bytes.writeInt(EndlessGameContext.mapIndex);
        AppContext.gameCtrl.net.sendMessage(PLAYER_READY_MSG, bytes);
    }

    public function waitForAllPlayersReadyForCurRound (callback :Function) :void
    {
        var roundId :int = EndlessGameContext.mapIndex;

        if (this.allPlayersReadyForRound(roundId)) {
            callback();
        } else {
            _waitForAllPlayersReadyForRoundId = roundId;
            _playersReadyCallback = callback;
        }
    }

    protected function allPlayersReadyForRound (roundId :int) :Boolean
    {
        for (var playerSeat :int = 0; playerSeat < _playersReadyForRound.length; ++playerSeat) {
            if (SeatingManager.isPlayerPresent(playerSeat) &&
                _playersReadyForRound[playerSeat] != roundId) {
                return false;
            }
        }

        return true;
    }

    protected function onMessageReceived (e :MessageReceivedEvent) :void
    {
        if (e.name != PLAYER_READY_MSG) {
            return;
        }

        var playerIndex :int;
        var roundId :int;
        try {
            var bytes :ByteArray = ByteArray(e.value);
            playerIndex = bytes.readByte();
            roundId = bytes.readInt();

        } catch (e :Error) {
            log.warning("Bad PlayerReady message received", e);
            return;
        }

        if (playerIndex < 0 || playerIndex >= _playersReadyForRound.length || _playersReadyForRound[playerIndex] >= roundId) {
            log.warning("Bad PlayerReady message received", "playerIndex", playerIndex,
                "roundId", roundId);
            return;
        }

        _playersReadyForRound[playerIndex] = roundId;

        checkPlayersReadyForRound();
    }

    protected function onPlayerLeft (e :OccupantChangedEvent) :void
    {
        if (_waitForAllPlayersReadyForRoundId >= 0) {
            checkPlayersReadyForRound();
        }
    }

    protected function checkPlayersReadyForRound () :void
    {
        if (_waitForAllPlayersReadyForRoundId >= 0 &&
            allPlayersReadyForRound(_waitForAllPlayersReadyForRoundId)) {

            _playersReadyCallback();
            _playersReadyCallback = null;
            _waitForAllPlayersReadyForRoundId = -1;
        }
    }


    protected var _playersReadyForRound :Array;
    protected var _playersReadyCallback :Function;
    protected var _waitForAllPlayersReadyForRoundId :int = -1;

    protected static var log :Log = Log.getLog(PlayerMonitor);

    protected static const PLAYER_READY_MSG :String = "player_ready";
}

}
