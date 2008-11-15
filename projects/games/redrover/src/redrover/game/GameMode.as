package redrover.game {

import com.whirled.contrib.simplegame.AppMode;

import redrover.*;
import redrover.game.view.*;

public class GameMode extends AppMode
{
    override protected function setup () :void
    {
        super.setup();

        for (var teamId :int = 0; teamId < 2; ++teamId) {
            _boards.push(new Board(Constants.BOARD_COLS, Constants.BOARD_ROWS));
        }
    }

    public function getBoard (teamId :int) :Board
    {
        return _boards[teamId];
    }

    protected var _boards :Array = []; // Array<Array<BoardCell>>, one for each team

}

}
