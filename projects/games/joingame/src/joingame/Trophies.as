
package joingame {

import com.threerings.util.Log;

import joingame.model.JoinGameModel;

public class Trophies
{
    private static const log :Log = Log.getLog(Trophies);
    
    public static const WAVE_1_TROPHY :String = "wave1";
    public static const WAVE_2_TROPHY :String = "wave2";
    public static const WAVE_3_TROPHY :String = "wave3";
    public static const WAVE_4_TROPHY :String = "wave4";
    public static const WAVE_5_TROPHY :String = "wave5";
    public static const WAVE_6_TROPHY :String = "wave6";
    public static const WAVE_7_TROPHY :String = "wave7";
    
    public static const WAVE_TROPHIES :Array = [WAVE_1_TROPHY,
                                                WAVE_2_TROPHY,
                                                WAVE_3_TROPHY,
                                                WAVE_4_TROPHY,
                                                WAVE_5_TROPHY,
                                                WAVE_6_TROPHY,
                                                WAVE_7_TROPHY];
    
    public static const BEAT_1_HUMAN_TROPHY :String = "beat1human";
    public static const BEAT_2_HUMAN_TROPHY :String = "beat2humans";
    public static const BEAT_3_HUMAN_TROPHY :String = "beat3humans";
    public static const BEAT_4_HUMAN_TROPHY :String = "beat4humans";
    public static const BEAT_5_HUMAN_TROPHY :String = "beat5humans";
    public static const BEAT_6_HUMAN_TROPHY :String = "beat6humans";
    public static const BEAT_7_HUMAN_TROPHY :String = "beat7humans";
    public static const BEAT_8_HUMAN_TROPHY :String = "beat8humans";
    public static const BEAT_9_HUMAN_TROPHY :String = "beat9humans";
    
    
    public static function getPlayerLevelBasedOnTrophies (playerId :int, model :JoinGameModel) :int
    {
        var level :int = 0;
        for( var k :int = 0; k < WAVE_TROPHIES.length; k++) {
            if( AppContext.gameCtrl.player.holdsTrophy(WAVE_TROPHIES[k], playerId)  ) {
                level = k + 1;
            }
        }
        return level;
    }
    
    public static function handleWaveDefeated (model :JoinGameModel, cookie :UserCookieDataSourcePlayer) :void
    {
        if( AppContext.isMultiplayer ) {
            log.error("handleWave(), but not a single player game.");
            return;
        }
//        var playersLevel :int = model.singlePlayerLevel;
        var playersLevel :int = cookie.highestRobotLevelDefeated;
        
        for( var k :int = 0; k < playersLevel && k < WAVE_TROPHIES.length; k++) {
            doAward( model.humanPlayerId, WAVE_TROPHIES[k]);
        } 
    }

   

    

    protected static function doAward (player :int, trophy :String) :void
    {
        if( AppContext.isConnected ) {
            if( !AppContext.gameCtrl.player.holdsTrophy(trophy, player) ) {
                AppContext.gameCtrl.player.awardTrophy(trophy, player);
            } 
        }
        log.info("Awarded " + trophy + " to player " + player);
    }
}
}
