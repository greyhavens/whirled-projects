package popcraft {

import core.AppMode;

public class GameMode extends AppMode
{
    public function GameMode ()
    {
    }

    // from core.AppMode
    override public function setup () :void
    {
        _board = new PuzzleBoard(GameConstants.BOARD_COLS, GameConstants.BOARD_ROWS, GameConstants.BOARD_CELL_SIZE);
        this.addObject(_board, this);
    }

    protected var _board :PuzzleBoard;
}

}
