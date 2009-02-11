package bloodbloom.client {

import bloodbloom.*;

import com.whirled.contrib.simplegame.MainLoop;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.net.BasicMessageManager;
import com.whirled.contrib.simplegame.net.Message;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.game.GameControl;
import com.whirled.game.NetSubControl;

import flash.display.Bitmap;
import flash.display.MovieClip;
import flash.utils.getTimer;

public class ClientCtx
{
    public static var gameCtrl :GameControl;
    public static var mainLoop :MainLoop;
    public static var rsrcs :ResourceManager;
    public static var audio :AudioManager;
    public static var msgMgr :BasicMessageManager;

    public static function get isSinglePlayer () :Boolean
    {
        return (!gameCtrl.isConnected() || gameCtrl.game.seating.getPlayerIds().length == 1);
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

    public static function sendMessage (msg :Message) :void
    {
        if (gameCtrl.isConnected()) {
            gameCtrl.net.sendMessage(
                msg.name,
                msgMgr.serializeMsg(msg),
                NetSubControl.TO_SERVER_AGENT);
        }
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
