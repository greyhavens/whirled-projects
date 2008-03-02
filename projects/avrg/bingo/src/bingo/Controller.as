package bingo {
    
import com.threerings.flash.DisablingButton;

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
        
        _newBallTimer = new Timer(Constants.NEW_BALL_DELAY_S * 1000, 1);
        _newBallTimer.addEventListener(TimerEvent.TIMER, handleNewBallTimerExpired);
        
        _newRoundTimer = new Timer(Constants.NEW_ROUND_DELAY_S * 1000, 1);
        _newRoundTimer.addEventListener(TimerEvent.TIMER, handleNewRoundTimerExpired);
    }
    
    public function setup () :void
    {
        _model.addEventListener(SharedStateChangedEvent.NEW_ROUND, handleNewRound);
        _model.addEventListener(SharedStateChangedEvent.NEW_BALL, handleNewBall);
        _model.addEventListener(SharedStateChangedEvent.PLAYER_WON_ROUND, handlePlayerWonRound);
        
        _mainSprite.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
        
        _bingoButton = createButton(200, 50, "Bingo!");
        _bingoButton.x = Constants.BINGO_BUTTON_LOC.x;
        _bingoButton.y = Constants.BINGO_BUTTON_LOC.y;
        _bingoButton.addEventListener(MouseEvent.CLICK, handleBingoButtonClick);
        _mainSprite.addChild(_bingoButton);
        
        var quitButton :DisablingButton = createButton(100, 25, "Quit");
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
        
        
        // each client maintains the concept of an expected state,
        // so that it is prepared to take over as the
        // authoritative client at any time.
        _expectedState = null;
        
        this.handleNewRound(null);
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
    
    public function destroy () :void
    {
        _model.removeEventListener(SharedStateChangedEvent.NEW_ROUND, handleNewRound);
        _model.removeEventListener(SharedStateChangedEvent.NEW_BALL, handleNewBall);
        _model.removeEventListener(SharedStateChangedEvent.PLAYER_WON_ROUND, handlePlayerWonRound);
        
        _mainSprite.removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
        
        _newBallTimer.removeEventListener(TimerEvent.TIMER, handleNewBallTimerExpired);
        _newRoundTimer.removeEventListener(TimerEvent.TIMER, handleNewRoundTimerExpired);
    }
    
    protected function handleEnterFrame (e :Event) :void
    {
        this.update();
    }
    
    protected function handleBingoButtonClick (e :MouseEvent) :void
    {
        if (!_calledBingoThisRound && _model.card.isComplete) {
            _model.callBingo();
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
    
    protected function createBallView () :void
    {
        if (null != _ballView) {
            _mainSprite.removeChild(_ballView);
        }
        
        _ballView = new BingoBallView(_model.curState.ballInPlay);
        _ballView.x = Constants.BALL_LOC.x;
        _ballView.y = Constants.BALL_LOC.y;
        
        _mainSprite.addChild(_ballView);
    }
    
    protected function handleNewRound (e :SharedStateChangedEvent) :void
    {
        this.createNewCard();
        
        // reset the expected state when the state changes
        _expectedState = null;
        
        // does a ball exist?
        if (null != _model.curState.ballInPlay) {
            this.createBallView();
            this.startNewBallTimer();
        } else {
            // create a ball immediately
            this.createNewBall();
        }
        
        _calledBingoThisRound = false;
        _roundIsOver = false;
        this.updateBingoButton();
        
        _winnerText.text = "";
        
        this.stopNewRoundTimer();
    }
    
    protected function handleNewBall (e :SharedStateChangedEvent) :void
    {
        this.createBallView();
        
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
        
        _roundIsOver = true;
        this.updateBingoButton();
        
        _winnerText.text = BingoMain.getPlayerName(_model.curState.roundWinningPlayerId) + " wins the round!";
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
        _expectedState.roundWinningPlayerId = 0;
        _expectedState.ballInPlay = this.getNextBall();
        this.update();
    }
    
    public function updateBingoButton () :void
    {
        _bingoButton.enabled = (!_calledBingoThisRound && !_roundIsOver && _model.card.isComplete);
    }
    
    protected var _model :Model;
    protected var _expectedState :SharedState;
    
    protected var _mainSprite :Sprite;
    protected var _cardView :BingoCardView;
    protected var _ballView :BingoBallView;
    protected var _bingoButton :DisablingButton;
    protected var _winnerText :TextField;
    
    protected var _newBallTimer :Timer;
    protected var _newRoundTimer :Timer;
    
    protected var _calledBingoThisRound :Boolean;
    protected var _roundIsOver :Boolean;

}

}