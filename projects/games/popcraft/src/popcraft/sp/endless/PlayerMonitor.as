package popcraft.sp.endless {

import com.threerings.util.ArrayUtil;
import com.threerings.util.HashMap;
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
        _roundScores = new HashMap();
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
        bytes.writeInt(EndlessGameContext.roundId);
        AppContext.gameCtrl.net.sendMessage(PLAYER_READY_MSG, bytes);
    }

    public function waitForAllPlayersReadyForCurRound (callback :Function) :void
    {
        _waitingForPlayersReadyForRoundId = EndlessGameContext.roundId;
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

    public function reportLocalPlayerRoundScore () :void
    {
        AppContext.gameCtrl.net.sendMessage(
            ROUND_SCORE_MSG,
            PlayerScore.create(
                GameContext.localPlayerIndex,
                EndlessGameContext.resourceScoreThisRound,
                EndlessGameContext.damageScoreThisRound,
                EndlessGameContext.roundId).toBytes());
    }

    public function waitForRoundScoresForCurRound (callback :Function) :void
    {
        _waitingForScoresForRoundId = EndlessGameContext.roundId;
        _gotRoundScoresCallback = callback;
        checkRoundScores();
    }

    protected function gotAllScoresForRound (roundId :int) :Boolean
    {
        var thisRoundScores :Array = _roundScores.get(roundId);
        if (thisRoundScores == null) {
            return false;
        }

        for (var playerSeat :int = 0; playerSeat < thisRoundScores.length; ++playerSeat) {
            if (SeatingManager.isPlayerPresent(playerSeat) && thisRoundScores[playerSeat] == null) {
                return false;
            }
        }

        return true;
    }

    protected function checkRoundScores () :void
    {
        if (_waitingForScoresForRoundId >= 0 && gotAllScoresForRound(_waitingForScoresForRoundId)) {
            _gotRoundScoresCallback();
            _gotRoundScoresCallback = null;
            _waitingForScoresForRoundId = -1;
        }
    }

    public function getScoresForRound (roundId :int) :Array
    {
        var thisRoundScores :Array = _roundScores.get(roundId);
        if (thisRoundScores == null) {
            thisRoundScores = ArrayUtil.create(SeatingManager.numExpectedPlayers, null);
            _roundScores.put(roundId, thisRoundScores);
        }

        return thisRoundScores;
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
        if (e.name == PLAYER_READY_MSG) {
            var roundId :int;
            var playerIndex :int;
            try {
                var bytes :ByteArray = ByteArray(e.value);
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

        } else if (e.name == FINAL_SCORE_MSG || e.name == ROUND_SCORE_MSG) {
            var ps :PlayerScore = new PlayerScore();
            try {
                ps.fromBytes(ByteArray(e.value));
            } catch (err :Error) {
                log.warning("Bad PlayerScore received", err);
                return;
            }

            if (ps.playerIndex < 0 || ps.playerIndex >= SeatingManager.numExpectedPlayers
                || ps.totalScore < 0) {
                log.warning("Bad PlayerScore received", "PlayerScore", ps);
            }

            if (e.name == FINAL_SCORE_MSG) {
                _finalScores[ps.playerIndex] = ps;
                checkFinalScores();

            } else if (e.name == ROUND_SCORE_MSG) {
                if (ps.roundId < 0) {
                    log.warning("Bad round_score message received", "PlayerScore", ps);
                }
                var thisRoundScores :Array = getScoresForRound(ps.roundId);
                thisRoundScores[ps.playerIndex] = ps;
                checkRoundScores();
            }
        }
    }

    protected var _playersReadyForRound :Array; // Array<Boolean>
    protected var _playersReadyCallback :Function;
    protected var _waitingForPlayersReadyForRoundId :int = -1;

    protected var _waitingForFinalScores :Boolean;
    protected var _finalScores :Array; // Array<PlayerScore>
    protected var _gotFinalScoresCallback :Function;

    protected var _waitingForScoresForRoundId :int = -1;
    protected var _roundScores :HashMap; // HashMap<roundId, Array<PlayerScore>>
    protected var _gotRoundScoresCallback :Function;

    protected static var log :Log = Log.getLog(PlayerMonitor);

    protected static const PLAYER_READY_MSG :String = "player_ready";
    protected static const FINAL_SCORE_MSG :String = "final_score";
    protected static const ROUND_SCORE_MSG :String = "round_score";
}

}
