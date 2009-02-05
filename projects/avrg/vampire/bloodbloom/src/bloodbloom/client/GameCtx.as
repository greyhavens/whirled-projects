package bloodbloom.client {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.components.LocationComponent;

import flash.display.Sprite;

import bloodbloom.*;

public class GameCtx
{
    public static var gameMode :GameMode;
    public static var heartbeatDb :NetObjDb;
    public static var beat :Beat;
    public static var prey :PreyCursor;
    public static var bloodMeter :PredatorBloodMeter;

    public static var cellLayer :Sprite;
    public static var cursorLayer :Sprite;
    public static var effectLayer :Sprite;

    public static function init () :void
    {
        gameMode = null;
        heartbeatDb = null;
        beat = null;
        prey = null;
        bloodMeter = null;

        cellLayer = null;
        cursorLayer = null;
        effectLayer = null;
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
