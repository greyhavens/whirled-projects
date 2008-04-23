package popcraft {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.game.GameControl;

import flash.display.Bitmap;
import flash.display.MovieClip;

import popcraft.sp.LevelLoader;

public class AppContext
{
    public static var mainLoop :MainLoop;
    public static var resources :ResourceManager = new ResourceManager();
    public static var gameCtrl :GameControl;
    public static var levelLoader :LevelLoader = new LevelLoader();

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
}

}
