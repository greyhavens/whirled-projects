package vampire.quest.client {

import com.whirled.avrg.AVRGameControl;
import com.threerings.flashbang.*;
import com.threerings.flashbang.resource.*;

import flash.display.Bitmap;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.geom.Rectangle;

public class ClientCtx
{
    public static var gameCtrl :AVRGameControl;
    public static var mainLoop :MainLoop;
    public static var rsrcs :ResourceManager;
    public static var appMode :AppMode;
    public static var questData :PlayerQuestData;
    public static var questProps :PlayerQuestProps;
    public static var notificationMgr :NotificationMgr;

    public static var dockSprite :DockSprite;
    public static var hudSprite :Sprite;
    public static var minigameLayer :Sprite;
    public static var notificationLayer :Sprite;

    public static function getPaintableArea (full :Boolean = true) :Rectangle
    {
        return (gameCtrl.isConnected() ?
            gameCtrl.local.getPaintableArea(full) :
            new Rectangle(0, 0, 1000, 700));
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

    public static function instantiateButton (rsrcName :String, className :String) :SimpleButton
    {
        return SwfResource.instantiateButton(rsrcs, rsrcName, className);
    }
}

}
