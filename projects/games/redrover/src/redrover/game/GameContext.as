package redrover.game {

import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.util.Rand;

import redrover.*;
import redrover.data.LevelData;

public class GameContext
{
    public static var gameMode :GameMode;
    public static var levelData :LevelData;

    public static var players :Array = [];
    public static var localPlayerIndex :int = -1;
    public static var playerColors :Array;
    public static var maleRobotNames :Array;
    public static var femaleRobotNames :Array;

    public static var playAudio :Boolean;
    public static var musicControls :AudioControls;
    public static var sfxControls :AudioControls;

    public static function init () :void
    {
        gameMode = null;
        levelData = null;
        players = [];
        localPlayerIndex = -1;
        playerColors = null;
        maleRobotNames = null;
        femaleRobotNames = null;
        playAudio = false;
        musicControls = null;
        sfxControls = null;
    }

    public static function nextPlayerColor () :uint
    {
        if (playerColors == null || playerColors.length == 0) {
            playerColors = levelData.playerColors.slice();
            Rand.shuffleArray(playerColors, Rand.STREAM_GAME);
        }

        return playerColors.pop();
    }

    public static function nextMaleRobotName () :String
    {
        if (maleRobotNames == null || maleRobotNames.length == 0) {
            maleRobotNames = levelData.maleRobotNames.slice();
            Rand.shuffleArray(maleRobotNames, Rand.STREAM_GAME);
        }

        return maleRobotNames.pop();
    }

    public static function nextFemaleRobotName () :String
    {
        if (femaleRobotNames == null || femaleRobotNames.length == 0) {
            femaleRobotNames = levelData.femaleRobotNames.slice();
            Rand.shuffleArray(femaleRobotNames, Rand.STREAM_GAME);
        }

        return femaleRobotNames.pop();
    }

    public static function nextPlayerIndex () :int
    {
        return players.length;
    }

    public static function getTeamSize (teamId :int) :int
    {
        var size :int = 0;
        for each (var player :Player in players) {
            if (player.teamId == teamId) {
                size++;
            }
        }

        return size;
    }

    public static function get localPlayer () :Player
    {
        return players[GameContext.localPlayerIndex];
    }

    public static function getBoard (boardId :int) :Board
    {
        return gameMode.getBoard(boardId);
    }

    public static function getCellAt (boardId :int, gridX :int, gridY :int) :BoardCell
    {
        return gameMode.getBoard(boardId).getCell(gridX, gridY);
    }

    public static function isCellOccupied (boardId :int, gridX :int, gridY :int) :Boolean
    {
        if (getCellAt(boardId, gridX, gridY).isObstacle) {
            return true;
        }

       for each (var player :Player in players) {
            if (player.curBoardId == boardId && player.gridX == gridX && player.gridY == gridY) {
                return true;
            }
        }

        return false;
    }

    public static function getPlayerAt (boardId :int, gridX :int, gridY :int) :Player
    {
        for each (var player :Player in players) {
            if (player.curBoardId == boardId && player.gridX == gridX && player.gridY == gridY) {
                return player;
            }
        }

        return null;
    }

    public static function playGameSound (soundName :String) :AudioChannel
    {
        return (playAudio ? AudioManager.instance.playSoundNamed(soundName, sfxControls) :
            new AudioChannel());
    }

    public static function playGameMusic (musicName :String) :AudioChannel
    {
        return (playAudio ?
            AudioManager.instance.playSoundNamed(musicName,
                                                 musicControls,
                                                 AudioManager.LOOP_FOREVER) :
            new AudioChannel());
    }
}

}
