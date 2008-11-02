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

        _scores = new HashMap();
    }

    public function shutdown () :void
    {
        AppContext.gameCtrl.net.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED,
            onMessageReceived);

        AppContext.gameCtrl.game.removeEventListener(OccupantChangedEvent.OCCUPANT_LEFT,
            onPlayerLeft);
    }

    public function reportLocalPlayerScore () :void
    {
        AppContext.gameCtrl.net.sendMessage(
            SCORE_MSG,
            PlayerScore.create(
                GameContext.localPlayerIndex,
                EndlessGameContext.resourceScore,
                EndlessGameContext.damageScore,
                EndlessGameContext.resourceScoreThisRound,
                EndlessGameContext.damageScoreThisRound,
                EndlessGameContext.roundId).toBytes());
    }

    public function waitForScoresForCurRound (callback :Function) :void
    {
        _waitingForScoresForRoundId = EndlessGameContext.roundId;
        _gotScoresCallback = callback;
        checkScores();
    }

    protected function gotAllScoresForRound (roundId :int) :Boolean
    {
        var thisRoundScores :Array = _scores.get(roundId);
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

    protected function checkScores () :void
    {
        if (_waitingForScoresForRoundId >= 0 && gotAllScoresForRound(_waitingForScoresForRoundId)) {
            _gotScoresCallback();
            _gotScoresCallback = null;
            _waitingForScoresForRoundId = -1;
        }
    }

    public function getScoresForRound (roundId :int) :Array
    {
        var thisRoundScores :Array = _scores.get(roundId);
        if (thisRoundScores == null) {
            thisRoundScores = ArrayUtil.create(SeatingManager.numExpectedPlayers, null);
            _scores.put(roundId, thisRoundScores);
        }

        return thisRoundScores;
    }

    public function get curRoundScores () :Array
    {
        return getScoresForRound(EndlessGameContext.roundId);
    }

    protected function onPlayerLeft (e :OccupantChangedEvent) :void
    {
        if (_gotScoresCallback != null) {
            checkScores();
        }
    }

    protected function onMessageReceived (e :MessageReceivedEvent) :void
    {
        if (e.name == SCORE_MSG) {
            var ps :PlayerScore = new PlayerScore();
            try {
                ps.fromBytes(ByteArray(e.value));
            } catch (err :Error) {
                log.warning("Bad PlayerScore received", err);
                return;
            }

            if (!ps.isValid) {
                log.warning("Bad PlayerScore received", "PlayerScore", ps);
                return;
            }

            var thisRoundScores :Array = getScoresForRound(ps.roundId);
            thisRoundScores[ps.playerIndex] = ps;
            checkScores();
        }
    }

    protected var _scores :HashMap; // HashMap<roundId, Array<PlayerScore>>
    protected var _gotScoresCallback :Function;
    protected var _waitingForScoresForRoundId :int = -1;

    protected static var log :Log = Log.getLog(PlayerMonitor);

    protected static const SCORE_MSG :String = "m_score";
}

}
