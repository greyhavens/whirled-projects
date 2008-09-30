package popcraft {

import com.whirled.contrib.LevelPacks;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.game.GameControl;

import flash.display.Sprite;

import popcraft.data.*;
import popcraft.sp.story.LevelManager;

public class AppContext
{
    public static var mainSprite :Sprite;
    public static var mainLoop :MainLoop;
    public static var gameCtrl :GameControl;
    public static var levelMgr :LevelManager;
    public static var randStreamPuzzle :uint;
    public static var globalPlayerStats :PlayerStats;

    public static function get isPremiumContentUnlocked () :Boolean
    {
        return (LevelPacks.getLevelPack(Constants.PREMIUM_SP_LEVEL_PACK_NAME) != null ||
                levelMgr.highestUnlockedLevelIndex >= Constants.NUM_FREE_SP_LEVELS);
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
            ResourceManager.instance.getResource("gameVariants") as GameVariantsResource;
        return variantResource.variants;
    }

    public static function showGameShop () :void
    {
        if (gameCtrl.isConnected()) {
            gameCtrl.local.showGameShop(GameControl.LEVEL_PACK_SHOP,
                Constants.PREMIUM_SP_LEVEL_PACK_ID);
        }
    }

    protected static function get gameDataResource () :GameDataResource
    {
        return GameDataResource(ResourceManager.instance.getResource("defaultGameData"));
    }
}

}
