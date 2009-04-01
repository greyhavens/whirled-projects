package com.whirled.contrib.avrg.avatar
{
    import com.threerings.util.HashMap;
    import com.whirled.AvatarControl;
    import com.whirled.ControlEvent;

    import flash.events.Event;

/**
 * AVRGs currently cannot observer movement from anything except avatars playing the game.
 * This must be embedded in the avatar code.  It notifies the client game when avatars
 * move.  The game client must embed the GameComponent class.
 */
public class AvatarComponent
{
    public function AvatarComponent (ctrl :AvatarControl)
    {
        _ctrl = ctrl;

        //Only the controlling instance updates, listens to events, and has custom properties.
        if (_ctrl.hasControl()) {
            _ctrl.registerPropertyProvider(propertyProvider);
            _events.registerListener(_ctrl, ControlEvent.ENTITY_MOVED, handleEntityMoved);
            _events.registerListener(_ctrl, ControlEvent.ENTITY_LEFT, handleEntityLeft);
            _events.registerListener(_ctrl, ControlEvent.ENTITY_ENTERED, handleEntityEntered);
            _events.registerListener(_ctrl, Event.UNLOAD, handleUnload);
        }
    }

    protected function propertyProvider(key :String) :Object
    {
        switch(key) {

            case ENTITY_PROPERTY_IS_LEGAL_AVATAR:
                return true;

            case ENTITY_PROPERTY_SET_AVATAR_ARRIVED_CALLBACK:
                return setAvatarArrivedCallback as Object;

            case ENTITY_PROPERTY_SET_AVATAR_MOVED_CALLBACKK:
                return setAvatarMovedCallback as Object;

           default:
                return null;
        }
    }


    protected function handleEntityMoved (e :ControlEvent) :void
    {
        if(!_ctrl.hasControl()) {
            return;
        }

        //We only care about avatars.
        if(_ctrl.getEntityProperty(EntityControl.PROP_TYPE, e.name) != EntityControl.TYPE_AVATAR) {
            return;
        }

        var userIdMoved :int = int(_ctrl.getEntityProperty(EntityControl.PROP_MEMBER_ID, e.name));

        //e.value == null means the avatar has arrived at it's location.
        if (e.value == null) {
            if (_avatarArrivedCallback != null) {
                _avatarArrivedCallback(userIdMoved, _userLocations.get(userIdMoved));
            }
        }
        else {//Not null means the avatar has started moving

            var startMovingLocation :Array = e.value as Array;
            _userLocations.put(userIdMoved, startMovingLocation);
            if (_avatarStartedMovingCallback != null) {
                _avatarStartedMovingCallback(userIdMoved, startMovingLocation);
            }
        }


    }

    /**
    * Remove a playerId from our location memory.
    *
    */
    protected function handleEntityLeft (e :ControlEvent) :void
    {
        var userId :int = int(_ctrl.getEntityProperty(EntityControl.PROP_MEMBER_ID, e.name));
        _userLocations.remove(userId);
    }

    /**
    * If we enter a room, clear our location memory.
    */
    protected function handleEntityEntered (e :ControlEvent) :void
    {
        var userId :int = int(_ctrl.getEntityProperty(EntityControl.PROP_MEMBER_ID, e.name));
        if (_ctrl.getInstanceId() == userId) {
            _userLocations.clear();
        }
    }




    protected function setAvatarArrivedCallback (callback :Function) :void
    {
        _avatarArrivedCallback = callback;
    }

    protected function setAvatarMovedCallback (callback :Function) :void
    {
        _avatarStartedMovingCallback = callback;
    }

    protected function handleUnload (...ignored) :void
    {
        _events.freeAllHandlers();
        _avatarStartedMovingCallback = null;
        _avatarArrivedCallback = null;
        _ctrl = null;
        _userLocations.clear();
    }

    protected function get playerId () :int
    {
        return int(_ctrl.getEntityProperty(EntityControl.PROP_MEMBER_ID));
    }

    protected function getEntityId (userId :int) :String
    {
        for each (var entityId :String in _ctrl.getEntityIds(EntityControl.TYPE_AVATAR)) {
            var entityUserId :int = int(_ctrl.getEntityProperty(EntityControl.PROP_MEMBER_ID, entityId));
            if (userId == entityUserId) {
                return entityId
            }
        }
        return null;
    }


    protected var _ctrl :AvatarControl;
    protected var _avatarStartedMovingCallback :Function;
    protected var _avatarArrivedCallback :Function;
    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _userLocations :HashMap = new HashMap();

    protected static const log :Log = Log.getLog(AvatarComponent);

    /** You must wear a level avatar to play the game */
    public static const ENTITY_PROPERTY_IS_LEGAL_AVATAR :String = "IsLegalMovementObserverAvatar";

    /**
    * Provide a function that takes as an argument another function.  We store the function
    * argument and call it when we arrive a a destination.
    */
    public static const ENTITY_PROPERTY_SET_AVATAR_ARRIVED_CALLBACK :String = "ArrivedCallback";

    /**
    * Provide a function that takes as an argument another function.  We store the function
    * argument and call it when we arrive a a destination.
    */
    public static const ENTITY_PROPERTY_SET_AVATAR_MOVED_CALLBACK :String = "StartedMovingCallback";
}
}