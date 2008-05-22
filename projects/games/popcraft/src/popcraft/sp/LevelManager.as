package popcraft.sp {

import com.whirled.contrib.simplegame.resource.*;

import popcraft.*;
import popcraft.data.*;
import popcraft.util.*;

public class LevelManager
{
    public function playLevel (forceReload :Boolean = false) :void
    {
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
                // @TEMP - if _curLevelNum < 0, we load the test level
                var loadParams :Object;
                if (_curLevelNum < 0) {
                    loadParams = (Constants.DEBUG_LOAD_LEVELS_FROM_DISK ?
                        { url: "levels/testlevel.xml" } :
                        { embeddedClass: LEVEL_TEST });
                } else {
                    loadParams = (Constants.DEBUG_LOAD_LEVELS_FROM_DISK ?
                        { url: "levels/level" + String(_curLevelNum + 1) + ".xml" } :
                        { embeddedClass: LEVELS[_curLevelNum] });
                }

                if (forceReload) {
                    // reload the default game data first, then load the level when it's complete
                    // (level requires that default game data already be loaded)
                    ResourceManager.instance.unload("defaultGameData");
                    ResourceManager.instance.pendResourceLoad("gameData", "defaultGameData", { url: "levels/defaultGameData.xml" });
                    ResourceManager.instance.load(function () :void { loadLevel(loadParams) }, onLoadError);

                } else {
                    this.loadLevel(loadParams);
                }
            }
        }
    }

    protected function loadLevel (loadParams :Object) :void
    {
        ResourceManager.instance.unload("level");
        ResourceManager.instance.pendResourceLoad("level", "level", loadParams);
        ResourceManager.instance.load(onLevelLoaded, onLoadError);
    }

    public function get curLevelNum () :int
    {
        return _curLevelNum;
    }

    public function set curLevelNum (val :int) :void
    {
        val = (val < 0 ? -1 : val % LEVELS.length);

        if (_curLevelNum != val) {
            _curLevelNum = val;
            _loadedLevel = null;
        }
    }

    public function incrementLevelNum () :void
    {
        if (_curLevelNum > 0) {
            this.curLevelNum = _curLevelNum + 1;
        }
    }

    public function get numLevels () :int
    {
        return LEVELS.length;
    }

    protected function onLevelLoaded () :void
    {
        _loadedLevel = (ResourceManager.instance.getResource("level") as LevelResourceLoader).levelData;
        this.startGame();
    }

    protected function onLoadError (err :String) :void
    {
        AppContext.mainLoop.unwindToMode(new LevelLoadErrorMode(err));
    }

    protected function startGame () :void
    {
        GameContext.gameType = GameContext.GAME_TYPE_SINGLEPLAYER;
        GameContext.spLevel = _loadedLevel;

        AppContext.mainLoop.unwindToMode(new GameMode());
    }

    protected var _curLevelNum :int = 0;
    protected var _loadedLevel :LevelData;

    // Embedded level data
    [Embed(source="../../../levels/level1.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_1 :Class;
    [Embed(source="../../../levels/level2.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_2 :Class;
    [Embed(source="../../../levels/level3.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_3 :Class;
    [Embed(source="../../../levels/level4.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_4 :Class;
    [Embed(source="../../../levels/level5.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_5 :Class;
    [Embed(source="../../../levels/level6.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_6 :Class;
    [Embed(source="../../../levels/level7.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_7 :Class;
    [Embed(source="../../../levels/level8.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_8 :Class;
    [Embed(source="../../../levels/level9.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_9 :Class;
    [Embed(source="../../../levels/level10.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_10 :Class;

    [Embed(source="../../../levels/testlevel.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_TEST :Class;

    protected static const LEVELS :Array =
        [ LEVEL_1, LEVEL_2, LEVEL_3, LEVEL_4, LEVEL_5, LEVEL_6, LEVEL_7, LEVEL_8, LEVEL_9 ];

}

}
