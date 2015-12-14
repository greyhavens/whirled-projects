package bingo.server {

import bingo.*;

import com.threerings.util.Log;
import com.whirled.contrib.TimerManager;
import com.whirled.contrib.avrg.oneroom.OneRoomGameRoom;

public class GameController extends OneRoomGameRoom
{
    override protected function finishInit () :void
    {
        super.finishInit();
        _bingoItems = new BingoItemManager(ServerBingoItems.ITEMS);
        _sharedState = new SharedState();
        _scores = new ScoreTable(Constants.SCORETABLE_MAX_ENTRIES);
        startNextRound();
    }

    override public function shutdown () :void
    {
        shutdownTimers();
        setNewGameState(null);
        setNewScores(null);
        super.shutdown();
    }

    protected function initTimers () :void
    {
        shutdownTimers();
        _timers = new TimerManager();
    }

    protected function shutdownTimers () :void
    {
        if (_timers != null) {
            _timers.shutdown();
            _timers = null;
        }
    }

    override protected function messageReceived (senderId :int, name :String, value :Object) :void
    {
        super.messageReceived(senderId, name, value);

        if (name == Constants.MSG_CALLBINGO) {
            if (value is int) {
                //log.info("bingo called", "senderId", senderId);
                bingoCalled(senderId, int(value));

            } else {
                badMessage();
            }

        } else if (name == Constants.MSG_WONTROPHIES) {
            if (value is Array) {
                log.info("awarding trophies", "senderId", senderId, "trophies", value);
                for each (var trophy :String in value as Array) {
                    if (trophy != null) {
                        _gameCtrl.getPlayer(senderId).awardTrophy(trophy);
                    } else {
                        badMessage();
                        break;
                    }
                }

            } else {
                badMessage();
            }

        } else if (name == Constants.MSG_CONSOLATIONPRIZE) {
            if (value is int) {
                awardConsolationPrize(senderId, int(value));
            } else {
                badMessage();
            }
        }

        function badMessage () :void {
            log.warning("bad message", "senderId", senderId, "name", name, "value", value);
        }
    }

    protected function bingoCalled (playerId :int, roundId :int) :void
    {
        // validate
        if (_sharedState.gameState != SharedState.STATE_PLAYING ||
             roundId != _sharedState.roundId) {
            if (roundId > _sharedState.roundId) {
                log.warning("discarding CallBingoMessage from the future", "playerId", playerId);
            } else if (roundId < _sharedState.roundId - 1) {
                log.warning("discarding CallBingoMessage from the distant past", "playerId",
                    playerId);
            }
            return;
        }

        _sharedState.gameState = SharedState.STATE_WEHAVEAWINNER;
        _sharedState.roundWinnerId = playerId;
        setNewGameState(_sharedState);

        _scores.incrementScore(playerId);
        setNewScores(_scores);

        // award coins if there's more than one player in the game
        if (_roomCtrl.getPlayerIds().length > 1) {
            _gameCtrl.getPlayer(playerId).completeTask("bingo", Constants.BINGO_PAYOUT);
        }

        // start the next round in a few seconds
        initTimers();
        _timers.runOnce(Constants.NEW_ROUND_DELAY_S * 1000, startNextRound);
    }

    protected function awardConsolationPrize (playerId :int, numFilledSquares :int) :void
    {
        if (_sharedState.gameState != SharedState.STATE_WEHAVEAWINNER) {
            log.warning("discarding ConsolationPrizeMessage received during round",
                "playerId", playerId);
            return;

        } else if (_roomCtrl.getPlayerIds().length < 2) {
            log.warning("discarding ConsolationPrizeMessage received with < 2 players", "playerId",
                playerId);
            return;

        } else if (numFilledSquares <= 0) {
            log.warning("discarding ConsolationPrizeMessage received with numFilledSquares <= 0",
                "playerId", playerId);
            return;
        }

        // award at most 20% of the bingo payout
        var payout :Number =
            Math.min(1, numFilledSquares / Constants.CONSOLATION_PAYOUT_MAX_SQUARES) *
            Constants.CONSOLATION_PAYOUT_MAX;

        _gameCtrl.getPlayer(playerId).completeTask("consolationPrize", payout);

        //log.info("Consolation prize awarded", "playerId", playerId, "numFilledSquares",
        //    numFilledSquares, "payout", payout);

    }

    protected function startNextRound (...ignored) :void
    {
        _numBallsThisRound = 0;
        _bingoItems.resetRemainingTags();

        initTimers();

        _sharedState.gameState = SharedState.STATE_PLAYING;
        _sharedState.roundId++;
        _sharedState.roundWinnerId = 0;

        // call a new ball every few seconds
        _timers.runForever(Constants.NEW_BALL_DELAY_S * 1000, callNextBall);
        // call the first ball immediately (will push the new gamestate out)
        callNextBall();
    }

    protected function callNextBall (...ignored) :void
    {
        _numBallsThisRound++;
        _sharedState.ballInPlay = _bingoItems.removeRandomTag();
        setNewGameState(_sharedState);

        //log.info("Calling next ball: " + _sharedState.ballInPlay);
    }

    protected function setNewGameState (newState :SharedState) :void
    {
        _sharedState = newState;
        _roomCtrl.props.set(Constants.PROP_STATE, (newState != null ? newState.toBytes() : null));
    }

    protected function setNewScores (newScores :ScoreTable) :void
    {
        _scores = newScores;
        _roomCtrl.props.set(Constants.PROP_SCORES,
            (newScores != null ? newScores.toBytes() : null));
    }

    protected var _timers :TimerManager;
    protected var _bingoItems :BingoItemManager;

    protected var _numBallsThisRound :int;
    protected var _sharedState :SharedState;
    protected var _scores :ScoreTable;

    protected static const log :Log = Log.getLog(GameController);

}

}
