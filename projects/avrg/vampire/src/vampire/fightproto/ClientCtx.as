package vampire.fightproto {

import com.whirled.contrib.simplegame.MainLoop;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.game.GameControl;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;

public class ClientCtx
{
    public static var mainSprite :Sprite;
    public static var mainLoop :MainLoop;
    public static var rsrcs :ResourceManager;
    public static var audio :AudioManager;

    public static var gameCtrl :GameControl;

    public static var player :Player;

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

    public static function instantiateButton (rsrcName :String, className :String) :SimpleButton
    {
        return SwfResource.instantiateButton(rsrcs, rsrcName, className);
    }

    public static function getSwfDisplayRoot (rsrcName :String) :DisplayObject
    {
        return SwfResource.getSwfDisplayRoot(rsrcs, rsrcName);
    }

    public static function getSwfBitmapData (rsrcName :String, bitmapName :String, width :int,
        height :int) :BitmapData
    {
        return SwfResource.getBitmapData(rsrcs, rsrcName, bitmapName, width, height);
    }

    public static function instantiateBitmap (rsrcName :String) :Bitmap
    {
        return ImageResource.instantiateBitmap(rsrcs, rsrcName);
    }
}

}
