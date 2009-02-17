package vampire.avatar
{
import com.threerings.flash.MathUtil;
import com.threerings.util.ArrayUtil;
import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.whirled.AvatarControl;
import com.whirled.ControlEvent;
import com.whirled.EntityControl;

import vampire.data.Constants;


/**
 * Monitors other room entities and reports to the AVRG game client (via sendSignal())
 * the closest avatar (not necessarily playing the game).
 *
 */
public class AvatarGameBridge
{
    public function AvatarGameBridge( ctrl :AvatarControl, applyColorScheme :Function)
    {
        _ctrl = ctrl;

        _colorSchemeFunction = applyColorScheme;

//        _ctrl.addEventListener(ControlEvent.STATE_CHANGED, handleStateChange);
        _ctrl.addEventListener(ControlEvent.CHAT_RECEIVED, handleChatReceived);
        _ctrl.addEventListener(ControlEvent.SIGNAL_RECEIVED, handleSignalReceived);

        _ctrl.addEventListener(ControlEvent.ENTITY_ENTERED, handleEntityEntered );
        _ctrl.addEventListener(ControlEvent.ENTITY_LEFT, handleEntityLeft );

        _ctrl.addEventListener(ControlEvent.ENTITY_MOVED, handleEntityMoved);
//        trace2("\nVampireAvatarController loaded!\n");

    }

    protected function handleEntityEntered (e :ControlEvent) :void
    {

        trace2("\n" + playerId + " "  + ControlEvent.ENTITY_ENTERED);
        computeClosestAvatar(e);

    }

    protected function handleEntityLeft (e :ControlEvent) :void
    {
        _userLocations.remove( e.name );
        trace2("\n" + playerId + " "  + ControlEvent.ENTITY_LEFT);
        computeClosestAvatar(e);


    }

    protected function handleEntityMoved (e :ControlEvent) :void
    {
        //We only care about avatars.
        if( _ctrl.getEntityProperty( EntityControl.PROP_TYPE, e.name) != EntityControl.TYPE_AVATAR) {
            return;
        }

        var userIdMoved :int = int(_ctrl.getEntityProperty( EntityControl.PROP_MEMBER_ID, e.name));


//        trace2("\nVampireAvatarController handleEntityMoved!, hotspot=" + _ctrl.getEntityProperty( EntityControl.PROP_HOTSPOT, e.name));
//        trace2( playerId + " e=" + e);
        if( e.value == null) {//Only compute closest avatars when this avatar has arrived at location

            //We only report the non-players, as the game knows where the players are
            var actualLocation :Array = _userLocations.get( userIdMoved ) as Array;
            if( !isPlayer( userIdMoved ) && actualLocation != null) {
                // TSC - don't check in. commenting out broken code.
                //_ctrl.sendSignal( Constants.SIGNAL_NON_PLAYER_MOVED, [userIdMoved, actualLocation]);
            }

//            computeClosestAvatar(e);
//            //If we arrived at out destination, notify the server, who may initiate the feeding animation
//            if( int(_ctrl.getEntityProperty( EntityControl.PROP_MEMBER_ID, e.name)) == playerId) {
//                trace2( "handleEntityMoved(), we have arrived!");
//                _ctrl.sendSignal( Constants.SIGNAL_PLAYER_ARRIVED_AT_DESTINATION, playerId);
//            }
        }
        else {

            //Because when the entity arrives, the locaiton info is stale, this holds a record of the correct location.
            var entityLocation :Array = _ctrl.getEntityProperty( EntityControl.PROP_LOCATION_LOGICAL, e.name) as Array;
            _userLocations.put( userIdMoved, entityLocation );


////            trace2("  e.value != null, beginning of move, so turn off targeting, sending closest == 0");
//            var targetEntityId :String = getEntityId( _targetId );
//            var targetLocation :Array = _ctrl.getEntityProperty( EntityControl.PROP_LOCATION_LOGICAL, targetEntityId) as Array;
////            if( userIdMoved ==
//            _ctrl.sendSignal( Constants.SIGNAL_CLOSEST_ENTITY, [playerId, 0, "", null, 0, targetLocation]);
        }
    }

    /**
     * Respond to signals from the room
     */
    protected function handleSignalReceived (e :ControlEvent) :void
    {
        //Update our target
        var data :Array;
        switch( e.name ) {
            case Constants.SIGNAL_PLAYER_TARGET :
                data = e.value as Array;
                if( data[0] == playerId) {
                    _targetId = data[1] as int;
                }
                break;

            case Constants.SIGNAL_CHANGE_COLOR_SCHEME:
                data = e.value as Array;
                if( data != null && data.length >= 2) {
                    if( data[0] == playerId && _colorSchemeFunction != null) {
//                        trace("calling _colorSchemeFunction from bridge");
                        _colorSchemeFunction( data[1] );
                    }
                }
                else {
                    trace("WTF, signal " + e);
                }
                break;
            // TSC - don't check in. commenting out broken code.
            /*case Constants.SIGNAL_PLAYER_IDS:
                _playerIds = e.value as Array;
                break;*/
            default:
//                log.debug("Ignoring signal " + e);
                break;

        }
    }

    protected function isPlayer( userId :int ) :Boolean
    {
        return ArrayUtil.contains( _playerIds, userId );
    }


    /**
     * This is called when the user selects a different state.
     */
    protected function handleStateChange (event :ControlEvent) :void
    {
//        trace2("\nVampireAvatarController changing state=" + event.name+ "!\n");
        _state = event.name;
    }

    protected function handleChatReceived( e :ControlEvent) :void
    {
        var chatterId :int = int(_ctrl.getEntityProperty( EntityControl.PROP_MEMBER_ID, e.name));
        trace2( "Chat received from " + chatterId);
        if( chatterId == _targetId) {
            trace2( "  Broadcasting, _targetId=" + _targetId);
            _ctrl.sendSignal( Constants.SIGNAL_TARGET_CHATTED, [playerId, chatterId] );
        }
        else {
            trace2( "  Not broadcasting...why?, _targetId=" + _targetId);
        }
        //Not yet implemented
//        var speakerId :int = int(e.name);
//        trace2("avatar handleChatReceived()", "e.name", e.name, "chat", e.value, "e.target", e.target);
//
//        if( e.target is AvatarControl) {
////            trace2("from/to??():" + AvatarControl(e.target).);
//        }
//
//        if( speakerId != _ctrl.getInstanceId()) {
//
////            _ctrl.sendChat("You said: " + e.value);
////            _ctrl.sendSignal("You said: " + e.value);
//        }
    }

    protected function get playerId() :int
    {
        return int(_ctrl.getEntityProperty(EntityControl.PROP_MEMBER_ID));
    }

    protected function computeClosestAvatar( e :ControlEvent ) :void
    {
        if( _ctrl == null || !_ctrl.isConnected() ) {
            log.error("computeClosestAvatar(), ctrl=" + _ctrl + ", _ctrl.isConnected()=" + _ctrl.isConnected());
            return;
        }

//        if( e.value == null) {
//            return;
//        }
        var userIdMoved :int = int(_ctrl.getEntityProperty( EntityControl.PROP_MEMBER_ID, e.name));
//        trace2("   computeClosestAvatar(), userIdMoved=" + userIdMoved + ", myId=" + playerId);

        var myLocation :Array = _ctrl.getLogicalLocation();
//        trace2("   myLocation from ctrl, location=" + myLocation);
        if( userIdMoved == playerId && e != null && e.value != null) {
            myLocation = e.value as Array;
//            trace2("   oh, I'm the entity in the event, myLocation=" + myLocation);
        }
        var closestUserId :int = 0;
        var closestEntityId :String;
        var closestUserDistance :Number = Number.MAX_VALUE;
        var closestLocation :Array;
        var myX :Number = myLocation[0] as Number;
        var myZ :Number = myLocation[2] as Number;
//        trace2("    me(" + myX + ", " + myZ + ")");

        var entityLocation :Array;
        for each( var entityId :String in _ctrl.getEntityIds(EntityControl.TYPE_AVATAR)) {

            var entityUserId :int = int(_ctrl.getEntityProperty( EntityControl.PROP_MEMBER_ID, entityId));

            if( entityUserId == playerId ) {
                continue;
            }

            entityLocation = _ctrl.getEntityProperty( EntityControl.PROP_LOCATION_LOGICAL, entityId) as Array;
//            trace2("     for entityUserId=" + entityUserId + ", loc=" + entityLocation);

            if( entityUserId == userIdMoved && e != null && e.value != null) {
                entityLocation = e.value as Array;
//                trace2("     oh, its the entity in the event, " + entityUserId + " location=" + entityLocation);
            }

            if( entityLocation != null) {
                var distance :Number = MathUtil.distance( myX, myZ, entityLocation[0], entityLocation[2]);
                if( !isNaN(distance)) {
                    if( distance < closestUserDistance) {
                        closestUserDistance = distance;
                        closestUserId = entityUserId;
                        closestEntityId = entityId;
                        closestLocation = entityLocation.slice();
                    }
                }

            }
        }


//        trace2("    Closests userId=" + closestUserId);
//        trace2("    Closests user name=" + _ctrl.getViewerName(closestUserId));
        var targetEntityId :String = getEntityId( _targetId );
        var targetLocation :Array = _ctrl.getEntityProperty( EntityControl.PROP_LOCATION_LOGICAL, targetEntityId) as Array;
        if(closestUserId == 0) {
            _ctrl.sendSignal( Constants.SIGNAL_CLOSEST_ENTITY, [playerId, 0, "", null, 0, targetLocation]);
        }
        else if( closestUserId > 0 && closestUserId != playerId  ){//closestUserId != _closestUserId) {
//            trace2("     sending closestUserId=" + closestUserId);
            _closestUserId = closestUserId;
//            entityLocation = _ctrl.getEntityProperty( EntityControl.PROP_LOCATION_LOGICAL, closestEntityId) as Array;
//            trace2("      for _closestUserId=" + _closestUserId + ", loc=" + entityLocation);
//            if( _closestUserId == userIdMoved && e != null && e.value != null) {
//                entityLocation = e.value as Array;
//                trace2("     oh, its the entity in the event, " + _closestUserId + " location=" + entityLocation);
//            }
//            trace2("      closestLocation=" + closestLocation);
//            var entityHeight :Number = (_ctrl.getEntityProperty( EntityControl.PROP_DIMENSIONS, closestEntityId) as Array)[1];

            var entityHotspot :Array = _ctrl.getEntityProperty( EntityControl.PROP_HOTSPOT, closestEntityId) as Array;


//            trace2("      entityHeight=" + entityHeight);
            _ctrl.sendSignal( Constants.SIGNAL_CLOSEST_ENTITY, [playerId, closestUserId, _ctrl.getViewerName(closestUserId), closestLocation, entityHotspot, targetLocation]);
        }


    }

    public function getEntityId( userId :int ) :String
    {
        for each( var entityId :String in _ctrl.getEntityIds(EntityControl.TYPE_AVATAR)) {
            var entityUserId :int = int(_ctrl.getEntityProperty( EntityControl.PROP_MEMBER_ID, entityId));
            if( userId == entityUserId) {
                return entityId
            }
        }
        return null;
    }

    public function trace2( s :String) :void
    {
        if( playerId == 23340) {
            trace(s);
        }
    }

    public function get state() :String
    {
        return _state;
    }

    protected var _playerIds :Array = [];

    protected var _userLocations :HashMap = new HashMap();



    protected var _colorSchemeFunction :Function;
    protected var _ctrl :AvatarControl;
    protected var _state :String = Constants.GAME_MODE_NOTHING;
    protected var _targetId :int;
    protected var _closestUserId :int;
    protected var _closestUserLocation :Array;

    protected static const log :Log = Log.getLog( AvatarGameBridge );

    public static const COLOR_SCHEME_VAMPIRE :String = "vampireColors";
    public static const COLOR_SCHEME_HUMAN :String = "humanColors";
}
}
