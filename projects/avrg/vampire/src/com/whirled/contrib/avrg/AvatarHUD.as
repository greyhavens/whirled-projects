package com.whirled.contrib.avrg
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.Hashable;
import com.threerings.util.Log;
import com.whirled.EntityControl;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;

import vampire.client.ClientContext;
import vampire.data.VConstants;

/**
 * The sprite is centered on the top-middle of the avatar hotspot, presumably this will
 * be close to where you place avatar HUD info.
 *
 *
 */
public class AvatarHUD extends SceneObject
    implements Hashable
{
    public function AvatarHUD(ctrl :AVRGameControl, userId :int)//,  updateCallback :Function )//roomCtrl :RoomSubControlBase,
    {
        if( ctrl == null ) {
            throw new Error("AVRGameControl cannot be null");
        }

        _ctrl = ctrl;
        _isPlayer = true;
        _userId = userId;


        _displaySprite = new Sprite();

        registerListener( _ctrl.room, AVRGameRoomEvent.AVATAR_CHANGED, avatarChanged);
        updateHotspot();








//        drawMouseSelectionGraphics();

//        drawNonSelectedSprite();
//        setBlood( maxBlood );

        //Set up event listeners.
        //If we live on the client, listen for blood updates.  On the server-side we are passive
//        if( _roomCtrl is RoomSubControlClient ) {
//
//            _updateCallback = updateCallback;
//            if( _updateCallback == null ) {
//                throw new Error("Cannot create NonPlayerAvatar for client without updateCallback");
//            }
//
//            //On the client, listen for signals from game avatars updating our location and hotspot
//            registerListener( _roomCtrl, AVRGameRoomEvent.SIGNAL_RECEIVED, handleSignalReceived );
//            registerListener( (_roomCtrl as RoomSubControlClient).props, ElementChangedEvent.ELEMENT_CHANGED, handleElementChanged );
////            getPropsFromRoom( _roomCtrl as RoomSubControlClient );
//
//            log.debug("CLient NonPlayerAvatar new and loaded room props=" + this);
//
//        }
    }

    protected function get mode() :AppMode
    {
        return db as AppMode;
    }

    protected function avatarChanged(...ignored) :void
    {
        _entityId = null;
        updateHotspot();
    }

    protected function updateHotspot () :void
    {
        var newHotspot :Array = _ctrl.room.getEntityProperty(
            EntityControl.PROP_HOTSPOT, entityId) as Array;
        setHotspot( newHotspot );
    }

    override protected function update(dt:Number) :void
    {
        super.update(dt);

        if( _ctrl == null || !_ctrl.isConnected() ) {
            return;
        }


        //We don't need to update every frame.
//        _timeSinceLastUpdate += dt;

        if( VConstants.LOCAL_DEBUG_MODE) {
            return;
        }

//        if( _timeSinceLastUpdate >= UPDATE_INTERVAL_SECONDS) {
//            trace("updating avatarHUD entityId=" + entityId);
//            _timeSinceLastUpdate = 0;


//            trace("size=" + _ctrl.room.getEntityProperty( EntityControl.PROP_DIMENSIONS, entityId));


            var newLocation :Array = _ctrl.room.getEntityProperty(
                EntityControl.PROP_LOCATION_LOGICAL, entityId) as Array;

            if( newLocation == null ) {
//                trace("newLocation null, not updating");
                return;
            }



//            }

//            if( !ArrayUtil.equals( newLocation, location ) ) {
                setLocation( newLocation, UPDATE_INTERVAL_SECONDS );
//            }

            //If we don't yet have a location, make us invisible
            visible = location != null;

//        }

    }




//    protected function handleElementChanged( e :ElementChangedEvent ) :void
//    {
//
////        var playerIdUpdated :int = parsePlayerIdFromPropertyName( e.name );
////
////        log.debug("handleElementChanged(" + e + "), playerIdUpdated=" + playerIdUpdated);
////
////        if( !isNaN( playerIdUpdated ) ) {
////            if( playerIdUpdated == playerId) {
////
////                if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD) {
////                    _blood = playerData( Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD, _roomCtrl as RoomSubControlClient  );
////                    //Let e.g. the HUD and target overlays know about our changed status.
////                    sendUpdateEvent();
////                }
////
////                if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_LOCATION) {
////                    _location = playerData( Codes.ROOM_PROP_PLAYER_DICT_INDEX_LOCATION, _roomCtrl as RoomSubControlClient  ) as Array;
////                    //Let e.g. the HUD and target overlays know about our changed status.
////                    sendUpdateEvent();
////                }
////                if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_HOTSPOT) {
////                    _hotspot = playerData( Codes.ROOM_PROP_PLAYER_DICT_INDEX_HOTSPOT, _roomCtrl as RoomSubControlClient  ) as Array;
////                    //Let e.g. the HUD and target overlays know about our changed status.
////                    sendUpdateEvent();
////                }
////
////                log.debug("handleElementChanged " + this );
////
////            }
////            else {
//////                log.debug("  Failed to update ElementChangedEvent" + e);
////            }
////        }
////        else {
////            log.error("isNaN( " + playerIdUpdated + " ), failed to update ElementChangedEvent" + e);
////        }
//    }


//    protected function handleSignalReceived( e :AVRGameRoomEvent ) :void
//    {
//        var data :Array;
//        var playerIdInSignal :int;
//        switch( e.name ) {
//
//            case Constants.SIGNAL_PLAYER_IDS:
//                //Remove any non-players that are now players
//                var playerIds :Array = e.value as Array;
//                if( playerIds != null && ArrayUtil.contains( playerIds, playerId )) {
//                    log.debug("handleSignalReceived, destroying self e=" + e + ", this=" + this );
//                    destroySelf();
//                }
//                break;
//            case Constants.SIGNAL_NON_PLAYER_MOVED:
//                data = e.value as Array;
//                playerIdInSignal = int(data[0]);
//
//                //We only act on signals about ourselved
//                if( playerIdInSignal != playerId ) {
//                    break;
//                }
//
//                log.debug(playerId + " handleSignalReceived "  + e);
//
//                var location :Array = data[1] as Array;
//                var hotspot :Array = data[2] as Array;
//
//                setLocation( location );
//                setHotspot( hotspot );
//
////                dispatchEvent( new NonPlayerAvatarUpdatedEvent( playerId ) );
//                log.debug("me=" + this)
//                break;
//
//            case Constants.SIGNAL_NON_PLAYER_LEFT_ROOM:
//                playerIdInSignal = int(e.value);
//
//                //Clients destroy non-players that have left the game
//                if( playerIdInSignal == playerId) {//  && roomCtrl is RoomSubControlClient
//                    log.debug(playerId + " handleSignalReceived , destroying me=" + this + " " + e);
//                    destroySelf();
//                }
//                break;
//            default:
//                break;
//        }
//    }
//    override protected function update( dt :Number ) :void
//    {
//        if( blood < maxBlood ) {
//            var currentBlood :Number = blood;
//            currentBlood += Constants.THRALL_BLOOD_REGENERATION_RATE * dt;
//            setBlood( currentBlood );
//        }
//
//        //If too much time passes while inactive and we are roomless, destroy ourselves.
//        if( !roomCtrl ) {
//            _timeSinceNoRoom += dt;
//            if( _timeSinceNoRoom > Constants.NON_PLAYER_TIMEOUT && blood >= maxBlood) {
//
//                destroySelf();
////                _isStale = true;
//            }
//        }
//        else {
//            _timeSinceNoRoom = 0;
//        }
//    }

//    public function handleSignalReceived( e :AVRGameRoomEvent ) :void
//    {
//        var data :Array;
//        switch( e.name ) {
//            case Constants.SIGNAL_NON_PLAYER_MOVED:
//                data = e.value as Array;
//                var userId :int = int(data[0]);
//
//                //If it's not us, ignore event
//                if( userId != playerId ) {
//                    return;
//                }
//
//                var newlocation :Array = data[1] as Array;
//                var newhotspot :Array = data[2] as Array;
//
//                setLocation( newlocation );
//                setHotspot( newhotspot );
//
//                //This means we have left the
//                if( newlocation == null ) {
//                    _room = null;
//                }
//
//                break;
//            default:
//                break;
//        }
//    }

    /**
     * Iterates over the groups that this object is a member of.
     * If a subclass overrides this function, it should do something
     * along the lines of:
     *
     * override public function getObjectGroup (groupNum :int) :String
     * {
     *     switch (groupNum) {
     *     case 0: return "Group0";
     *     case 1: return "Group1";
     *     // 2 is the number of groups this class defines
     *     default: return super.getObjectGroup(groupNum - 2);
     *     }
     * }
     */
//    override public function getObjectGroup (groupNum :int) :String
//    {
//        switch (groupNum) {
//          case 0: return GROUP;
//          default: return super.getObjectGroup(groupNum - 1);
//        }
//    }

//    protected function sendUpdateEvent() :void
//    {
//        if( _updateCallback != null ) {
//            _updateCallback( this );
//        }
////        log.debug("Client NonPlayerAvatar updated, sending event.  Us: " + toString());
////        dispatchEvent( new AvatarUpdatedEvent( playerId, location, hotspot ));
//    }


//    public function setIntoRoomProps( roomCtrl :RoomSubControlServer ) :void
//    {
//        if( _updated ) {
//            return;
//        }
//        log.debug("setIntoRoomProps() " + this);
//        if( roomCtrl == null) {
//            log.error("setIntoRoomProps() but roomCtrl == null");
//            return;
//        }
//
//        var serverRoomCtrl :RoomSubControlServer = roomCtrl as RoomSubControlServer;
//        if( serverRoomCtrl == null ) {
//            log.error("setIntoRoomProps() but serverRoomCtrl == null");
//            return;
//        }
//
//
//        var dict :Dictionary = roomCtrl.props.get(_roomKey) as Dictionary;
//        if (dict == null) {
//            dict = new Dictionary();
//        }
//
//        if (!ArrayUtil.equals( dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_HOTSPOT], hotspot )) {
//            log.debug("Setting new hotspot=" + hotspot);
//            roomCtrl.props.setIn(_roomKey, Codes.ROOM_PROP_PLAYER_DICT_INDEX_HOTSPOT, hotspot);
//        }
//        if (!ArrayUtil.equals( dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_LOCATION], location )) {
//            log.debug("Setting new location=" + location);
//            roomCtrl.props.setIn(_roomKey, Codes.ROOM_PROP_PLAYER_DICT_INDEX_LOCATION, location);
//        }
//
//        _updated = true;
//
//    }


//    public function setIntoRoomProps() :void
//    {
//        log.debug("setIntoRoomProps() " + this);
//        if( roomCtrl == null) {
//            log.error("setIntoRoomProps() but roomCtrl == null");
//            return;
//        }
//
//        var serverRoomCtrl :RoomSubControlServer = roomCtrl as RoomSubControlServer;
//        if( serverRoomCtrl == null ) {
//            log.error("setIntoRoomProps() but serverRoomCtrl == null");
//            return;
//        }
//
//
//        var dict :Dictionary = serverRoomCtrl.props.get(_roomKey) as Dictionary;
//        if (dict == null) {
//            dict = new Dictionary();
//        }
//
////        if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_NAME] != name) {
////            room.ctrl.props.setIn(_roomKey, Codes.ROOM_PROP_PLAYER_DICT_INDEX_NAME, name);
////        }
//        if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD] != blood && !isNaN(blood)) {
//            log.debug("Setting new blood=" + blood);
//            serverRoomCtrl.props.setIn(_roomKey, Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD, blood);
//        }
//        if (!ArrayUtil.equals( dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_HOTSPOT], hotspot )) {
//            log.debug("Setting new hotspot=" + hotspot);
//            serverRoomCtrl.props.setIn(_roomKey, Codes.ROOM_PROP_PLAYER_DICT_INDEX_HOTSPOT, hotspot);
//        }
//        if (!ArrayUtil.equals( dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_LOCATION], location )) {
//            log.debug("Setting new location=" + location);
//            serverRoomCtrl.props.setIn(_roomKey, Codes.ROOM_PROP_PLAYER_DICT_INDEX_LOCATION, location);
//        }
//
//    }

//    protected function playerData (ix :int, clientRoomCtrl :RoomSubControlClient) :*
//    {
//        if( clientRoomCtrl == null ) {
//            return null;
//        }
//        var dict :Dictionary =
//            clientRoomCtrl.props.get(_roomKey) as Dictionary;
//        return (dict != null) ? dict[ix] : undefined;
//    }



//    protected function isProps() :Boolean
//    {
//        if( _roomCtrlClient == null ) {
//            return false;
//        }
//        return _roomCtrlClient.props.get(_roomKey) != null;
//    }

//    public static function parsePlayerIdFromPropertyName (prop :String) :int
//    {
//        if (StringUtil.startsWith(prop, Codes.ROOM_PROP_PREFIX_PLAYER_DICT)) {
//            var num :Number = parseInt(prop.slice(Codes.ROOM_PROP_PREFIX_PLAYER_DICT.length));
//            if (!isNaN(num)) {
//                return num;
//            }
//        }
//        return -1;
//    }



//    protected function get room() :RoomSubControlBase
//    {
//        return _room;
//    }

//    public function setBlood (blood :Number, force :Boolean = false) :void
//    {
//        // update our runtime state
//        blood = MathUtil.clamp(blood, 1, maxBlood);
//        if (!force && blood == _blood) {
//            return;
//        }
//
//        _blood = blood;
//
//        // and if we're in a room, update the room properties
//        if (_roomCtrl != null && _roomCtrl is RoomSubControlServer) {
//            setIntoRoomProps();
//        }
//    }

//    public function setRoomControlServer ( ctrl :RoomSubControlServer ) :void
//    {
//        _roomCtrl = ctrl;
//        if (_roomCtrl != null) {
//            setIntoRoomProps();
//        }
//    }

//    public function setRoomControlClient ( ctrl :RoomSubControlClient ) :void
//    {
//        //Remove the old listeners first
////        _events.freeAllHandlers();
//
//        _roomCtrlClient = ctrl;
//        if( _roomCtrlClient != null ) {
//            getPropsFromRoom();
//            //we were gong to listen personally to room updates, but lets pass that to something else for now
//        }
//
//    }

//    public function getPropsFromRoom(clientRoomCtrl :RoomSubControlClient) :void
//    {
//        if( clientRoomCtrl != null ) {
//            return;
//        }
//
//        _blood = playerData( Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD, clientRoomCtrl );
//        _location = playerData( Codes.ROOM_PROP_PLAYER_DICT_INDEX_LOCATION, clientRoomCtrl );
//        _hotspot = playerData( Codes.ROOM_PROP_PLAYER_DICT_INDEX_HOTSPOT, clientRoomCtrl );
//    }



//    public function handleElementChanged(

    override public function toString () :String
    {
        return "NonPlayer [userId=" + _userId
            + ", roomId="
//            (_roomCtrl != null ? _roomCtrl.getRoomId() : "null")
//            + ", blood=" + blood + "/" + maxBlood
            + ", loc=" + _location
            + ", hs=" + _hotspot
            + "]";
    }


//    public function setName (name :String, force :Boolean = false) :void
//    {
//        // update our runtime state
//        if (!force && name == _name) {
//            return;
//        }
//        _name = name;
////        if (_room != null) {
////            setIntoRoomProps();
////        }
//    }

    public function setHotspot (hotspot :Array) :void
    {
        _hotspot = hotspot;
    }

    public function setLocation (location :Array, dt :Number) :void
    {
        updateHotspot();

        _location = location;
        var newXY :Point = locationToRoomCoords( _ctrl, location, hotspot, _displaySprite );

        if( newXY == null) {
            log.debug("setLocation(" + location + ") returns null point");
            return;
        }



//        trace("avatarhud setLocation(" + location + ") = " + newXY);
        this.x = newXY.x;
        this.y = newXY.y;
//        removeAllTasks();
//        addTask( LocationTask.CreateSmooth( newXY.x, newXY.y, dt ) );
    }


    /**
    * The point is the middle-top of the hotspot.
    *
    */
    protected static function locationToRoomCoords( ctrl :AVRGameControl, location :Array, hotspot :Array, s :Sprite = null ) :Point
    {
        if( location == null
            || ctrl == null
            || ctrl.local == null
            || ctrl.local.locationToRoom(0, 0, 0) == null ) {
            return null;
        }

        if( hotspot == null || hotspot.length < 2) {
            hotspot = [0,0];
        }


        var heightLogical :Number = hotspot[1]/ctrl.local.getRoomBounds()[1];


        var fuckedPoint :Point = ClientContext.ctrl.local.locationToPaintable(location[0], heightLogical, location[2]);

       return fuckedPoint;

    }


    public function get playerId() :int
    {
        return _userId;
    }
//    public function get name() :String
//    {
//        return _name;
//    }

    public function get location() :Array
    {
        return _location;
    }
    public function get hotspot() :Array
    {
        return _hotspot;
    }

//    override public function get objectName () :String
//    {
//        return _roomKey;
//    }

    public function equals (other :Object) :Boolean
    {
        if (this == other) {
            return true;
        }
        if (other == null || !ClassUtil.isSameClass(this, other)) {
            return false;
        }
        return AvatarHUD(other).hashCode() == this.hashCode();
    }

    public function hashCode () :int
    {
        return _userId;
    }


    public function get isPlayer() :Boolean
    {

        return _isPlayer;
    }

    public function set isPlayer( p :Boolean ) :void
    {
        _isPlayer = p;
    }



    /**
    * Override this
    */
    protected function drawMouseSelectionGraphics() :void
    {

//        _sprite.graphics.clear();
//        _sprite.graphics.beginFill(0, 0.3);
//        _sprite.graphics.drawRect( -hotspot[0]/2, -hotspot[1], hotspot[0], hotspot[1]);
//        _sprite.graphics.endFill();
//
//
//        _sprite.graphics.beginFill(0, 0.3);
//        _sprite.graphics.drawCircle(0, 0, 10);
//        _sprite.graphics.endFill();
    }

//    public function setSelectable( s :Boolean ) :void
//    {
//        if( s ) {
//            drawNonSelected_sprite( );
//        }
//        else {
//            _sprite.graphics.clear();
//        }
//    }
//
//    public function setMouseOver( m :Boolean ) :void
//    {
//        if( m ) {
//
//        }
//        else {
//            drawNonSelected_sprite();
//        }
//    }

//    public function mouseState( sele

//    public function drawNonSelectedSprite() :void
//    {
//        if( hotspot == null )
//        {
//            return;
//        }
////        while( _sprite.numChildren ) { _sprite.removeChildAt(0);}
//        _sprite.graphics.clear();
//        _sprite.graphics.beginFill(0, 0.3);
//        _sprite.graphics.drawCircle(0, 0, 10);
////        _sprite.graphics.drawRect( -hotspot[0]/2, -hotspot[1], hotspot[0], hotspot[1]);
//        _sprite.graphics.endFill();
//        _sprite.graphics.lineStyle(1, 0);
//        _sprite.graphics.drawRect( -hotspot[0]/2, -hotspot[1], hotspot[0], hotspot[1]);
//    }
//    public function drawSelectedSpriteSinglePredator( ) :void
//    {
//        if( hotspot == null )
//        {
//            return;
//        }
//
////        while( _sprite.numChildren ) { _sprite.removeChildAt(0);}
//        _sprite.graphics.clear();
//        _sprite.graphics.beginFill(0, 0.3);
//        _sprite.graphics.drawRect( -hotspot[0]/2, -hotspot[1], hotspot[0], hotspot[1]);
//        _sprite.graphics.endFill();
//        _sprite.addChild( TextFieldUtil.createField("Single Pred.", {scaleX:2, scaleY:2, textColor:0xffffff} ));
//    }
//    public function drawSelectedSpriteFrenzyPredator() :void
//    {
//        if( hotspot == null )
//        {
//            return;
//        }
//
////        while( _sprite.numChildren ) { _sprite.removeChildAt(0);}
//        _sprite.graphics.clear();
//        _sprite.graphics.beginFill(0, 0.3);
//        _sprite.graphics.drawRect( -hotspot[0]/2, -hotspot[1], hotspot[0], hotspot[1]);
//        _sprite.graphics.endFill();
//
//        _sprite.addChild( TextFieldUtil.createField("Frenzy", {scaleX:2, scaleY:2, textColor:0xffffff} ));
//    }

    public function get sprite(): Sprite
    {
        return _displaySprite;
    }

    override public function get displayObject () :DisplayObject
    {
        return _displaySprite;
    }


//    public function setZScaleFactor( f :Number ) :void
//    {
//        _zScaleFactor = f;
//
//       drawMouseSelectionGraphics();
////        _sprite.addChild( TextFieldUtil.createField("Single Pred.", {scaleX:2, scaleY:2, textColor:0xffffff} ));
//
//    }

    public function get entityId () :String
    {
//        avatarChanged();

        if( _entityId == null ) {
            for each( var entityId :String in _ctrl.room.getEntityIds(EntityControl.TYPE_AVATAR)) {

                var entityUserId :int = int(_ctrl.room.getEntityProperty( EntityControl.PROP_MEMBER_ID, entityId));

                if( entityUserId == _userId ) {
                    _entityId = entityId;
                    break;
                }

            }
        }

        return _entityId;
    }

    protected var _displaySprite :Sprite;




    protected var _userId :int;
    protected var _entityId :String;
//    protected var _name :String;
//    protected var _blood :Number;
    protected var _location :Array;
    protected var _hotspot :Array;

    protected var _isPlayer :Boolean;

//    protected var _isMoving :Boolean = false;

//    protected var _updated :Boolean = false;



//    protected var _zScaleFactor :Number = 1.0;
    protected var _ctrl :AVRGameControl;
//    protected var _roomCtrl :RoomSubControlBase;
//    protected var _roomCtrlClient :RoomSubControlClient;

    /** After some time without a room, assume user left whirled, and destroy*/
//    protected var _timeSinceNoRoom :int;
//    protected var _isStale :Boolean = false;
//    protected var _serverNonPlayerHashMap :HashMap;

//    protected var _updateCallback :Function;

//    public static const GROUP :String = "NonPlayerGroup";
    protected var _timeSinceLastUpdate :Number = 0;
    protected static const UPDATE_INTERVAL_SECONDS :Number = 0.01;
    protected static const EMPTY_LOCATION :Array = [0,0,0];
    protected static const log :Log = Log.getLog( AvatarHUD );
}
}