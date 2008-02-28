package bingo {
    
import flash.display.Sprite;
    
public class BingoController
{
    public function BingoController (mainSprite :Sprite, model :BingoModel)
    {
        _mainSprite = mainSprite;
        _model = model;
    }
    
    public function setup () :void
    {
        _model.addEventListener(BingoStateChangedEvent.NEW_ROUND, handleNewRound);
        _model.addEventListener(BingoStateChangedEvent.NEW_BALL, handleNewBall);
        
        if (null != _model.card) {
            this.createCardView()
        }
        
        if (null != _model.bingoBallInPlay) {
            this.createBallView();
        }
    }
    
    public function destroy () :void
    {
        _model.removeEventListener(BingoStateChangedEvent.NEW_ROUND, handleNewRound);
        _model.removeEventListener(BingoStateChangedEvent.NEW_BALL, handleNewBall);
    }
    
    protected function createCardView () :void
    {
        _cardView = new BingoCardView(_model.card);
        _cardView.x = Constants.CARD_LOC.x;
        _cardView.y = Constants.CARD_LOC.y;
        
        _mainSprite.addChild(_cardView);
    }
    
    protected function createBallView () :void
    {
        _ballView = new BingoBallView(_model.bingoBallInPlay);
        _ballView.x = Constants.BALL_LOC.x;
        _ballView.y = Constants.BALL_LOC.y;
        
        _mainSprite.addChild(_ballView);
    }
    
    protected function handleNewRound (e :BingoStateChangedEvent) :void
    {
        if (null != _cardView) {
            _mainSprite.removeChild(_cardView);
        }
        
        this.createCardView();
    }
    
    protected function handleNewBall (e :BingoStateChangedEvent) :void
    {
        if (null != _ballView) {
            _mainSprite.removeChild(_ballView);
        }
        
        this.createBallView();
    }
    
    protected var _mainSprite :Sprite;
    protected var _model :BingoModel;
    protected var _cardView :BingoCardView;
    protected var _ballView :BingoBallView;

}

}