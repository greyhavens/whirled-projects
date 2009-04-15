package vampire.quest.client {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.Bitmap;
import flash.display.MovieClip;

import vampire.quest.PlayerQuestData;
import vampire.quest.PlayerQuestStats;

public class ClientCtx
{
    public static var mainLoop :MainLoop;
    public static var rsrcs :ResourceManager;
    public static var questData :PlayerQuestData;
    public static var stats :PlayerQuestStats;

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
}

}
