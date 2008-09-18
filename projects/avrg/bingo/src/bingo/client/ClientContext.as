package bingo.client {

import bingo.BingoItemManager;

import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.AVRGameControl;

import flash.geom.Rectangle;

public class ClientContext
{
    public static var gameMode :GameMode;
    public static var gameCtrl :AVRGameControl;
    public static var items :BingoItemManager;
    public static var model :Model;
    public static var ourPlayerId :int;

    public static function quit () :void
    {
        if (gameCtrl.isConnected()) {
            gameCtrl.player.deactivateGame();
        }
    }

    public static function getScreenBounds () :Rectangle
    {
        if (gameCtrl.isConnected()) {
            return gameCtrl.local.getStageSize(true);
        } else {
            return new Rectangle(0, 0, 700, 500);
        }
    }

    public static function getPlayerName (playerId :int) :String
    {
        if (gameCtrl.isConnected()) {
            var avatar :AVRGameAvatar = gameCtrl.room.getAvatarInfo(playerId);
            if (null != avatar) {
                return avatar.name;
            }
        }

        return "player " + playerId.toString();
    }
}

}