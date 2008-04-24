package popcraft.sp {

import com.whirled.contrib.simplegame.resource.*;

import popcraft.*;
import popcraft.util.*;

public class LevelManager
{
    public function LevelManager ()
    {
        _levelRsrcMgr.addEventListener(ResourceLoadEvent.LOADED, onXmlLoaded);
        _levelRsrcMgr.addEventListener(ResourceLoadEvent.ERROR, onXmlLoadErr);
    }

    public function playLevel (forceReload :Boolean = false) :void
    {
        // do we need to (re)load the level?
        if (!forceReload && null != _loadedLevel) {
            this.startGame();
        } else {
            _loadedLevel = null;
            _levelRsrcMgr.unload("level");
            if (Constants.DEBUG_LOAD_LEVELS_FROM_DISK) {
                _levelRsrcMgr.pendResourceLoad("xml", "level", { url: "levels/level" + String(_curLevelNum + 1) + ".xml" });
            } else {
                _levelRsrcMgr.pendResourceLoad("xml", "level", { embeddedClass: LEVELS[_curLevelNum] });
            }
            _levelRsrcMgr.load();
        }
    }

    public function get curLevelNum () :int
    {
        return _curLevelNum;
    }

    public function set curLevelNum (val :int) :void
    {
        val %= LEVELS.length;

        if (_curLevelNum != val) {
            _curLevelNum = val;
            _loadedLevel = null;
        }
    }

    public function incrementLevelNum () :void
    {
        this.curLevelNum = _curLevelNum + 1;
    }

    public function get numLevels () :int
    {
        return LEVELS.length;
    }

    protected function onXmlLoaded (...ignored) :void
    {
        // Try loading the level. Alert the designer if the level has an error.
        var xmlLoader :XmlResourceLoader = (_levelRsrcMgr.getResource("level") as XmlResourceLoader);
        try {
            _loadedLevel = LevelData.fromXml(xmlLoader.xml);
        } catch (e :XmlReadError) {
            _loadedLevel = null;
            this.displayErrorScreen(e.message);
            return;
        }

        this.startGame();
    }

    protected function onXmlLoadErr (e :ResourceLoadEvent) :void
    {
        this.displayErrorScreen(e.data as String);
    }

    protected function displayErrorScreen (e :String) :void
    {
        AppContext.mainLoop.unwindToMode(new LevelLoadErrorMode(e));
    }

    protected function startGame () :void
    {
        GameContext.gameType = GameContext.GAME_TYPE_SINGLEPLAYER;
        GameContext.spLevel = _loadedLevel;
        AppContext.mainLoop.unwindToMode(new GameMode());
    }

    protected var _levelRsrcMgr :ResourceManager = new ResourceManager();
    protected var _curLevelNum :int = 0;
    protected var _loadedLevel :LevelData;

    // Embedded level data
    [Embed(source="../levels/level1.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_1 :Class;
    [Embed(source="../levels/level2.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_2 :Class;

    protected static const LEVELS :Array = [ LEVEL_1, LEVEL_2 ];

}

}
