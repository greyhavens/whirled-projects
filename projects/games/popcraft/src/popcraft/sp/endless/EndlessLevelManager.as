package popcraft.sp.endless {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.resource.*;

import popcraft.*;
import popcraft.data.*;
import popcraft.util.*;

public class EndlessLevelManager
{
    public function playLevel (levelReadyCallback :Function = null, forceReload :Boolean = false)
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

                var loadParams :Object = (Constants.DEBUG_LOAD_LEVELS_FROM_DISK ?
                    { url: "levels/endless_01.xml" } :
                    { embeddedClass: ENDLESS_LEVEL_1 });

                if (forceReload) {
                    // reload the default game data first, then load the level when it's complete
                    // (level requires that default game data already be loaded)
                    ResourceManager.instance.unload(Constants.RSRC_DEFAULTGAMEDATA);
                    ResourceManager.instance.queueResourceLoad(
                        Constants.RESTYPE_GAMEDATA,
                        Constants.RSRC_DEFAULTGAMEDATA,
                        { url: "levels/defaultGameData.xml" });

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
        AppContext.mainLoop.pushMode(new LevelLoadErrorMode(err));
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
            AppContext.mainLoop.unwindToMode(new StoryGameMode(_loadedLevel));
        }
    }

    protected var _loadedLevel :EndlessLevelData;
    protected var _levelReadyCallback :Function;

    protected static var log :Log = Log.getLog(LevelManager);

    protected static const RSRC_CURLEVEL :String = "curEndlessLevel";

    // Embedded level data
    [Embed(source="../../../../levels/endless_01.xml", mimeType="application/octet-stream")]
    protected static const ENDLESS_LEVEL_1 :Class;
}

}
