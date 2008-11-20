package redrover.game {

import com.threerings.flash.DisplayUtil;
import com.threerings.util.KeyboardCodes;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.DisplayObject;

import redrover.*;
import redrover.data.*;
import redrover.game.view.*;

public class GameMode extends AppMode
{
    public function GameMode (levelData :LevelData)
    {
        _levelData = levelData;
    }

    override protected function setup () :void
    {
        super.setup();

        GameContext.init();
        GameContext.gameMode = this;

        setupAudio();

        setupLogicObjects();
        setupViewObjects();
    }

    override protected function destroy () :void
    {
        shutdownAudio();
        super.destroy();
    }

    override protected function enter () :void
    {
        super.enter();

        GameContext.sfxControls.pause(false);
        GameContext.musicControls.pause(false);
        GameContext.musicControls.volumeTo(1, 0.3);
    }

    override protected function exit () :void
    {
        if (GameContext.sfxControls != null) {
            GameContext.sfxControls.pause(true);
        }

        if (GameContext.musicControls != null) {
            GameContext.musicControls.volumeTo(0.2, 0.3);
        }

        super.exit();
    }

    protected function setupAudio () :void
    {
        GameContext.playAudio = true;

        GameContext.sfxControls = new AudioControls(
            AudioManager.instance.getControlsForSoundType(SoundResource.TYPE_SFX));
        GameContext.musicControls = new AudioControls(
            AudioManager.instance.getControlsForSoundType(SoundResource.TYPE_MUSIC));

        GameContext.sfxControls.retain();
        GameContext.musicControls.retain();

        GameContext.sfxControls.pause(true);
        GameContext.musicControls.pause(true);
    }

    protected function shutdownAudio () :void
    {
        GameContext.sfxControls.stop(true);
        GameContext.musicControls.stop(true);

        GameContext.sfxControls.release();
        GameContext.musicControls.release();
    }

    protected function setupLogicObjects () :void
    {
        for (var teamId :int = 0; teamId < Constants.NUM_TEAMS; ++teamId) {
            var board :Board = new Board(teamId, Constants.BOARD_COLS, Constants.BOARD_ROWS,
                                         _levelData.terrain);
            _boards.push(board);
            addObject(board);

            addObject(new GemTimer(teamId));
        }

        // create players
        var playerColors :Array = Constants.PLAYER_COLORS.slice();
        Rand.shuffleArray(playerColors, Rand.STREAM_GAME);
        var gridX :int = Rand.nextIntRange(0, Constants.BOARD_COLS, Rand.STREAM_GAME);
        var gridY :int = Rand.nextIntRange(0, Constants.BOARD_ROWS, Rand.STREAM_GAME);
        var player :Player = new Player(0, 0, gridX, gridY, playerColors.pop());
        GameContext.players.push(player);
        GameContext.localPlayerIndex = 0;
        addObject(player);
    }

    protected function setupViewObjects () :void
    {
        for (var teamId :int = 0; teamId < Constants.NUM_TEAMS; ++teamId) {
            var teamSprite :TeamSprite = new TeamSprite();
            _teamSprites.push(teamSprite);

            addObject(new BoardView(_boards[teamId]), teamSprite.boardLayer);
        }

        for each (var player :Player in GameContext.players) {
            addObject(new PlayerView(player));
        }

        addObject(new Camera(Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y), _modeSprite);
        addObject(new HUDView(), _modeSprite);
        addObject(new MusicPlayer());
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);

        // sort the board objects in the currently-visible TeamSprite
        var curTeamSprite :TeamSprite = _teamSprites[GameContext.localPlayer.curBoardId];
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
        case KeyboardCodes.SPACE:
            GameContext.localPlayer.beginSwitchBoards();
            break;

        case KeyboardCodes.LEFT:
            GameContext.localPlayer.move(Constants.DIR_WEST);
            break;

        case KeyboardCodes.RIGHT:
            GameContext.localPlayer.move(Constants.DIR_EAST);
            break;

        case KeyboardCodes.UP:
            GameContext.localPlayer.move(Constants.DIR_NORTH);
            break;

        case KeyboardCodes.DOWN:
            GameContext.localPlayer.move(Constants.DIR_SOUTH);
            break;
        }
    }

    public function createGem (boardId :int) :void
    {
        var board :Board = getBoard(boardId);
        if (board.countGems() >= Constants.MAX_BOARD_GEMS) {
            return;
        }

        // find a random unoccupied BoardCell
        var cell :BoardCell;
        for (var ii :int = 0; ii < 20; ++ii) {
            var x :int = Rand.nextIntRange(0, board.cols, Rand.STREAM_GAME);
            var y :int = Rand.nextIntRange(0, board.rows, Rand.STREAM_GAME);
            var thisCell :BoardCell = board.getCell(x, y);
            if (!thisCell.hasGem && GameContext.getPlayerAt(boardId, x, y) == null) {
                cell = thisCell;
                break;
            }
        }

        if (cell != null) {
            var gemType :int = Rand.nextIntRange(0, Constants.GEM__LIMIT, Rand.STREAM_GAME)
            cell.addGem(gemType);
            addObject(new GemView(gemType, cell), getTeamSprite(boardId).objectLayer);
        }
    }

    public function getBoard (boardId :int) :Board
    {
        return _boards[boardId];
    }

    public function getTeamSprite (teamId :int) :TeamSprite
    {
        return _teamSprites[teamId];
    }

    protected var _levelData :LevelData;
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
