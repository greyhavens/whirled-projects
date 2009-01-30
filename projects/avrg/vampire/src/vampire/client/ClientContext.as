package vampire.client {


import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.simplegame.SimpleGame;

import flash.geom.Rectangle;

import vampire.data.Constants;
import vampire.net.MessageManager;

/**
 * Client specific functions and info.
 */
public class ClientContext
{
    public static var gameCtrl :AVRGameControl;
    public static var msg :MessageManager;
    public static var game :SimpleGame;
    public static var model :GameModel;
    public static var ourPlayerId :int;
    public static var currentClosestPlayerId :int;

    public static function quit () :void
    {
        if (gameCtrl.isConnected()) {
            gameCtrl.player.deactivateGame();
        }
    }

    public static function getScreenBounds () :Rectangle
    {
        if (gameCtrl.isConnected()) {
            var bounds :Rectangle = gameCtrl.local.getPaintableArea(true);
            // apparently getPaintableArea can return null...
            return (bounds != null ? bounds : new Rectangle());
        } else {
            return new Rectangle(0, 0, 700, 500);
        }
    }

    public static function getPlayerName (playerId :int) :String
    {
        if (gameCtrl != null && gameCtrl.isConnected() && !Constants.LOCAL_DEBUG_MODE) {
            var avatar :AVRGameAvatar = gameCtrl.room.getAvatarInfo(playerId);
            if (null != avatar) {
                return avatar.name;
            }
        }

        return "player " + playerId.toString();
    }
    
    public static function isPlayerProps() :Boolean
    {
        return model.time > 0;
    }
    
    
}

}
