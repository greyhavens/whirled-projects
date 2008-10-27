package popcraft.sp.endless {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.util.Rand;

import flash.utils.ByteArray;

import popcraft.*;
import popcraft.data.*;
import popcraft.util.*;

public class EndlessLevelManager
    implements UserCookieDataSource
{
    public function EndlessLevelManager ()
    {
        this.resetSavedData();
    }

    public function playSpLevel (levelReadyCallback :Function = null, forceReload :Boolean = false)
        :void
    {
        this.playLevel(SP_LEVEL, levelReadyCallback, forceReload);
    }

    public function playMpLevel (levelReadyCallback :Function = null, forceReload :Boolean = false)
        :void
    {
        this.playLevel(MP_LEVEL, levelReadyCallback, forceReload);
    }

    public function createDummyMpSaves () :void
    {
        var dummySaves :SavedEndlessGameList = new SavedEndlessGameList();
        var numSaves :int = Rand.nextIntRange(9, 15, Rand.STREAM_COSMETIC);
        var score :int;
        for (var mapIndex :int = 1; mapIndex < numSaves; ++mapIndex) {
            score += Rand.nextIntRange(100, 10000, Rand.STREAM_COSMETIC);
            var multiplier :int = Rand.nextIntRange(1, 6, Rand.STREAM_COSMETIC);
            var health :int = Rand.nextIntRange(0, 150, Rand.STREAM_COSMETIC);
            var spells :Array = [];
            for (var spellType :int = 0; spellType < Constants.CASTABLE_SPELL_TYPE__LIMIT; ++spellType) {
                var numSpells :int = Rand.nextIntRange(0, 4, Rand.STREAM_COSMETIC);
                spells.push(numSpells);
            }

            dummySaves.addSave(SavedEndlessGame.create(
                mapIndex,
                score,
                multiplier,
                health,
                spells));
        }

        _savedMpGames = dummySaves;
    }

    public function saveCurrentGame () :void
    {
        var saveList :SavedEndlessGameList =
            (GameContext.isSinglePlayerGame ? _savedSpGames : _savedMpGames);

        var savedPlayerData :SavedLocalPlayerInfo =
            EndlessGameContext.savedHumanPlayers[GameContext.localPlayerIndex];

        // this is called when a level is ending, so we increment mapIndex
        var newSave :SavedEndlessGame = SavedEndlessGame.create(
            EndlessGameContext.mapIndex + 1,
            EndlessGameContext.score,
            EndlessGameContext.scoreMultiplier,
            savedPlayerData.health,
            savedPlayerData.spells);

        if (saveList.addSave(newSave)) {
            // save the new data
            AppContext.userCookieMgr.setNeedsUpdate();
        }
    }

    public function writeCookieData (cookie :ByteArray) :void
    {
        _savedSpGames.toBytes(cookie);
        _savedMpGames.toBytes(cookie);
    }

    public function readCookieData (version :int, cookie :ByteArray) :void
    {
        this.resetSavedData();

        _savedSpGames.fromBytes(cookie);
        _savedMpGames.fromBytes(cookie);
    }

    public function get minCookieVersion () :int
    {
        return 1;
    }

    public function cookieReadFailed () :Boolean
    {
        this.resetSavedData();
        return true;
    }

    public function get savedSpGames () :SavedEndlessGameList
    {
        return _savedSpGames;
    }

    public function get savedMpGames () :SavedEndlessGameList
    {
        return _savedMpGames;
    }

    protected function resetSavedData () :void
    {
        _savedSpGames = new SavedEndlessGameList();
        _savedMpGames = new SavedEndlessGameList();
    }

    protected function playLevel (level :int, levelReadyCallback :Function, forceReload :Boolean)
        :void
    {
        _levelReadyCallback = levelReadyCallback;

        // forceReload only makes sense when we're loading levels from disk (and
        // they can therefore be edited at runtime)
        forceReload &&= Constants.DEBUG_LOAD_LEVELS_FROM_DISK;

        if (forceReload) {
            _loadedLevel = null;
        }

        if (null != _loadedLevel) {
            this.startGame();

        } else {
            // load the level
            if (null == _loadedLevel) {
                var levelName :String;
                var theEmbeddedClass :Class
                if (level == SP_LEVEL) {
                    levelName = "endless_sp_01.xml";
                    theEmbeddedClass = ENDLESS_SP_LEVEL_1;
                    _loadingMultiplayer = false;
                } else {
                    levelName = "endless_mp_01.xml";
                    theEmbeddedClass = ENDLESS_MP_LEVEL_1;
                    _loadingMultiplayer = true;
                }

                var loadParams :Object = (Constants.DEBUG_LOAD_LEVELS_FROM_DISK ?
                    { url: LEVELS_DIR + "/" + levelName } :
                    { embeddedClass: theEmbeddedClass });

                if (forceReload) {
                    // reload the default game data first, then load the level when it's complete
                    // (level requires that default game data already be loaded)
                    ResourceManager.instance.unload(Constants.RSRC_DEFAULTGAMEDATA);
                    ResourceManager.instance.queueResourceLoad(
                        Constants.RESTYPE_GAMEDATA,
                        Constants.RSRC_DEFAULTGAMEDATA,
                        { url: LEVELS_DIR + "/defaultGameData.xml" });

                    ResourceManager.instance.loadQueuedResources(
                        function () :void {
                            loadLevel(loadParams)
                        },
                        onLoadError);

                } else {
                    this.loadLevel(loadParams);
                }
            }
        }
    }

    protected function loadLevel (loadParams :Object) :void
    {
        ResourceManager.instance.unload(RSRC_CURLEVEL);
        ResourceManager.instance.queueResourceLoad(Constants.RESTYPE_ENDLESS, RSRC_CURLEVEL,
            loadParams);
        ResourceManager.instance.loadQueuedResources(onLevelLoaded, onLoadError);
    }

    protected function onLevelLoaded () :void
    {
        _loadedLevel =
            EndlessLevelResource(ResourceManager.instance.getResource(RSRC_CURLEVEL)).levelData;
        this.startGame();
    }

    protected function onLoadError (err :String) :void
    {
        AppContext.mainLoop.pushMode(new EndlessLevelLoadErrorMode(err));
    }

    protected function startGame () :void
    {
        GameContext.gameType = (_loadingMultiplayer ? GameContext.GAME_TYPE_ENDLESS_MP :
            GameContext.GAME_TYPE_ENDLESS_SP);

        var gameDataOverride :GameData = _loadedLevel.gameDataOverride;
        GameContext.gameData =
            (null != gameDataOverride ? gameDataOverride : AppContext.defaultGameData);

        if (null != _levelReadyCallback) {
            _levelReadyCallback(_loadedLevel);
        } else {
            AppContext.mainLoop.unwindToMode(new EndlessGameMode(_loadedLevel, null, true));
        }
    }

    protected var _loadedLevel :EndlessLevelData;
    protected var _levelReadyCallback :Function;
    protected var _loadingMultiplayer :Boolean;
    protected var _savedSpGames :SavedEndlessGameList = new SavedEndlessGameList();
    protected var _savedMpGames :SavedEndlessGameList = new SavedEndlessGameList();

    protected static var log :Log = Log.getLog(EndlessLevelManager);

    protected static const RSRC_CURLEVEL :String = "curEndlessLevel";
    protected static const LEVELS_DIR :String = "../levels";

    protected static const SP_LEVEL :int = 0;
    protected static const MP_LEVEL :int = 1;

    // Embedded level data
    [Embed(source="../../../../levels/endless_sp_01.xml", mimeType="application/octet-stream")]
    protected static const ENDLESS_SP_LEVEL_1 :Class;
    [Embed(source="../../../../levels/endless_mp_01.xml", mimeType="application/octet-stream")]
    protected static const ENDLESS_MP_LEVEL_1 :Class;
}

}
