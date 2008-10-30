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
        _finalScores = ArrayUtil.create(numPlayers, null);
    }

    public function shutdown () :void
    {
        AppContext.gameCtrl.net.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED,
            onMessageReceived);

        AppContext.gameCtrl.game.removeEventListener(OccupantChangedEvent.OCCUPANT_LEFT,
            onPlayerLeft);
    }

    public function reportLocalPlayerReadyForCurRound () :void
    {
        var bytes :ByteArray = new ByteArray();
        bytes.writeByte(GameContext.localPlayerIndex);
        bytes.writeInt(EndlessGameContext.mapIndex);
        AppContext.gameCtrl.net.sendMessage(PLAYER_READY_MSG, bytes);
    }

    public function waitForAllPlayersReadyForCurRound (callback :Function) :void
    {
        _waitingForPlayersReadyForRoundId = EndlessGameContext.mapIndex;
        _playersReadyCallback = callback;
        checkPlayersReadyForRound();
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

    protected function checkPlayersReadyForRound () :void
    {
        if (_waitingForPlayersReadyForRoundId >= 0 &&
            allPlayersReadyForRound(_waitingForPlayersReadyForRoundId)) {

            _playersReadyCallback();
            _playersReadyCallback = null;
            _waitingForPlayersReadyForRoundId = -1;
        }
    }

    public function reportLocalPlayerFinalScore () :void
    {
        AppContext.gameCtrl.net.sendMessage(
            FINAL_SCORE_MSG,
            PlayerScore.create(
                GameContext.localPlayerIndex,
                EndlessGameContext.resourceScore,
                EndlessGameContext.damageScore).toBytes());
    }

    public function waitForFinalScores (callback :Function) :void
    {
        _waitingForFinalScores = true;
        _gotFinalScoresCallback = callback;
        checkFinalScores();
    }

    protected function get gotAllFinalScores () :Boolean
    {
        for (var playerSeat :int = 0; playerSeat < _playersReadyForRound.length; ++playerSeat) {
            if (SeatingManager.isPlayerPresent(playerSeat) && _finalScores[playerSeat] == null) {
                return false;
            }
        }

        return true;
    }

    protected function checkFinalScores () :void
    {
        if (_waitingForFinalScores && this.gotAllFinalScores) {
            _gotFinalScoresCallback();
            _gotFinalScoresCallback = null;
            _waitingForFinalScores = false;
        }
    }

    public function get finalScores () :Array
    {
        return _finalScores;
    }

    protected function onPlayerLeft (e :OccupantChangedEvent) :void
    {
        if (_waitingForPlayersReadyForRoundId >= 0) {
            checkPlayersReadyForRound();
        }

        if (_waitingForFinalScores) {
            checkFinalScores();
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

            } catch (err :Error) {
                log.warning("Bad PlayerReady message received", err);
                return;
            }

            if (playerIndex < 0 || playerIndex >= _playersReadyForRound.length || _playersReadyForRound[playerIndex] >= roundId) {
                log.warning("Bad PlayerReady message received", "playerIndex", playerIndex,
                    "roundId", roundId);
                return;
            }

            _playersReadyForRound[playerIndex] = roundId;

            checkPlayersReadyForRound();

        } else if (e.name == FINAL_SCORE_MSG) {
            var ps :PlayerScore = new PlayerScore();
            try {
                ps.fromBytes(ByteArray(e.value));
            } catch (err :Error) {
                log.warning("Bad PlayerScore message received", err);
                return;
            }

            if (ps.playerIndex < 0 || ps.playerIndex >= _finalScores.length || ps.totalScore < 0) {
                log.warning("Bad PlayerScore message received", "PlayerScore", ps);
            }

            _finalScores[ps.playerIndex] = ps;

            checkFinalScores();
        }
    }

    protected var _playersReadyForRound :Array;
    protected var _playersReadyCallback :Function;
    protected var _waitingForPlayersReadyForRoundId :int = -1;

    protected var _waitingForFinalScores :Boolean;
    protected var _finalScores :Array; // Array<PlayerScore>
    protected var _gotFinalScoresCallback :Function;

    protected static var log :Log = Log.getLog(PlayerMonitor);

    protected static const PLAYER_READY_MSG :String = "player_ready";
    protected static const FINAL_SCORE_MSG :String = "final_score";
}

}
