package redrover.game {

import com.whirled.contrib.simplegame.audio.*;

import redrover.*;

public class GameContext
{
    public static var gameMode :GameMode;

    public static var players :Array = [];
    public static var localPlayerIndex :int = -1;

    public static var playAudio :Boolean;
    public static var musicControls :AudioControls;
    public static var sfxControls :AudioControls;

    public static function get localPlayer () :Player
    {
        return players[GameContext.localPlayerIndex];
    }

    public static function init () :void
    {
        gameMode = null;
        players = [];
        localPlayerIndex = -1;
        playAudio = false;
        musicControls = null;
        sfxControls = null;
    }

    public static function getCellAt (boardId :int, gridX :int, gridY :int) :BoardCell
    {
        return gameMode.getBoard(boardId).getCell(gridX, gridY);
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
