package joingame {

import com.threerings.util.ArrayUtil;
import com.threerings.util.HashMap;
import com.whirled.contrib.simplegame.MainLoop;
import com.whirled.contrib.simplegame.audio.AudioChannel;
import com.whirled.contrib.simplegame.audio.AudioControls;
import com.whirled.contrib.simplegame.audio.AudioManager;
import com.whirled.contrib.simplegame.resource.ImageResource;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.text.TextField;

import joingame.model.*;
import joingame.modes.*;
import joingame.view.*;


public class GameContext
{
    
    public static var mainSprite :Sprite;
    
    public static var mainLoop :MainLoop;

    public static var puzzleBoardMiddle :JoinGameBoardGameArea;
    
    public static var puzzleBoardLeft :JoinGameBoardGameArea;
    public static var puzzleBoardRight :JoinGameBoardGameArea;
        
    public static var gameModel: JoinGameModel;
    
    public static var cookieManager :UserCookieManager = new UserCookieManager(1);
    public static var playerCookieData :UserCookieDataSourcePlayer = new UserCookieDataSourcePlayer();
    
    public static var requestedSinglePlayerLevel :int;
        
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
    
    
    /**
    * The DisplayObject returned is always 80x60 pixels large (from API).
    * 
    */
    public static function getHeadshot( playerid :int) :DisplayObject
    {
        if(_headshots.containsKey(playerid)) {
            return _headshots.get(playerid) as DisplayObject;
        }
        else {
            var headshot :DisplayObject = AppContext.isConnected && playerid > 0 ? 
                                    AppContext.gameCtrl.local.getHeadShot( playerid) :
                                    null;
            if(headshot != null) {
                _headshots.put(playerid, headshot);
                return headshot; 
            }
            else {
                var dummyHeadShot :Sprite = new Sprite();
                var icon :Bitmap = ImageResource.instantiateBitmap("ICON");
                var txt:TextField = new TextField();
                
                if(playerid < 0) {
                    dummyHeadShot.addChild(icon);
                    txt.textColor = 0xffffff;
    //                txt.backgroundColor = 0xffffff;
    //                txt.background = true;
                    txt.width = 30;
                    txt.height = 20;
                    txt.scaleX = 3;
                    txt.scaleY = 3;
    //                txt.text = "" + Math.abs(playerid) +" " + gameModel.getBoardForPlayerID(playerid)._computerPlayerLevel;
//                    txt.text = "" + gameModel.getBoardForPlayerID(playerid)._computerPlayerLevel;
                    txt.text = "" + SinglePlayerServerPlugin.getLevelForComputerId(playerid);
//                    txt.text = "" + Math.abs(playerid);
    //                txt.text = "" + 12;
                    if( txt.text.length == 1) {
                        txt.text = " " + txt.text;
                    }
                    else { 
                           txt.text = "" + txt.text;
                    }
    //                txt.x = 40 - Math.round(txt.width/2);
    //                txt.y = 30 //- Math.round(txt.height/2);
                }
                else {
                    txt.textColor = 0xffffff;
                    txt.width = 60;
                    txt.height = 20;
                    txt.scaleX = 2;
                    txt.scaleY = 2;
    //                txt.text = "" + Math.abs(playerid) +" " + gameModel.getBoardForPlayerID(playerid)._computerPlayerLevel;
                    txt.text = "Player";
                }
                dummyHeadShot.addChild(txt);
                
                _headshots.put(playerid, dummyHeadShot);
                return dummyHeadShot;
            }
        }
    }
    
    private static var _headshots :HashMap = new HashMap();
    

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
}

}
