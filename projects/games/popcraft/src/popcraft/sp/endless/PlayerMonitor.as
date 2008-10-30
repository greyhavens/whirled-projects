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
        _playerScores = ArrayUtil.create(numPlayers, -1);
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

    public function reportLocalPlayerScore () :void
    {
        var bytes :ByteArray = new ByteArray();
        bytes.writeByte(GameContext.localPlayerIndex);
        bytes.writeInt(EndlessGameContext.totalScore);
        AppContext.gameCtrl.net.sendMessage(PLAYER_SCORE_MSG, bytes);
    }

    public function waitForAllPlayersReadyForCurRound (callback :Function) :void
    {
        _waitingForPlayersReadyForRoundId = EndlessGameContext.mapIndex;
        _playersReadyCallback = callback;
        checkPlayersReadyForRound();
    }

    public function waitForPlayerScores (callback :Function) :void
    {
        _waitingForPlayerScores = true;
        _gotPlayerScoresCallback = callback;
        checkPlayerScores();
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

    protected function get gotAllPlayerScores () :Boolean
    {
        for (var playerSeat :int = 0; playerSeat < _playersReadyForRound.length; ++playerSeat) {
            if (SeatingManager.isPlayerPresent(playerSeat) && _playerScores[playerSeat] < 0) {
                return false;
            }
        }

        return true;
    }

    protected function onPlayerLeft (e :OccupantChangedEvent) :void
    {
        if (_waitingForPlayersReadyForRoundId >= 0) {
            checkPlayersReadyForRound();
        }

        if (_waitingForPlayerScores) {
            checkPlayerScores();
        }
    }

    protected function onMessageReceived (e :MessageReceivedEvent) :void
    {
        var playerIndex :int;
        var bytes :ByteArray;

        if (e.name == PLAYER_READY_MSG) {
            var roundId :int;
            try {
                bytes = ByteArray(e.value);
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

        } else if (e.name == PLAYER_SCORE_MSG) {
            var score :int;
            try {
                bytes = ByteArray(e.value);
                playerIndex = bytes.readByte();
                score = bytes.readInt();
            } catch (e :Error) {
                log.warning("Bad PlayerScore message received", e);
                return;
            }

            if (playerIndex < 0 || playerIndex >= _playerScores.length || score < 0) {
                log.warning("Bad PlayerScore message received", "playerIndex", playerIndex,
                    "score", score);
            }

            _playerScores[playerIndex] = score;

            checkPlayerScores();
        }
    }

    protected function checkPlayersReadyForRound () :void
    {
        if (_waitingForPlayersReadyForRoundId >= 0 &&
            allPlayersReadyForRound(_waitingForPlayersReadyForRoundId)) {

            _playersReadyCallback();
            _playersReadyCallback = null;
            _waitingForPlayersReadyForRoundId = -1;
        }
    }

    protected function checkPlayerScores () :void
    {
        if (_waitingForPlayerScores && this.gotAllPlayerScores) {
            _gotPlayerScoresCallback();
            _gotPlayerScoresCallback = null;
            _waitingForPlayerScores = false;
        }
    }

    public function get playerScores () :Array
    {
        return _playerScores;
    }

    protected var _playersReadyForRound :Array;
    protected var _playersReadyCallback :Function;
    protected var _waitingForPlayersReadyForRoundId :int = -1;

    protected var _waitingForPlayerScores :Boolean;
    protected var _playerScores :Array;
    protected var _gotPlayerScoresCallback :Function;

    protected static var log :Log = Log.getLog(PlayerMonitor);

    protected static const PLAYER_READY_MSG :String = "player_ready";
    protected static const PLAYER_SCORE_MSG :String = "player_score";
}

}
