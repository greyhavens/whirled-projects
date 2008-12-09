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
import redrover.game.robot.*;
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
        GameContext.levelData = _levelData;

        setupAudio();

        setupLogicObjects();
        setupViewObjects();
        setupPlayers();
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
            var board :Board =
                new Board(teamId, _levelData.cols, _levelData.rows, _levelData.terrain);
            _boards.push(board);
            addObject(board);

            // create board objects
            for each (var obj :LevelObjData in _levelData.objects) {
                switch (obj.objType) {
                case Constants.OBJ_GREENSPAWNER:
                    addObject(new GemSpawner(board, Constants.GEM_GREEN, obj.gridX, obj.gridY));
                    break;

                case Constants.OBJ_PURPLESPAWNER:
                    addObject(new GemSpawner(board, Constants.GEM_PURPLE, obj.gridX, obj.gridY));
                    break;
                }
            }

            // create gem distance maps
            for (var gemType :int = 0; gemType < Constants.GEM__LIMIT; ++gemType) {
                _gemDistanceMaps.push(DataMap.createGemMap(board, gemType));
            }

            // create redemption distance map
            _redemptionDistanceMaps.push(DataMap.createGemRedemptionMap(board));
        }
    }

    protected function setupViewObjects () :void
    {
        for (var teamId :int = 0; teamId < Constants.NUM_TEAMS; ++teamId) {
            var teamSprite :TeamSprite = new TeamSprite();
            _teamSprites.push(teamSprite);

            addObject(new BoardView(_boards[teamId]), teamSprite.boardLayer);
        }

        addObject(new Camera(Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y), _modeSprite);
        addObject(new HUDView(), _modeSprite);
        addObject(new MusicPlayer());

        var switchBoardsButton :SwitchBoardsButton = new SwitchBoardsButton();
        switchBoardsButton.x = Constants.SCREEN_SIZE.x * 0.5;
        switchBoardsButton.y = Constants.SCREEN_SIZE.y - 25;
        addObject(switchBoardsButton, _modeSprite);
    }

    protected function setupPlayers () :void
    {
        // create local player
        var board :Board = getBoard(0);
        var startX :int;
        var startY :int;
        for (;;) {
            startX = Rand.nextIntRange(0, board.cols, Rand.STREAM_GAME);
            startY = Rand.nextIntRange(0, board.rows, Rand.STREAM_GAME);
            if (!GameContext.isCellOccupied(0, startX, startY)) {
                break;
            }
        }

        PlayerFactory.initPlayer(new Player(0, 0, startX, startY, GameContext.nextPlayerColor()));
        GameContext.localPlayerIndex = 0;

        // create ai players
        //PlayerFactory.createRobot(PlayerFactory.DUMB_ROBOT, 1);
        PlayerFactory.createRobot(PlayerFactory.GEM_HOG_ROBOT, 1);
    }

    override public function update (dt :Number) :void
    {
        dt = 1 / 30; // TODO - remove this!
        super.update(dt);

        handlePlayerCollisions();

        // sort the board objects in the currently-visible TeamSprite
        var curTeamSprite :TeamSprite = _teamSprites[GameContext.localPlayer.curBoardId];
        DisplayUtil.sortDisplayChildren(curTeamSprite.objectLayer, displayObjectYSort);
    }

    protected function handlePlayerCollisions () :void
    {
        // collide the players
        for (var ii :int = 0; ii < GameContext.players.length; ++ii) {
            var playerA :Player = GameContext.players[ii];
            for (var jj :int = ii + 1; jj < GameContext.players.length; ++jj) {
                var playerB :Player = GameContext.players[jj];
                if (playerA.curBoardId == playerB.curBoardId &&
                    playerA.teamId != playerB.teamId &&
                    playerA.gridX == playerB.gridX &&
                    playerA.gridY == playerB.gridY &&
                    playerA.state != Player.STATE_EATEN &&
                    playerA.state != Player.STATE_EATEN) {

                    if (playerA.curBoardId == playerA.teamId) {
                        playerA.eatPlayer(playerB);
                    } else {
                        playerB.eatPlayer(playerA);
                    }
                }
            }
        }
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

        default:
            if (Constants.DEBUG_ALLOW_CHEATS) {
                handleCheat(keyCode);
            }
            break;
        }
    }

    protected function handleCheat (keyCode :uint) :void
    {
        var localPlayer :Player = GameContext.localPlayer;

        switch (keyCode) {
        case KeyboardCodes.G:
            if (localPlayer.numGems < GameContext.levelData.maxCarriedGems) {
                var lastGemType :int =
                    (localPlayer.numGems > 0 ? localPlayer.gems[localPlayer.gems.length - 1] : 0);
                var nextGemType :int = (lastGemType == Constants.GEM_PURPLE ?
                                        Constants.GEM_GREEN : Constants.GEM_PURPLE);
                localPlayer.addGem(nextGemType);
            }
            break;
        }
    }

    public function createGem (boardId :int, gridX :int, gridY :int, gemType :int) :void
    {
        var cell :BoardCell = getBoard(boardId).getCell(gridX, gridY);
        if (cell != null) {
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

    public function getGemMap (boardId :int, gemType :int) :DataMap
    {
        return _gemDistanceMaps[(Constants.GEM__LIMIT * boardId) + gemType];
    }

    public function getRedemptionMap (boardId :int) :DataMap
    {
        return _redemptionDistanceMaps[boardId];
    }

    protected var _levelData :LevelData;
    protected var _teamSprites :Array = []; // Array<Sprite>, one for each team
    protected var _boards :Array = []; // Array<Board>, one for each team
    protected var _gemDistanceMaps :Array = []; // Array<DataMap>, one for each board/gemType combination
    protected var _redemptionDistanceMaps :Array = []; // Array<DataMap>, one for each board
}

}
