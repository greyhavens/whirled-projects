package vampire.client {


import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.EntityControl;
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.SimpleGame;
import com.whirled.contrib.simplegame.net.BasicMessageManager;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.ResourceManager;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.contrib.simplegame.tasks.LocationTask;
import com.whirled.contrib.simplegame.tasks.ScaleTask;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.geom.Rectangle;

import vampire.Util;
import vampire.avatar.VampireAvatarHUDOverlay;
import vampire.avatar.VampireBody;
import vampire.data.Codes;
import vampire.data.VConstants;

/**
 * Client specific functions and info.
 */
public class ClientContext
{
    public static var ctrl :AVRGameControl;
    public static var msg :BasicMessageManager;

    public static var game :SimpleGame;
    public static var gameResources :ResourceManager;

    public static var model :GameModel;

    /**The main game mode to add all game objects.*/
    public static var gameMode :AppMode;
    public static var hud :HUD;
    public static var avatarOverlay :VampireAvatarHUDOverlay;
    public static var ourPlayerId :int;
    public static var currentClosestPlayerId :int;

    public static var controller :VampireController;

    public static var tutorial :Tutorial;

    public static var isNewPlayer :Boolean = false;

    protected static var _playerRoomKey :String;


    public static function init (gameControl :AVRGameControl) :void
    {
        ctrl = gameControl;
        if (ctrl != null && ctrl.isConnected()) {
            ourPlayerId = ctrl.player.getPlayerId();
        }
        msg = new BasicMessageManager();
        vampire.Util.initMessageManager(msg);
    }
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

    public static function isPlayerProps () :Boolean
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
        for each(var entityId :String in ctrl.room.getEntityIds(EntityControl.TYPE_AVATAR)) {
            var entityUserId :int = int(ctrl.room.getEntityProperty(EntityControl.PROP_MEMBER_ID, entityId));
            if(entityUserId == ctrl.player.getPlayerId()) {
                return entityId;
            }
        }
        return null;
    }

    public static function get ourRoomKey () :String
    {
        if(_playerRoomKey == null) {
            _playerRoomKey = Codes.playerRoomPropKey(ClientContext.ourPlayerId);
        }

        return _playerRoomKey;
    }

    public static function getPlayerEntityId (playerId :int) :String
    {
        for each(var entityId :String in ctrl.room.getEntityIds(EntityControl.TYPE_AVATAR)) {

            var entityUserId :int = int(ctrl.room.getEntityProperty(EntityControl.PROP_MEMBER_ID, entityId));

            if(entityUserId == playerId) {
                return entityId;
            }

        }
        return null;
    }


    public static function get avatarNumberInRoom () :int
    {
        return ctrl.room.getEntityIds(EntityControl.TYPE_AVATAR).length
    }


    public static function getNonPlayerIds () :Array
    {

        var playerIds :Array = ctrl.room.getPlayerIds();
        var nonPlayerIds :Array = new Array();

        for each(var entityId :String in ctrl.room.getEntityIds(EntityControl.TYPE_AVATAR)) {
            var userId :int = int(ctrl.room.getEntityProperty(EntityControl.PROP_MEMBER_ID, entityId));

            if(!ArrayUtil.contains(playerIds, userId)) {
                nonPlayerIds.push(userId);
            }
        }
        return nonPlayerIds;
    }

    public static function getAvatarIds (excludeOurId :Boolean = false) :Array
    {
        var avatarIds :Array = new Array();

        for each(var entityId :String in ctrl.room.getEntityIds(EntityControl.TYPE_AVATAR)) {
            var userId :int = int(ctrl.room.getEntityProperty(EntityControl.PROP_MEMBER_ID, entityId));
            if(!(excludeOurId && ourPlayerId == userId)) {
                avatarIds.push(userId);
            }
        }
        return avatarIds;
    }

    public static function get isWearingValidAvatar () :Boolean
    {
        var isLegal :Object = ClientContext.ctrl.room.getEntityProperty(
            VampireBody.ENTITY_PROPERTY_IS_LEGAL_AVATAR, ClientContext.ourEntityId);

        return isLegal != null && Boolean(isLegal);
    }

    public static function isAdmin (playerId :int) :Boolean
    {
        return playerId == 23340 || //Ragbeard
               playerId == 1769  || //Capital-T-Tim
               playerId == 12    || //Nemo (Whirled and dev).
//               playerId == 1     || //local msoy
//               playerId == 2     || //local msoy
//               playerId == 3     || //local msoy
//               playerId == 1734     || //dev Dion
//               playerId == 1735     || //dev Ragbeard's Evil Twin
               playerId == VConstants.UBER_VAMP_ID; //Übervamp
    }

    //FOr debugging positions
    public static function drawDotAtCenter (s :Sprite) :void
    {
        s.graphics.beginFill(0x00ffff);
        s.graphics.drawCircle(0,0,10);
        s.graphics.endFill();
    }

    public static function animateEnlargeFromMouseClick (so :SceneObject) :void
    {

        var finalX :int = so.x;
        var finalY :int = so.y;

        //Get the mouse point
        var mouseX :int = so.displayObject.parent.mouseX;
        var mouseY :int = so.displayObject.parent.mouseY;
        so.x = mouseX;
        so.y = mouseY;

        so.scaleX = so.scaleY = 0.1;
        so.addTask(ScaleTask.CreateEaseIn(1, 1, ANIMATION_TIME));
        so.addTask(LocationTask.CreateEaseIn(finalX, finalY, ANIMATION_TIME));
    }

    public static function centerOnViewableRoom (d :DisplayObject) :void
    {
        if (d.parent == null) {
            log.error("centerOnViewableRoom, add to parent first", "d", d);
//            throw new Error("centerOnViewableRoom, add to parent first");
        }
        //Workaround as roombounds can be bigger than the paintable area
        var middlePoint :Point = new Point();
//        if(ctrl.local.getRoomBounds()[0] > ctrl.local.getPaintableArea().width) {
            middlePoint.x = ctrl.local.getPaintableArea().width/2;
            middlePoint.y = ctrl.local.getPaintableArea().height/2;
//        }
//        else {
//
//            middlePoint.x = ctrl.local.getRoomBounds()[0]/2;
//            middlePoint.y = ctrl.local.getRoomBounds()[1]/2;
//        }

//        var local :Point = d.parent.globalToLocal(middlePoint);
        d.x = middlePoint.x;
        d.y = middlePoint.y;
    }

    public static function placeTopRight (d :DisplayObject) :void
    {
        //Workaround as roombounds can be bigger than the paintable area
        if(ctrl.local.getRoomBounds()[0] > ctrl.local.getPaintableArea().width) {
            d.x = ctrl.local.getPaintableArea().width;
            d.y = 0;
        }
        else {
            d.x = ctrl.local.getRoomBounds()[0];
            d.y = 0;
        }
//        var bounds :Rectangle = d.getBounds(d.parent);
//        d.x += -bounds.x - bounds.width / 2;
//        d.y += -bounds.y - bounds.height / 2;
    }

    protected static const ANIMATION_TIME :Number = 0.3;
    public static const glowFilter :GlowFilter = new GlowFilter(0xffffff);

    protected static const log :Log = Log.getLog(ClientContext);

}

}
