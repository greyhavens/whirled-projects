package popcraft.sp.endless {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.resource.*;

import popcraft.*;
import popcraft.data.*;
import popcraft.util.*;

public class EndlessLevelManager
{
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
        GameContext.gameType = GameContext.GAME_TYPE_STORY;
        var gameDataOverride :GameData = _loadedLevel.gameDataOverride;
        GameContext.gameData =
            (null != gameDataOverride ? gameDataOverride : AppContext.defaultGameData);

        if (null != _levelReadyCallback) {
            _levelReadyCallback(_loadedLevel);
        } else {
            AppContext.mainLoop.unwindToMode(new EndlessGameMode(_loadedLevel));
        }
    }

    protected var _loadedLevel :EndlessLevelData;
    protected var _levelReadyCallback :Function;

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
