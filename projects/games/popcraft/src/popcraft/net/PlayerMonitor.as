package popcraft.net {

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
        ClientContext.gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED,
            onMessageReceived);

        ClientContext.gameCtrl.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT,
            onPlayerLeft);

        _scores = new HashMap();
    }

    public function shutdown () :void
    {
        ClientContext.gameCtrl.net.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED,
            onMessageReceived);

        ClientContext.gameCtrl.game.removeEventListener(OccupantChangedEvent.OCCUPANT_LEFT,
            onPlayerLeft);
    }

    public function getScores (roundId :int) :Array
    {
        var thisRoundScores :Array = _scores.get(roundId);
        if (thisRoundScores == null) {
            thisRoundScores = ArrayUtil.create(ClientContext.seatingMgr.numExpectedPlayers, null);
            _scores.put(roundId, thisRoundScores);
        }

        return thisRoundScores;
    }

    public function reportScore (scoreMsg :PlayerScoreMsg) :void
    {
        ClientContext.gameCtrl.net.sendMessage(SCORE_MSG, scoreMsg.toBytes());
    }

    public function waitForScores (callback :Function, roundId :int) :void
    {
        _waitingForScoresForRoundId = roundId;
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
            if (ClientContext.seatingMgr.isPlayerPresent(playerSeat) && thisRoundScores[playerSeat] == null) {
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

    protected function onPlayerLeft (e :OccupantChangedEvent) :void
    {
        if (_gotScoresCallback != null) {
            checkScores();
        }
    }

    protected function onMessageReceived (e :MessageReceivedEvent) :void
    {
        if (e.name == SCORE_MSG) {
            var ps :PlayerScoreMsg = new PlayerScoreMsg();
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

            var thisRoundScores :Array = getScores(ps.roundId);
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
