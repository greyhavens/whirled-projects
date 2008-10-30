package joingame {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.game.GameControl;


import joingame.net.JoinMessageManager;

//import popcraft.data.*;
//import popcraft.sp.LevelManager;

//Copied and modified from popcraft
public class AppContext
{
    
    
    public static var gameCtrl :GameControl;
//    public static var levelMgr :LevelManager;
    public static var randStreamPuzzle :uint;
    
    public static var localServer :JoingameServer;
    public static var messageManager :JoinMessageManager;
    
    public static var playerId :int;
    
    public static var isConnected :Boolean;
    
    public static var isMultiplayer :Boolean;
    
    public static var log :Log = Log.getLog(AppContext);
    
    
//    public static var globalPlayerStats :PlayerStats;

//    public static function get defaultGameData () :GameData
//    {
//        var dataRsrc :GameDataResource = ResourceManager.instance.getResource("defaultGameData") as GameDataResource;
//        return dataRsrc.gameData;
//    }

//    public static function get levelProgression () :LevelProgressionData
//    {
//        var dataRsrc :GameDataResource = ResourceManager.instance.getResource("defaultGameData") as GameDataResource;
//        return dataRsrc.levelProgression;
//    }

//    public static function get multiplayerSettings () :Array
//    {
//        var dataRsrc :GameDataResource = ResourceManager.instance.getResource("defaultGameData") as GameDataResource;
//        return dataRsrc.multiplayerSettings;
//    }

//    public static function get gameVariants () :Array
//    {
//        var variantResource :GameVariantsResource = ResourceManager.instance.getResource("gameVariants") as GameVariantsResource;
//        return variantResource.variants;
//    }

//    public static function LOG(s: String): void
//    {
//        if(false && gameCtrl != null && gameCtrl.local != null && gameCtrl.net.isConnected())
//        {
//            gameCtrl.local.feedback(s);
//        }
//        else
//        {
//            if( Constants.PLAYER_ID_TO_LOG == gameCtrl.game.getMyId() || gameCtrl.game.amServerAgent()) {
//                trace(s);
////                gameCtrl.local.feedback(s);
//            }
//        }
//    }
    
    
    /**
    * Convenience function, saves typing.
    */
    public static function get myid() :int 
    {
        return gameCtrl.game.getMyId();
    }
    
    public static var isObserver :Boolean;
    
    public static var gameHeight :int = 500;
    public static var gameWidth :int = 700;
    
    public static var beginToShowInstructionsTime :int = 0;
}

}
