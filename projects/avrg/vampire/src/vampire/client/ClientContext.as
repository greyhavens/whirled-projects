package vampire.client {


import com.threerings.util.ArrayUtil;
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
    public static var ctrl :AVRGameControl;
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
        if (ctrl.isConnected()) {
            ctrl.player.deactivateGame();
        }
    }

    public static function getScreenBounds () :Rectangle
    {
        if (ctrl.isConnected()) {
            var bounds :Rectangle = ctrl.local.getPaintableArea(true);
            // apparently getPaintableArea can return null...
            return (bounds != null ? bounds : new Rectangle());
        } else {
            return new Rectangle(0, 0, 700, 500);
        }
    }

    public static function getPlayerName (playerId :int) :String
    {
        if (ctrl != null && ctrl.isConnected() && !VConstants.LOCAL_DEBUG_MODE) {
            var avatar :AVRGameAvatar = ctrl.room.getAvatarInfo(playerId);
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
    
    public static function get ourEntityId () :String
    {
        if( _playerEntityId == null ) {
            for each( var entityId :String in ctrl.room.getEntityIds(EntityControl.TYPE_AVATAR)) {
            
                var entityUserId :int = int(ctrl.room.getEntityProperty( EntityControl.PROP_MEMBER_ID, entityId));
                
                if( entityUserId == ctrl.player.getPlayerId() ) {
                    _playerEntityId = entityId;
                    break;
                }
                
            }
        }
        
        return _playerEntityId;
    }
    
    
    public static function getPlayerEntityId ( playerId :int ) :String
    {
        for each( var entityId :String in ctrl.room.getEntityIds(EntityControl.TYPE_AVATAR)) {
        
            var entityUserId :int = int(ctrl.room.getEntityProperty( EntityControl.PROP_MEMBER_ID, entityId));
            
            if( entityUserId == playerId ) {
                return entityId;
            }
            
        }
        return null;
    }
    
    
    
    public static function getNonPlayerIds() :Array
    {
    
        var playerIds :Array = ctrl.room.getPlayerIds();
        var nonPlayerIds :Array = new Array();
        
        for each( var entityId :String in ctrl.room.getEntityIds( EntityControl.TYPE_AVATAR) ) {
            var userId :int = int(ctrl.room.getEntityProperty( EntityControl.PROP_MEMBER_ID, entityId));
            
            if( !ArrayUtil.contains( playerIds, userId ) ) {
                nonPlayerIds.push( userId );
            }
        }
        return nonPlayerIds;
    }
    
    
    
}

}
