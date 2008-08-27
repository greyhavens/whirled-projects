package joingame {

import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.audio.AudioChannel;
import com.whirled.contrib.simplegame.audio.AudioControls;
import com.whirled.contrib.simplegame.audio.AudioManager;

import joingame.view.*;
import joingame.model.*;
import joingame.modes.*;

public class GameContext
{
	

	
	public static var puzzleBoardMiddle :JoinGameBoardGameArea;
    
	public static var puzzleBoardLeft :JoinGameBoardGameArea;
	public static var puzzleBoardRight :JoinGameBoardGameArea;
		
	public static var gameState: JoinGameModel;
		
//    public static const GAME_TYPE_MULTIPLAYER :int = 0;
//    public static const GAME_TYPE_SINGLEPLAYER :int = 1;

    /* Frequently-used values that are cached here for performance reasons */
//    public static var mapScaleXInv :Number;
//    public static var mapScaleYInv :Number;
//    public static var scaleSprites :Boolean;

//    public static var gameType :int;
//    public static var gameData :GameData;
//    public static var spLevel :LevelData;
//    public static var mpSettings :MultiplayerSettingsData;
//    public static var playerStats :PlayerStats;
//    public static function get isSinglePlayer () :Boolean { return gameType == GAME_TYPE_SINGLEPLAYER; }
//    public static function get isMultiplayer () :Boolean { return gameType == GAME_TYPE_MULTIPLAYER; }

    public static var gameMode :PlayPuzzleMode;
//    public static var netObjects :NetObjectDB;
//    public static var battleBoardView :BattleBoardView;
//    public static var diurnalCycle :DiurnalCycle;
//    public static var dashboard :DashboardView;
    
    
    
//    public static var forceParticleContainer :ForceParticleContainer;
//    public static var unitFactory :UnitFactory;

//    public static var overlayLayer :Sprite;
//    public static var dashboardLayer :Sprite;
//    public static var battleLayer :Sprite;

    public static var playAudio :Boolean;
    public static var musicControls :AudioControls;
    public static var sfxControls :AudioControls;

    public static var playerInfos :Array;
//    public static var playerCreatureSpellSets :Array;
//    public static var localPlayerIndex :int;

//    public static var winningTeamId :int;

//    public static function get localPlayerInfo () :LocalPlayerInfo { return playerInfos[localPlayerIndex]; }
    public static function get numPlayers () :int { return playerInfos.length; }

//    public static function get mapSettings () :MapSettingsData
//    {
//        return (isSinglePlayer ? spLevel.mapSettings : mpSettings.mapSettings);
//    }

//    public static function get battlefieldWidth () :Number
//    {
//        return (Constants.BATTLE_WIDTH * mapSettings.mapScaleX);
//    }
//
//    public static function get battlefieldHeight () :Number
//    {
//        return (Constants.BATTLE_HEIGHT * mapSettings.mapScaleY);
//    }

    public static function getPlayerByName (playerName :String) :PlayerInfo
    {
        return ArrayUtil.findIf(
            playerInfos,
            function (info :PlayerInfo) :Boolean { return info.playerName == playerName; });
    }

//    public static function findEnemyForPlayer (playerIndex :int) :PlayerInfo
//    {
//        var thisPlayer :PlayerInfo = playerInfos[playerIndex];
//
//        // find the first player after this one that is on an opposing team
//        for (var i :int = 0; i < playerInfos.length - 1; ++i) {
//            var otherPlayerIndex :int = (playerIndex + i + 1) % playerInfos.length;
//            var otherPlayer :PlayerInfo = playerInfos[otherPlayerIndex];
//            if (otherPlayer.teamId != thisPlayer.teamId && otherPlayer.isAlive && !otherPlayer.isInvincible) {
//                return otherPlayer;
//            }
//        }
//
//        return null;
//    }

    public static function playGameSound (soundName :String) :AudioChannel
    {
        return (playAudio ? AudioManager.instance.playSoundNamed(soundName, sfxControls) : new AudioChannel());
    }

    public static function playGameMusic (musicName :String) :AudioChannel
    {
        return (playAudio ? AudioManager.instance.playSoundNamed(musicName, musicControls, AudioManager.LOOP_FOREVER) : new AudioChannel());
    }
    
    
    public static function LOG(s: String): void
	{
		if(AppContext.gameCtrl != null && AppContext.gameCtrl.local != null && AppContext.gameCtrl.net.isConnected())
		{
//			AppContext.gameCtrl.local.feedback(s);
			AppContext.gameCtrl.game.systemMessage(s);
		}
		else
		{
			trace(s);
		
		}
	}
}

}