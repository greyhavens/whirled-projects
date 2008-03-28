package simon {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.AVRGameControlEvent;
import com.whirled.contrib.simplegame.*;

import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

public class GameMode extends AppMode
{
    override protected function setup () :void
    {
        // timers
        _newRoundTimer = new Timer(Constants.NEW_ROUND_DELAY_S * 1000, 1);
        _newRoundTimer.addEventListener(TimerEvent.TIMER, handleNewRoundTimerExpired);

        // state change events
        SimonMain.model.addEventListener(SharedStateChangedEvent.GAME_STATE_CHANGED, handleGameStateChange);
        SimonMain.model.addEventListener(SharedStateChangedEvent.NEXT_PLAYER, handleCurPlayerChanged);
        SimonMain.model.addEventListener(SharedStateChangedEvent.NEW_SCORES, handleNewScores);

        SimonMain.control.addEventListener(AVRGameControlEvent.PLAYER_LEFT, handlePlayerLeft);

        // controllers
        this.addObject(new CloudViewController(), this.modeSprite);
        this.addObject(new AvatarController());

        // each client maintains the concept of an expected state,
        // so that it is prepared to take over as the
        // authoritative client at any time.

        if (SimonMain.control.isConnected() && SimonMain.control.hasControl() && SimonMain.model.curState.gameState != SharedState.INVALID_STATE) {
            // try to reset the state when we first enter a game, in case
            // there's a current game in progress that isn't controlled by anybody
            _expectedState = new SharedState();
            this.applyStateChanges();
        } else {
            _expectedState = null;
            this.handleGameStateChange(null);
        }
    }

    override protected function destroy () :void
    {
        // @TODO - remove this once SimObject gets a function that's called
        // on mode shutdown
        this.destroyObjectNamed(RainbowController.NAME);
        this.destroyObjectNamed(CloudViewController.NAME);
        this.destroyObjectNamed(AvatarController.NAME);

        SimonMain.model.removeEventListener(SharedStateChangedEvent.GAME_STATE_CHANGED, handleGameStateChange);
        SimonMain.model.removeEventListener(SharedStateChangedEvent.NEXT_PLAYER, handleCurPlayerChanged);
        SimonMain.model.removeEventListener(SharedStateChangedEvent.NEW_SCORES, handleNewScores);

        SimonMain.control.removeEventListener(AVRGameControlEvent.PLAYER_LEFT, handlePlayerLeft);

        _newRoundTimer.removeEventListener(TimerEvent.TIMER, handleNewRoundTimerExpired);
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);

        switch (SimonMain.model.curState.gameState) {
        case SharedState.WAITING_FOR_GAME_START:
            if (this.canStartGame) {
                this.startNextGame();
            }
            break;

        default:
            // do nothing;
            break;
        }

        this.applyStateChanges();

        this.updateStatusText();
    }

    protected function applyStateChanges () :void
    {
        if (null != _expectedState) {

            // trySetNewState is idempotent in the sense that
            // we can keep calling it until the state changes.
            // The state change we see will not necessarily
            // be what was requested (this client may not be in control)

            SimonMain.model.trySetNewState(_expectedState);
        }

        if (null != _expectedScores) {

            // see above

            SimonMain.model.trySetNewScores(_expectedScores);
        }
    }

    protected function handleQuitButtonClick (e :MouseEvent) :void
    {
        SimonMain.quit();
    }

    protected function handleGameStateChange (e :SharedStateChangedEvent) :void
    {
        // reset the expected state when the state changes
        _expectedState = null;

        this.destroyObjectNamed(RainbowController.NAME);

        switch (SimonMain.model.curState.gameState) {
        case SharedState.INVALID_STATE:
            // no game in progress. kick a new one off.
            this.setupFirstGame();
            break;

        case SharedState.WAITING_FOR_GAME_START:
            // in the "lobby", waiting for enough players to join
            if (this.canStartGame) {
                this.startNextGame();
            }
            break;

        case SharedState.PLAYING_GAME:
            // the game has started -- it's the first player's turn
            this.handleCurPlayerChanged(null);
            break;

        case SharedState.WE_HAVE_A_WINNER:
            this.handleGameOver();
            break;

        default:
            log.info("unrecognized gameState: " + SimonMain.model.curState.gameState);
            break;
        }

        this.updateStatusText();
    }

    protected function handleCurPlayerChanged (e :SharedStateChangedEvent) :void
    {
        // reset the expected state when the state changes
        _expectedState = null;

        this.destroyObjectNamed(RainbowController.NAME);

        if (SimonMain.model.curState.players.length == 0) {
            _expectedState = SimonMain.model.curState.clone();
            _expectedState.gameState = SharedState.WAITING_FOR_GAME_START;

            this.applyStateChanges();
        } else if (SimonMain.model.curState.players.length == 1 && SimonMain.minPlayersToStart > 1) {
            _expectedState = SimonMain.model.curState.clone();
            _expectedState.gameState = SharedState.WE_HAVE_A_WINNER;
            _expectedState.roundWinnerId = (_expectedState.players.length > 0 ? _expectedState.players[0] : 0);

            this.applyStateChanges();
        } else {
            // show the rainbow on the correct player
            this.addObject(new RainbowController(SimonMain.model.curState.curPlayerOid), this.modeSprite);
        }
    }

    protected function handlePlayerLeft (e :AVRGameControlEvent) :void
    {
        // handle players who leave while playing the game

        var playerId :int = e.value as int;
        var index :int = SimonMain.model.curState.players.indexOf(playerId);
        if (index >= 0) {

            if (null == _expectedState) {
                _expectedState = SimonMain.model.curState.clone();
            }

            _expectedState.players = SimonMain.model.curState.players.slice();
            _expectedState.players.splice(index, 1);

            // was it this player's turn?
            if (_expectedState.curPlayerIdx >= _expectedState.players.length) {
                _expectedState.curPlayerIdx = 0;
            }

        }
    }

    protected function handleNewScores (e :SharedStateChangedEvent) :void
    {
        _expectedScores = null;
    }

    protected function handleGameOver () :void
    {
        // update scores
        if (SimonMain.model.curState.roundWinnerId != 0) {
            _expectedScores = SimonMain.model.curScores.clone();
            _expectedScores.incrementScore(SimonMain.model.curState.roundWinnerId, new Date());
            this.applyStateChanges();

            // are you TEH WINNAR?
            if (SimonMain.model.curState.roundWinnerId == SimonMain.localPlayerId && SimonMain.control.isConnected()) {
                SimonMain.control.quests.completeQuest("dummyString", null, 1);
                AvatarController.instance.setAvatarState("Dance", Constants.AVATAR_DANCE_TIME, "Default");
            }
        }

        // start a new round soon
        this.startNewRoundTimer();
    }

    protected function updateStatusText () :void
    {
        var newStatusText :String;

        switch (SimonMain.model.curState.gameState) {
        case SharedState.INVALID_STATE:
            newStatusText = "INVALID_STATE";
            break;

        case SharedState.WAITING_FOR_GAME_START:
            newStatusText = "Waiting to start (players: " + SimonMain.model.getPlayerOids().length + "/" + SimonMain.minPlayersToStart + ")";
            break;

        case SharedState.PLAYING_GAME:
            var curPlayerName :String = SimonMain.getPlayerName(SimonMain.model.curState.curPlayerOid);
            newStatusText = "Playing game. " + curPlayerName + "'s turn.";
            break;

        case SharedState.WE_HAVE_A_WINNER:
            newStatusText = SimonMain.getPlayerName(SimonMain.model.curState.roundWinnerId) + " is the winner!";
            break;

        default:
            log.info("unrecognized gameState: " + SimonMain.model.curState.gameState);
            break;
        }

        if (newStatusText != _statusText) {
            log.info("** STATUS: " + newStatusText);
            _statusText = newStatusText;
        }
    }

    protected function setupFirstGame () :void
    {
        log.info("setupFirstGame()");

        _expectedState = new SharedState();
        _expectedState.gameState = SharedState.WAITING_FOR_GAME_START;

        this.applyStateChanges();
    }

    protected function get canStartGame () :Boolean
    {
        return (SimonMain.model.getPlayerOids().length >= SimonMain.minPlayersToStart);
    }

    protected function startNextGame () :void
    {
        log.info("startNextGame()");

        // set up for the next game state if we haven't already
        if (null == _expectedState || _expectedState.gameState != SharedState.PLAYING_GAME) {
            _expectedState = new SharedState();

            _expectedState.gameState = SharedState.PLAYING_GAME;
            _expectedState.curPlayerIdx = 0;

            // shuffle the player list
            var playerOids :Array = SimonMain.model.getPlayerOids();
            ArrayUtil.shuffle(playerOids, null);
            _expectedState.players = playerOids;
        }

        this.applyStateChanges();
    }

    protected function startNewRoundTimer () :void
    {
        _newRoundTimer.reset();
        _newRoundTimer.start();
    }

    protected function stopNewRoundTimer () :void
    {
        _newRoundTimer.stop();
    }

    protected function handleNewRoundTimerExpired (e :TimerEvent) :void
    {
        _expectedState = SimonMain.model.curState.clone();

        // push a new round update out
        _expectedState.gameState = SharedState.WAITING_FOR_GAME_START;
        _expectedState.players = [];
        _expectedState.pattern = [];
        _expectedState.roundId += 1;
        _expectedState.roundWinnerId = 0;

        this.applyStateChanges();
    }

    public function currentPlayerTurnSuccess (newNote :int) :void
    {
        this.destroyObjectNamed(RainbowController.NAME);

        _expectedState = SimonMain.model.curState.clone();
        _expectedState.pattern.push(newNote);

        _expectedState.curPlayerIdx =
            (_expectedState.curPlayerIdx < _expectedState.players.length - 1 ? _expectedState.curPlayerIdx + 1 : 0);

        this.applyStateChanges();
    }

    public function currentPlayerTurnFailure () :void
    {
        this.destroyObjectNamed(RainbowController.NAME);

        _expectedState = SimonMain.model.curState.clone();

        // the current player is out of the round
        _expectedState.players.splice(_expectedState.curPlayerIdx, 1);

        // move to the next player
        if (_expectedState.curPlayerIdx >= _expectedState.players.length) {
            _expectedState.curPlayerIdx = 0;
        }

        this.applyStateChanges();
    }

    protected var _expectedState :SharedState;
    protected var _expectedScores :ScoreTable;

    protected var _statusText :String;

    protected var _newRoundTimer :Timer;

    protected var log :Log = Log.getLog(this);

}

}
