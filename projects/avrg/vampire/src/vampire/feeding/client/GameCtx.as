package vampire.feeding.client {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.components.LocationComponent;

import flash.display.Sprite;

import vampire.feeding.*;

public class GameCtx
{
    public static var gameMode :GameMode;
    public static var heart :Heart;
    public static var cursor :PlayerCursor;
    public static var score :ScoreHelpQuitView;
    public static var specialCellSpawner :SpecialCellSpawner;
    public static var specialStrainTallyView :SpecialStrainTallyView;
    public static var sentMultiplierIndicator :SentMultiplierIndicator;
    public static var tipFactory :TipFactory;

    public static var bgLayer :Sprite;
    public static var cellBirthLayer :Sprite;
    public static var heartLayer :Sprite;
    public static var burstLayer :Sprite;
    public static var cellLayer :Sprite;
    public static var cursorLayer :Sprite;
    public static var uiLayer :Sprite;
    public static var helpLayer :Sprite;

    public static var timeLeft :Number;
    public static var gameOver :Boolean;
    public static var gotCorruption :Boolean;

    public static function init () :void
    {
        gameMode = null;
        heart = null;
        cursor = null;
        score = null;
        specialCellSpawner = null;
        specialStrainTallyView = null;
        sentMultiplierIndicator = null;

        bgLayer = null;
        cellLayer = null;
        cursorLayer = null;
        uiLayer = null;

        timeLeft = Constants.GAME_TIME;
        gameOver = false;
        gotCorruption = false;
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
