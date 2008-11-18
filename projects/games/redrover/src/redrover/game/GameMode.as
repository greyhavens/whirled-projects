package redrover.game {

import com.threerings.flash.DisplayUtil;
import com.threerings.flash.Vector2;
import com.threerings.util.KeyboardCodes;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.tasks.FunctionTask;
import com.whirled.contrib.simplegame.tasks.RepeatingTask;
import com.whirled.contrib.simplegame.tasks.VariableTimedTask;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.DisplayObject;

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
        var playerColors :Array = Constants.PLAYER_COLORS.slice();
        Rand.shuffleArray(playerColors, Rand.STREAM_GAME);
        var player :Player = new Player(0, 0, playerColors.pop());
        GameContext.players.push(player);
        GameContext.localPlayerIndex = 0;
        addObject(player);
    }

    protected function createViewObjects () :void
    {
        for (var teamId :int = 0; teamId < Constants.NUM_TEAMS; ++teamId) {
            var teamSprite :TeamSprite = new TeamSprite();
            _teamSprites.push(teamSprite);

            addObject(new BoardView(_boards[teamId]), teamSprite.boardLayer);
        }

        for each (var player :Player in GameContext.players) {
            addObject(new PlayerView(player));
        }

        addObject(new Camera(), _modeSprite);
        addObject(new HUDView(), _modeSprite);
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);

        // sort the board objects in the currently-visible TeamSprite
        var curTeamSprite :TeamSprite = _teamSprites[GameContext.localPlayer.curBoardTeamId];
        DisplayUtil.sortDisplayChildren(curTeamSprite.objectLayer, displayObjectYSort);
    }

    protected static function displayObjectYSort (a :DisplayObject, b :DisplayObject) :int
    {
        var ay :Number = a.y;
        var by :Number = b.y;

        if (ay < by) {
            return -1;
        } else if (ay > by) {
            return 1;
        } else {
            return 0;
        }
    }

    override public function onKeyDown (keyCode :uint) :void
    {
        switch (keyCode) {
        case KeyboardCodes.LEFT:
            GameContext.localPlayer.moveDirection = new Vector2(-1, 0);
            break;

        case KeyboardCodes.RIGHT:
            GameContext.localPlayer.moveDirection = new Vector2(1, 0);
            break;

        case KeyboardCodes.UP:
            GameContext.localPlayer.moveDirection = new Vector2(0, -1);
            break;

        case KeyboardCodes.DOWN:
            GameContext.localPlayer.moveDirection = new Vector2(0, 1);
            break;
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
        addObject(new GemView(teamId, cell), getTeamSprite(teamId).objectLayer);
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
