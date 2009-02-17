package vampire.data
{
import com.threerings.util.ClassUtil;
import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.threerings.util.StringBuilder;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.avrg.RoomSubControlBase;
import com.whirled.avrg.RoomSubControlServer;
import com.whirled.contrib.simplegame.EventCollecter;

import flash.events.IEventDispatcher;

import vampire.client.PlayerAvatar;
import vampire.client.events.AvatarUpdatedEvent;

public class AvatarManager extends EventCollecter
    implements IEventDispatcher
{
//    protected var t :Timer;
    public function AvatarManager( roomCtrlClient :RoomSubControlBase)//, nonPlayerUpdatedCallback :Function = null)
    {
        _avatars = new HashMap();
        
        _roomCtrl = roomCtrlClient;
//        
        registerListener( roomCtrlClient, AVRGameRoomEvent.SIGNAL_RECEIVED, handleSignalReceived);
        
        //testing
        
        var p1 :PlayerAvatar = new PlayerAvatar( true, 23340 );
        p1.setLocation( [0.6, 0, 0.4] );
        p1.setHotspot( [300, 390] );
        addAvatar( p1 );
        
        var p2 :PlayerAvatar = new PlayerAvatar( true, 10393 );
        p2.setLocation( [0.2, 0, 0.8] );
        p2.setHotspot( [300, 390] );
        addAvatar( p2 );
        
        //If running on the client, we update by listening to the room prop changes.
//        if( _roomCtrlClient != null ) {
////            _nonPlayerUpdatedCallback = nonPlayerUpdatedCallback;
////            if( nonPlayerUpdatedCallback == null) {
////                throw new Error("Client side must have a nonPlayerUpdatedCallback");
////            }
////            registerListener( roomCtrlClient.props, PropertyChangedEvent.PROPERTY_CHANGED, handlePropChanged);
////            registerListener( roomCtrlClient.props, ElementChangedEvent.ELEMENT_CHANGED, handleElementChanged);
////            log.debug("NonPlayerManager(), roomCtrlClient.props.get( Codes.ROOM_PROP_NON_PLAYERS )=" + roomCtrlClient.props.get( Codes.ROOM_PROP_NON_PLAYERS ));
////            updateNonPlayersIds( roomCtrlClient.props.get( Codes.ROOM_PROP_NON_PLAYERS ) as Array );
//            
////            t = new Timer( 1000, 10 );
////            registerListener(t, TimerEvent.TIMER, print);
////            setInterval(print, 1000);
//        }
    }
    
    public function avatarMoved( roomCtrl :RoomSubControlBase, userId :int, location :Array, hotspot :Array) :void
    {
        
    }
    
    
    public function updateIntoRoomProps( userId :int, roomCtrlServer :RoomSubControlServer ) :void
    {
        if( !_avatars.containsKey( userId )) {
            log.warning("updateIntoRoomProps(" + userId + "), but no avatar exists");
            return;
        }   
        
        if( roomCtrlServer == null) {
            log.error("updateIntoRoomProps() but ", "roomCtrlServer", roomCtrlServer);
            return;
        }
            
        var avatar :PlayerAvatar = _avatars.get( userId ) as PlayerAvatar;
        
        if( avatar == null ) {
            log.error("updateIntoRoomProps() but ", "avatar", avatar);
            return;
        }
        
        avatar.setIntoRoomProps( roomCtrlServer );
        
//        var key :String = Codes.ROOM_PROP_PREFIX_PLAYER_DICT + userId;
//        
//        var dict :Dictionary = roomCtrlServer.props.get(key) as Dictionary;
//        if (dict == null) {
//            dict = new Dictionary(); 
//        }
//        
//        if (!ArrayUtil.equals( dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_LOCATION], avatar.location )) {
//            roomCtrlServer.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_LOCATION, avatar.location);
//        }
//        
//        if (!ArrayUtil.equals( dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_HOTSPOT], avatar.hotspot )) {
//            roomCtrlServer.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_HOTSPOT, avatar.hotspot);
//        }
        

    }
    
//    protected function avatarUpdated( av :NonPlayerAvatar ) :void
//    {
//        if( _nonPlayerUpdatedCallback != null) {
//            _nonPlayerUpdatedCallback( av );
//        }
//    }
    
//    override public function shutdown():void
//    {
////        t.stop();
//        super.shutdown();
//    }
    
    protected function print(...ignored) :void
    {
        trace( toString() );    
    }
    
//    protected function handleElementChanged( e :ElementChangedEvent ) :void
//    {
//        var playerIdUpdated :int = PlayerAvatar.parsePlayerIdFromPropertyName( e.name );
//        
//        log.debug("handleElementChanged(" + e + "), playerIdUpdated=" + playerIdUpdated);
//        
//        if( !isNaN( playerIdUpdated ) && playerIdUpdated > 0 ) { 
//            
//            if( _nonPlayers.containsKey(playerIdUpdated)) {
//                log.debug("playerIdUpdated=" + playerIdUpdated + " is in the db, it should report this event");
//            }
//            else {
//                log.debug("Creating nonplayer because we got an element changed for player that doesn't exist " + 
//                getNonPlayer( playerIdUpdated, _roomCtrlClient ));
//                
//            }
//            log.debug("handleElementChanged " + this );
//                
//        }
//        else {
//            log.error("isNaN( " + playerIdUpdated + " ), failed to update ElementChangedEvent" + e);
//        }
//    }


    /**
    * By listening to signals from the game avatar, build up location and hotspot data on 
    * the rooms avatars.
    * 
    */
    protected function handleSignalReceived( e :AVRGameRoomEvent ) :void
    {
//        trace("AvatarManager heard signal=" + e );
//        var data :Array;
//        var playerId :int;
//        switch( e.name ) {
//            
//            case Constants.SIGNAL_AVATAR_MOVED:
//                data = e.value as Array;
//                playerId = int(data[0]);
//                
//                log.debug(playerId + " handleSignalReceived "  + e);
//                
//                var location :Array = data[1] as Array;
//                var hotspot :Array = data[2] as Array;
//                
//                if( !_avatars.containsKey( playerId ) ) {
//                    var isPlayer :Boolean = ArrayUtil.contains(_roomCtrl.getPlayerIds(), playerId);
//                    var av :PlayerAvatar = new PlayerAvatar( isPlayer, playerId );
//                    _avatars.put( playerId, av);
//                }
//                
//                var avatar :PlayerAvatar = _avatars.get( playerId ) as PlayerAvatar;
//                
//                avatar.setLocation( location );
//                avatar.setHotspot( hotspot );
//                
//                log.debug("    me=" + this)
//                break;
//                
//            case Constants.SIGNAL_NON_PLAYER_LEFT_ROOM:
//                playerId = int(e.value);
//                _avatars.remove( playerId )
//                break;
//            default:
//                break;
//        }
    }


    public function getAvatar( playerId :int ) :PlayerAvatar
    {
//        if( !_avatars.containsKey( playerId )) {
//            _avatars.put( playerId, new PlayerAvatar(
//        }
        return _avatars.get( playerId );
    }
    
    public function addAvatar( a :PlayerAvatar ) :void
    {
        _avatars.put( a.playerId, a );
    }
    
    public function isAvatar( userId :int ) :Boolean
    {
        return _avatars.containsKey( userId );
    }
    
    
//    public function getNonPlayer( playerId :int, roomCtrl :RoomSubControlBase ) :PlayerAvatar
//    {
//        
//        if( !_avatars.containsKey( playerId ) ) {
//            var np :PlayerAvatar = new PlayerAvatar(false, playerId, handleAvatarUpdated);//roomCtrl
//            np.setServerNonPlayerHashMap( _avatars );
//            registerListener( np, AvatarUpdatedEvent.LOCATION_CHANGED, handleAvatarUpdated);
//            addObject( np );
//        }
//        return _avatars.get( playerId ) as PlayerAvatar;
//    }
    
    protected function handleAvatarUpdated( np :PlayerAvatar ) :void
    {
        dispatchEvent( new AvatarUpdatedEvent( np.playerId, np.location, np.hotspot ));
    }
    
    public function get avatars() :Array
    {
        return _avatars.values();
    }
    
    public function get nonPlayerIds() :Array
    {
        var nonPlayerIds :Array = [];
        _avatars.forEach( function( id :int, pv :PlayerAvatar) :void {
            if( !pv.isPlayer ) {
                nonPlayerIds.push( id );
            }
        });
        return nonPlayerIds;
    }
    
//    protected function handlePropChanged (e :PropertyChangedEvent) :void
//    {
//        log.debug("handlePropChanged( " + e + ")");
//        if( e.name == Codes.ROOM_PROP_NON_PLAYERS ) {
//            updateNonPlayersIds( e.newValue as Array );
//        }
//    }
    
//    protected function updateNonPlayersIds( newNonplayerIds :Array ) :void
//    {
//        log.debug("updateNonPlayersIds() " + this );
////       var newNonplayerIds :Array = _propsCtrl.get( Codes.ROOM_PROP_NON_PLAYERS ) as Array;
//       log.debug("updateNonPlayersIds(), newNonplayerIds=" + newNonplayerIds +", oldnonplayers=" + _avatars.keys());
//        if( newNonplayerIds != null ) {
//            //Add new non-players, remove, er, removed non players.
//            var currentNonPlayerIds :Array = _avatars.keys();
//            for each ( var nonplayerid :int in currentNonPlayerIds) {
//                //Remove stale nonplayers
//                if( !ArrayUtil.contains( newNonplayerIds, nonplayerid )) {
//                    var nonplayer :PlayerAvatar = _avatars.get( nonplayerid ) as PlayerAvatar;
//                    if( nonplayer != null && nonplayer.isLiveObject ) {
//                        trace("removeing nonplayer: " + nonplayer );
//                        nonplayer.destroySelf();
//                    }
//                }
//            }
//            //Add new nonplayers
//            for each( var newNonPlayerId :int in newNonplayerIds ) {
////                if( !ArrayUtil.contains( currentNonPlayerIds, newNonPlayerId ) ) {
////                    var newNonPlayer :PlayerAvatar = new PlayerAvatar( newNonPlayerId, _roomCtrlClient);
////                    newNonPlayer.setServerNonPlayerHashMap( _nonPlayers );
////                    addObject( newNonPlayer );
////                    trace("Adding new non player avatar: " + newNonPlayer + "\n,  and the model hashmap that should contain us" + this);
////                    trace("nonplayers=" + this);
////                }
//            }
//        }
//        else {
//            log.error("updateNonPlayersIds(" + Codes.ROOM_PROP_NON_PLAYERS + "), but nonplayerIds is null ");
//        }
//        
//        log.debug("end updateNonPlayersIds() " + this );
//    }
    
//    public function isNonPlayer( playerId :int ) :Boolean
//    {
//        return !isPlayer( playerId );
////        return _avatars.containsKey( playerId );
//    }
    
//    public function isPlayer( playerId :int ) :Boolean
//    {
//        return ArrayUtil.contains( _roomCtrl.getPlayerIds(), playerId );
////        return _avatars.containsKey( playerId );
//    }
    
    override public function toString():String
    {
        var sb :StringBuilder = new StringBuilder(ClassUtil.tinyClassName(this) + "toString(): avatars: size=" + _avatars.size() );
        for each( var np :PlayerAvatar in _avatars.values ) {
            sb.append("\n   " + np );
        }
        return sb.toString();
    }  
    
    
    
//
//    public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
//    {
//        _ed.addEventListener(type, listener, useCapture, priority, useWeakReference);
//    }
//    public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
//    {
//        _ed.removeEventListener(type, listener, useCapture);
//    }
//    public function dispatchEvent(event:Event):Boolean
//    {
//        return _ed.dispatchEvent(event);
//    }
//    public function hasEventListener(type:String):Boolean
//    {
//        return _ed.hasEventListener(type);
//    }
//    public function willTrigger(type:String):Boolean
//    {
//        return _ed.willTrigger(type);
//    }   
    
//    private var _ed :EventDispatcher = new EventDispatcher();
    protected var _roomCtrl :RoomSubControlBase;
    protected var _avatars :HashMap;
    
    protected var _roomId2Avatars :HashMap = new HashMap();
//    protected var _nonPlayerUpdatedCallback :Function;
    protected static const log :Log = Log.getLog( AvatarManager );
}
}