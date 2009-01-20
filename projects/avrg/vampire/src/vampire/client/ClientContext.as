package vampire.client {


import vampire.client.modes.BloodBondMode;
import vampire.client.modes.FeedMode;
import vampire.client.modes.FightMode;
import vampire.client.modes.HierarchyMode;

import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.AVRGameControl;

import flash.geom.Rectangle;

/**
 * Client specific functions and info.
 */
public class ClientContext
{
    public static var gameCtrl :AVRGameControl;
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
            var bounds :Rectangle = gameCtrl.local.getPaintableArea(true);
            // apparently getPaintableArea can return null...
            return (bounds != null ? bounds : new Rectangle());
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
