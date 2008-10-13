package popcraft.sp.endless {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.net.MessageReceivedEvent;

import flash.utils.ByteArray;

import popcraft.*;

public class PlayerReadyMonitor
{
    public function PlayerReadyMonitor (numPlayers :int)
    {
        AppContext.gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED,
            onMessageReceived);

        _playersReadyForRound = ArrayUtil.create(numPlayers, -1);
    }

    public function shutdown () :void
    {
        AppContext.gameCtrl.net.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED,
            onMessageReceived);
    }

    public function setLocalPlayerReadyForCurRound () :void
    {
        var bytes :ByteArray = new ByteArray();
        bytes.writeByte(GameContext.localPlayerIndex);
        bytes.writeInt(EndlessGameContext.mapDataIndex);
        AppContext.gameCtrl.net.sendMessage(MESSAGE_NAME, bytes);
    }

    public function waitForAllPlayersReadyForCurRound (callback :Function) :void
    {
        var roundId :int = EndlessGameContext.mapDataIndex;

        if (this.allPlayersReadyForRound(roundId)) {
            callback();
        } else {
            _waitForAllPlayersReadyForRoundId = roundId;
            _playersReadyCallback = callback;
        }
    }

    protected function allPlayersReadyForRound (roundId :int) :Boolean
    {
        for each (var readyForRoundId :int in _playersReadyForRound) {
            if (roundId != readyForRoundId) {
                return false;
            }
        }

        return true;
    }

    protected function onMessageReceived (e :MessageReceivedEvent) :void
    {
        if (e.name != MESSAGE_NAME) {
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

        if (_waitForAllPlayersReadyForRoundId >= 0 &&
            this.allPlayersReadyForRound(_waitForAllPlayersReadyForRoundId)) {

            _playersReadyCallback();
            _playersReadyCallback = null;
            _waitForAllPlayersReadyForRoundId = -1;
        }
    }


    protected var _playersReadyForRound :Array;
    protected var _playersReadyCallback :Function;
    protected var _waitForAllPlayersReadyForRoundId :int = -1;

    protected static var log :Log = Log.getLog(PlayerReadyMonitor);

    protected static const MESSAGE_NAME :String = "pr";
}

}
