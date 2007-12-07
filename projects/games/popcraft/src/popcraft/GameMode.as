package popcraft {

import core.AppMode;
import core.MainLoop;
import com.threerings.util.Assert;

public class GameMode extends AppMode
{
    public static function get instance () :GameMode
    {
        var instance :GameMode = (MainLoop.instance.topMode as GameMode);

        Assert.isNotNull(instance);

        return instance;
    }

    public function GameMode ()
    {
    }

    // from core.AppMode
    override public function setup () :void
    {
        _playerData = new PlayerData();

        // add the top-level game objects

        _board = new PuzzleBoard(GameConstants.BOARD_COLS, GameConstants.BOARD_ROWS, GameConstants.BOARD_CELL_SIZE);
        this.addObject(_board, this);

        var resourceDisplay :ResourceDisplay = new ResourceDisplay();
        this.addObject(resourceDisplay, this);
        resourceDisplay.displayObject.y = _board.displayObject.height;
    }

    public function get playerData () :PlayerData
    {
        return _playerData;
    }

    protected var _board :PuzzleBoard;
    protected var _playerData :PlayerData;
}

}
