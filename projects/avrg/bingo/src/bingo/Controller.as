package bingo {
    
import flash.display.Sprite;
import flash.events.Event;
    
public class Controller
{
    public function Controller (mainSprite :Sprite, model :Model)
    {
        _mainSprite = mainSprite;
        _model = model;
    }
    
    public function setup () :void
    {
        _model.addEventListener(BingoStateChangedEvent.NEW_ROUND, handleNewRound);
        _model.addEventListener(BingoStateChangedEvent.NEW_BALL, handleNewBall);
        _model.addEventListener(BingoStateChangedEvent.PLAYER_WON_ROUND, handlePlayerWonRound);
        
        _mainSprite.addEventListener(Event.ENTER_FRAME, update);
        
        this.createNewCard();
        
        // each client maintains the concept of an expected state,
        // so that it is prepared to take over as the
        // authoritative client at any time.
        _expectedState = null;
        
        if (null != _model.curState.ballInPlay) {
            this.createBallView();
        }
        
        this.update(null);
    }
    
    public function destroy () :void
    {
        _model.removeEventListener(BingoStateChangedEvent.NEW_ROUND, handleNewRound);
        _model.removeEventListener(BingoStateChangedEvent.NEW_BALL, handleNewBall);
        _model.removeEventListener(BingoStateChangedEvent.PLAYER_WON_ROUND, handlePlayerWonRound);
        
        _mainSprite.removeEventListener(Event.ENTER_FRAME, update);
    }
    
    public function update (e :Event) :void
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
        _model.createNewCard();
        
        _cardView = new BingoCardView(_model.card);
        _cardView.x = Constants.CARD_LOC.x;
        _cardView.y = Constants.CARD_LOC.y;
        
        _mainSprite.addChild(_cardView);
    }
    
    protected function createBallView () :void
    {
        _ballView = new BingoBallView(_model.curState.ballInPlay);
        _ballView.x = Constants.BALL_LOC.x;
        _ballView.y = Constants.BALL_LOC.y;
        
        _mainSprite.addChild(_ballView);
    }
    
    protected function handleNewRound (e :BingoStateChangedEvent) :void
    {
        if (null != _cardView) {
            _mainSprite.removeChild(_cardView);
        }
        
        this.createNewCard();
    }
    
    protected function handleNewBall (e :BingoStateChangedEvent) :void
    {
        if (null != _ballView) {
            _mainSprite.removeChild(_ballView);
        }
        
        this.createBallView();
    }
    
    protected function handlePlayerWonRound (e :BingoStateChangedEvent) :void
    {
        
    }
    
    protected var _expectedState :SharedState;
    
    protected var _mainSprite :Sprite;
    protected var _model :Model;
    protected var _cardView :BingoCardView;
    protected var _ballView :BingoBallView;

}

}