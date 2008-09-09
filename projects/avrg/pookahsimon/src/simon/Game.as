package simon {

import flash.utils.Dictionary;
import flash.utils.Timer;
import flash.events.TimerEvent;

import com.threerings.util.Log;
import com.threerings.util.StringUtil;

import com.whirled.net.MessageReceivedEvent;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.avrg.RoomServerSubControl;
import com.whirled.avrg.AVRGameRoomEvent;

/**
 * Handles a single instance of simon on the server agent (currently per room).
 */
public class Game
{
    public static var log :Log = Server.log;

    /**
     * Creates a new game instance in the given room.
     */
    public function Game (gameCtrl :AVRServerGameControl, roomId :int)
    {
        log.info("Starting up new game [roomId=" + roomId + "]");

        _gameCtrl = gameCtrl;
        _roomCtrl = _gameCtrl.getRoom(roomId);

        // set up our listeners
        _roomCtrl.addEventListener(AVRGameRoomEvent.PLAYER_ENTERED, playerEntered);
        _roomCtrl.addEventListener(AVRGameRoomEvent.PLAYER_LEFT, playerLeft);
        _gameCtrl.game.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
        _playerTimer.addEventListener(TimerEvent.TIMER, playerTimeout);
        _roundTimer.addEventListener(TimerEvent.TIMER, newRoundTimeout);
    }

    /**
     * Terminates this game, saving any persistent data and resetting transient room state.
     */
    public function shutdown () :void
    {
        // remove our listeners
        _roomCtrl.removeEventListener(AVRGameRoomEvent.PLAYER_ENTERED, playerEntered);
        _roomCtrl.removeEventListener(AVRGameRoomEvent.PLAYER_LEFT, playerLeft);
        _gameCtrl.game.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
        _playerTimer.removeEventListener(TimerEvent.TIMER, playerTimeout);
        _roundTimer.removeEventListener(TimerEvent.TIMER, newRoundTimeout);

        // stop timers
        _playerTimer.stop();
        _roundTimer.stop();

        // clear transient state
        _roomCtrl.props.set(Constants.PROP_STATE, null);
        _roomCtrl.props.set(Constants.PROP_SCORES, null);

        log.info("Shut down game [roomId=" + _roomCtrl.getRoomId() + "]");
    }

    /**
     * Relays agent messages to the appropriate callback if the sender is a part of this game.
     */
    protected function messageReceived (evt :MessageReceivedEvent) :void
    {
        if (evt.name == Constants.MSG_PLAYERREADY) {
            if (_state.getPlayerState(evt.senderId) == State.PLAYER_PENDING) {
                playerReady(evt.senderId);
            }

        } else if (evt.name == Constants.MSG_RAINBOWCLICKED) {
            if (_state.curPlayerId == evt.senderId) {
                rainbowClicked(evt.value as int);
            }
        }
    }

    /**
     * Called by whirled when a new player enters our room.
     */
    protected function playerEntered (evt :AVRGameRoomEvent) :void
    {
        var playerId :int = evt.value as int;

        // remove the player as a test to make sure he is not already here
        if (_state.removePlayer(playerId)) {
            log.warning(
                "Player already entered [roomId=" + _roomCtrl.getRoomId() + ", playerId=" + 
                evt.value + "]");
        }

        // add in the pending state
        log.info("Pending player [playerId=" + evt.value + "]");
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

    /**
     * Called by whirled when a player leaves our room (or game).
     */
    protected function playerLeft (evt :AVRGameRoomEvent) :void
    {
        var playerId :int = evt.value as int;

        log.info("Removing player [playerId=" + evt.value + "]");

        // first find the player to take over the turn
        if (_state.curPlayerId == playerId && _state.numReadyPlayers > 1) {
            advanceCurrentPlayer();
        }

        // remove the player from the state
        if (!_state.removePlayer(playerId)) {
            log.warning(
                "Player leaving is not in game [roomId=" + _roomCtrl.getRoomId() + ", playerId=" + 
                evt.value + "]");
            return;
        }

        // transition back into waiting if there are not enough players to continue now
        if (_state.numReadyPlayers < Constants.MIN_MP_PLAYERS_TO_START) {
            // TODO: award remaining player?
            _state.gameState = State.STATE_WAITINGFORPLAYERS;
            _roundTimer.stop();
            _playerTimer.stop();
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
                _roundTimer.stop();
                _roundTimer.start();
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

            // failed turn: boot player, go to next and send updates
            if (playerFailed()) {

                // send state and new scores is someone just won
                sendState();
                sendScores();

            } else {

                // ...otherwise just send state
                sendState();
            }


        // matching note
        } else {

            // get ready for the next one and reset timer
            _remainingPattern.shift();
            _playerTimer.stop();
            _playerTimer.start();
        }
    }

    /**
     * Called when it has been the current player's turn for longer than the allotted time.
     */
    protected function playerTimeout (evt :TimerEvent) :void
    {
        var playerId :int = _state.curPlayerId;

        log.info("Player timed out [playerId=" + playerId + "]");

        // move on to the next player and send updates
        if (playerFailed()) {
            sendState();
            sendScores();

        } else {
            sendState();
        }

        // increment the timeout count
        _timeoutCounts[playerId] = int(_timeoutCounts[playerId]) + 1;

        // this is lame for other players, so boot the player completely if it happens a lot
        if (_timeoutCounts[playerId] > Constants.MAX_PLAYER_TIMEOUTS) {
            log.info("Player timeout limit exceeded [playerId=" + playerId + "]");
            _gameCtrl.getPlayer(playerId).deactivateGame();
        }
    }

    /**
     * Called when the round has been over and no new players have shown up for more than the 
     * allotted amount of time.
     */
    protected function newRoundTimeout (evt :TimerEvent) :void
    {
        log.info("Round timeout");

        // move the ousted folks back in
        for each (var playerId :int in _state.playersInState(State.PLAYER_OUT)) {
            _state.setPlayerState(playerId, State.PLAYER_READY);
        }

        // start a new round if we've got enough people
        _state.gameState = State.STATE_WAITINGFORPLAYERS;
        maybeStartNewRound();

        // send updates
        sendState();
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

        // stop the play timer
        _playerTimer.stop();

        // award coins
        _gameCtrl.getPlayer(winnerId).completeTask("winner", 1);

        // kick off a new round in a bit
        _roundTimer.start();
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

        // restart the timer
        _playerTimer.stop();
        _playerTimer.start();

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
        _roundTimer.stop();
        _playerTimer.start();

        log.info(
            "Staring new round [players=" + StringUtil.toString(_state.players) + ", state=" + 
            _state + "]");
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

    /** The top-level control. */
    protected var _gameCtrl :AVRServerGameControl;

    /** The room control. */
    protected var _roomCtrl :RoomServerSubControl;

    /** The state (shared between the server and all clients). */
    protected var _state :State = new State();

    /** The scores (shared between the server and all clients). */
    protected var _scores :ScoreTable = new ScoreTable(Constants.SCORETABLE_MAX_ENTRIES);

    /** Timer for player's turn. */
    protected var _playerTimer :Timer = new Timer(Constants.PLAYER_TIMEOUT_S * 1000, 0);

    /** Timer for starting a new round. */
    protected var _roundTimer :Timer = new Timer(Constants.NEW_ROUND_DELAY_S * 1000, 0);

    /** Mapping of player id to the number of timeout violations. */
    protected var _timeoutCounts :Dictionary = new Dictionary();

    /** The remaining notes that the current player has to play. */
    protected var _remainingPattern :Array = [];
}
}
