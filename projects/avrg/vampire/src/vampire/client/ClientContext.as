package vampire.client {


import com.whirled.EntityControl;
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.simplegame.SimpleGame;
import com.whirled.contrib.simplegame.resource.ResourceManager;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.geom.Rectangle;

import vampire.data.VConstants;
import vampire.net.VMessageManager;

/**
 * Client specific functions and info.
 */
public class ClientContext
{
    public static var gameCtrl :AVRGameControl;
    public static var msg :VMessageManager;
    
    public static var game :SimpleGame;
    public static var gameResources :ResourceManager;
    
    public static var model :GameModel;
    public static var hud :HUD;
    public static var ourPlayerId :int;
    public static var currentClosestPlayerId :int;
    
    public static var controller :VampireController;
    
    
    protected static var _playerEntityId :String;

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
        if (gameCtrl != null && gameCtrl.isConnected() && !VConstants.LOCAL_DEBUG_MODE) {
            var avatar :AVRGameAvatar = gameCtrl.room.getAvatarInfo(playerId);
            if (null != avatar) {
                return avatar.name;
            }
        }

        return "Player " + playerId.toString();
    }
    
    public static function isPlayerProps() :Boolean
    {
        return model.time > 0;
    }
    
    public static function instantiateMovieClip (rsrcName :String, className :String,
        disableMouseInteraction :Boolean = false, fromCache :Boolean = false) :MovieClip
    {
        return SwfResource.instantiateMovieClip(
            game.ctx.rsrcs,
            rsrcName,
            className,
            disableMouseInteraction,
            fromCache);
    }
    
    public static function instantiateButton (rsrcName :String, className :String) :SimpleButton
    {
        return SwfResource.instantiateButton(
            game.ctx.rsrcs,
            rsrcName,
            className);
    }
    
    public static function get playerEntityId () :String
    {
        if( _playerEntityId == null ) {
            for each( var entityId :String in gameCtrl.room.getEntityIds(EntityControl.TYPE_AVATAR)) {
            
                var entityUserId :int = int(gameCtrl.room.getEntityProperty( EntityControl.PROP_MEMBER_ID, entityId));
                
                if( entityUserId == gameCtrl.player.getPlayerId() ) {
                    _playerEntityId = entityId;
                    break;
                }
                
            }
        }
        
        return _playerEntityId;
    }
    
    
}

}
