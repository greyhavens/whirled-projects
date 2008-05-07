package popcraft {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.game.GameControl;

import flash.display.Bitmap;
import flash.display.MovieClip;

import popcraft.data.*;
import popcraft.sp.LevelManager;

public class AppContext
{
    public static var mainLoop :MainLoop;
    public static var resources :ResourceManager = new ResourceManager();
    public static var gameCtrl :GameControl;
    public static var levelMgr :LevelManager = new LevelManager();

    public static function playSound (soundName :String, parentControls :AudioControllerContainer = null) :GameSoundChannel
    {
        var soundLoader :SoundResourceLoader = resources.getResource(soundName) as SoundResourceLoader;
        if (null != soundLoader) {
            return Audio.play(soundLoader.sound, parentControls);
        } else {
            return new GameSoundChannel(parentControls);
        }
    }

    public static function instantiateMovieClip (resourceName :String, className :String) :MovieClip
    {
        var swf :SwfResourceLoader = resources.getResource(resourceName) as SwfResourceLoader;
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
        var img :ImageResourceLoader = resources.getResource(resourceName) as ImageResourceLoader;
        if (null != img) {
            return img.createBitmap();
        }

        return null;
    }

    public static function get defaultGameData () :GameData
    {
        var dataRsrc :GameDataResourceLoader = resources.getResource("defaultGameData") as GameDataResourceLoader;
        return dataRsrc.gameData;
    }
}

}
