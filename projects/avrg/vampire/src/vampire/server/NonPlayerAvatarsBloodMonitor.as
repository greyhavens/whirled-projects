package vampire.server
{
    import com.threerings.util.HashMap;
    import com.threerings.util.HashSet;
    import com.whirled.contrib.simplegame.server.SimObjectThane;
    
    import flash.utils.Dictionary;
    
    import vampire.data.Codes;
    import vampire.data.Constants;
    
public class NonPlayerAvatarsBloodMonitor extends SimObjectThane
{
    /**
     * Returns the name of this object.
     * Two objects in the same db cannot have the same name.
     * Objects cannot change their names once added to a mode.
     */
    override public function get objectName () :String
    {
        return NAME;
    }
    
    /**
    * Make sure you have already checked that the user is a non-player.
    */    
    public function bloodAvailableFromNonPlayer( userId :int) :Number
    {
        if( _nonplayerBlood.containsKey( userId )) {
            return _nonplayerBlood.get( userId ) as Number;
        }
        
        return Constants.MAX_BLOOD_NONPLAYERS;
    }
    
    public function maxBloodFromNonPlayer( userId :int) :Number
    {
        return Constants.MAX_BLOOD_NONPLAYERS;
    }
    
    public function isNonPlayerCapableOfBeingEaten( userId :int ) :Boolean
    {
        if( _nonplayerBlood.containsKey( userId ) ) {
            return _nonplayerBlood.get( userId ) >= Constants.BLOOD_LOSS_FROM_THRALL_OR_NONPLAYER_FROM_FEED;
        }
        return true;
    }
    
    public function removeBloodAvailableFromNonPlayer( blood :Number, userId :int) :void
    {
        var currentBlood :Number = Constants.MAX_BLOOD_NONPLAYERS;
        
        if( _nonplayerBlood.containsKey( userId )) {
            currentBlood =  _nonplayerBlood.get( userId ) as Number;
        }
        
        currentBlood -= blood;
        currentBlood = Math.max( 0, currentBlood );
        
        _nonplayerBlood.put( userId, currentBlood );
    }
    
//    public function playerFeedsFromNonPlayer( player :Player, victimId :int, bloodLost :int) :void
//    {
//        if( _nonplayerBlood.containsKey( victimId )) {
//            _nonplayerBlood.put( victimId, Math.max( Number(_nonplayerBlood.get(victimId)) - bloodLost, 0));
//        }
//        else {
//            _nonplayerBlood.put( victimId, Constants.MAX_BLOOD_NONPLAYERS - bloodLost);
//        }
//        
//        //Update the room location of the nonplayer if necessary
//        if( player.room != null) {
//            if( player.room.hashCode() != _nonplayer2RoomId.get( victimId )) {
//                removeNonPlayerFromAllRooms( victimId );
//            }
//            //Put the nonplayer in the new room
////            player.room.nonPlayerAvatarIds.add( victimId );
//            _nonplayer2RoomId.put( victimId, player.room.hashCode());  
//            
////            setIntoRoomProperties(player.room);
//        }
//    }
    
    public function nonplayerLosesBlood( victimId :int, bloodLost :int) :void
    {
        if( _nonplayerBlood.containsKey( victimId )) {
            _nonplayerBlood.put( victimId, Math.max( Number(_nonplayerBlood.get(victimId)) - bloodLost, 0));
        }
        else {
            _nonplayerBlood.put( victimId, Constants.MAX_BLOOD_NONPLAYERS - bloodLost);
        }
        
    }
    
    protected function setIntoRoomProperties( room :Room ) :void
    {
        var data :Array = new Array();
//        room.nonPlayerAvatarIds.forEach( function( nonplayerId :int) :void {
//            if( _nonplayerBlood.containsKey( nonplayerId )) {
//                data.put( nonplayerId);
//                data.put( _nonplayerBlood.get(nonplayerId));
//            }
//        });
        
//        if( !ArrayUtil.equals(room.ctrl.props.get( Codes.ROOM_PROP_BLOOD_NON_PLAYERS ), data)) {
//            room.ctrl.props.get( Codes.ROOM_PROP_BLOOD_NON_PLAYERS, data);
//        }
        
    }
    
    
    protected function removeNonPlayerFromAllRooms( nonplayerId :int ) :void
    {
        //Remove the nonplayer from its old room
//        if( ServerContext.vserver.isRoom( _nonplayer2RoomId.get( nonplayerId ))) {
//            var room :Room = ServerContext.vserver.getRoom( _nonplayer2RoomId.get( nonplayerId ));
//            room.nonPlayerAvatarIds.remove( nonplayerId );
//        }
//        _nonplayer2RoomId.remove( nonplayerId );
    }
    
    override protected  function update( dt :Number ) :void
    {
        //Allow the non-players to regenerate
        var keys :Array = _nonplayerBlood.keys();
        
        for each( var userId :int in keys) {
            var blood :Number = _nonplayerBlood.get( userId );
            blood += Constants.THRALL_BLOOD_REGENERATION_RATE * dt;
            blood = Math.max( blood, Constants.MAX_BLOOD_NONPLAYERS);
            if( blood >= Constants.MAX_BLOOD_NONPLAYERS) {//If they have regained all blood, remove from counter.
                _nonplayerBlood.remove( userId );
            }
            else {
                _nonplayerBlood.put( userId, blood );
            }
            var room :Room = ServerContext.vserver.getRoom( _nonplayer2RoomId.get( userId ) ) as Room;
            if( room != null) {
                var key :String = Codes.ROOM_PROP_PREFIX_PLAYER_DICT + userId;
        
                var dict :Dictionary = room.ctrl.props.get(key) as Dictionary;
                if (dict == null) {
                    dict = new Dictionary(); 
                }
        
                if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD] != blood && !isNaN(blood)) {
                    room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD, blood);
                }
            }
        } 
    }
    
    public function isUserNonPlayer( userId :int ) :Boolean
    {
        return !_playerIdsThatHavePlayedEver.contains( userId );
    }
    
    public function addNewPlayer( playerId :int ) :void
    {
        _playerIdsThatHavePlayedEver.add( playerId );
    }
    
    /**
    * Rooms call this when they receive location information
    */
    public function setUserRoom( userId :int, roomId :int ) :void
    {
        _nonplayer2RoomId.put( userId, roomId );
    }

    
    //Non-players can only be fed occasionally
    protected var _nonplayerBlood :HashMap = new HashMap();
//    protected var _room2NonPlayers :HashMap = new HashMap();
    protected var _nonplayer2RoomId :HashMap = new HashMap();
    
    //We use this too keep players and non-players seperate, even if a player quits.
    public var _playerIdsThatHavePlayedEver :HashSet = new HashSet();
    
    protected static const NAME :String = "NonAvatarPlayersBloodMonitor";

}
}