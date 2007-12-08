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

        var resourceDisplay :ResourceDisplay = new ResourceDisplay();
        resourceDisplay.displayObject.x = GameConstants.RESOURCE_DISPLAY_LOC.x;
        resourceDisplay.displayObject.y = GameConstants.RESOURCE_DISPLAY_LOC.y;

        this.addObject(resourceDisplay, this);

        _puzzleBoard = new PuzzleBoard(
            GameConstants.PUZZLE_COLS,
            GameConstants.PUZZLE_ROWS,
            GameConstants.PUZZLE_TILE_SIZE);

        _puzzleBoard.displayObject.x = GameConstants.PUZZLE_LOC.x;
        _puzzleBoard.displayObject.y = GameConstants.PUZZLE_LOC.y;

        this.addObject(_puzzleBoard, this);

        _battleBoard = new BattleBoard(
            GameConstants.BATTLE_COLS,
            GameConstants.BATTLE_ROWS,
            GameConstants.BATTLE_TILE_SIZE);

        _battleBoard.displayObject.x = GameConstants.BATTLE_LOC.x;
        _battleBoard.displayObject.y = GameConstants.BATTLE_LOC.y;

        this.addObject(_battleBoard, this);
    }

    public function get playerData () :PlayerData
    {
        return _playerData;
    }

    protected var _puzzleBoard :PuzzleBoard;
    protected var _battleBoard :BattleBoard;
    protected var _playerData :PlayerData;
}

}
