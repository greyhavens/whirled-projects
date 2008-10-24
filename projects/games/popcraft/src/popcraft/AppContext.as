package popcraft {

import com.whirled.contrib.LevelPackManager;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.game.GameControl;

import flash.display.Sprite;

import popcraft.data.*;
import popcraft.sp.endless.EndlessLevelManager;
import popcraft.sp.story.LevelManager;

public class AppContext
{
    public static var mainSprite :Sprite;
    public static var mainLoop :MainLoop;
    public static var gameCtrl :GameControl;
    public static var randStreamPuzzle :uint;
    public static var levelMgr :LevelManager = new LevelManager();
    public static var endlessLevelMgr :EndlessLevelManager = new EndlessLevelManager();
    public static var globalPlayerStats :PlayerStats = new PlayerStats();
    public static var allLevelPacks :LevelPackManager = new LevelPackManager();
    public static var playerLevelPacks :LevelPackManager = new LevelPackManager();
    public static var prizeMgr :PrizeManager = new PrizeManager();
    public static var userCookieMgr :UserCookieManager;

    public static function awardTrophy (trophyName :String) :void
    {
        if (AppContext.gameCtrl.isConnected()) {
            gameCtrl.player.awardTrophy(trophyName);
        } else {
            PopCraft.log.info("Trophy awarded: " + trophyName);
        }
    }

    public static function hasTrophy (trophyName :String) :Boolean
    {
        return (gameCtrl.isConnected() && gameCtrl.player.holdsTrophy(trophyName));
    }

    public static function get isEndlessModeUnlocked () :Boolean
    {
        return (Constants.DEBUG_UNLOCK_PREMIUM_CONTENT || hasPremiumLevelPack);
    }

    public static function get isStoryModeUnlocked () :Boolean
    {
        return (Constants.DEBUG_UNLOCK_PREMIUM_CONTENT || hasPremiumLevelPack ||
            levelMgr.highestUnlockedLevelIndex >= Constants.NUM_FREE_SP_LEVELS);
    }

    public static function get hasPremiumLevelPack () :Boolean
    {
        return (playerLevelPacks.getLevelPack(Constants.PREMIUM_SP_LEVEL_PACK_NAME) != null);
    }

    public static function get isMultiplayer () :Boolean
    {
        return (gameCtrl.isConnected() && gameCtrl.game.seating.getPlayerIds().length > 1);
    }

    public static function get defaultGameData () :GameData
    {
        return gameDataResource.gameData;
    }

    public static function get levelProgression () :LevelProgressionData
    {
        return gameDataResource.levelProgression;
    }

    public static function get multiplayerSettings () :Array
    {
        return gameDataResource.multiplayerSettings;
    }

    public static function get gameVariants () :Array
    {
        var variantResource :GameVariantsResource =
            GameVariantsResource(ResourceManager.instance.getResource(Constants.RSRC_GAMEVARIANTS));
        return variantResource.variants;
    }

    public static function showGameShop () :void
    {
        if (gameCtrl.isConnected()) {
            gameCtrl.local.showGameShop(GameControl.LEVEL_PACK_SHOP,
                Constants.PREMIUM_SP_LEVEL_PACK_ID);
        }
    }

    public static function reloadLevelPacks () :void
    {
        if (gameCtrl.isConnected()) {
            allLevelPacks.init(gameCtrl.game.getLevelPacks());
        }
    }

    public static function reloadPlayerLevelPacks () :void
    {
        if (gameCtrl.isConnected()) {
            playerLevelPacks.init(gameCtrl.player.getPlayerLevelPacks());
        }
    }

    protected static function get gameDataResource () :GameDataResource
    {
        return GameDataResource(ResourceManager.instance.getResource(Constants.RSRC_DEFAULTGAMEDATA));
    }
}

}
