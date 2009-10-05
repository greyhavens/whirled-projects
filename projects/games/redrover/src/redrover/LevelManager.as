package redrover {

import com.threerings.util.Log;
import com.threerings.flashbang.resource.*;

import redrover.data.*;
import redrover.game.GameMode;
import redrover.ui.LevelLoadErrorMode;

public class LevelManager
{
    public function playLevel (levelIndex :int, levelReadyCallback :Function = null,
        forceReload :Boolean = false) :void
    {
        _levelReadyCallback = levelReadyCallback;

        // forceReload only makes sense when we're loading levels from disk (and
        // they can therefore be edited at runtime)
        forceReload &&= Constants.DEBUG_LOAD_LEVELS_FROM_DISK;

        if (forceReload || levelIndex != _loadedLevelIndex) {
            _loadedLevel = null;
        }

        if (null != _loadedLevel) {
            startGame();

        } else {
            // load the level
            var loadParams :Object;
            var levelNumString :String = String(levelIndex + 1);
            if (levelIndex + 1 < 10) {
                levelNumString = "0" + levelNumString;
            }

            loadParams = (Constants.DEBUG_LOAD_LEVELS_FROM_DISK ?
                { url: LEVELS_DIR + "/" + levelNumString + "_level.xml" } :
                { embeddedClass: LEVELS[levelIndex] });

            loadLevel(loadParams);
            _loadedLevelIndex = levelIndex;
        }
    }

    protected function loadLevel (loadParams :Object) :void
    {
        ClientCtx.rsrcs.unload(RSRC_CURLEVEL);
        ClientCtx.rsrcs.queueResourceLoad(Constants.RESTYPE_LEVEL, RSRC_CURLEVEL,
            loadParams);
        ClientCtx.rsrcs.loadQueuedResources(onLevelLoaded, onLoadError);
    }

    public function get numLevels () :int
    {
        return LEVELS.length;
    }

    protected function onLevelLoaded () :void
    {
        _loadedLevel = LevelResource(ClientCtx.rsrcs.getResource(RSRC_CURLEVEL)).levelData;
        startGame();
    }

    protected function onLoadError (err :String) :void
    {
        ClientCtx.mainLoop.pushMode(new LevelLoadErrorMode(err, _loadedLevelIndex,
            _levelReadyCallback));
    }

    protected function startGame () :void
    {
        if (null != _levelReadyCallback) {
            _levelReadyCallback(_loadedLevel);
        } else {
            ClientCtx.mainLoop.unwindToMode(new GameMode(_loadedLevel));
        }
    }

    protected var _loadedLevelIndex :int = -1;
    protected var _loadedLevel :LevelData;
    protected var _levelReadyCallback :Function;

    protected static var log :Log = Log.getLog(LevelManager);

    protected static const LEVELS_DIR :String = "../levels";
    protected static const RSRC_CURLEVEL :String  = "curLevel";

    // Embedded level data
    [Embed(source="../../levels/01_level.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_1 :Class;

    protected static const LEVELS :Array = [
        LEVEL_1,
    ];

    protected static const NUM_LEVELS :int = 1;
}

}
