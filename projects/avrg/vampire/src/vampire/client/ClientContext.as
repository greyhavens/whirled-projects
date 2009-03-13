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
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;

import vampire.avatar.AvatarGameBridge;
import vampire.avatar.VampireAvatarHUDOverlay;
import vampire.data.Codes;
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
    public static var avatarOverlay :VampireAvatarHUDOverlay;
    public static var ourPlayerId :int;
    public static var currentClosestPlayerId :int;

    public static var controller :VampireController;

    public static var isNewPlayer :Boolean = false;


    protected static var _playerEntityId :String;
    protected static var _playerRoomKey :String;

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

    public static function get ourRoomKey () :String
    {
        if( _playerRoomKey == null ) {
            _playerRoomKey = Codes.playerRoomPropKey( ClientContext.ourPlayerId );
        }

        return _playerRoomKey;
    }


    public static function clearOurEntityId () :void
    {
        _playerEntityId = null;
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


    public static function get avatarNumberInRoom() :int
    {
        return ctrl.room.getEntityIds(EntityControl.TYPE_AVATAR).length
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

    public static function get isWearingValidAvatar() :Boolean
    {
        var isLegal :Object = ClientContext.ctrl.room.getEntityProperty(
            AvatarGameBridge.ENTITY_PROPERTY_IS_LEGAL_AVATAR, ClientContext.ourEntityId);

        return isLegal != null && Boolean(isLegal);
    }

    public static function isAdmin( playerId :int ) :Boolean
    {
        return playerId == 23340 || //Ragbeard
               playerId == 1769  || //Capital-T-Tim
               playerId == 12    || //Nemo
               playerId == 1     || //local msoy
               playerId == 2     || //local msoy
               playerId == 3     || //local msoy
               playerId == 1734     || //dev Dion
               playerId == 1735     || //dev Ragbeard's Evil Twin

               playerId == VConstants.UBER_VAMP_ID; //Übervamp
    }

    //FOr debugging positions
    public static function drawDotAtCenter( s :Sprite ) :void
    {
        s.graphics.beginFill(0xffffff);
        s.graphics.drawCircle(0,0,10);
        s.graphics.endFill();
    }

    public static const glowFilter :GlowFilter = new GlowFilter(0xffffff);

}

}
