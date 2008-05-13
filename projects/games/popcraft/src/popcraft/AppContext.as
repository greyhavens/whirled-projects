package popcraft {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.game.GameControl;

import flash.display.Bitmap;
import flash.display.MovieClip;
import flash.media.Sound;

import popcraft.data.*;
import popcraft.sp.LevelManager;

public class AppContext
{
    public static var mainLoop :MainLoop;
    public static var gameCtrl :GameControl;
    public static var levelMgr :LevelManager = new LevelManager();

    public static function instantiateMovieClip (resourceName :String, className :String) :MovieClip
    {
        var swf :SwfResourceLoader = ResourceManager.instance.getResource(resourceName) as SwfResourceLoader;
        if (null != swf) {
            var movieClass :Class = swf.getClass(className);
            if (null != movieClass) {
                return new movieClass();
            }
        }

        return null;
    }

    public static function instantiateBitmap (resourceName :String) :Bitmap
    {
        var img :ImageResourceLoader = ResourceManager.instance.getResource(resourceName) as ImageResourceLoader;
        if (null != img) {
            return img.createBitmap();
        }

        return null;
    }

    public static function get defaultGameData () :GameData
    {
        var dataRsrc :GameDataResourceLoader = ResourceManager.instance.getResource("defaultGameData") as GameDataResourceLoader;
        return dataRsrc.gameData;
    }
}

}
