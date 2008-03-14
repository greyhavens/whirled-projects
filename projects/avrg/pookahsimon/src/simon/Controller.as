package simon {

import com.threerings.flash.DisablingButton;
import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.AVRGameControlEvent;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.utils.Timer;

public class Controller
{
    public function Controller (mainSprite :Sprite, model :Model)
    {
        _mainSprite = mainSprite;
        _model = model;
    }

    public function setup () :void
    {
        // timers
        _newRoundTimer = new Timer(Constants.NEW_ROUND_DELAY_S * 1000, 1);
        _newRoundTimer.addEventListener(TimerEvent.TIMER, handleNewRoundTimerExpired);

        // state change events
        _model.addEventListener(SharedStateChangedEvent.GAME_STATE_CHANGED, handleGameStateChange);
        _model.addEventListener(SharedStateChangedEvent.NEXT_PLAYER, handleCurPlayerIndexChanged);
        _model.addEventListener(SharedStateChangedEvent.NEW_SCORES, handleNewScores);

        SimonMain.control.addEventListener(AVRGameControlEvent.PLAYER_LEFT, handlePlayerLeft);

        _mainSprite.addEventListener(Event.ENTER_FRAME, handleEnterFrame);

        // visuals
        var quitButton :DisablingButton = createButton(100, 25, "Quit");
        quitButton.x = Constants.QUIT_BUTTON_LOC.x;
        quitButton.y = Constants.QUIT_BUTTON_LOC.y;
        quitButton.addEventListener(MouseEvent.CLICK, handleQuitButtonClick);
        _mainSprite.addChild(quitButton);

        _statusText = new TextField();
        _statusText.autoSize = TextFieldAutoSize.LEFT;
        _statusText.textColor = 0x0000FF;
        _statusText.scaleX = 3;
        _statusText.scaleY = 3;
        _statusText.x = Constants.STATUS_TEXT_LOC.x;
        _statusText.y = Constants.STATUS_TEXT_LOC.y;
        _mainSprite.addChild(_statusText);

        _scoreboardView = new ScoreboardView(_model.curScores);
        _scoreboardView.x = Constants.SCOREBOARD_LOC.x;
        _scoreboardView.y = Constants.SCOREBOARD_LOC.y;
        _mainSprite.addChild(_scoreboardView);

        _playerListView = new PlayerListViewController();
        _playerListView.x = Constants.PLAYER_LIST_LOC.x;
        _playerListView.y = Constants.PLAYER_LIST_LOC.y;
        _mainSprite.addChild(_playerListView);

        // each client maintains the concept of an expected state,
        // so that it is prepared to take over as the
        // authoritative client at any time.

        _expectedState = null;

        this.handleGameStateChange(null);
    }

    public function destroy () :void
    {
        _model.removeEventListener(SharedStateChangedEvent.GAME_STATE_CHANGED, handleGameStateChange);
        _model.removeEventListener(SharedStateChangedEvent.NEXT_PLAYER, handleCurPlayerIndexChanged);
        _model.removeEventListener(SharedStateChangedEvent.NEW_SCORES, handleNewScores);

        SimonMain.control.removeEventListener(AVRGameControlEvent.PLAYER_LEFT, handlePlayerLeft);

        _mainSprite.removeEventListener(Event.ENTER_FRAME, handleEnterFrame);

        _newRoundTimer.removeEventListener(TimerEvent.TIMER, handleNewRoundTimerExpired);
    }

    protected static function createButton (width :int, height :int, text :String) :DisablingButton
    {
        var upState :DisplayObject = createButtonFace(width, height, text, 0x000000, 0xFFFFFF);
        var overState :DisplayObject = createButtonFace(width, height, text, 0x000000, 0xDDDDDD);
        var downState :DisplayObject = createButtonFace(width, height, text, 0xFFFFFF, 0x000000);
        var hitTestState :DisplayObject = upState;
        var disabledState :DisplayObject = overState;

        return new DisablingButton(upState, overState, downState, hitTestState, disabledState);
    }

    protected static function createButtonFace (width :int, height :int, text :String, textColor :uint, bgColor :uint) :DisplayObject
    {
        var sprite :Sprite = new Sprite();
        var g :Graphics = sprite.graphics;

        g.lineStyle(1, 0x000000);

        g.beginFill(bgColor);
        g.drawRect(0, 0, width, height);
        g.endFill();

        var textField :TextField = new TextField();
        textField.autoSize = TextFieldAutoSize.LEFT;
        textField.textColor = textColor;
        textField.text = text;

        var scale :Number = Math.min((width - 2) / textField.width, (height - 2) / textField.height);
        textField.scaleX = scale;
        textField.scaleY = scale;

        textField.x = (width * 0.5) - (textField.width * 0.5);
        textField.y = (height * 0.5) - (textField.height * 0.5);

        sprite.addChild(textField);

        return sprite;
    }

    protected function handleEnterFrame (e :Event) :void
    {
        this.update();
    }

    protected function handleQuitButtonClick (e :MouseEvent) :void
    {
        if (SimonMain.control.isConnected()) {
            SimonMain.control.deactivateGame();
        }
    }

    protected function update () :void
    {
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

            _model.trySetNewState(_expectedState);
        }

        if (null != _expectedScores) {

            // see above

            _model.trySetNewScores(_expectedScores);
        }
    }

    protected function handleGameStateChange (e :SharedStateChangedEvent) :void
    {
        // reset the expected state when the state changes
        _expectedState = null;

        switch (_model.curState.gameState) {
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
            this.handleCurPlayerIndexChanged(null);
            break;

        case SharedState.SHOWING_WINNER_ANIMATION:
            this.showWinnerAnimation();
            break;

        default:
            log.info("unrecognized gameState: " + _model.curState.gameState);
            break;
        }

        this.updateStatusText();
    }

    protected function handleCurPlayerIndexChanged (e :SharedStateChangedEvent) :void
    {
        // reset the expected state when the state changes
        _expectedState = null;

        if (null != _currentRainbow) {
            _currentRainbow.destroy();
            _currentRainbow = null;
        }

        // if there are two players left, the last man standing is the winner
        if (SimonMain.model.curState.players.length <= 1) {
            var nextSharedState :SharedState = this.createNextSharedState();
            nextSharedState.gameState = SharedState.SHOWING_WINNER_ANIMATION;
            nextSharedState.roundWinnerId = (nextSharedState.players.length > 0 ? nextSharedState.players[0] : 0);

            this.applyStateChanges();
        } else {
            // show the rainbow on the correct player
            _currentRainbow = new RainbowController(SimonMain.model.curState.curPlayerOid);
        }
    }

    protected function handlePlayerLeft (e :AVRGameControlEvent) :void
    {
        // handle players who leave while playing the game

        var playerId :int = e.value as int;
        var index :int = SimonMain.model.curState.players.indexOf(playerId);
        if (index >= 0) {

            if (null != _expectedState) {
                this.createNextSharedState();
            }

            _expectedState.players = SimonMain.model.curState.players.slice();
            _expectedState.players.splice(index, 1);

            // was it this player's turn?
            if (index == _expectedState.curPlayerIdx) {
                _expectedState.curPlayerIdx = (_expectedState.curPlayerIdx >= _expectedState.players.length - 1 ? _expectedState.curPlayerIdx + 1 : 0);
            }

        }
    }

    protected function handleNewScores (e :SharedStateChangedEvent) :void
    {
        _expectedScores = null;
        _scoreboardView.scoreboard = _model.curScores;
    }

    protected function showWinnerAnimation () :void
    {
        // @TODO - show the winner animation, then start a new game
        this.startNewRoundTimer();
    }

    protected function updateStatusText () :void
    {
        switch (_model.curState.gameState) {
        case SharedState.INVALID_STATE:
            _statusText.text = "INVALID_STATE";
            break;

        case SharedState.WAITING_FOR_GAME_START:
            _statusText.text = "Waiting to start (players: " + SimonMain.model.getPlayerOids().length + "/" + Constants.MIN_PLAYERS_TO_START + ")";
            break;

        case SharedState.PLAYING_GAME:
            var curPlayerName :String = SimonMain.getPlayerName(_model.curState.curPlayerOid);
            _statusText.text = "Playing game. " + curPlayerName + "'s turn.";
            break;

        case SharedState.SHOWING_WINNER_ANIMATION:
            _statusText.text = SimonMain.getPlayerName(_model.curState.roundWinnerId) + " is the winner!";
            break;

        default:
            log.info("unrecognized gameState: " + _model.curState.gameState);
            break;
        }
    }

    protected function setupFirstGame () :void
    {
        log.info("setupFirstGame()");

        var nextSharedState :SharedState = this.createNextSharedState();
        nextSharedState.gameState = SharedState.WAITING_FOR_GAME_START;
        this.applyStateChanges();
    }

    protected function get canStartGame () :Boolean
    {
        return (SimonMain.model.getPlayerOids().length >= Constants.MIN_PLAYERS_TO_START);
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
        var nextSharedState :SharedState = this.createNextSharedState();

        // push a new round update out
        nextSharedState.gameState = SharedState.WAITING_FOR_GAME_START;
        nextSharedState.players = [];
        nextSharedState.pattern = [];
        nextSharedState.roundId += 1;
        nextSharedState.roundWinnerId = 0;

        this.applyStateChanges();
    }

    public function createNextSharedState () :SharedState
    {
        _expectedState = SimonMain.model.curState.clone();
        return _expectedState;
    }

    public function currentPlayerTurnSuccess (newNote :int) :void
    {
        _currentRainbow.destroy();
        _currentRainbow = null;

        var nextSharedState :SharedState = this.createNextSharedState();
        nextSharedState.pattern.push(newNote);

        nextSharedState.curPlayerIdx =
            (nextSharedState.curPlayerIdx < nextSharedState.players.length - 1 ? nextSharedState.curPlayerIdx + 1 : 0);

        this.applyStateChanges();
    }

    public function currentPlayerTurnFailure () :void
    {
        _currentRainbow.destroy();
        _currentRainbow = null;

        var nextSharedState :SharedState = this.createNextSharedState();

        // the current player is out of the round
        nextSharedState.players.splice(nextSharedState.curPlayerIdx, 1);

        // move to the next player
        if (nextSharedState.curPlayerIdx >= nextSharedState.players.length - 1) {
            nextSharedState.curPlayerIdx = 0;
        }

        this.applyStateChanges();
    }

    protected var _model :Model;
    protected var _expectedState :SharedState;
    protected var _expectedScores :Scoreboard;

    protected var _mainSprite :Sprite;
    protected var _scoreboardView :ScoreboardView;
    protected var _statusText :TextField;
    protected var _playerListView :PlayerListViewController;

    protected var _newRoundTimer :Timer;

    protected var _currentRainbow :RainbowController;

    protected var log :Log = Log.getLog(this);

}

}