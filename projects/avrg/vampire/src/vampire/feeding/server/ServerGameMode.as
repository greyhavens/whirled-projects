package vampire.feeding.server {

import com.threerings.util.ArrayUtil;
import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.net.Message;
import com.whirled.contrib.simplegame.util.Rand;

import vampire.data.VConstants;
import vampire.feeding.*;
import vampire.feeding.net.*;

public class ServerGameMode extends ServerMode
{
    public function ServerGameMode (ctx :ServerCtx)
    {
        super(ctx);
    }

    override public function run () :void
    {
        // Only the players who are in the game when this round starts
        // will participate in the round. Anyone who joins during the round will
        // have to wait for the next one to start
        _playersInGame = _ctx.playerIds.slice();
        _ctx.props.set(Props.GAME_PLAYERS, FeedingUtil.arrayToDict(_playersInGame), true);

        _state = STATE_PLAYING;
        _timerMgr.createTimer(Constants.GAME_TIME * 1000, 1, onTimeOver).start();

        super.run();
    }

    override public function playerLeft (playerId :int) :void
    {
        super.playerLeft(playerId);

        ArrayUtil.removeFirst(_playersInGame, playerId);
        _ctx.props.setIn(Props.GAME_PLAYERS, playerId, null, true);

        if (_playersInGame.length == 0) {
            // End the round immediately, without reporting anything (there
            // may be other players waiting to play the game)
            _ctx.lastRoundScore = 0;
            _ctx.server.setMode(Constants.MODE_LOBBY);

        } else if (_state == STATE_WAITING_FOR_SCORES) {
            ArrayUtil.removeFirst(_playersNeedingScoreUpdate, playerId);
            endRoundIfReady();

        } else if (!_noMoreFeeding && !_ctx.canContinueFeeding()) {
            // If the prey has left, or all the predators have left, no more feeding
            // can take place.
            _noMoreFeeding = true;
            _ctx.sendMessage(NoMoreFeedingMsg.create());
        }
    }

    override public function onMsgReceived (senderId :int, msg :Message) :Boolean
    {
        if (msg is RoundScoreMsg) {
            if (_state != STATE_WAITING_FOR_SCORES) {
                _ctx.logBadMessage(log, senderId, msg.name, "not waiting for scores");

            } else if (!ArrayUtil.removeFirst(_playersNeedingScoreUpdate, senderId)) {
                _ctx.logBadMessage(log, senderId, msg.name,
                                   "unrecognized player, or player already reported score");

            } else {
                _finalScores.put(senderId, (msg as RoundScoreMsg).score);
                endRoundIfReady();
            }

            return true;
        }

        if (msg is CreateMultiplierMsg) {
            if (_state == STATE_PLAYING) {
                var targetPlayerId :int = getAnotherPlayer(senderId);
                if (targetPlayerId != Constants.NULL_PLAYER) {
                    _ctx.sendMessage(msg, targetPlayerId);
                }
            }

            return true;
        }

        return super.onMsgReceived(senderId, msg);
    }

    override public function get modeName () :String
    {
        return Constants.MODE_PLAYING;
    }

    protected function onTimeOver (...ignored) :void
    {
        _state = STATE_WAITING_FOR_SCORES;
        _playersNeedingScoreUpdate = _playersInGame.slice();
        _finalScores = new HashMap();
        _ctx.sendMessage(GetRoundScores.create());
    }

    protected function endRoundIfReady () :void
    {
        if (_playersNeedingScoreUpdate.length == 0) {
            var totalScore :int;
            _finalScores.forEach(
                function (playerId :int, score :int) :void {
                    totalScore += score;
                });
            _ctx.lastRoundScore = totalScore;
            // Send the final scores to the clients.
            _ctx.feedingHost.onRoundComplete();
            _ctx.sendMessage(RoundOverMsg.create(_finalScores));

            // If there are two people playing the game, a predator and a prey, and they
            // aren't already blood bonded with each other, increment the blood bond progress
            var predatorId :int = _ctx.getPredatorIds()[0];
            if (_ctx.getPredatorIds().length == 1 &&
                _ctx.preyId != Constants.NULL_PLAYER &&
                _ctx.feedingHost.getBloodBondPartner(predatorId) != _ctx.preyId &&
                _ctx.bloodBondProgress < VConstants.FEEDING_ROUNDS_TO_FORM_BLOODBOND) {

                _ctx.bloodBondProgress++;
                log.info("Incrementing blood bond progress", "progress", _ctx.bloodBondProgress);
                if (_ctx.bloodBondProgress == VConstants.FEEDING_ROUNDS_TO_FORM_BLOODBOND) {
                    _ctx.feedingHost.formBloodBond(_ctx.getPredatorIds()[0], _ctx.preyId);
                }
            }

            _ctx.server.setMode(Constants.MODE_LOBBY);

        } else {
            log.info("Waiting for " + _playersNeedingScoreUpdate.length +
                     " more player scores to end the round.");
        }
    }

    protected function getAnotherPlayer (playerId :int) :int
    {
        // returns a random player id
        var players :Array = _playersInGame.slice();
        if (players.length <= 1) {
            return Constants.NULL_PLAYER;
        }

        ArrayUtil.removeFirst(players, playerId);
        return Rand.nextElement(players, Rand.STREAM_GAME);
    }

    protected var _state :int;
    protected var _playersInGame :Array;
    protected var _playersNeedingScoreUpdate :Array;
    protected var _finalScores :HashMap; // Map<playerId, score>
    protected var _noMoreFeeding :Boolean;

    protected static const log :Log = Log.getLog(ServerGameMode);

    protected static const STATE_PLAYING :int = 0;
    protected static const STATE_WAITING_FOR_SCORES :int = 1;
}

}
