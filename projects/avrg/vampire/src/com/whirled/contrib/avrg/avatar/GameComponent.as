package com.whirled.contrib.avrg.avatar
{
    import com.threerings.util.Log;
    import com.whirled.EntityControl;
    import com.whirled.avrg.AVRGameControl;
    import com.whirled.contrib.simplegame.EventCollecter;

public class GameComponent extends EventCollecter
{
    public function GameComponent (ctrl :AVRGameControl)
    {
        _ctrl = ctrl;
    }


    protected function resetAvatarCallbackFunctions () :void
    {
        if (!isLegalAvatar) {
            log.error("resetAvatarCallbackFunctions", "avatar is not legal");
            return;
        }

        //Let's hear when the avatar arrived at a destination
        var setAvatarArrivedCallback :Function = _ctrl.room.getEntityProperty(
            AvatarComponent.ENTITY_PROPERTY_SET_AVATAR_ARRIVED_CALLBACK, ourEntityId) as Function;
        if (setAvatarArrivedCallback != null) {
            setAvatarArrivedCallback(avatarEndedMove);
        }
        else {
            log.error("This avatar is missing property " +
                AvatarComponent.ENTITY_PROPERTY_SET_AVATAR_ARRIVED_CALLBACK);
        }


        var setAvatarMovedCallback :Function = ClientContext.ctrl.room.getEntityProperty(
            AvatarComponent.ENTITY_PROPERTY_SET_AVATAR_MOVED_CALLBACK, ourEntityId) as Function;
        if( setAvatarMovedCallback != null) {
            setAvatarMovedCallback(avatarStartedMove);
        }
    }

    /**
    * Remove references to functions help on the avatar.  This is a precaution, as I'm not sure
    * if this is needed for garbage collection.
    */
    protected function clearAvatarCallbackFunctions () :void
    {
        var setAvatarArrivedCallback :Function = _ctrl.room.getEntityProperty(
            AvatarComponent.ENTITY_PROPERTY_SET_AVATAR_ARRIVED_CALLBACK, ourEntityId) as Function;
        if (setAvatarArrivedCallback != null) {
            setAvatarArrivedCallback(null);
        }

        var setAvatarMovedCallback :Function = ClientContext.ctrl.room.getEntityProperty(
            AvatarComponent.ENTITY_PROPERTY_SET_AVATAR_MOVED_CALLBACK, ourEntityId) as Function;
        if( setAvatarMovedCallback != null) {
            setAvatarMovedCallback(null);
        }
    }

    override public function shutdown () :void
    {
        super.shutdown();
        clearAvatarCallbackFunctions();
    }

    protected function avatarEndedMove (playerId :int, location :Array) :void
    {
        dispatchEvent(new AvatarMovedEvent(AvatarMovedEvent.AVATAR_ENDED_MOVE, playerId));
    }

    protected function avatarStartedMove (playerId :int, location :Array) :void
    {
        dispatchEvent(new AvatarMovedEvent(AvatarMovedEvent.AVATAR_STARTED_MOVE, playerId));
    }

    protected function get isLegalAvatar () :Boolean
    {
        return ctrl.room.getEntityProperty(AvatarComponent.ENTITY_PROPERTY_IS_LEGAL_AVATAR,
            ourEntityId)) as Boolean;
    }

    protected function get ourEntityId () :String
    {
        for each (var entityId :String in ctrl.room.getEntityIds(EntityControl.TYPE_AVATAR)) {
            var entityUserId :int = int(ctrl.room.getEntityProperty(EntityControl.PROP_MEMBER_ID, entityId));
            if (entityUserId == ctrl.player.getPlayerId()) {
                return entityUserId;
            }
        }
        return null;
    }

    protected function get ctrl () :AVRGameControl
    {
        return _ctrl;
    }

    protected var _ctrl :AVRGameControl;
    protected static const log :Log = Log.getLog(GameComponent);

}
}