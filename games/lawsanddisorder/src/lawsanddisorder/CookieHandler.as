package lawsanddisorder {

import com.whirled.contrib.UserCookie;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.utils.Timer;

import lawsanddisorder.component.*;

/**
 * Stores player information across multiple game sessions.  Information includes progress towards
 * multi-session trophies, and default single player settings.
 */
public class CookieHandler
{
    /** Cookie Id for the array of jobs whose powers have been used across all games */
    public static var POWERS_USED :String = "powersUsed";
    
    /** Cookie Id for the count of laws ever created by this player across all games */
    public static var NUM_LAWS_PLAYED :String = "numLawsPlayed";
    
    /** Cookie Id for the default speed in 1 player games */
    public static var DEFAULT_AI_SPEED :String = "defaultSpeed";
    
    /** Cookie Id for the default ai level in 1 player games */
    public static var DEFAULT_AI_LEVEL :String = "defaultAILevel";
    
    /** Cookie Id for the default number of ai players in 1 player games */
    public static var DEFAULT_NUM_AI :String = "defaultNumAI";
    
    /** Cookie Id for the default sound settings in 1 player games */
    public static var DEFAULT_SOUND :String = "defaultSound";
    
    /** Persistant data across multiple games for the player */
    public static var cookie :UserCookie;
    
    /**
     * Constructor - fetch persistant data from the server cookie
     */
    public static function init (ctx :Context, gotCookieFunction :Function) :void
    {
        _ctx = ctx;
        
        // dummy array of the job powers this player has ever used
        var powersUsed :Array = [];
        for (var jobId :int = 0; jobId < 6; jobId++) {
            powersUsed.push(UserCookie.getIntParameter("", 0));
        }
        
        var cookieDef :Array = [
            // version 1
            UserCookie.getVersionParameter(),
            UserCookie.getIntParameter(NUM_LAWS_PLAYED, 0),
            UserCookie.getArrayParameter(POWERS_USED, powersUsed),
            // added in version 2
            UserCookie.getVersionParameter(),
            UserCookie.getStringParameter(DEFAULT_AI_SPEED, Context.SPEED_SLOW_STRING),
            UserCookie.getStringParameter(DEFAULT_AI_LEVEL, Context.LEVEL_DUMBEST_STRING),
            UserCookie.getStringParameter(DEFAULT_NUM_AI, "2"),
            UserCookie.getStringParameter(DEFAULT_SOUND, Context.SOUND_ALL_STRING)
        ];
         
        UserCookie.getCookie(_ctx.control, function gotCookie (cookie :UserCookie) :void {
                CookieHandler.cookie = cookie;
                gotCookieFunction();
            }, cookieDef);
    }
    
    /** Context */
    protected static var _ctx :Context;
}
}