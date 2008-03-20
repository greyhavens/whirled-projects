package bingo {

import com.threerings.flash.DisablingButton;

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
        _newBallTimer = new Timer(Constants.NEW_BALL_DELAY_S * 1000, 1);
        _newBallTimer.addEventListener(TimerEvent.TIMER, handleNewBallTimerExpired);

        _newRoundTimer = new Timer(Constants.NEW_ROUND_DELAY_S * 1000, 1);
        _newRoundTimer.addEventListener(TimerEvent.TIMER, handleNewRoundTimerExpired);

        // state change events
        _model.addEventListener(SharedStateChangedEvent.NEW_ROUND, handleNewRound);
        _model.addEventListener(SharedStateChangedEvent.NEW_BALL, handleNewBall);
        _model.addEventListener(SharedStateChangedEvent.PLAYER_WON_ROUND, handlePlayerWonRound);
        _model.addEventListener(SharedStateChangedEvent.NEW_SCORES, handleNewScores);

        _mainSprite.addEventListener(Event.ENTER_FRAME, handleEnterFrame);

        // visuals
        _ballView = new BingoBallViewController();

        _bingoButton = new DisablingButton(
            new Resources.IMG_BINGOENABLED(),
            new Resources.IMG_BINGOOVER(),
            new Resources.IMG_BINGODOWN(),
            new Resources.IMG_BINGOENABLED(),
            new Resources.IMG_BINGODISABLED());

        _bingoButton.x = Constants.BINGO_BUTTON_LOC.x;
        _bingoButton.y = Constants.BINGO_BUTTON_LOC.y;
        _bingoButton.addEventListener(MouseEvent.CLICK, handleBingoButtonClick);
        _mainSprite.addChild(_bingoButton);

        var quitButton :DisablingButton = new DisablingButton(
            new Resources.IMG_QUITENABLED(),
            new Resources.IMG_QUITOVER(),
            new Resources.IMG_QUITENABLED(),
            new Resources.IMG_QUITDOWN());

        quitButton.x = Constants.QUIT_BUTTON_LOC.x;
        quitButton.y = Constants.QUIT_BUTTON_LOC.y;
        quitButton.addEventListener(MouseEvent.CLICK, handleQuitButtonClick);
        _mainSprite.addChild(quitButton);

        _winnerText = new TextField();
        _winnerText.autoSize = TextFieldAutoSize.LEFT;
        _winnerText.textColor = 0x0000FF;
        _winnerText.scaleX = 3;
        _winnerText.scaleY = 3;
        _winnerText.x = Constants.WINNER_TEXT_LOC.x;
        _winnerText.y = Constants.WINNER_TEXT_LOC.y;
        _mainSprite.addChild(_winnerText);

        _scoreboardView = new ScoreboardView(_model.curScores);
        _scoreboardView.x = Constants.SCOREBOARD_LOC.x;
        _scoreboardView.y = Constants.SCOREBOARD_LOC.y;
        _mainSprite.addChild(_scoreboardView);

        // each client maintains the concept of an expected state,
        // so that it is prepared to take over as the
        // authoritative client at any time.
        _expectedState = null;

        this.handleNewRound(null);
    }

    public function destroy () :void
    {
        _model.removeEventListener(SharedStateChangedEvent.NEW_ROUND, handleNewRound);
        _model.removeEventListener(SharedStateChangedEvent.NEW_BALL, handleNewBall);
        _model.removeEventListener(SharedStateChangedEvent.PLAYER_WON_ROUND, handlePlayerWonRound);

        _mainSprite.removeEventListener(Event.ENTER_FRAME, handleEnterFrame);

        _newBallTimer.removeEventListener(TimerEvent.TIMER, handleNewBallTimerExpired);
        _newRoundTimer.removeEventListener(TimerEvent.TIMER, handleNewRoundTimerExpired);

        _ballView.destroy();
    }

    protected function handleEnterFrame (e :Event) :void
    {
        this.update();
    }

    protected function handleBingoButtonClick (e :MouseEvent) :void
    {
        if (!_calledBingoThisRound && _model.card.isComplete) {
            _model.tryCallBingo();
            _calledBingoThisRound = true;
            this.updateBingoButton();
        }
    }

    protected function handleQuitButtonClick (e :MouseEvent) :void
    {
        if (BingoMain.control.isConnected()) {
            BingoMain.control.deactivateGame();
        }
    }

    protected function update () :void
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

    protected function createNewCard () :void
    {
        if (null != _cardView) {
            _mainSprite.removeChild(_cardView);
        }

        _model.createNewCard();

        _cardView = new BingoCardView(_model.card);
        _cardView.x = Constants.CARD_LOC.x;
        _cardView.y = Constants.CARD_LOC.y;

        _mainSprite.addChild(_cardView);
    }

    protected function handleNewRound (e :SharedStateChangedEvent) :void
    {
        this.createNewCard();

        // reset the expected state when the state changes
        _expectedState = null;

        // does a ball exist?
        if (null != _model.curState.ballInPlay) {
            this.startNewBallTimer();
        } else {
            // create a ball immediately
            this.createNewBall();
        }

        _calledBingoThisRound = false;
        this.updateBingoButton();

        _winnerText.text = "";

        this.stopNewRoundTimer();
    }

    protected function handleNewBall (e :SharedStateChangedEvent) :void
    {
        // reset the expected state when the state changes
        _expectedState = null;

        this.startNewBallTimer();
    }

    protected function handlePlayerWonRound (e :SharedStateChangedEvent) :void
    {
        // reset the expected state when the state changes
        _expectedState = null;

        this.stopNewBallTimer();
        this.startNewRoundTimer(); // a new round should start shortly

        this.updateBingoButton();

        var playerName :String = BingoMain.getPlayerName(_model.curState.roundWinnerId);

        _winnerText.text = playerName + " wins the round!";

        // update scores
        if (null == _expectedScores) {
            _expectedScores = _model.curScores.clone();
        }

        _expectedScores.incrementScore(playerName, new Date());

        // grant some flow to the winner
        if (_model.curState.roundWinnerId == BingoMain.ourPlayerId && BingoMain.control.isConnected()) {
            BingoMain.control.quests.completeQuest("dummyString", null, 1);
        }
    }

    protected function handleNewScores (e :SharedStateChangedEvent) :void
    {
        _expectedScores = null;
        _scoreboardView.scoreboard = _model.curScores;
    }

    protected function startNewBallTimer () :void
    {
        _newBallTimer.reset();
        _newBallTimer.start();
    }

    protected function stopNewBallTimer () :void
    {
        _newBallTimer.stop();
    }

    protected function handleNewBallTimerExpired (e :TimerEvent) :void
    {
        this.createNewBall();
    }

    protected function getNextBall () :String
    {
        var nextBall :String;
        do {
            nextBall = BingoItemManager.instance.getRandomTag();
        }
        while (nextBall == _model.curState.ballInPlay);

        return nextBall;
    }

    protected function createNewBall () :void
    {
        if (null == _expectedState) {
            _expectedState = _model.curState.clone();
        }

        // push a new ball update out
        _expectedState.ballInPlay = this.getNextBall();
        this.update();
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
        if (null == _expectedState) {
            _expectedState = _model.curState.clone();
        }

        // push a new round update out
        _expectedState.roundId += 1;
        _expectedState.roundWinnerId = 0;
        _expectedState.ballInPlay = this.getNextBall();
        this.update();
    }

    public function updateBingoButton () :void
    {
        _bingoButton.enabled = (!_calledBingoThisRound && _model.roundInPlay && _model.card.isComplete);
    }

    protected var _model :Model;
    protected var _expectedState :SharedState;
    protected var _expectedScores :Scoreboard;

    protected var _mainSprite :Sprite;
    protected var _cardView :BingoCardView;
    protected var _ballView :BingoBallViewController;
    protected var _scoreboardView :ScoreboardView;
    protected var _bingoButton :DisablingButton;
    protected var _winnerText :TextField;

    protected var _newBallTimer :Timer;
    protected var _newRoundTimer :Timer;

    protected var _calledBingoThisRound :Boolean;

}

}
