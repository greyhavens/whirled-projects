package vampire.feeding.client {

import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.simplegame.MainLoop;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.Bitmap;
import flash.display.MovieClip;
import flash.utils.getTimer;

import vampire.feeding.*;

public class ClientCtx
{
    public static var gameCtrl :AVRGameControl;
    public static var mainLoop :MainLoop;
    public static var rsrcs :ResourceManager;
    public static var audio :AudioManager;

    public static function get localPlayerId () :int
    {
        return (isSinglePlayer ? 0 : gameCtrl.player.getPlayerId());
    }

    public static function get isSinglePlayer () :Boolean
    {
        return (!gameCtrl.isConnected());
    }

    public static function get isMultiplayer () :Boolean
    {
        return !isSinglePlayer;
    }

    public static function get timeNow () :Number
    {
        return flash.utils.getTimer() * 0.001; // returns seconds
    }

    public static function get isConnected () :Boolean
    {
        return gameCtrl.isConnected();
    }

    public static function getPlayerName (playerId :int) :String
    {
        if (gameCtrl.isConnected()) {
            var avatar :AVRGameAvatar = gameCtrl.room.getAvatarInfo(playerId);
            if (null != avatar) {
                return avatar.name;
            }
        }

        return "";
    }

    public static function createCellBitmap (type :int) :Bitmap
    {
        var bm :Bitmap;
        switch (type) {
        case Constants.CELL_RED:
            bm = instantiateBitmap("red_cell");
            break;

        case Constants.CELL_WHITE:
            bm = instantiateBitmap("white_cell");
            break;

        case Constants.CELL_BONUS:
            bm = instantiateBitmap("bonus_cell");
            break;
        }

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
}

}
