package bloodbloom {

import com.whirled.contrib.simplegame.MainLoop;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.Bitmap;

public class ClientCtx
{
    public static var mainLoop :MainLoop;
    public static var rsrcs :ResourceManager;
    public static var audio :AudioManager;

    public static function instantiateBitmap (name :String) :Bitmap
    {
        return ImageResource.instantiateBitmap(rsrcs, name);
    }
}

}
