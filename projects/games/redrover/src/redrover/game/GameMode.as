package redrover.game {

import com.threerings.util.KeyboardCodes;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.tasks.FunctionTask;
import com.whirled.contrib.simplegame.tasks.RepeatingTask;
import com.whirled.contrib.simplegame.tasks.VariableTimedTask;
import com.whirled.contrib.simplegame.util.Rand;

import redrover.*;
import redrover.game.view.*;

public class GameMode extends AppMode
{
    override protected function setup () :void
    {
        super.setup();

        GameContext.init();
        GameContext.gameMode = this;

        createLogicObjects();
        createViewObjects();
    }

    protected function createLogicObjects () :void
    {
        for (var teamId :int = 0; teamId < Constants.NUM_TEAMS; ++teamId) {
            var board :Board = new Board(teamId, Constants.BOARD_COLS, Constants.BOARD_ROWS);
            _boards.push(board);
            addObject(board);

            addObject(new GemTimer(teamId));
        }

        // create players
        var player :Player = new Player(0, 0);
        GameContext.players.push(player);
        GameContext.localPlayerIndex = 0;
    }

    protected function createViewObjects () :void
    {
        for (var teamId :int = 0; teamId < Constants.NUM_TEAMS; ++teamId) {
            var teamSprite :TeamSprite = new TeamSprite();
            _teamSprites.push(teamSprite);

            var boardView :BoardView = new BoardView(_boards[teamId]);
            addObject(boardView, teamSprite.boardLayer);
        }

        addObject(new Camera(), _modeSprite);
    }

    override public function onKeyDown (keyCode :uint) :void
    {
        switch (keyCode) {
        case KeyboardCodes.SPACE:

        }
    }

    public function createGem (teamId :int) :void
    {
        var board :Board = getBoard(teamId);
        if (board.countGems() >= Constants.MAX_BOARD_GEMS) {
            return;
        }

        // find a random unoccupied BoardCell
        var cell :BoardCell;
        for (;;) {
            var x :int = Rand.nextIntRange(0, board.cols, Rand.STREAM_GAME);
            var y :int = Rand.nextIntRange(0, board.rows, Rand.STREAM_GAME);
            cell = board.getCell(x, y);
            if (!cell.hasGem) {
                break;
            }
        }

        cell.hasGem = true;
        addObject(new GemView(teamId, cell), getTeamSprite(teamId).gemLayer);
    }

    public function getBoard (teamId :int) :Board
    {
        return _boards[teamId];
    }

    public function getTeamSprite (teamId :int) :TeamSprite
    {
        return _teamSprites[teamId];
    }

    protected var _teamSprites :Array = []; // Array<Sprite>, one for each team
    protected var _boards :Array = []; // Array<Board>, one for each team
}

}

import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.tasks.RepeatingTask;
import com.whirled.contrib.simplegame.tasks.VariableTimedTask;
import com.whirled.contrib.simplegame.util.Rand;

import redrover.*;
import redrover.game.*;
import com.whirled.contrib.simplegame.tasks.FunctionTask;

class GemTimer extends SimObject
{
    public function GemTimer (teamId :int)
    {
        addTask(new RepeatingTask(
            new VariableTimedTask(Constants.GEM_SPAWN_TIME.min,
                                  Constants.GEM_SPAWN_TIME.max,
                                  Rand.STREAM_GAME),
            new FunctionTask(
                function () :void {
                    GameContext.gameMode.createGem(teamId);
                })));

    }
}
