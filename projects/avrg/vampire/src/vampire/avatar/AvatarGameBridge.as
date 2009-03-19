﻿package vampire.avatar{import com.threerings.flash.MathUtil;import com.threerings.util.Log;import com.whirled.AvatarControl;import com.whirled.ControlEvent;import com.whirled.EntityControl;import com.whirled.contrib.EventHandlerManager;import flash.events.Event;import vampire.data.VConstants;/** * Monitors other room entities and reports to the AVRG game client * the closest avatar (not necessarily playing the game). * */public class AvatarGameBridge{    /**    *    * applyColorScheme: a function to change the avatar color state.    *   e.g. applyColorScheme( Constants.COLOR_SCHEME_VAMPIRE)    */    public function AvatarGameBridge( ctrl :AvatarControl)    {        _ctrl = ctrl;        Log.setLevel("vampire.avatar.VampireBody", Log.ERROR);        //Only the controlling instance updates, listens to events, and has custom properties.        if( _ctrl.hasControl()) {            _ctrl.registerPropertyProvider(propertyProvider);//            _events.registerListener(_ctrl, ControlEvent.CHAT_RECEIVED, handleChatReceived);//            _events.registerListener(_ctrl, ControlEvent.ENTITY_ENTERED, handleEntityEntered );//            _events.registerListener(_ctrl, ControlEvent.ENTITY_LEFT, handleEntityLeft );            _events.registerListener(_ctrl, ControlEvent.ENTITY_MOVED, handleEntityMoved);//            _ctrl.setTickInterval(UPDATE_INTERVAL_MS);//            _events.registerListener(_ctrl, TimerEvent.TIMER, update);        }        _events.registerListener(_ctrl, Event.UNLOAD, handleUnload);//        storeAllCurrentAvatarLocations(true);    }    protected function propertyProvider(key :String) :Object    {        trace("propertyProvider(" + key + ")");        switch( key ) {//            case ENTITY_PROPERTY_CHAT_TARGETS://                return _chatRecord.validPlayerIds;            case ENTITY_PROPERTY_SETSTATE_FUNCTION:                return setState as Object;            case ENTITY_PROPERTY_SETTARGET_FUNCTION:                return setTarget as Object;            case ENTITY_PROPERTY_SET_STAND_BEHIND_ID_FUNCTION:                return setAvatarIdToStandBehind as Object;            case ENTITY_PROPERTY_IS_LEGAL_AVATAR:                return true;            case ENTITY_PROPERTY_SET_AVATAR_ARRIVED_CALLBACK:                trace(" returning setArrivedCallback, null? " + (setArrivedCallback == null));                return setArrivedCallback as Object;            case ENTITY_PROPERTY_SET_TARGET_MOVED_CALLBACK:                return setTargetMovedCallback as Object;           default:                return null;        }    }//    protected function update(...ignored) :void//    {//        _chatRecord.update();//    }    protected function setTarget( targetId :int) :void    {        trace(playerId + " setting target=" + targetId);        _targetId = targetId;    }    protected function setAvatarIdToStandBehind( targetId :int) :void    {        trace(playerId + " setting standBehindId=" + targetId);        _avatarIdToStandBehind = targetId;    }    protected function setState( newState :String ) :void    {        _ctrl.setState( newState );    }//    protected function resetLocations() :void//    {//        _userLocations.clear();//        _isLocationsChanged = true;//        storeAllCurrentAvatarLocations( true );////    }//    protected function setUserLocation( userId :int, location :Array, hotspot :Array ) :void//    {//        if( !ArrayUtil.equals( location, [0,0,0] ) ) {//            _userLocations.put( userId, [location, hotspot] );//        }//    }    protected function handleUnload( ...ignored ) :void    {        _events.freeAllHandlers();        _avatarArrivedCallback = null;        _targetMovedCallback = null;    }//    protected function handleEntityEntered (e :ControlEvent) :void//    {//        if( !_ctrl.hasControl()) {//            return;//        }////        //We only care about avatars.//        if( _ctrl.getEntityProperty( EntityControl.PROP_TYPE, e.name) != EntityControl.TYPE_AVATAR) {//            return;//        }////        _isLocationsChanged = true;////        var userIdMoved :int = int(_ctrl.getEntityProperty( EntityControl.PROP_MEMBER_ID, e.name));////        //If we've entered a room, clear all the previous data.//        if( userIdMoved == playerId ) {//            resetLocations();////        }//        else {//            var actualLocation :Array = _ctrl.getEntityProperty( EntityControl.PROP_LOCATION_LOGICAL, e.name) as Array;//            var hotspot :Array = _ctrl.getEntityProperty( EntityControl.PROP_HOTSPOT, e.name) as Array;////            setUserLocation( userIdMoved, actualLocation, hotspot );//        }////    }//    protected function handleEntityLeft (e :ControlEvent) :void//    {//        if( !_ctrl.hasControl()) {//            return;//        }////        //We only care about avatars.//        if( _ctrl.getEntityProperty( EntityControl.PROP_TYPE, e.name) != EntityControl.TYPE_AVATAR) {//            return;//        }////        _isLocationsChanged = true;////        var userIdMoved :int = int(_ctrl.getEntityProperty( EntityControl.PROP_MEMBER_ID, e.name));//        //The the server that the non-player has left the game.//        _userLocations.remove( userIdMoved );//        _userLocationsTempWhileMoving.remove( userIdMoved );////////    }//    protected function storeAllCurrentAvatarLocations(reset :Boolean = false) :void//    {//        _isLocationsChanged = true;////        if( reset ) {//            _userLocations.clear();//        }//        for each( var entityId :String in _ctrl.getEntityIds(EntityControl.TYPE_AVATAR)) {////            var entityUserId :int = int(_ctrl.getEntityProperty( EntityControl.PROP_MEMBER_ID, entityId));////            var entityLocation :Array = _ctrl.getEntityProperty( EntityControl.PROP_LOCATION_LOGICAL, entityId) as Array;//            var entityHotspot :Array = _ctrl.getEntityProperty( EntityControl.PROP_HOTSPOT, entityId) as Array;////            setUserLocation( entityUserId, entityLocation.slice(), entityHotspot );//        }////    }    protected function handleEntityMoved (e :ControlEvent) :void    {        if( !_ctrl.hasControl()) {            return;        }        if( playerId != 1) {///Debugging            return;        }        //We only care about avatars.        if( _ctrl.getEntityProperty( EntityControl.PROP_TYPE, e.name) != EntityControl.TYPE_AVATAR) {            return;        }        var userIdMoved :int = int(_ctrl.getEntityProperty( EntityControl.PROP_MEMBER_ID, e.name));        trace(userIdMoved + " " + (e.value != null ? "started to" : "ending") + " move");        trace("_targetId=" + _targetId);        if (userIdMoved == _targetId) {            //Our target has begun to move            if (e.value != null) {                if (_targetMovedCallback != null) {                    trace(" calling _targetMovedCallback()");                    _targetMovedCallback();                }                else {                    log.error("_targetMovedCallback == null");                }            }            return;        }        //We only care about our own avatar        if( userIdMoved != playerId ) {            return;        }        var userHotspot :Array = _ctrl.getEntityProperty( EntityControl.PROP_HOTSPOT, e.name) as Array;        //e.value == null means the avatar has arrived at it's location.        if (e.value == null) {//Only compute closest avatars when this avatar has arrived at location            //We only report the non-players, as the game knows where the players are            var actualLocation :Array = _myLocation;            _myLocation = null;            //Notify listeners that we have arrived at our destination            if( userIdMoved == playerId ) {                trace(playerId + " avatar thinks we have arrived at our destination, loc=" + _myLocation + ", e=" + e);                if( _avatarArrivedCallback != null) {                    if( _turningToPreysAngle) {                        _turningToPreysAngle = false;                    }                    else {                        _avatarArrivedCallback(actualLocation);                    }                }                //And adjust our angle to our targets, if we have a target                //If our location is the same as our targets, we have the same orientation                //otherwise, we want to face our target                if( _avatarIdToStandBehind > 0 ) {                    var targetEntityId :String = getEntityId( _avatarIdToStandBehind );                    var targetLocation :Array = _ctrl.getEntityProperty( EntityControl.PROP_LOCATION_LOGICAL, targetEntityId) as Array;                    //If we are not the first predator, standing slightly behind the target, make                    //sure we are facing the same orientation as th target.  If we aren't the first                    //pred, face the target                    var distance :Number = MathUtil.distance( actualLocation[0], actualLocation[2], targetLocation[0], targetLocation[2] );                    _turningToPreysAngle = true;                    if( distance <= MINIMUM_FIRST_TARGET_DISTANCE ) {                        var targetorientation :Number = Number(_ctrl.getEntityProperty(                            EntityControl.PROP_ORIENTATION, targetEntityId));                        _ctrl.setLogicalLocation(actualLocation[0], actualLocation[1], actualLocation[2], targetorientation );                    }                    else {                        var faceTargetOrientation :Number = targetLocation[0] < actualLocation[0] ? 270 : 90;                        _ctrl.setLogicalLocation(actualLocation[0], actualLocation[1], actualLocation[2], faceTargetOrientation );                    }                    //Reset our target                    _avatarIdToStandBehind = -1;                }            }            if( actualLocation == null ) {                actualLocation = _ctrl.getEntityProperty( EntityControl.PROP_LOCATION_LOGICAL, e.name) as Array;                if(actualLocation) {                    actualLocation = actualLocation.slice();                }            }        }        else {            //Because when the entity arrives, the locaiton info is stale, this holds a record of the correct location.            var entityLocation :Array = e.value as Array;            _myLocation = entityLocation.slice();        }    }//    protected function handleEntityMoved (e :ControlEvent) :void//    {//        if( !_ctrl.hasControl()) {//            return;//        }////        //We only care about avatars.//        if( _ctrl.getEntityProperty( EntityControl.PROP_TYPE, e.name) != EntityControl.TYPE_AVATAR) {//            return;//        }////        storeAllCurrentAvatarLocations();////        _isLocationsChanged = true;////        var userIdMoved :int = int(_ctrl.getEntityProperty( EntityControl.PROP_MEMBER_ID, e.name));////        var userHotspot :Array = _ctrl.getEntityProperty( EntityControl.PROP_HOTSPOT, e.name) as Array;//////        //e.value == null means the avatar has arrived at it's location.//        if( e.value == null) {//Only compute closest avatars when this avatar has arrived at location////            //We only report the non-players, as the game knows where the players are//            var actualLocation :Array = _userLocationsTempWhileMoving.get( userIdMoved ) as Array;////            //Notify listeners that we have arrived at our destination//            if( userIdMoved == playerId ) {//                if( _avatarArrivedCallback != null) {//                    _avatarArrivedCallback();//                }//                _isUserArrivedAtDestination = true;//                //And adjust our angle to our targets, if we have a target//                //If our location is the same as our targets, we have the same orientation//                //otherwise, we want to face our target//                if( _targetId > 0 ) {//                    var targetEntityId :String = getEntityId( _targetId );////                    var targetLocation :Array = _ctrl.getEntityProperty( EntityControl.PROP_LOCATION_LOGICAL, targetEntityId) as Array;////                    //If we are not the first predator, standing slightly behind the target, make//                    //sure we are facing the same orientation as th target.  If we aren't the first//                    //pred, face the target//                    var distance :Number = MathUtil.distance( actualLocation[0], actualLocation[2], targetLocation[0], targetLocation[2] );//                    if( distance <= MINIMUM_FIRST_TARGET_DISTANCE ) {//                        var targetorientation :Number = Number(_ctrl.getEntityProperty(//                            EntityControl.PROP_ORIENTATION, targetEntityId));//                        _ctrl.setLogicalLocation(actualLocation[0], actualLocation[1], actualLocation[2], targetorientation );//                    }//                    else {//                        var faceTargetOrientation :Number = targetLocation[0] < actualLocation[0] ? 270 : 90;//                        _ctrl.setLogicalLocation(actualLocation[0], actualLocation[1], actualLocation[2], faceTargetOrientation );//                    }////                    //Reset our target//                    _targetId = -1;//                }////            }////            if( actualLocation == null ) {//                actualLocation = _ctrl.getEntityProperty( EntityControl.PROP_LOCATION_LOGICAL, e.name) as Array;//                if(actualLocation) {//                    actualLocation = actualLocation.slice();//                }//            }////            setUserLocation( userIdMoved, actualLocation, userHotspot );//        }//        else {////            //Because when the entity arrives, the locaiton info is stale, this holds a record of the correct location.//            var entityLocation :Array = e.value as Array;//            if( entityLocation != null) {//                _userLocationsTempWhileMoving.put( userIdMoved, entityLocation.slice() );//            }//            else {//                log.error("handleEntityMoved(" + e + "), but location value could not be coerced to an Array.");//            }////            setUserLocation( userIdMoved, null, userHotspot );//        }//////    }//    /**//     * This is called when the user selects a different state.//     *///    protected function handleStateChange (event :ControlEvent) :void//    {//        _state = event.name;//    }//    protected function handleChatReceived( e :ControlEvent) :void//    {//        var chatterId :int = int(_ctrl.getEntityProperty( EntityControl.PROP_MEMBER_ID, e.name));//        _chatRecord.playerChatted( chatterId );//    }    protected function get playerId() :int    {        return int(_ctrl.getEntityProperty(EntityControl.PROP_MEMBER_ID));    }    protected function getEntityId( userId :int ) :String    {        for each( var entityId :String in _ctrl.getEntityIds(EntityControl.TYPE_AVATAR)) {            var entityUserId :int = int(_ctrl.getEntityProperty( EntityControl.PROP_MEMBER_ID, entityId));            if( userId == entityUserId) {                return entityId            }        }        return null;    }//    public function get state() :String//    {//        return _state;//    }//    public function toString() :String//    {//        var sb :StringBuilder = new StringBuilder("\nCurrent stored avatar locations:");//        _userLocations.forEach( function( userId :int, location :Array) :void {//            sb.append("\n   " + userId + "     " + location );//        });//        return sb.toString();//    }    protected function setArrivedCallback( callback :Function ) :void    {//        trace(" AvatarGameBridge setArrivedCallback, callback null?" + (callback == null));        _avatarArrivedCallback = callback;    }    protected function setTargetMovedCallback( callback :Function ) :void    {        trace(" AvatarGameBridge setTargetMovedCallback, callback null?" + (callback == null));        _targetMovedCallback = callback;    }    protected var _myLocation :Array;//    protected var _userLocations :HashMap = new HashMap();//    protected var _userLocationsTempWhileMoving :HashMap = new HashMap();//    protected var _isLocationsChanged :Boolean = false;////    protected var _isUserArrivedAtDestination :Boolean = false;    protected var _ctrl :AvatarControl;//    protected var _state :String = VConstants.AVATAR_STATE_DEFAULT;    protected var _avatarArrivedCallback :Function;    protected var _targetMovedCallback :Function;//    protected var _chatRecord :ChatRecord = new ChatRecord();    protected var _targetId :int = -1;    protected var _avatarIdToStandBehind :int = -1;    /**Don't send an event when turning to the prey.*/    protected var _turningToPreysAngle :Boolean = false;    protected var _events :EventHandlerManager = new EventHandlerManager();    /**For providing a function to change avatar states*/    public static const ENTITY_PROPERTY_SETSTATE_FUNCTION :String = "SetStateFunction";    /**For providing a function to change avatar states*/    public static const ENTITY_PROPERTY_SETTARGET_FUNCTION :String = "SetTargetFunction";    /**For providing a function to change avatar states*/    public static const ENTITY_PROPERTY_SET_STAND_BEHIND_ID_FUNCTION :String = "SetStandBehind";    /**We record who chatted when.  This is used to provide valid  *///    public static const ENTITY_PROPERTY_CHAT_TARGETS :String = "ChatTargets";    /** You must wear a level avatar to play the game */    public static const ENTITY_PROPERTY_IS_LEGAL_AVATAR :String = "IsLegalAvatar";    /**    * Provide a function that takes as an argument another function.  We store the function    * argument and call it when we arrive a a destination.    */    public static const ENTITY_PROPERTY_SET_AVATAR_ARRIVED_CALLBACK :String = "ArrivedCallback";    /**    * Provide a function that takes as an argument another function.  We store the function    * argument and call it when we arrive a a destination.    */    public static const ENTITY_PROPERTY_SET_TARGET_MOVED_CALLBACK :String = "TargetMoved";//    protected static const UPDATE_INTERVAL_MS :Number = 1000;    /**    * When this avatar arrives at it's destination, and it has a target, check how far away    * we are from the target location.  If we are below this distance, we must be the first    * predator (standing directly behind the target).  If we are greater than this distance,    * we must have our orientation changed to face the target.    */    public static const MINIMUM_FIRST_TARGET_DISTANCE :Number = MathUtil.distance(0, 0, VConstants.FEEDING_LOGICAL_X_OFFSET, VConstants.FEEDING_LOGICAL_Z_OFFSET) + 0.01;    protected static const log :Log = Log.getLog( AvatarGameBridge );}}