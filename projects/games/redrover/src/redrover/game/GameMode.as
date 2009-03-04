package redrover.game {

import com.threerings.flash.DisplayUtil;
import com.threerings.util.Integer;
import com.threerings.util.KeyboardCodes;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.objects.SimpleTimer;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;

import redrover.*;
import redrover.data.*;
import redrover.game.robot.*;
import redrover.game.view.*;
import redrover.util.SpriteUtil;

public class GameMode extends AppMode
{
    public function GameMode (levelData :LevelData)
    {
        _levelData = levelData;
    }

    override protected function setup () :void
    {
        super.setup();

        GameCtx.init();
        GameCtx.gameMode = this;
        GameCtx.levelData = _levelData;

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

        GameCtx.sfxControls.pause(false);
        GameCtx.musicControls.pause(false);
        GameCtx.musicControls.volumeTo(1, 0.3);
    }

    override protected function exit () :void
    {
        GameCtx.sfxControls.pause(true);
        GameCtx.musicControls.volumeTo(0.2, 0.3);

        super.exit();
    }

    protected function setupAudio () :void
    {
        GameCtx.playAudio = true;

        GameCtx.sfxControls = new AudioControls(
            ClientCtx.audio.getControlsForSoundType(SoundResource.TYPE_SFX));
        GameCtx.musicControls = new AudioControls(
            ClientCtx.audio.getControlsForSoundType(SoundResource.TYPE_MUSIC));

        GameCtx.sfxControls.retain();
        GameCtx.musicControls.retain();

        GameCtx.sfxControls.pause(true);
        GameCtx.musicControls.pause(true);
    }

    protected function shutdownAudio () :void
    {
        GameCtx.sfxControls.stop(true);
        GameCtx.musicControls.stop(true);

        GameCtx.sfxControls.release();
        GameCtx.musicControls.release();
    }

    protected function setupLogicObjects () :void
    {
        for (var teamId :int = 0; teamId < Constants.NUM_TEAMS; ++teamId) {
            var board :Board =
                new Board(teamId, _levelData.cols, _levelData.rows, _levelData.terrain);
            _boards.push(board);
            addObject(board);

            var gemType :int;

            // create board objects
            for each (var obj :LevelObjData in _levelData.objects) {
                if (obj.objType >= Constants.OBJ_GEMSPAWNER__FIRST &&
                    obj.objType < Constants.OBJ_GEMSPAWNER__LIMIT) {
                    gemType = obj.objType - Constants.OBJ_GEMSPAWNER__FIRST;
                    addObject(new GemSpawner(board, gemType, obj.gridX, obj.gridY));
                }
            }

            // create gem distance maps
            for (gemType = 0; gemType < Constants.GEM__LIMIT; ++gemType) {
                _gemDistanceMaps.push(DataMap.createGemMap(board, gemType));
            }

            // create redemption distance map
            _redemptionDistanceMaps.push(DataMap.createGemRedemptionMap(board));
        }

        if (_levelData.endCondition == Constants.END_CONDITION_TIMED) {
            GameCtx.gameClock = new SimpleTimer(_levelData.endValue);
            addObject(GameCtx.gameClock);
        }
    }

    protected function setupViewObjects () :void
    {
        for (var teamId :int = 0; teamId < Constants.NUM_TEAMS; ++teamId) {
            var teamSprite :TeamSprite = new TeamSprite();
            _teamSprites.push(teamSprite);

            addObject(new BoardView(_boards[teamId]), teamSprite.boardLayer);
        }

        var cam :Camera = new Camera(CAM_SIZE);
        cam.x = CAM_LOC.x;
        cam.y = CAM_LOC.y;
        addObject(cam, _modeSprite);

        _overlayLayer = SpriteUtil.createSprite(true);
        _modeSprite.addChild(_overlayLayer);

        var hud :HUDView = new HUDView(HUD_SIZE);
        hud.x = HUD_LOC.x;
        hud.y = HUD_LOC.y;
        addObject(hud, _overlayLayer);

        addObject(new MusicPlayer());

        var notificationMgr :NotificationMgr = new NotificationMgr();
        addObject(notificationMgr);
        GameCtx.notificationMgr = notificationMgr;
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
            if (!GameCtx.isCellOccupied(0, startX, startY)) {
                break;
            }
        }

        PlayerFactory.initPlayer(
            new Player(0, "You", 0, startX, startY, GameCtx.nextPlayerColor(), true));

        // create ai players
        /*for (var ii :int = 0; ii < 8; ++ii) {
            var robotType :int = (ii % 2 ? PlayerFactory.DUMB_ROBOT : PlayerFactory.GEM_HOG_ROBOT);
            var teamId :int = (ii < 4 ? 0 : 1);
            PlayerFactory.createRobot(robotType, teamId);
        }*/
    }

    override public function update (dt :Number) :void
    {
        // update team sizes
        for (var ii :int = 0; ii < GameCtx.teamSizes.length; ++ii) {
            GameCtx.teamSizes[ii] = 0;
        }

        for each (var player :Player in GameCtx.players) {
            GameCtx.teamSizes[player.teamId] += 1;
        }

        dt = 1 / 30; // TODO - remove this!
        super.update(dt);

        handlePlayerCollisions();

        // update winners
        GameCtx.winningPlayers.sort(scoreSort);

        // handle game over
        if(checkGameOver()) {
            ClientCtx.mainLoop.pushMode(new GameOverMode());
        }

        // sort the board objects in the currently-visible TeamSprite
        var curTeamSprite :TeamSprite = _teamSprites[GameCtx.localPlayer.curBoardId];
        DisplayUtil.sortDisplayChildren(curTeamSprite.playerLayer, displayObjectYSort);
    }

    protected static function scoreSort (a :Player, b :Player) :int
    {
        // higher scores come before lower ones
        return Integer.compare(b.score, a.score);
    }

    protected function checkGameOver () :Boolean
    {
        switch (_levelData.endCondition) {
        case Constants.END_CONDITION_TIMED:
            _gameOver = GameCtx.gameClock.timeLeft <= 0;
            break;

        case Constants.END_CONDITION_POINTS:
            var hiScore :int;
            var winningPlayer :Player = GameCtx.winningPlayers[0];
            _gameOver = winningPlayer.score >= GameCtx.levelData.endValue;
            break;
        }

        return _gameOver;
    }

    protected function handlePlayerCollisions () :void
    {
        // collide the players
        for (var ii :int = 0; ii < GameCtx.players.length; ++ii) {
            var playerA :Player = GameCtx.players[ii];
            for (var jj :int = ii + 1; jj < GameCtx.players.length; ++jj) {
                var playerB :Player = GameCtx.players[jj];
                if (playerA.curBoardId == playerB.curBoardId &&
                    playerA.teamId != playerB.teamId &&
                    playerA.gridX == playerB.gridX &&
                    playerA.gridY == playerB.gridY &&
                    playerA.state != PlayerData.STATE_EATEN &&
                    playerA.state != PlayerData.STATE_EATEN) {

                    if (playerA.curBoardId == playerA.teamId && !playerB.isInvincible) {
                        playerA.eatPlayer(playerB);
                    } else if (playerB.curBoardId == playerB.teamId && !playerA.isInvincible) {
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
            GameCtx.localPlayer.beginSwitchBoards();
            break;

        case KeyboardCodes.LEFT:
            GameCtx.localPlayer.move(Constants.DIR_WEST);
            break;

        case KeyboardCodes.RIGHT:
            GameCtx.localPlayer.move(Constants.DIR_EAST);
            break;

        case KeyboardCodes.UP:
            GameCtx.localPlayer.move(Constants.DIR_NORTH);
            break;

        case KeyboardCodes.DOWN:
            GameCtx.localPlayer.move(Constants.DIR_SOUTH);
            break;

        case KeyboardCodes.ESCAPE:
            if (this.canPause) {
                ClientCtx.mainLoop.pushMode(new PauseMode());
            }
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
        var localPlayer :Player = GameCtx.localPlayer;

        switch (keyCode) {
        case KeyboardCodes.G:
            if (localPlayer.numGems < GameCtx.levelData.maxCarriedGems) {
                for (var gemType :int = 0; gemType < Constants.GEM__LIMIT; ++gemType) {
                    if (localPlayer.isGemValidForPickup(gemType)) {
                        localPlayer.addGem(gemType);
                        break;
                    }
                }
            }
            break;
        }
    }

    public function createGem (boardId :int, gridX :int, gridY :int, gemType :int) :void
    {
        var cell :BoardCell = getBoard(boardId).getCell(gridX, gridY);
        if (cell != null) {
            cell.addGem(gemType);
            addObject(new GemView(gemType, boardId, cell), getTeamSprite(boardId).objectLayer);
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

    public function get overlayLayer () :Sprite
    {
        return _overlayLayer;
    }

    protected function get canPause () :Boolean
    {
        return true;
    }

    protected var _levelData :LevelData;
    protected var _teamSprites :Array = []; // Array<Sprite>, one for each team
    protected var _overlayLayer :Sprite;
    protected var _boards :Array = []; // Array<Board>, one for each team
    protected var _gemDistanceMaps :Array = []; // Array<DataMap>, one for each board/gemType combination
    protected var _redemptionDistanceMaps :Array = []; // Array<DataMap>, one for each board
    protected var _gameOver :Boolean;

    protected static const CAM_LOC :Point = new Point(0, 0);
    protected static const CAM_SIZE :Point = new Point(700, 445);
    protected static const HUD_LOC :Point = new Point(0, 445);
    protected static const HUD_SIZE :Point = new Point(700, 55);
}

}
