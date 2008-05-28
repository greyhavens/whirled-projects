package popcraft {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.game.GameControl;

import popcraft.data.*;
import popcraft.sp.LevelManager;

public class AppContext
{
    public static var mainLoop :MainLoop;
    public static var gameCtrl :GameControl;
    public static var levelMgr :LevelManager;
    public static var randStreamPuzzle :uint;

    public static function get defaultGameData () :GameData
    {
        var dataRsrc :GameDataResource = ResourceManager.instance.getResource("defaultGameData") as GameDataResource;
        return dataRsrc.gameData;
    }

    public static function get levelProgression () :LevelProgressionData
    {
        var dataRsrc :GameDataResource = ResourceManager.instance.getResource("defaultGameData") as GameDataResource;
        return dataRsrc.levelProgression;
    }
}

}
