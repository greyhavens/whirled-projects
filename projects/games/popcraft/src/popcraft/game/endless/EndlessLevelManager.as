package popcraft.game.endless {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.util.Rand;

import flash.utils.ByteArray;

import popcraft.*;
import popcraft.data.*;
import popcraft.game.*;
import popcraft.util.*;

public class EndlessLevelManager
    implements UserCookieDataSource
{
    public function EndlessLevelManager ()
    {
        resetSavedData();
    }

    public function playSpLevel (levelReadyCallback :Function = null, forceReload :Boolean = false)
        :void
    {
        playLevel(SP_LEVEL, levelReadyCallback, forceReload);
    }

    public function playMpLevel (levelReadyCallback :Function = null, forceReload :Boolean = false)
        :void
    {
        playLevel(MP_LEVEL, levelReadyCallback, forceReload);
    }

    public function createDummySpSaves () :void
    {
        _savedSpGames = createDummySaves(9, 9);
    }

    public function createDummyMpSaves () :void
    {
        _savedMpGames = createDummySaves(9, 14);
    }

    protected function createDummySaves (min :int, max :int) :SavedEndlessGameList
    {
        var dummySaves :SavedEndlessGameList = new SavedEndlessGameList();
        var numSaves :int = Rand.nextIntRange(min, max + 1, Rand.STREAM_COSMETIC);
        for (var mapIndex :int = 1; mapIndex < numSaves; ++mapIndex) {
            dummySaves.addSave(SavedEndlessGame.create(mapIndex, 0, 0, 1, 150));
        }

        return dummySaves;
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
            EndlessGameContext.resourceScore,
            EndlessGameContext.damageScore,
            EndlessGameContext.scoreMultiplier,
            savedPlayerData.health,
            savedPlayerData.spells);

        if (saveList.addSave(newSave)) {
            // save the new data
            ClientCtx.userCookieMgr.needsUpdate();
        }
    }

    public function writeCookieData (cookie :ByteArray) :void
    {
        _savedSpGames.toBytes(cookie);
        _savedMpGames.toBytes(cookie);
    }

    public function readCookieData (version :int, cookie :ByteArray) :void
    {
        resetSavedData();

        _savedSpGames.fromBytes(cookie);
        _savedMpGames.fromBytes(cookie);
    }

    public function get minCookieVersion () :int
    {
        return 1;
    }

    public function cookieReadFailed () :Boolean
    {
        resetSavedData();
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

    public function resetSavedGames () :void
    {
        _savedSpGames = new SavedEndlessGameList();
        _savedMpGames = new SavedEndlessGameList();
    }

    protected function resetSavedData () :void
    {
        resetSavedGames();
    }

    protected function playLevel (levelType :int, levelReadyCallback :Function, forceReload :Boolean)
        :void
    {
        _levelReadyCallback = levelReadyCallback;

        // forceReload only makes sense when we're loading levels from disk (and
        // they can therefore be edited at runtime)
        forceReload &&= Constants.DEBUG_LOAD_LEVELS_FROM_DISK;

        if (forceReload || levelType != _loadedLevelType) {
            _loadedLevel = null;
        }

        _loadedLevelType = levelType;

        if (null != _loadedLevel) {
            startGame();

        } else {
            // load the level
            var levelName :String;
            var theEmbeddedClass :Class
            if (levelType == SP_LEVEL) {
                levelName = "endless_sp_01.xml";
                theEmbeddedClass = ENDLESS_SP_LEVEL_1;
            } else {
                levelName = "endless_mp_01.xml";
                theEmbeddedClass = ENDLESS_MP_LEVEL_1;
            }

            var loadParams :Object = (Constants.DEBUG_LOAD_LEVELS_FROM_DISK ?
                { url: LEVELS_DIR + "/" + levelName } :
                { embeddedClass: theEmbeddedClass });

            if (forceReload) {
                // reload the default game data first, then load the level when it's complete
                // (level requires that default game data already be loaded)
                ClientCtx.rsrcs.unload(Constants.RSRC_DEFAULTGAMEDATA);
                ClientCtx.rsrcs.queueResourceLoad(
                    Constants.RESTYPE_GAMEDATA,
                    Constants.RSRC_DEFAULTGAMEDATA,
                    { url: LEVELS_DIR + "/defaultGameData.xml" });

                ClientCtx.rsrcs.loadQueuedResources(
                    function () :void {
                        loadLevel(loadParams)
                    },
                    onLoadError);

            } else {
                loadLevel(loadParams);
            }
        }
    }

    protected function loadLevel (loadParams :Object) :void
    {
        ClientCtx.rsrcs.unload(RSRC_CURLEVEL);
        ClientCtx.rsrcs.queueResourceLoad(Constants.RESTYPE_ENDLESS, RSRC_CURLEVEL,
            loadParams);
        ClientCtx.rsrcs.loadQueuedResources(onLevelLoaded, onLoadError);
    }

    protected function onLevelLoaded () :void
    {
        _loadedLevel =
            EndlessLevelResource(ClientCtx.rsrcs.getResource(RSRC_CURLEVEL)).levelData;
        startGame();
    }

    protected function onLoadError (err :String) :void
    {
        ClientCtx.mainLoop.pushMode(new EndlessLevelLoadErrorMode(err));
    }

    protected function startGame () :void
    {
        if (null != _levelReadyCallback) {
            _levelReadyCallback(_loadedLevel);
        } else {
            ClientCtx.mainLoop.unwindToMode(new EndlessGameMode(_loadedLevelType == MP_LEVEL,
                                                                 _loadedLevel, null, true));
        }
    }

    protected var _loadedLevelType :int = -1;
    protected var _loadedLevel :EndlessLevelData;
    protected var _levelReadyCallback :Function;
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
