package popcraft {

import com.threerings.flash.Vector2;
import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.audio.AudioChannel;
import com.whirled.contrib.simplegame.audio.AudioControls;
import com.whirled.contrib.simplegame.audio.AudioManager;

import popcraft.battle.*;
import popcraft.battle.geom.ForceParticleContainer;
import popcraft.battle.view.*;
import popcraft.data.*;
import popcraft.puzzle.*;
import popcraft.ui.DashboardView;

public class GameContext
{
    public static const GAME_TYPE_MULTIPLAYER :int = 0;
    public static const GAME_TYPE_SINGLEPLAYER :int = 1;

    public static var gameType :int;
    public static var gameData :GameData;
    public static var spLevel :LevelData;
    public static var mpSettings :MultiplayerSettingsData;
    public static function get isSinglePlayer () :Boolean { return gameType == GAME_TYPE_SINGLEPLAYER; }
    public static function get isMultiplayer () :Boolean { return gameType == GAME_TYPE_MULTIPLAYER; }

    public static var gameMode :GameMode;
    public static var netObjects :NetObjectDB;
    public static var battleBoardView :BattleBoardView;
    public static var diurnalCycle :DiurnalCycle;
    public static var dashboard :DashboardView;
    public static var puzzleBoard :PuzzleBoard;
    public static var forceParticleContainer :ForceParticleContainer;

    public static var musicControls :AudioControls;
    public static var sfxControls :AudioControls;

    public static var playerInfos :Array;
    public static var playerCreatureSpellSets :Array;
    public static var localPlayerId :int;
    public static function get localPlayerInfo () :LocalPlayerInfo { return playerInfos[localPlayerId]; }
    public static function get isFirstPlayer () :Boolean { return (localPlayerId == 0); }
    public static function get numPlayers () :int { return playerInfos.length; }
    public static function get localUserIsPlaying () :Boolean { return localPlayerId >= 0; }

    public static function get mapSettings () :MapSettingsData
    {
        return (isSinglePlayer ? spLevel.mapSettings : mpSettings.mapSettings);
    }

    public static function getPlayerByName (playerName :String) :PlayerInfo
    {
        return ArrayUtil.findIf(
            playerInfos,
            function (info :PlayerInfo) :Boolean { return info.playerName == playerName; });
    }

    public static function findEnemyForPlayer (playerId :int) :PlayerInfo
    {
        var thisPlayer :PlayerInfo = playerInfos[playerId];

        // find the first player after this one that is on an opposing team
        for (var i :int = 0; i < playerInfos.length - 1; ++i) {
            var otherPlayerId :int = (playerId + i + 1) % playerInfos.length;
            var otherPlayer :PlayerInfo = playerInfos[otherPlayerId];
            if (otherPlayer.teamId != thisPlayer.teamId && otherPlayer.isAlive && !otherPlayer.isInvincible) {
                return otherPlayer;
            }
        }

        return null;
    }

    public static function playGameSound (soundName :String) :AudioChannel
    {
        return AudioManager.instance.playSoundNamed(soundName, sfxControls);
    }

    public static function playGameMusic (musicName :String) :AudioChannel
    {
        return AudioManager.instance.playSoundNamed(musicName, musicControls, AudioManager.LOOP_FOREVER);
    }
}

}
