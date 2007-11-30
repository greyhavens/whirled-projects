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
        _board = new PuzzleBoard(5, 5);
        this.addObject(_board);
    }

    protected var _board :PuzzleBoard;
}

}
