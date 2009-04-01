package vampire.client
{
    import com.threerings.flash.MathUtil;
    import com.threerings.flash.Vector2;
    import com.threerings.util.ClassUtil;
    import com.threerings.util.Log;
    import com.whirled.EntityControl;
    import com.whirled.avrg.AVRGameAvatar;
    import com.whirled.avrg.AVRGameControl;
    import com.whirled.avrg.AVRGameRoomEvent;
    import com.whirled.contrib.simplegame.SimObject;
    import com.whirled.contrib.simplegame.objects.SimpleTimer;
    import com.whirled.net.MessageReceivedEvent;

    import vampire.avatar.AvatarGameBridge;
    import vampire.client.events.PlayerArrivedAtLocationEvent;
    import vampire.data.VConstants;
    import vampire.net.messages.MovePredIntoPositionMsg;


/**
 * The avatar
 */
public class AvatarClientController extends SimObject
{
    public function AvatarClientController (ctrl :AVRGameControl)
    {
        _ctrl = ctrl;
    }

    override protected function addedToDB () :void
    {
        //If the avatar is changed, reset the callbacks.
        registerListener(_ctrl.room, AVRGameRoomEvent.AVATAR_CHANGED, handleAvatarChanged);

        //If we start moving, and we are in bared mode, change to default mode.
        registerListener(_ctrl.room, AVRGameRoomEvent.PLAYER_MOVED, handlePlayerMoved);

        registerListener(_ctrl.player, MessageReceivedEvent.MESSAGE_RECEIVED,
            handleMessageReceived);

        resetAvatarCallbackFunctions();
    }

    override protected function destroyed () :void
    {
        super.destroyed();
        //I don't know how the garbage collecter works with these objects,
        //so just to make sure, set our callback on the avatar to null
        if (_ctrl != null && _ctrl.isConnected()) {
            var setAvatarArrivedCallback :Function = _ctrl.room.getEntityProperty(
                AvatarGameBridge.ENTITY_PROPERTY_SET_AVATAR_ARRIVED_CALLBACK, ClientContext.ourEntityId) as Function;

            if(setAvatarArrivedCallback != null) {
                setAvatarArrivedCallback(null);
            }
        }
    }


    protected function handleMessageReceived (e :MessageReceivedEvent) :void
    {
        if (e.name == VConstants.NAMED_EVENT_MOVE_PREDATOR_AFTER_FEEDING) {

            var moveTimer :SimpleTimer = new SimpleTimer(2.5, function() :void {

                var location :Array = ClientContext.model.location;
                var hotspot :Array = ClientContext.model.hotspot;
                if (location != null && hotspot != null) {

                    var xDirection :Number = location[3] > 0 && location[3] <= 180 ? 1 : -1;

                    var widthLogical :Number = hotspot[0]/_ctrl.local.getRoomBounds()[0];

                    var xDistance :Number = xDirection * widthLogical / 3;

                    _ctrl.player.setAvatarLocation(
                        MathUtil.clamp(location[0] + xDistance, 0, 1),
                        location[1],
                        MathUtil.clamp(location[2] - 0.1, 0, 1), location[3]);
                }
            }, false);
            db.addObject(moveTimer);
        }
        else if (e.name == MovePredIntoPositionMsg.NAME) {

            function convertStandardRads2GameDegrees(rad :Number) :Number
            {
                return MathUtil.toDegrees(MathUtil.normalizeRadians(rad + Math.PI / 2));
            }


            var movemsg :MovePredIntoPositionMsg = ClientContext.msg.deserializeMessage(
                e.name, e.value) as MovePredIntoPositionMsg;

            //If we are the first predator, we go directly behind the prey
            //Otherwise, take a a place
            var targetLocation :Array = movemsg.preyLocation;//ClientContext.model.getLocation(movemsg.preyId);
            var avatar :AVRGameAvatar = ClientContext.model.avatar;



            trace("MovePredIntoPositionMsg");
            trace("targetLocation=" + targetLocation);
//            trace("movemsg.preyId=" + movemsg.preyId);
//            trace("avatar=" + avatar);

            var targetX :Number;
            var targetY :Number;
            var targetZ :Number;

            //TODO: add the hotspot width /2, then test.
            var hotspot :Array = ClientContext.model.hotspot;
            trace("hotspot=" + hotspot);
            var widthLogical :Number = hotspot[0]/_ctrl.local.getRoomBounds()[0];

            var distanceLogicalAwayFromPrey :Number = widthLogical / 3;

//            var p1 :Point = ctrl.local.locationToPaintable(0, targetLocation[1],
//                targetLocation[2]);
//            var p2 :Point = ctrl.local.locationToPaintable(widthLogical, targetLocation[1],
//                targetLocation[2]);
////
//            var absoluteWidth :Number = Math.abs(p2.x - p1.x);
//            var absoluteDistanceFrom

//            _hudSprite.graphics.clear();
//            _hudSprite.graphics.beginFill(0, 0.3);
//
//            _hudSprite.graphics.drawRect(-absoluteWidth/2, 0, absoluteWidth, absoluteHeight);
//            _hudSprite.graphics.endFill();



            var angleRadians :Number = new Vector2(targetLocation[0] - avatar.x,
                targetLocation[2] - avatar.z).angle;
            var degs :Number = convertStandardRads2GameDegrees(angleRadians);

            targetX = targetLocation[0] +
                VConstants.PREDATOR_LOCATIONS_RELATIVE_TO_PREY[movemsg.predIndex][0] *
                distanceLogicalAwayFromPrey;
            targetY = targetLocation[1] +
                VConstants.PREDATOR_LOCATIONS_RELATIVE_TO_PREY[movemsg.predIndex][1] *
                distanceLogicalAwayFromPrey;
            targetZ = targetLocation[2] +
                VConstants.PREDATOR_LOCATIONS_RELATIVE_TO_PREY[movemsg.predIndex][2] *
                distanceLogicalAwayFromPrey;

            //If the avatar is already at the location, the client will dispatch a
            //PlayerArrivedAtLocation event, as the location doesn't change.
//            if(targetX == avatar.x &&
//                targetY == avatar.y &&
//                targetZ == avatar.z) {
//                log.error("Player already at location, changing to feed mode");
//                handlePlayerArrivedAtLocation(player);
//            }
//            else {
                ClientContext.ctrl.player.setAvatarLocation(targetX, targetY, targetZ, degs);
//            }
        }



    }

    protected function handlePlayerMoved (e :AVRGameRoomEvent) :void
    {
        var playerMovedId :int = int(e.value);
        if(playerMovedId == _ctrl.player.getPlayerId()) {
            if(ClientContext.model.state == VConstants.AVATAR_STATE_BARED) {
                ClientContext.controller.handleChangeState(VConstants.AVATAR_STATE_DEFAULT);
                ClientContext.model.setAvatarState(VConstants.AVATAR_STATE_DEFAULT);
            }
        }
    }

    protected function handleAvatarChanged (e :AVRGameRoomEvent) :void
    {
        checkForAvatarSwitch(e);
        checkForBaredModeViaAvatarMenu(e);
    }

    /**
    * If we change avatars, make sure to update the movement notification function
    */
    protected function checkForAvatarSwitch (e :AVRGameRoomEvent) :void
    {
//        trace("handleAvatarChanged");
        var playerAvatarChangedId :int = int(e.value);

        //We are care about our own avatar
        if(playerAvatarChangedId != _ctrl.player.getPlayerId()) {
            return;
        }

        //Get our entityId
        var currentEntityId :String;

        for each(var entityId :String in _ctrl.room.getEntityIds(EntityControl.TYPE_AVATAR)) {

            var entityUserId :int = int(_ctrl.room.getEntityProperty(EntityControl.PROP_MEMBER_ID, entityId));

            if(entityUserId == _ctrl.player.getPlayerId()) {
                currentEntityId = entityId;
                break;
            }

        }

        if(currentEntityId != _currentEntityId) {

            //Change our id for future reference.
            _currentEntityId = currentEntityId;

            //Connect to the new avatar
            resetAvatarCallbackFunctions();
        }

    }
    /**
    * We can go into 'bared' mode via the game HUD menu, or via the regular avatar menu.
    * Therefore, we must listen to changes in the avatar and check if we have gone into
    * bared mode.
    */
    protected function checkForBaredModeViaAvatarMenu (e :AVRGameRoomEvent) :void
    {
        var playerAvatarChangedId :int = int(e.value);

        //We are only allowed to change our own avatar.
        if(playerAvatarChangedId != _ctrl.player.getPlayerId()) {
            return;
        }

        //Do as if we have pushed the 'Bared" button.
        var avatar :AVRGameAvatar = _ctrl.room.getAvatarInfo(playerAvatarChangedId);
        if(avatar != null) {

            var isBared :Boolean = ClientContext.model.state == VConstants.PLAYER_STATE_BARED ||
                ClientContext.model.state == VConstants.PLAYER_STATE_FEEDING_PREY;
            //If we change our avatar to bared, but we are not in the bared player state.
            if(!isBared && avatar.state == VConstants.AVATAR_STATE_BARED) {
                ClientContext.controller.handleChangeState(VConstants.PLAYER_STATE_BARED);
            }
        }
    }

    protected function resetAvatarCallbackFunctions () :void
    {
        trace("resetting avatar callbacks");
//        trace("resetAvatarArrivedFunction, ClientContext.ourEntityId=" + ClientContext.ourEntityId);
        //Let's hear when the avatar arrived at a destination
        var setAvatarArrivedCallback :Function = _ctrl.room.getEntityProperty(
            AvatarGameBridge.ENTITY_PROPERTY_SET_AVATAR_ARRIVED_CALLBACK, ClientContext.ourEntityId) as Function;




        if(setAvatarArrivedCallback != null) {
            setAvatarArrivedCallback(avatarArrivedAtDestination);
        }
        else {
            log.error("!!!!!! This avatar is CRUSTY and old, missing AvatarGameBridge.ENTITY_PROPERTY_SET_AVATAR_ARRIVED_CALLBACK");

            trace("trying again after some time");
            var t :SimpleTimer = new SimpleTimer(1, function () :void {
                resetAvatarCallbackFunctions();
            });
            db.addObject(t);
//
//            //Ok, our avatar has changed.
//            //I can't seem to update the avatar location function, so quit the game with a warning
//            if (!VConstants.LOCAL_DEBUG_MODE) {
//                var quitPopupName :String = "QuitAvatarBorked";
//                if(ClientContext.gameMode.getObjectNamed(quitPopupName) == null) {
//                    var popup :PopupQuery = new PopupQuery(
//                        quitPopupName,
//                        "Sorry.  Vampire Whirled cannot (yet) handle a mid-game avatar change.  " +
//                        "Click the vampire icon to restart..");
//                    ClientContext.gameMode.addSceneObject(popup, ClientContext.gameMode.modeSprite);
//                    ClientContext.centerOnViewableRoom(popup.displayObject);
//                    ClientContext.animateEnlargeFromMouseClick(popup);
//
//                    var quitTimer :SimpleTimer = new SimpleTimer(5, function() :void {
//                        ClientContext.controller.handleQuit();
//                    });
//                    ClientContext.gameMode.addObject(quitTimer);
//
//                }
//            }
        }
    }

    protected function avatarArrivedAtDestination (...ignored) :void
    {
        trace(ClassUtil.getClassName(this) + "GameModel.avatarArrivedAtDestination");
        if(!_ctrl.isConnected()) {
            trace("avatarArrivedAtDestination, ctrl null, setting callback null");
            var setCallback :Function = _ctrl.room.getEntityProperty(
            AvatarGameBridge.ENTITY_PROPERTY_SET_AVATAR_ARRIVED_CALLBACK, ClientContext.ourEntityId) as Function;
            if(setCallback != null) {
                setCallback(null);
            }
            return;
        }

        trace(_ctrl.player.getPlayerId() + " Sending player arrived event");
        _ctrl.agent.sendMessage(PlayerArrivedAtLocationEvent.PLAYER_ARRIVED);
//        trace("dispatchEvent PlayerArrivedAtLocationEvent");
//        dispatchEvent(new PlayerArrivedAtLocationEvent());

    }

    protected var _ctrl :AVRGameControl;
    protected var _currentEntityId :String;
    protected static const log :Log = Log.getLog(AvatarClientController);
}
}