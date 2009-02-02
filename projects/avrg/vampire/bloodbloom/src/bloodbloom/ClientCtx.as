package bloodbloom {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.MainLoop;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.Bitmap;

public class ClientCtx
{
    public static var mainLoop :MainLoop;
    public static var rsrcs :ResourceManager;
    public static var audio :AudioManager;

    public static var gameMode :GameMode;
    public static var beat :Beat;

    public static function instantiateBitmap (name :String) :Bitmap
    {
        return ImageResource.instantiateBitmap(rsrcs, name);
    }

    // Returns a new Vector, clamped within the bounds of the game
    public static function clampToGame (loc :Vector2) :Vector2
    {
        var v :Vector2 = loc.subtract(Constants.GAME_CTR);
        if (v.lengthSquared > Constants.GAME_RADIUS2) {
            v.length = Constants.GAME_RADIUS;
        }
        return v.addLocal(Constants.GAME_CTR);
    }


}

}
