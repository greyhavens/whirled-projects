package vampire.avatar
{
import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.whirled.AvatarControl;
import com.whirled.ControlEvent;
import com.whirled.EntityControl;
import com.threerings.util.EventHandlerManager;

import flash.events.Event;

/**
 * Currently the Whirled AVRG API does not notify the client when
 * 1) A player avatar arrives at a destination.
 * 2) Any non-player avatar moves.
 *
 * This class notifies the client when avatars stop moving.  Unfortunately, it
 * has to be compiled into an avatar, as only Avatar (Entity types) can listen to these events.
 */
public class AvatarEndMovementNotifier
{
    public function AvatarEndMovementNotifier (ctrl :AvatarControl)
    {
        _ctrl = ctrl;

        //Only the controlling instance updates, listens to events, and has custom properties.
        if(_ctrl.hasControl()) {
            _events.registerListener(_ctrl, ControlEvent.ENTITY_MOVED, handleEntityMoved);
            _events.registerListener(_ctrl, ControlEvent.ENTITY_LEFT, handleEntityLeft);
            _events.registerListener(_ctrl, ControlEvent.ENTITY_ENTERED, handleEntityEntered);
        }

        _events.registerListener(_ctrl, Event.UNLOAD, handleUnload);
    }

    /**
    * This is public, so it can be chained to another classes property provider.
    * E.g.
    *
    *       protected function propertyProvider (key :String) :Object
    *        {
    *            switch(key) {
    *
    *                case ENTITY_PROPERTY_IS_LEGAL_AVATAR:
    *                    return true;
    *
    *               default://The rest of the properties are provided by the movement notifier.
    *                    return _movementNotifier.propertyProvider(key);
    *            }
    *        }
    *
    */
    public function propertyProvider (key :String) :Object
    {
        switch(key) {

            case AvatarConstants.ENTITY_PROPERTY_SET_AVATAR_ARRIVED_CALLBACK:
                return setArrivedCallback as Object;

           default:
                return null;
        }
    }

    protected function handleUnload (...ignored) :void
    {
        _events.freeAllHandlers();
        _avatarArrivedCallback = null;
        _ctrl = null;
    }

    protected function handleEntityLeft (e :ControlEvent) :void
    {
        var userIdMoved :int = int(_ctrl.getEntityProperty(EntityControl.PROP_MEMBER_ID, e.name));
        _locations.remove(userIdMoved);
    }

    protected function handleEntityEntered (e :ControlEvent) :void
    {
        var userIdMoved :int = int(_ctrl.getEntityProperty(EntityControl.PROP_MEMBER_ID, e.name));
        if (userIdMoved == playerId) {
            _locations.clear();
        }
    }
    protected function handleEntityMoved (e :ControlEvent) :void
    {
        if (!_ctrl.hasControl()) {
            return
        }

        //We only care about avatars.
        if (_ctrl.getEntityProperty(EntityControl.PROP_TYPE, e.name) != EntityControl.TYPE_AVATAR) {
            return;
        }

        var userIdMoved :int = int(_ctrl.getEntityProperty(EntityControl.PROP_MEMBER_ID, e.name));

        var userHotspot :Array = _ctrl.getEntityProperty(EntityControl.PROP_HOTSPOT, e.name) as Array;

        //e.value == null means the avatar has arrived at it's location.
        if (e.value == null) {//Only compute closest avatars when this avatar has arrived at location

            //Notify listeners that we have arrived at our destination
            var actualLocation :Array = _locations.get(userIdMoved) as Array;
            if(actualLocation == null) {
                actualLocation = _ctrl.getEntityProperty(EntityControl.PROP_LOCATION_LOGICAL, e.name) as Array;
                //Make sure it's a copy
                if(actualLocation) {
                    actualLocation = actualLocation.slice();
                }
            }

            if(_avatarArrivedCallback != null && _ctrl.isConnected()) {
                _avatarArrivedCallback(userIdMoved, actualLocation);
            }
        }
        else {

            //Because when the entity arrives, the location info is stale,
            //tso we hold a record of the correct location.
            var entityLocation :Array = e.value as Array;
            _locations.put(userIdMoved, entityLocation.slice());
        }


    }

    protected function get playerId () :int
    {
        return int(_ctrl.getEntityProperty(EntityControl.PROP_MEMBER_ID));
    }

    protected function getEntityId (userId :int) :String
    {
        for each(var entityId :String in _ctrl.getEntityIds(EntityControl.TYPE_AVATAR)) {
            var entityUserId :int = int(_ctrl.getEntityProperty(EntityControl.PROP_MEMBER_ID, entityId));
            if(userId == entityUserId) {
                return entityId
            }
        }
        return null;
    }

    protected function setArrivedCallback (callback :Function) :void
    {
        _avatarArrivedCallback = callback;
    }

    protected var _locations :HashMap = new HashMap();
    protected var _ctrl :AvatarControl;
    protected var _avatarArrivedCallback :Function;


    protected var _events :EventHandlerManager = new EventHandlerManager();


    protected static const log :Log = Log.getLog(AvatarEndMovementNotifier);
}
}
