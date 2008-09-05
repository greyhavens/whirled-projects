package simon {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.*;

import flash.display.Sprite;

public class GameMode extends AppMode
{
    override protected function setup () :void
    {
        _gameLayer = new Sprite();
        _helpLayer = new Sprite();

        this.modeSprite.addChild(_gameLayer);
        this.modeSprite.addChild(_helpLayer);

        // controllers
        this.addObject(new CloudViewController(), _gameLayer);
        this.addObject(new AvatarController());
        this.addObject(new HelpViewController(), _helpLayer);

        this.helpScreenVisible = false;

        // state change events
        SimonMain.model.addEventListener(SharedStateChangedEvent.GAME_STATE_CHANGED, handleGameStateChange);
        SimonMain.model.addEventListener(SharedStateChangedEvent.NEXT_PLAYER, handleCurPlayerChanged);
        SimonMain.model.addEventListener(SharedStateChangedEvent.NEW_SCORES, handleNewScores);

        SimonMain.control.room.addEventListener(AVRGameRoomEvent.PLAYER_LEFT, handlePlayerLeft);

        // each client maintains the concept of an expected state,
        // so that it is prepared to take over as the
        // authoritative client at any time.

        if (SimonMain.control.isConnected() && SimonMain.model.hasControl() && SimonMain.model.curState.gameState != SharedState.STATE_INITIAL) {
            // try to reset the state when we first enter a game, in case
            // there's a current game in progress that isn't controlled by anybody
            _expectedState = new SharedState();
            this.applyStateChanges();
        } else {
            _expectedState = null;
            this.handleGameStateChange();
        }
    }

    override protected function destroy () :void
    {
        // @TODO - remove this once SimObject gets a function that's called
        // on mode shutdown
        this.destroyObjectNamed(AbstractRainbowController.NAME);
        this.destroyObjectNamed(CloudViewController.NAME);
        this.destroyObjectNamed(AvatarController.NAME);

        SimonMain.model.removeEventListener(SharedStateChangedEvent.GAME_STATE_CHANGED, handleGameStateChange);
        SimonMain.model.removeEventListener(SharedStateChangedEvent.NEXT_PLAYER, handleCurPlayerChanged);
        SimonMain.model.removeEventListener(SharedStateChangedEvent.NEW_SCORES, handleNewScores);

        SimonMain.control.room.removeEventListener(AVRGameRoomEvent.PLAYER_LEFT, handlePlayerLeft);
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);

        switch (SimonMain.model.curState.gameState) {
        case SharedState.STATE_WAITINGFORPLAYERS:
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

    protected function handleQuitButtonClick (...ignored) :void
    {
        SimonMain.quit();
    }

    protected function handleGameStateChange (...ignored) :void
    {
        // reset the expected state when the state changes
        _expectedState = null;

        this.destroyObjectNamed(AbstractRainbowController.NAME);
        this.destroyObjectNamed(WinnerCloudController.NAME);

        switch (SimonMain.model.curState.gameState) {
        case SharedState.STATE_INITIAL:
            // no game in progress. kick a new one off.
            this.setupFirstGame();
            break;

        case SharedState.STATE_WAITINGFORPLAYERS:
            // in the "lobby", waiting for enough players to join
            if (this.canStartGame) {
                this.startNextGame();
            }
            break;

        case SharedState.STATE_PLAYING:
            // the game has started -- it's the first player's turn
            this.handleCurPlayerChanged();
            break;

        case SharedState.STATE_WEHAVEAWINNER:
            this.handleGameOver();
            break;

        default:
            log.info("unrecognized gameState: " + SimonMain.model.curState.gameState);
            break;
        }

        this.updateStatusText();
    }

    protected function handleCurPlayerChanged (...ignored) :void
    {
        // reset the expected state when the state changes
        _expectedState = null;

        this.destroyObjectNamed(AbstractRainbowController.NAME);

        if (SimonMain.model.curState.players.length == 0) {
            _expectedState = SimonMain.model.curState.clone();
            _expectedState.gameState = SharedState.STATE_WAITINGFORPLAYERS;

            this.applyStateChanges();
        } else if (SimonMain.model.curState.players.length == 1 && SimonMain.minPlayersToStart > 1) {
            _expectedState = SimonMain.model.curState.clone();
            _expectedState.gameState = SharedState.STATE_WEHAVEAWINNER;
            _expectedState.roundWinnerId = (_expectedState.players.length > 0 ? _expectedState.players[0] : 0);

            this.applyStateChanges();
        } else {
            // show the rainbow on the correct player
            this.addObject(AbstractRainbowController.create(SimonMain.model.curState.curPlayerOid), _gameLayer);
        }
    }

    protected function handlePlayerLeft (e :AVRGameRoomEvent) :void
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

    protected function handleNewScores (...ignored) :void
    {
        _expectedScores = null;
    }

    protected function handleGameOver () :void
    {
        var roundWinnerId :int = SimonMain.model.curState.roundWinnerId;
        var patternEmpty :Boolean = SimonMain.model.curState.pattern.length == 0;

        // update scores and coins, but only if we had a winner, and only
        // if at least one note was played this game
        if (roundWinnerId != 0 && !patternEmpty) {

            // update scores
            _expectedScores = SimonMain.model.curScores.clone();
            _expectedScores.incrementScore(roundWinnerId, new Date());
            this.applyStateChanges();

            // show the winner screen
            this.addObject(new WinnerCloudController(roundWinnerId), _gameLayer);

            // award us coins if we are the winner
            if (roundWinnerId == SimonMain.localPlayerId && SimonMain.control.isConnected()) {
                SimonMain.control.player.completeTask("winner", 1);
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
        case SharedState.STATE_INITIAL:
            newStatusText = "STATE_INITIAL";
            break;

        case SharedState.STATE_WAITINGFORPLAYERS:
            newStatusText = "Waiting to start (players: " + SimonMain.model.getPlayerOids().length + "/" + SimonMain.minPlayersToStart + ")";
            break;

        case SharedState.STATE_PLAYING:
            var curPlayerName :String = SimonMain.getPlayerName(SimonMain.model.curState.curPlayerOid);
            newStatusText = "Playing game. " + curPlayerName + "'s turn.";
            break;

        case SharedState.STATE_WEHAVEAWINNER:
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
        _expectedState.gameState = SharedState.STATE_WAITINGFORPLAYERS;

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
        if (null == _expectedState || _expectedState.gameState != SharedState.STATE_PLAYING) {
            _expectedState = new SharedState();

            _expectedState.gameState = SharedState.STATE_PLAYING;
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
        this.stopNewRoundTimer();
        this.addObject(new SimpleTimer(Constants.NEW_ROUND_DELAY_S, handleNewRoundTimerExpired, false, NEW_ROUND_TIMER_NAME));
    }

    protected function stopNewRoundTimer () :void
    {
        this.destroyObjectNamed(NEW_ROUND_TIMER_NAME);
    }

    protected function handleNewRoundTimerExpired () :void
    {
        _expectedState = SimonMain.model.curState.clone();

        // push a new round update out
        _expectedState.gameState = SharedState.STATE_WAITINGFORPLAYERS;
        _expectedState.players = [];
        _expectedState.pattern = [];
        _expectedState.roundId += 1;
        _expectedState.roundWinnerId = 0;

        this.applyStateChanges();
    }

    public function currentPlayerTurnSuccess (newNote :int) :void
    {
        this.destroyObjectNamed(AbstractRainbowController.NAME);

        _expectedState = SimonMain.model.curState.clone();
        _expectedState.pattern.push(newNote);

        _expectedState.curPlayerIdx =
            (_expectedState.curPlayerIdx < _expectedState.players.length - 1 ? _expectedState.curPlayerIdx + 1 : 0);

        this.applyStateChanges();
    }

    public function currentPlayerTurnFailure () :void
    {
        this.destroyObjectNamed(AbstractRainbowController.NAME);

        _expectedState = SimonMain.model.curState.clone();

        // the current player is out of the round
        _expectedState.players.splice(_expectedState.curPlayerIdx, 1);

        // move to the next player
        if (_expectedState.curPlayerIdx >= _expectedState.players.length) {
            _expectedState.curPlayerIdx = 0;
        }

        this.applyStateChanges();
    }

    public function get helpScreenVisible () :Boolean
    {
        return _helpLayer.visible;
    }

    public function set helpScreenVisible (visible :Boolean) :void
    {
        _helpLayer.visible = visible;
    }

    public function incrementPlayerTimeoutCount () :void
    {
        if (++_playerTimeouts >= Constants.MAX_PLAYER_TIMEOUTS) {
            SimonMain.quit();
        }
    }

    protected var _expectedState :SharedState;
    protected var _expectedScores :ScoreTable;
    protected var _gameLayer :Sprite;
    protected var _helpLayer :Sprite;

    protected var _statusText :String;

    protected var _playerTimeouts :int;

    protected var log :Log = Log.getLog(this);

    protected static const NEW_ROUND_TIMER_NAME :String = "NewRoundTimer";

}

}
