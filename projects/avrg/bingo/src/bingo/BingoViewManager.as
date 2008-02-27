package bingo {
    
import flash.display.Sprite;
    
public class BingoViewManager
{
    public function BingoViewManager (mainSprite :Sprite, model :BingoModel)
    {
        _mainSprite = mainSprite;
        _model = model;
        
        _model.addEventListener(BingoStateChangedEvent.NEW_ROUND, handleNewRound);
    }
    
    public function destroy () :void
    {
        _model.removeEventListener(BingoStateChangedEvent.NEW_ROUND, handleNewRound);
    }
    
    protected function handleNewRound (e :BingoStateChangedEvent) :void
    {
        if (null != _cardView) {
            _mainSprite.removeChild(_cardView);
        }
        
        _cardView = new BingoCardView(_model.card);
    }
    
    protected var _mainSprite :Sprite;
    protected var _model :BingoModel;
    protected var _cardView :BingoCardView;

}

}