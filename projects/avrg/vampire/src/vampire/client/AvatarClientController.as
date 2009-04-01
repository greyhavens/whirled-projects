package vampire.client
{
    import com.threerings.flash.MathUtil;
    import com.threerings.flash.Vector2;
    import com.threerings.util.Log;
    import com.whirled.EntityControl;
    import com.whirled.avrg.AVRGameAvatar;
    import com.whirled.avrg.AVRGameControl;
    import com.whirled.avrg.AVRGameRoomEvent;
    import com.whirled.contrib.simplegame.ObjectMessage;
    import com.whirled.contrib.simplegame.SimObject;
    import com.whirled.contrib.simplegame.objects.SimpleTimer;
    import com.whirled.net.MessageReceivedEvent;

    import vampire.avatar.AvatarEndMovementNotifier;
    import vampire.data.VConstants;
    import vampire.net.messages.MovePredIntoPositionMsg;
    import vampire.net.messages.PlayerArrivedAtLocationMsg;


/**
 * The avatar
 */
public class AvatarClientController extends SimObject
{
    public function AvatarClientController (ctrl :AVRGameControl)
    {
        _ctrl = ctrl;
    }

    override public function get objectName () :String
    {
        return NAME;
    }

    override protected function addedToDB () :void
    {
        //If the avatar is changed, reset the callbacks.
        registerListener(_ctrl.room, AVRGameRoomEvent.AVATAR_CHANGED, handleAvatarChanged);
        //If we start moving, and we are in bared mode, change to default mode.
        registerListener(_ctrl.room, AVRGameRoomEvent.PLAYER_MOVED, handlePlayerMoved);
        registerListener(_ctrl.player, MessageReceivedEvent.MESSAGE_RECEIVED,
            handleMessageReceived);
        //Listen for avatar state changes.
//        registerListener(_ctrl.room.props, ElementChangedEvent.ELEMENT_CHANGED, handleElementChanged);

        resetAvatarCallbackFunctions();
    }
















//    protected function handleElementChanged (e :ElementChangedEvent) :void
//    {
//        //Why do I have to do this?  Is there a race condidtion, where the game is shutdown
//        //but it's still receiving updates?
//        if (!_ctrl.isConnected()) {
//            return;
//        }
//
//        var playerIdUpdated :int = SharedPlayerStateClient.parsePlayerIdFromPropertyName(e.name);
//
//        if (playerIdUpdated == _ctrl.player.getPlayerId()) {
//
//            //If a state change comes in, inform the avatar
//            if(e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_AVATAR_STATE) {
//
//                var setStateFunction :Function = _ctrl.room.getEntityProperty(
//                    AvatarGameBridge.ENTITY_PROPERTY_SETSTATE_FUNCTION, ourEntityId) as Function;
//
//                _ctrl.player.setAvatarState(e.newValue.toString());
//            }
//        }
//    }


    protected function get ourEntityId () :String
    {
        for each(var entityId :String in _ctrl.room.getEntityIds(EntityControl.TYPE_AVATAR)) {
            var entityUserId :int = int(_ctrl.room.getEntityProperty(EntityControl.PROP_MEMBER_ID, entityId));
            if(entityUserId == _ctrl.player.getPlayerId()) {
                return entityId;
            }
        }
        return null;
    }

    override protected function destroyed () :void
    {
        super.destroyed();
        //I don't know how the garbage collecter works with these objects,
        //so just to make sure, set our callback on the avatar to null
        if (_ctrl != null && _ctrl.isConnected()) {
            var setAvatarArrivedCallback :Function = _ctrl.room.getEntityProperty(
                AvatarEndMovementNotifier.ENTITY_PROPERTY_SET_AVATAR_ARRIVED_CALLBACK, ClientContext.ourEntityId) as Function;

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
            AvatarEndMovementNotifier.ENTITY_PROPERTY_SET_AVATAR_ARRIVED_CALLBACK, ClientContext.ourEntityId) as Function;




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

    protected function avatarArrivedAtDestination (playerId :int, location :Array) :void
    {
        if (!_ctrl.isConnected()) {
            return;
        }
//        trace(ClassUtil.getClassName(this) + "GameModel.avatarArrivedAtDestination");
//        if(!_ctrl.isConnected()) {
//            trace("avatarArrivedAtDestination, ctrl null, setting callback null");
//            var setCallback :Function = _ctrl.room.getEntityProperty(
//            AvatarGameBridge.ENTITY_PROPERTY_SET_AVATAR_ARRIVED_CALLBACK,
//                ClientContext.ourEntityId) as Function;
//            if(setCallback != null) {
//                setCallback(null);
//            }
//            return;
//        }

        //If our player moved, inform the server.
        if (playerId == _ctrl.player.getPlayerId()) {
            trace(_ctrl.player.getPlayerId() + " Sending player arrived event");
            _ctrl.agent.sendMessage(PlayerArrivedAtLocationMsg.NAME,
                new PlayerArrivedAtLocationMsg(_ctrl.player.getPlayerId()).toBytes());


    //        trace("dispatchEvent PlayerArrivedAtLocationEvent");
    //        dispatchEvent(new PlayerArrivedAtLocationEvent());

            //And if this is our avatar, and we have a target to stand behind,
            //make sure we are in the same orientation.
            //And adjust our angle to our targets, if we have a target
            //If our location is the same as our targets, we have the same orientation
            //otherwise, we want to face our target
            if(_avatarIdToStandBehind != 0) {

                var targetEntityId :String = getEntityId(_avatarIdToStandBehind);

                var targetLocation :Array = _ctrl.room.getEntityProperty(
                    EntityControl.PROP_LOCATION_LOGICAL, targetEntityId) as Array;

                //If we are not the first predator, standing slightly behind the target, make
                //sure we are facing the same orientation as th target.  If we aren't the first
                //pred, face the target
                var distance :Number = MathUtil.distance(location[0], location[2], targetLocation[0], targetLocation[2]);
                if(distance <= MINIMUM_FIRST_TARGET_DISTANCE) {
                    var targetorientation :Number = Number(_ctrl.room.getEntityProperty(
                        EntityControl.PROP_ORIENTATION, targetEntityId));
                    _ctrl.player.setAvatarLocation(location[0], location[1], location[2], targetorientation);
                }
                else {
                    var faceTargetOrientation :Number = targetLocation[0] < location[0] ? 270 : 90;
                    _ctrl.player.setAvatarLocation(location[0], location[1], location[2], faceTargetOrientation);
                }

                //Reset our target
                _avatarIdToStandBehind = 0;
            }
        }

    }

    public function getEntityId (playerId :int) :String
    {
        for each(var entityId :String in _ctrl.room.getEntityIds(EntityControl.TYPE_AVATAR)) {

            var entityUserId :int = int(_ctrl.room.getEntityProperty(EntityControl.PROP_MEMBER_ID, entityId));

            if(entityUserId == playerId) {
                return entityId;
            }

        }
        return null;
    }

    override protected function receiveMessage (msg:ObjectMessage) :void
    {
        if (msg.name == GAME_MESSAGE_TARGETID) {
            _avatarIdToStandBehind = int(msg.data);
        }
    }

    protected var _ctrl :AVRGameControl;
    protected var _currentEntityId :String;

    /**
    * When the avatar moves to stand behind a target, upon arrival the avatar should stand
    * in the same orientation.
    */
    protected var _avatarIdToStandBehind :int;
    protected static const log :Log = Log.getLog(AvatarClientController);

    public static const NAME :String = "AvatarClientController";
    public static const GAME_MESSAGE_TARGETID :String = "GameMessage: TargetId";

    /**
    * When our avatar arrives at it's destination, and it has a target, check how far away
    * we are from the target location.  If we are below this distance, we must be the first
    * predator (standing directly behind the target).  If we are greater than this distance,
    * we must have our orientation changed to face the target.
    */
    public static const MINIMUM_FIRST_TARGET_DISTANCE :Number = MathUtil.distance(0, 0, VConstants.FEEDING_LOGICAL_X_OFFSET, VConstants.FEEDING_LOGICAL_Z_OFFSET) + 0.01;

}
}