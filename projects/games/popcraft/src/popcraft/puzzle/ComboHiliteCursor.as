package popcraft.puzzle {
    
import com.whirled.contrib.core.*;

import flash.events.MouseEvent;

import popcraft.*;

public class ComboHiliteCursor extends SimObject
{
    public function ComboHiliteCursor (board :PuzzleBoard)
    {
        _board = board;
    }

    override protected function addedToDB () :void
    {
        _board.interactiveObject.addEventListener(MouseEvent.ROLL_OUT, rollOut, false, 0, true);
        _board.interactiveObject.addEventListener(MouseEvent.ROLL_OVER, rollOver, false, 0, true);
        _board.interactiveObject.addEventListener(MouseEvent.CLICK, mouseClick, false, 0, true);
    }

    override protected function destroyed () :void
    {
        _board.interactiveObject.removeEventListener(MouseEvent.ROLL_OUT, rollOut);
        _board.interactiveObject.removeEventListener(MouseEvent.ROLL_OVER, rollOver);
        _board.interactiveObject.removeEventListener(MouseEvent.CLICK, mouseClick);
    }
    
    protected function showHilites (show :Boolean) :void
    {
        _hilitedPieces.forEach(function (piece :Piece, index :int, array :Array) :void { piece.showHilite(show); });
    }
    
    protected function hilitesContainsPiece (x :int, y :int) :Boolean
    {
        var boardIndex :int = _board.coordsToIdx(x, y);
        
        return !(_hilitedPieces.every(isNotPiece));
        
        function isNotPiece (piece :Piece, index :int, array :Array) :Boolean
        {
            return (piece.boardIndex != boardIndex);
        }
    }

    protected function rollOut (evt :MouseEvent) :void
    {
        _over = false;
        
        this.showHilites(false);
        
        _mouseIndexX = -1;
        _mouseIndexY = -1;
        
        _hilitedPieces = [];
    }

    protected function rollOver (evt :MouseEvent) :void
    {
        _over = true;
    }
    
    override protected function update (dt :Number) :void
    {
        if (_over && !_board.resolvingClears) {
            this.repositionOnBoard(_board.displayObject.mouseX, _board.displayObject.mouseY);
        }
    }

    protected function mouseClick (evt :MouseEvent) :void
    {
        if (!_board.resolvingClears) {
            
            _board.clearPieceGroup(_mouseIndexX, _mouseIndexY);
            
            this.showHilites(false);
        
            _mouseIndexX = -1;
            _mouseIndexY = -1;
        
            _hilitedPieces = [];
        }
    }

    protected function repositionOnBoard (localX :Number, localY :Number) :void
    {
        // the mouseIndex is the piece directly under the mouse
        var newIndexX :int = (localX / Constants.PUZZLE_TILE_SIZE);
        var newIndexY :int = (localY / Constants.PUZZLE_TILE_SIZE);

        newIndexX = Math.max(newIndexX, 0);
        newIndexX = Math.min(newIndexX, Constants.PUZZLE_COLS - 1);

        newIndexY = Math.max(newIndexY, 0);
        newIndexY = Math.min(newIndexY, Constants.PUZZLE_ROWS - 1);
        
        if ((newIndexX != _mouseIndexX || newIndexY != _mouseIndexY) && !this.hilitesContainsPiece(newIndexX, newIndexY)) {
            
            // hide old hilites
            this.showHilites(false);
            
            _mouseIndexX = newIndexX;
            _mouseIndexY = newIndexY;
            
            // show new hilites
            _hilitedPieces = _board.findConnectedSimilarPieces(newIndexX, newIndexY);
            
            this.showHilites(true);
        }
    }
    
    protected var _board :PuzzleBoard;

    protected var _mouseIndexX :int = -1;
    protected var _mouseIndexY :int = -1;
    
    protected var _hilitedPieces :Array = [];
    
    protected var _over :Boolean;
    
}

}