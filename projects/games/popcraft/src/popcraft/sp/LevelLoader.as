package popcraft.sp {

import com.whirled.contrib.simplegame.resource.*;

import popcraft.*;

public class LevelLoader
{
    public function LevelLoader ()
    {
        _levelRsrcMgr.addEventListener(ResourceLoadEvent.LOADED, onXmlLoaded);
        _levelRsrcMgr.addEventListener(ResourceLoadEvent.ERROR, onXmlLoadErr);
    }

    public function loadLevel (levelNum :int) :void
    {
        _levelRsrcMgr.unload("level");

        if (Constants.DEBUG_LOAD_LEVELS_FROM_DISK) {
            _levelRsrcMgr.pendResourceLoad("xml", "level", { url: "levels/level" + levelNum + ".xml" });

        } else {
            _levelRsrcMgr.pendResourceLoad("xml", "level", { embeddedClass: LEVELS[levelNum - 1] });
        }

        _levelRsrcMgr.load();
    }

    protected function onXmlLoaded (...ignored) :void
    {
        // Try loading the level. Alert the designer if the level has an error.
        var xmlLoader :XmlResourceLoader = (_levelRsrcMgr.getResource("level") as XmlResourceLoader);
        var levelData :LevelData;
        try {
            levelData = LevelData.fromXml(xmlLoader.xml);
        } catch (e :XmlReadError) {
            this.displayErrorScreen(e.message);
            return;
        }

        GameContext.gameType = GameContext.GAME_TYPE_SINGLEPLAYER;
        GameContext.spLevel = levelData;
        AppContext.mainLoop.changeMode(new GameMode());
    }

    protected function onXmlLoadErr (e :ResourceLoadEvent) :void
    {
        this.displayErrorScreen(e.data as String);
    }

    protected function displayErrorScreen (e :String) :void
    {
        AppContext.mainLoop.pushMode(new LevelLoadErrorMode(e));
    }

    protected var _levelRsrcMgr :ResourceManager = new ResourceManager();

    [Embed(source="../levels/level1.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_1 :Class;

    protected static const LEVELS :Array = [ LEVEL_1 ];

}

}
