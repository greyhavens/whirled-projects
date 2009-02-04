package bloodbloom.client {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.MainLoop;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.components.LocationComponent;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.game.GameControl;

import flash.display.Bitmap;
import flash.display.MovieClip;
import flash.display.Sprite;

public class ClientCtx
{
    public static var gameCtrl :GameControl;
    public static var mainLoop :MainLoop;
    public static var rsrcs :ResourceManager;
    public static var audio :AudioManager;

    public static var gameMode :GameMode;
    public static var heartbeatDb :NetObjDb;
    public static var beat :Beat;
    public static var prey :PreyCursor;
    public static var bloodMeter :PredatorBloodMeter;

    public static var cellLayer :Sprite;
    public static var cursorLayer :Sprite;
    public static var effectLayer :Sprite;

    public static function createCellBitmap (type :int) :Bitmap
    {
        var bm :Bitmap = instantiateBitmap(type == Constants.CELL_RED ? "red_cell" : "white_cell");
        bm.x = -bm.width * 0.5;
        bm.y = -bm.height * 0.5;
        return bm;
    }

    public static function instantiateBitmap (name :String) :Bitmap
    {
        return ImageResource.instantiateBitmap(rsrcs, name);
    }

    public static function instantiateMovieClip (rsrcName :String, className :String,
        disableMouseInteraction :Boolean = false, fromCache :Boolean = false) :MovieClip
    {
        return SwfResource.instantiateMovieClip(
            rsrcs,
            rsrcName,
            className,
            disableMouseInteraction,
            fromCache);
    }

    // Returns a new Vector, clamped within the bounds of the game
    public static function clampLoc (loc :Vector2) :Vector2
    {
        // clamp to the background
        var v :Vector2 = loc.subtract(Constants.GAME_CTR);
        if (v.lengthSquared > Constants.GAME_RADIUS2) {
            v.length = Constants.GAME_RADIUS;
        }

        // don't enter the heart
        if (v.lengthSquared < Constants.HEART_RADIUS2) {
            v.length = Constants.HEART_RADIUS;
        }

        return v.addLocal(Constants.GAME_CTR);
    }

    public static function getHemisphere (obj :LocationComponent) :int
    {
        return (obj.x < Constants.GAME_CTR.x ? Constants.HEMISPHERE_WEST :
            Constants.HEMISPHERE_EAST);
    }

}

}
