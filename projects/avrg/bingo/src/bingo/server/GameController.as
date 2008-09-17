package bingo.server {

import bingo.*;

import com.whirled.contrib.TimerManager;
import com.whirled.contrib.avrg.oneroom.OneRoomGameRoom;

public class GameController extends OneRoomGameRoom
{
    override protected function finishInit () :void
    {
        super.finishInit();
        _bingoItems = new BingoItemManager();
        _sharedState = new SharedState();
        startNextRound();
    }

    override public function shutdown () :void
    {
        shutdownTimers();
        setNewGameState(null);
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

        if (name == Constants.MSG_REQUEST_BINGO) {
            bingoCalled(senderId, CallBingoMessage.fromBytes(ByteArray(value));
        }
    }

    protected function bingoCalled (playerId :int, msg :CallBingoMessage) :void
    {
        // validate
        if (_sharedState.gameState != SharedState.STATE_PLAYING ||
             msg.roundId != _sharedState.roundId) {
            if (msg.roundId > _sharedState.roundId) {
                log.info("discarding CallBingoMessage from the future: " + msg.toString());
            }
            return;
        } else if (_numBallsThisRound < 4) {
            log.info("discarding CallBingoMessage (too few balls called): " + msg.toString());
            return;
        }

        _sharedState.gameState = SharedState.STATE_WEHAVEAWINNER;
        _sharedState.roundWinnerId = playerId;
        setNewGameState(newState);

        // award coins if there's more than one player in the game
        if (_roomCtrl.getPlayerIds().length > 1) {
            _gameCtrl.getPlayer(playerId).completeTask("bingo", 1);
        }

        // start the next round in a few seconds
        initTimers();
        _timers.runOnce(Constants.NEW_ROUND_DELAY_S * 1000, startNextRound);
    }

    protected function startNextRound (...ignored) :void
    {
        _bingoItems.resetRemainingTags();
        initTimers();

        _sharedState.gameState = SharedState.STATE_PLAYING;
        _sharedState.roundId++;
        _sharedState.roundWinnerId = 0;

        // call a new ball every few seconds
        _timers.createTimer(Constants.NEW_BALL_DELAY_S * 1000, -1, callNextBall);
        // call the first ball immediately (will push the new gamestate out)
        callNextBall();
    }

    protected function callNextBall (...ignored) :void
    {
        _sharedState.ballInPlay = _bingoItems.getRandomTag();
        setNewGameState(_sharedState);
    }

    protected function setNewGameState (newState :SharedState) :void
    {
        _sharedState = newState;
        _roomCtrl.props.set(Constants.PROP_STATE, (newState != null ? newState.toBytes() : null));
    }

    protected var _timers :TimerManager;
    protected var _bingoItems :BingoItemManager;

    protected var _numBallsThisRound :int;
    protected var _sharedState :SharedState;

    protected static const log :Log = Log.getLog(Server);

}

}
