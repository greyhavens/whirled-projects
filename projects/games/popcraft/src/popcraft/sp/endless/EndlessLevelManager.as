package popcraft.sp.endless {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.resource.*;

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

    public function saveCurrentGame () :void
    {
        var saveArray :Array = (GameContext.isSinglePlayerGame ? _savedSpGames : _savedMpGames);

        var savedPlayerData :SavedLocalPlayerInfo =
            EndlessGameContext.savedHumanPlayers[GameContext.localPlayerIndex];

        // this is called when a level is ending, so we increment mapIndex
        var newSave :SavedEndlessGame = SavedEndlessGame.create(
            EndlessGameContext.mapIndex + 1,
            EndlessGameContext.score,
            EndlessGameContext.scoreMultiplier,
            savedPlayerData.health);

        var existingSaveIndex :int = ArrayUtil.indexIf(saveArray,
            function (save :SavedEndlessGame) :Boolean {
                return save.mapIndex == newSave.mapIndex;
            });

        if (existingSaveIndex != -1) {
            var existingSave :SavedEndlessGame = saveArray[existingSaveIndex];
            // combine this save with the existing save to get the max values of both
            newSave = SavedEndlessGame.max(newSave, existingSave);
            if (newSave.isEqual(existingSave)) {
                // didn't make any progress - don't save
                return;
            }

            saveArray[existingSaveIndex] = newSave;

        } else {
            saveArray.push(newSave);
        }

        // save the new data
        AppContext.userCookieMgr.setNeedsUpdate();
    }

    public function writeCookieData (cookie :ByteArray) :void
    {
        writeSavedGames(_savedSpGames);
        writeSavedGames(_savedMpGames);

        function writeSavedGames (saves :Array) :void {
            cookie.writeShort(saves.length);
            for each (var save :SavedEndlessGame in saves) {
                save.toBytes(cookie);
            }
        }
    }

    public function readCookieData (version :int, cookie :ByteArray) :void
    {
        this.resetSavedData();

        readSavedGames(_savedSpGames);
        readSavedGames(_savedMpGames);

        function readSavedGames (saves :Array) :void {
            var numSaves :int = cookie.readShort();
            for (var ii :int = 0; ii < numSaves; ++ii) {
                var save :SavedEndlessGame = new SavedEndlessGame();
                save.fromBytes(cookie);
                saves.push(save);
            }
        }
    }

    public function get minVersion () :int
    {
        return 1;
    }

    public function readFailed () :Boolean
    {
        this.resetSavedData();
        return true;
    }

    public function get savedSpGames () :Array
    {
        return _savedSpGames;
    }

    public function get savedMpGames () :Array
    {
        return _savedMpGames;
    }

    protected function resetSavedData () :void
    {
        _savedSpGames = [];
        _savedMpGames = [];
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
    protected var _savedSpGames :Array = [];
    protected var _savedMpGames :Array = [];

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
