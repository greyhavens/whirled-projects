package bingo {
    
import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;
    
public class Controller
{
    public function Controller (mainSprite :Sprite, model :Model)
    {
        _mainSprite = mainSprite;
        _model = model;
        
        _newBallTimer = new Timer(Constants.SECONDS_BETWEEN_BINGO_BALLS * 1000, 1);
        _newBallTimer.addEventListener(TimerEvent.TIMER, handleNewBallTimerExpired);
    }
    
    public function setup () :void
    {
        _model.addEventListener(BingoStateChangedEvent.NEW_ROUND, handleNewRound);
        _model.addEventListener(BingoStateChangedEvent.NEW_BALL, handleNewBall);
        _model.addEventListener(BingoStateChangedEvent.PLAYER_WON_ROUND, handlePlayerWonRound);
        
        _mainSprite.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
        
        // each client maintains the concept of an expected state,
        // so that it is prepared to take over as the
        // authoritative client at any time.
        _expectedState = null;
        
        this.handleNewRound(null);
    }
    
    public function destroy () :void
    {
        _model.removeEventListener(BingoStateChangedEvent.NEW_ROUND, handleNewRound);
        _model.removeEventListener(BingoStateChangedEvent.NEW_BALL, handleNewBall);
        _model.removeEventListener(BingoStateChangedEvent.PLAYER_WON_ROUND, handlePlayerWonRound);
        
        _mainSprite.removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
    }
    
    protected function handleEnterFrame (e :Event) :void
    {
        this.update();
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
    
    protected function handleNewRound (e :BingoStateChangedEvent) :void
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
    }
    
    protected function handleNewBall (e :BingoStateChangedEvent) :void
    {
        this.createBallView();
        
        // reset the expected state when the state changes
        _expectedState = null;
        
        this.startNewBallTimer();
    }
    
    protected function handlePlayerWonRound (e :BingoStateChangedEvent) :void
    {
        // @TODO - kick off some animation
        
        // reset the expected state when the state changes
        _expectedState = null;
        
        this.stopNewBallTimer();
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
    
    protected function createNewBall () :void
    {
        if (null == _expectedState) {
            _expectedState = _model.curState.clone();
        }
        
        _expectedState.ballInPlay = BingoItemManager.instance.getRandomTag();
        this.update();
    }
    
    protected var _expectedState :SharedState;
    
    protected var _mainSprite :Sprite;
    protected var _model :Model;
    protected var _cardView :BingoCardView;
    protected var _ballView :BingoBallView;
    
    protected var _newBallTimer :Timer;

}

}