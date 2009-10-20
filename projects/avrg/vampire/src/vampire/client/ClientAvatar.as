package vampire.client
{
    import com.threerings.flash.MathUtil;
    import com.threerings.flash.Vector2;
    import com.threerings.util.Log;
    import com.whirled.EntityControl;
    import com.whirled.avrg.AVRGameAvatar;
    import com.whirled.avrg.AVRGameControl;
    import com.whirled.avrg.AVRGameRoomEvent;
    import com.threerings.flashbang.GameObject;
    import com.whirled.contrib.messagemgr.Message;
    import com.threerings.flashbang.objects.SimpleTimer;
    import com.threerings.flashbang.tasks.FunctionTask;
    import com.threerings.flashbang.tasks.SerialTask;
    import com.threerings.flashbang.tasks.TimedTask;
    import com.whirled.net.MessageReceivedEvent;
    import com.whirled.net.PropertyChangedEvent;

    import vampire.avatar.AvatarConstants;
    import vampire.data.Codes;
    import vampire.data.VConstants;
    import vampire.net.messages.MovePredAfterFeedingMsg;
    import vampire.net.messages.MovePredIntoPositionMsg;


/**
 * The avatar
 */
public class ClientAvatar extends GameObject
{
    public function ClientAvatar (ctrl :AVRGameControl)
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
        registerListener(_ctrl.player, MessageReceivedEvent.MESSAGE_RECEIVED,
            handleMessageReceived);

        registerListener(_ctrl.player.props, PropertyChangedEvent.PROPERTY_CHANGED,
            handlePlayerPropChanged);

        resetAvatarCallbackFunctions();

        //Set the level on startup
        setAvatarCurrentLevel();
    }

    protected function handlePlayerPropChanged (e :PropertyChangedEvent) :void
    {
        switch (e.name) {
            case Codes.PLAYER_PROP_XP:
            case Codes.PLAYER_PROP_INVITES:
            setAvatarCurrentLevel();
            break;

            default:
            break;
        }
    }

    protected function setAvatarCurrentLevel () :void
    {
        var level :int = ClientContext.model.level;
        //Let's hear when the avatar arrived at a destination
        var setLevel :Function = _ctrl.room.getEntityProperty(
                                                AvatarConstants.ENTITY_PROPERTY_SET_PLAYER_LEVEL,
                                                ClientContext.ourEntityId) as Function;
        if (setLevel != null) {
            setLevel(level);
        }
        else {
            log.error("setAvatarLevel", "setLevel", setLevel);
        }
    }


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
                AvatarConstants.ENTITY_PROPERTY_SET_AVATAR_ARRIVED_CALLBACK, ClientContext.ourEntityId) as Function;

            if(setAvatarArrivedCallback != null) {
                setAvatarArrivedCallback(null);
            }
        }
    }


    protected function handleMessageReceived (e :MessageReceivedEvent) :void
    {
        var msg :Message = ClientContext.msg.deserializeMessage(e.name, e.value);

        if (msg != null) {

            if (msg is MovePredAfterFeedingMsg) {
                //Delay this so the avatar has time to show the stop feeding animation
                addTask(new SerialTask(new TimedTask(3), new FunctionTask(function () :void {
                    handleMovePredAfterFeedingMsg();
                })));
            }
            else if (msg is MovePredIntoPositionMsg) {
                handleMovePredIntoPositionMsg(MovePredIntoPositionMsg(msg));
            }
        }
    }

    protected function handleMovePredAfterFeedingMsg (...ignored) :void
    {
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

    protected function handleMovePredIntoPositionMsg (movemsg :MovePredIntoPositionMsg) :void
    {
        function convertStandardRads2GameDegrees(rad :Number) :Number
        {
            return MathUtil.toDegrees(MathUtil.normalizeRadians(rad + Math.PI / 2));
        }

        //If we are the first predator, we go directly behind the prey
        //Otherwise, take a a place
        var targetLocation :Array = movemsg.preyLocation;//ClientContext.model.getLocation(movemsg.preyId);
        var avatar :AVRGameAvatar = ClientContext.model.avatar;

        var targetX :Number;
        var targetY :Number;
        var targetZ :Number;

        //TODO: add the hotspot width /2, then test.
        var hotspot :Array = ClientContext.model.hotspot;
        var widthLogical :Number = hotspot[0]/_ctrl.local.getRoomBounds()[0];

        var distanceLogicalAwayFromPrey :Number = widthLogical / 3;

        //Maybe stand behind the prey?
        if (movemsg.isStandingBehindPrey) {
            _avatarIdToStandBehind = movemsg.preyId;
        }


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

        if (avatar != null && avatar.x == targetX && avatar.y == targetY && avatar.z == targetZ) {
            //We are already at the feeding position
            _movingPredatorIntoPosition = false;
        }
        else {
            _movingPredatorIntoPosition = true;
            ClientContext.ctrl.player.setAvatarLocation(targetX, targetY, targetZ, degs);
        }
    }

    protected function handleAvatarChanged (e :AVRGameRoomEvent) :void
    {
        checkForAvatarSwitch(e);
        setAvatarCurrentLevel();
    }

    /**
    * If we change avatars, make sure to update the movement notification function
    */
    protected function checkForAvatarSwitch (e :AVRGameRoomEvent) :void
    {
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

    protected function resetAvatarCallbackFunctions () :void
    {
        //Let's hear when the avatar arrived at a destination
        var setAvatarArrivedCallback :Function = _ctrl.room.getEntityProperty(
            AvatarConstants.ENTITY_PROPERTY_SET_AVATAR_ARRIVED_CALLBACK, ClientContext.ourEntityId) as Function;

        if(setAvatarArrivedCallback != null) {
            setAvatarArrivedCallback(avatarArrivedAtDestination);
        }
        else {
            var t :SimpleTimer = new SimpleTimer(1, function () :void {
                resetAvatarCallbackFunctions();
            });
            db.addObject(t);
        }
    }

    protected function avatarArrivedAtDestination (playerId :int, location :Array) :void
    {
        if (!_ctrl.isConnected()) {
            return;
        }

        //If we're not moving the predator into position, ignore
        if (!_movingPredatorIntoPosition) {
            return;
        }

        //If our player moved, inform the server.
        if (playerId == _ctrl.player.getPlayerId()) {
            var locationFromProps :Array = ClientContext.model.location;

            //And if this is our avatar, and we have a target to stand behind,
            //make sure we are in the same orientation.
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

            //And get into feeding state
            _ctrl.player.setAvatarState(VConstants.AVATAR_STATE_FEEDING);
            _movingPredatorIntoPosition = false;
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

    protected var _ctrl :AVRGameControl;
    protected var _currentEntityId :String;

    /**
    * When the avatar moves to stand behind a target, upon arrival the avatar should stand
    * in the same orientation.
    */
    protected var _avatarIdToStandBehind :int;

    /**
    * Only send the server notification of arriving at a destination when
    * the server cares about it.
    */
    protected var _movingPredatorIntoPosition :Boolean = false;



    public static const NAME :String = "AvatarClientController";

    /**This is like a radius in logical distance units.*/
    protected static const FEEDING_LOGICAL_X_OFFSET :Number = 0.1;
    protected static const FEEDING_LOGICAL_Z_OFFSET :Number = 0.01;

    /**
    * When our avatar arrives at it's destination, and it has a target, check how far away
    * we are from the target location.  If we are below this distance, we must be the first
    * predator (standing directly behind the target).  If we are greater than this distance,
    * we must have our orientation changed to face the target.
    */
    protected static const MINIMUM_FIRST_TARGET_DISTANCE :Number = MathUtil.distance(0, 0,
        FEEDING_LOGICAL_X_OFFSET, FEEDING_LOGICAL_Z_OFFSET) + 0.01;

    protected static const log :Log = Log.getLog(ClientAvatar);

}
}
