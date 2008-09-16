package simon {

import com.threerings.util.StringUtil;

import flash.utils.Dictionary;
import flash.utils.setTimeout;
import flash.utils.Timer;
import flash.events.TimerEvent;

import com.whirled.contrib.avrg.oneroom.OneRoomGameRoom;

/**
 * Handles a single game of simon (in a single room).
 */
public class Game extends OneRoomGameRoom
{
    /** @inheritDoc */
    // from OneRoomGameRoom
    override protected function finishInit () :void
    {
        super.finishInit();
        _timer.addEventListener(TimerEvent.TIMER, handleTimer);
    }

    /** @inheritDoc */
    // from OneRoomGameRoom
    override public function shutdown () :void
    {
        _timer.removeEventListener(TimerEvent.TIMER, handleTimer);

        // stop timer
        stopTimer();

        // clear transient state
        _roomCtrl.props.set(Constants.PROP_STATE, null);
        _roomCtrl.props.set(Constants.PROP_SCORES, null);

        super.shutdown();
    }

    /** @inheritDoc */
    // from OneRoomGameRoom
    override protected function messageReceived (senderId :int, name :String, value :Object) :void
    {
        if (name == Constants.MSG_PLAYERREADY) {
            if (_state.getPlayerState(senderId) == State.PLAYER_PENDING) {
                playerReady(senderId);
            }

        } else if (name == Constants.MSG_RAINBOWCLICKED) {
            if (_state.curPlayerId == senderId) {
                rainbowClicked(value as int);
            }
        }
    }

    /** @inheritDoc */
    // from OneRoomGameRoom
    override protected function playerEntered (playerId :int) :void
    {
        // remove the player as a test to make sure he is not already here
        if (_state.removePlayer(playerId)) {
            log.warning("Player already entered [playerId=" + playerId + "]");
        }

        // add in the pending state
        log.info("Pending player [playerId=" + playerId + "]");
        _state.addPlayer(playerId);

        // reset the player's timeout count
        delete _timeoutCounts[playerId];

        // if this is the first player, transition into the wait state
        if (_state.gameState == State.STATE_INITIAL) {
            _state.gameState = State.STATE_WAITINGFORPLAYERS;
        }

        // let everyone know
        sendState();
    }

    /** @inheritDoc */
    // from OneRoomGameRoom
    override protected function playerLeft (playerId :int) :void
    {
        log.info("Removing player [playerId=" + playerId + "]");

        // first find the player to take over the turn
        if (_state.curPlayerId == playerId && _state.numReadyPlayers > 1) {
            advanceCurrentPlayer();
        }

        // remove the player from the state
        if (!_state.removePlayer(playerId)) {
            log.warning("Player leaving is not in game [playerId=" + playerId + "]");
            return;
        }

        // transition back into waiting if there are not enough players to continue now
        if (_state.numReadyPlayers < Constants.MIN_MP_PLAYERS_TO_START) {
            // TODO: award remaining player?
            _state.gameState = State.STATE_WAITINGFORPLAYERS;
            stopTimer();
        }

        // update everyone
        sendState();
    }

    /**
     * Called by client when resources have finished loading.
     */
    protected function playerReady (playerId :int) :void
    {
        // only newly entered (pending) players should call this
        if (_state.getPlayerState(playerId) != State.PLAYER_PENDING) {
            log.warning("Player ready but not pending [playerId=" + playerId + "]");
            return;
        }

        log.info("Player ready [playerId=" + playerId + "]");

        // if the game is not started yet, set this player to ready
        if (_state.gameState == State.STATE_WAITINGFORPLAYERS) {
            _state.setPlayerState(playerId, State.PLAYER_READY);
            
            // if we can start now, reset the round timer to allow more players to join
            // TODO: this is subject to abuse, should only allow a player to reset the round timer 
            // once per minute or something
            if (_state.numReadyPlayers >= Constants.MIN_MP_PLAYERS_TO_START) {
                startTimer(ROUND_BREAK, Constants.NEW_ROUND_DELAY_S);
            }

        } else {
            // otherwise, set this player to go in on the next round
            _state.setPlayerState(playerId, State.PLAYER_OUT);
        }

        // update clients
        sendState();
    }

    /**
     * Called by client when the rainbow has been clicked.
     */
    protected function rainbowClicked (note :int) :void
    {
        log.info("Rainbow clicked [note=" + note + "]");

        // validate note
        if (note < 0 || note >= Constants.NUM_NOTES) {
            log.warning("Illegal note sent [state=" + _state + "]");
            return;
        }

        // relay the message so everyone can hear the note
        _roomCtrl.sendMessage(Constants.MSG_RAINBOWCLICKED, note);
        
        // the first note after pattern completion
        if (_remainingPattern.length == 0) {

            // extend the pattern and start the next turn
            _state.pattern.push(note);
            advanceCurrentPlayer();
            sendState();

        // incorrect note
        } else if (note != _remainingPattern[0]) {

            // failed turn: boot player, go to next
            var roundEnded :Boolean = playerFailed();

            // update clients
            sendState();
            
            // update scores if the round ended
            if (roundEnded) {
                sendScores();
            }

        // matching note
        } else {

            // get ready for the next note
            _remainingPattern.shift();

            // restart timer
            startTimer(PLAYER_CLICK, Constants.PLAYER_TIMEOUT_S);
        }
    }

    /**
     * Called when the timer expires.
     */
    protected function handleTimer (evt :TimerEvent) :void
    {
        var playerId :int = _state.curPlayerId;

        log.info("Handling timer [action=" + _timedAction + "]");

        if (_timedAction == NOTE_REPLAY) {
            log.info("Note replay complete [playerId=" + playerId + "]");
            startTimer(PLAYER_CLICK, Constants.PLAYER_TIMEOUT_S);
            sendStartPlayerTimer();

        } else if (_timedAction == PLAYER_CLICK) {
            log.info("Player timed out [playerId=" + playerId + "]");

            // move on to the next player and send updates
            var roundEnded :Boolean = playerFailed();
            sendState();
            if (roundEnded) {
                sendScores();
            }

            // increment the timeout count
            _timeoutCounts[playerId] = int(_timeoutCounts[playerId]) + 1;

            // this is lame for other players, so boot the player completely if it happens a lot
            if (_timeoutCounts[playerId] > Constants.MAX_PLAYER_TIMEOUTS) {
                log.info("Player timeout limit exceeded [playerId=" + playerId + "]");
                _gameCtrl.getPlayer(playerId).deactivateGame();
            }

        } else if (_timedAction == ROUND_BREAK) {
            log.info("Round timeout");

            // move the ousted folks back in
            for each (playerId in _state.playersInState(State.PLAYER_OUT)) {
                _state.setPlayerState(playerId, State.PLAYER_READY);
            }

            // start a new round if we've got enough people
            _state.gameState = State.STATE_WAITINGFORPLAYERS;
            maybeStartNewRound();

            // send updates
            sendState();
        }
    }

    /**
     * Ends the current round and designates the given player as the winner. The caller must send 
     * state and score updates.
     */
    protected function endRoundWithWinner (winnerId :int) :void
    {
        log.info("Ending round [winnerId=" + winnerId + "]");

        // update state and score
        _state.gameState = State.STATE_WEHAVEAWINNER;
        _state.roundWinnerId = winnerId;
        _scores.incrementScore(winnerId, new Date());

        // award coins
        var payout :Number = (_state.pattern.length - Constants.MIN_NOTES_FOR_PAYOUT + 1) / 
            (Constants.NOTES_FOR_MAX_PAYOUT - Constants.MIN_NOTES_FOR_PAYOUT + 1);
        if (payout > 0 && payout <= 1.0) {
            _gameCtrl.getPlayer(winnerId).completeTask("winner", payout);
        }

        // TODO: trophy for consecutive wins
        
        // TODO: trophy for total wins in time period

        // kick off a new round in a bit
        startTimer(ROUND_BREAK, Constants.NEW_ROUND_DELAY_S);
    }

    /**
     * Ends the current player's turn and kicks them out of the current round (to be brought back 
     * in next round). If there is only one player left, declares him the winner and returns true.
     * Otherwise returns false. The caller must send state and score updates.
     */
    protected function playerFailed () :Boolean
    {
        var curPlayer :int = _state.curPlayerId;

        log.info("Player failed [playerId=" + curPlayer + "]");

        // do this first since we are about to un-ready this player
        advanceCurrentPlayer();

        // this shouldn't happen
        if (_state.getPlayerState(curPlayer) != State.PLAYER_READY) {
            log.warning(
                "playerFailed() - player not playing [state=" + _state + ", curPlayer=" + 
                curPlayer + "]");
            return false;
        }

        // kick out
        _state.setPlayerState(curPlayer, State.PLAYER_OUT);

        // check for winner
        if (_state.numReadyPlayers == 1) {
            endRoundWithWinner(_state.curPlayerId);
            return true;
        }

        return false;
    }

    /**
     * Updates the current player id to be the next player in the list and prepares for him to 
     * make his move.
     */
    protected function advanceCurrentPlayer () :void
    {
        var players :Array = _state.playersInState(State.PLAYER_READY);
        if (players.length < 2) {
            throw new Error("Internal error, too few players ready");
        }

        var idx :int = players.indexOf(_state.curPlayerId);
        if (idx < 0) {
            throw new Error("Internal error, current player not ready");
        }

        // advance the player
        _state.curPlayerId = players[(idx + 1) % players.length];

        // reset the pattern
        _remainingPattern = _state.pattern.slice();

        // allow the client some time to animate the change of tuen and note replay
        startTimer(NOTE_REPLAY, Constants.PLAYER_GRACE_PERIOD_S + 
            _state.pattern.length * Constants.PLAYER_TIME_PER_NOTE_S);

        log.info("New current player [playerId=" + _state.curPlayerId + "]");
    }

    /**
     * Kicks off a new round if there are enough players ready to go. The caller must send the 
     * state updates.
     */
    protected function maybeStartNewRound () :void
    {
        // not enough ready, keep waiting
        if (_state.numReadyPlayers < Constants.MIN_MP_PLAYERS_TO_START) {
            return;
        }

        // get the players who are ready
        var players :Array = _state.playersInState(State.PLAYER_READY);

        // update the state
        _state.gameState = State.STATE_PLAYING;
        _state.curPlayerId = players[int(Math.random() * players.length)];
        _state.roundWinnerId = 0;
        _state.pattern = [];
        _remainingPattern = [];

        // stop the round timer, start the player timer
        startTimer(NOTE_REPLAY, Constants.PLAYER_GRACE_PERIOD_S);

        log.info(
            "Staring new round [players=" + StringUtil.toString(_state.players) + ", state=" + 
            _state + "]");
    }

    protected function startTimer (action :int, delay :Number) :void
    {
        _timer.stop();
        _timer.delay = delay * 1000;
        _timedAction = action;

        // TODO: remove this when all avmthane binaries are rebuilt
        setTimeout(function () :void {
            _timer.start();
        }, 0);

        log.debug("Started timer [action=" + action + ", delay=" + delay + "]");
    }

    protected function stopTimer () :void
    {
        _timer.stop();
        _timedAction = NONE;

        log.debug("Stopped timer");
    }

    /**
     * Sets the state property so that it dispatches to everyone in our room.
     */
    protected function sendState () :void
    {
        log.debug("Sending state [state=" + _state + "]");
        _roomCtrl.props.set(Constants.PROP_STATE, _state.toBytes());
    }

    /**
     * Sets the scores property so that it dispatches to everyone in our room.
     */
    protected function sendScores () :void
    {
        log.debug("Sending scores");
        _roomCtrl.props.set(Constants.PROP_SCORES, _scores.toBytes());
    }

    protected function sendStartPlayerTimer () :void
    {
        log.debug("Sending start player timer message");
        _roomCtrl.sendMessage(Constants.MSG_PLAYERTIMERSTARTED);
    }


    /** The state (shared between the server and all clients). */
    protected var _state :State = new State();

    /** The scores (shared between the server and all clients). */
    protected var _scores :ScoreTable = new ScoreTable(Constants.SCORETABLE_MAX_ENTRIES);

    protected var _timer :Timer = new Timer(1, 0);

    protected var _timedAction :int = NONE;

    /** Mapping of player id to the number of timeout violations. */
    protected var _timeoutCounts :Dictionary = new Dictionary();

    /** The remaining notes that the current player has to play. */
    protected var _remainingPattern :Array = [];

    protected static const NONE :int = 0;
    protected static const ROUND_BREAK :int = 1;
    protected static const NOTE_REPLAY :int = 2;
    protected static const PLAYER_CLICK :int = 3;
}
}
