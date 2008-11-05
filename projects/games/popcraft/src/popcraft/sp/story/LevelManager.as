package popcraft.sp.story {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.resource.*;

import flash.utils.ByteArray;

import popcraft.*;
import popcraft.data.*;
import popcraft.util.*;

public class LevelManager
    implements UserCookieDataSource
{
    public static const TEST_LEVEL :int = -1;
    public static const DEMO_LEVEL :int = -2;

    public function LevelManager ()
    {
        resetLevelData();
    }

    protected function resetLevelData () :void
    {
        _levelRecords = [];
        for (var i :int = 0; i < NUM_LEVELS; ++i) {
            _levelRecords.push(new LevelRecord());
        }

        // make sure the first level is always unlocked
        LevelRecord(_levelRecords[0]).unlocked = true;
    }

    public function readCookieData (version :int, cookie :ByteArray) :void
    {
        try {
            _levelRecords = [];
            for (var i :int = 0; i < NUM_LEVELS; ++i) {
                _levelRecords.push(LevelRecord.fromByteArray(cookie));
            }
        } catch (e :Error) {
            resetLevelData();
            throw e;
        }
    }

    public function writeCookieData (cookie :ByteArray) :void
    {
        for each (var lr :LevelRecord in _levelRecords) {
            lr.toByteArray(cookie);
        }
    }

    public function get minCookieVersion () :int
    {
        return 0;
    }

    public function cookieReadFailed () :Boolean
    {
        resetLevelData();
        return true;
    }

    public function get totalScore () :int
    {
        var score :int;
        for each (var lr :LevelRecord in _levelRecords) {
            score += lr.score;
        }

        return score;
    }

    public function get playerBeatGameWithExpertScore () :Boolean
    {
        for each (var lr :LevelRecord in _levelRecords) {
            if (!lr.expert) {
                return false;
            }
        }

        return true;
    }

    public function get playerBeatGame () :Boolean
    {
        for each (var lr :LevelRecord in _levelRecords) {
            if (lr.score == 0) {
                return false;
            }
        }

        return true;
    }

    public function get playerStartedGame () :Boolean
    {
        return LevelRecord(_levelRecords[1]).unlocked;
    }

    public function get levelRecords () :Array
    {
        return _levelRecords;
    }

    public function getLevelRecord (levelNum :int) :LevelRecord
    {
        return (levelNum < _levelRecords.length ? _levelRecords[levelNum] : null);
    }

    public function get levelRecordsLoaded () :Boolean
    {
        return _levelRecords.length > 0;
    }

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
            startGame();

        } else {
            // load the level
            if (null == _loadedLevel) {
                var loadParams :Object;
                if (_curLevelIndex == TEST_LEVEL) {
                    loadParams = (Constants.DEBUG_LOAD_LEVELS_FROM_DISK ?
                        { url: LEVELS_DIR + "/testlevel.xml" } :
                        { embeddedClass: LEVEL_TEST });

                } else if (_curLevelIndex == DEMO_LEVEL) {
                    loadParams = (Constants.DEBUG_LOAD_LEVELS_FROM_DISK ?
                        { url: LEVELS_DIR + "/demolevel.xml" } :
                        { embeddedClass: LEVEL_DEMO });

                } else {
                    var levelNumString :String = String(_curLevelIndex + 1);
                    if (_curLevelIndex + 1 < 10) {
                        levelNumString = "0" + levelNumString;
                    }

                    loadParams = (Constants.DEBUG_LOAD_LEVELS_FROM_DISK ?
                        { url: LEVELS_DIR + "/story_" + levelNumString + ".xml" } :
                        { embeddedClass: LEVELS[_curLevelIndex] });
                }

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
                    loadLevel(loadParams);
                }
            }
        }
    }

    protected function loadLevel (loadParams :Object) :void
    {
        ResourceManager.instance.unload(RSRC_CURLEVEL);
        ResourceManager.instance.queueResourceLoad(Constants.RESTYPE_LEVEL, RSRC_CURLEVEL,
            loadParams);
        ResourceManager.instance.loadQueuedResources(onLevelLoaded, onLoadError);
    }

    public function get curLevelName () :String
    {
        var levelNames :Array = AppContext.levelProgression.levelNames;
        if (_curLevelIndex >= 0 && _curLevelIndex < levelNames.length) {
            return levelNames[_curLevelIndex];
        }

        return "(Level " + String(_curLevelIndex + 1) + ")";
    }

    public function get curLevelIndex () :int
    {
        return _curLevelIndex;
    }

    public function get isLastLevel () :Boolean
    {
        return (_curLevelIndex == this.numLevels - 1);
    }

    public function set curLevelIndex (val :int) :void
    {
        val = (val < 0 ? val : val % LEVELS.length);

        if (_curLevelIndex != val) {
            _curLevelIndex = val;
            _loadedLevel = null;
        }
    }

    public function incrementCurLevelIndex () :void
    {
        if (_curLevelIndex >= 0) {
            this.curLevelIndex = _curLevelIndex + 1;
        }
    }

    public function get highestUnlockedLevelIndex () :int
    {
        for (var i :int = _levelRecords.length - 1; i >= 0; --i) {
            var lr :LevelRecord = _levelRecords[i];
            if (lr.unlocked) {
                return i;
            }
        }

        return 0;
    }

    public function get numLevels () :int
    {
        return LEVELS.length;
    }

    protected function onLevelLoaded () :void
    {
        _loadedLevel = LevelResource(ResourceManager.instance.getResource(RSRC_CURLEVEL)).levelData;
        startGame();
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

    protected var _curLevelIndex :int = 0;
    protected var _loadedLevel :LevelData;
    protected var _levelRecords :Array = [];
    protected var _recordsLoaded :Boolean;
    protected var _levelReadyCallback :Function;

    protected static var log :Log = Log.getLog(LevelManager);

    protected static const RSRC_CURLEVEL :String = "curLevel";
    protected static const LEVELS_DIR :String = "../levels";

    // Embedded level data
    [Embed(source="../../../../levels/story_01.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_1 :Class;
    [Embed(source="../../../../levels/story_02.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_2 :Class;
    [Embed(source="../../../../levels/story_03.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_3 :Class;
    [Embed(source="../../../../levels/story_04.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_4 :Class;
    [Embed(source="../../../../levels/story_05.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_5 :Class;
    [Embed(source="../../../../levels/story_06.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_6 :Class;
    [Embed(source="../../../../levels/story_07.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_7 :Class;
    [Embed(source="../../../../levels/story_08.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_8 :Class;
    [Embed(source="../../../../levels/story_09.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_9 :Class;
    [Embed(source="../../../../levels/story_10.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_10 :Class;
    [Embed(source="../../../../levels/story_11.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_11 :Class;
    [Embed(source="../../../../levels/story_12.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_12 :Class;
    [Embed(source="../../../../levels/story_13.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_13 :Class;
    [Embed(source="../../../../levels/story_14.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_14 :Class;

    [Embed(source="../../../../levels/testlevel.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_TEST :Class;
    [Embed(source="../../../../levels/demolevel.xml", mimeType="application/octet-stream")]
    protected static const LEVEL_DEMO :Class;

    protected static const LEVELS :Array = [
        LEVEL_1,
        LEVEL_2,
        LEVEL_3,
        LEVEL_4,
        LEVEL_5,
        LEVEL_6,
        LEVEL_7,
        LEVEL_8,
        LEVEL_9,
        LEVEL_10,
        LEVEL_11,
        LEVEL_12,
        LEVEL_13,
        LEVEL_14,
    ];

    protected static const NUM_LEVELS :int = 14;
}

}
