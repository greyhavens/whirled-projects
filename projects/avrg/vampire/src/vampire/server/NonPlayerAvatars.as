package vampire.server
{
    import com.threerings.util.ArrayUtil;
    import com.threerings.util.HashMap;
    import com.threerings.util.HashSet;
    
    import vampire.data.Codes;
    import vampire.data.Constants;
    
public class NonPlayerAvatars
{
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
    
    public function isNonPlayerCapableOfBeingEaten( userId :int ) :Boolean
    {
        if( _nonplayerBlood.containsKey( userId ) ) {
            return _nonplayerBlood.get( userId ) >= Constants.BLOOD_LOSS_FROM_THRALL_OR_NO_FROM_FEED;
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
    
    public function playerFeedsFromNonPlayer( player :Player, victimId :int, bloodLost :int) :void
    {
        if( _nonplayerBlood.containsKey( victimId )) {
            _nonplayerBlood.put( victimId, Math.max( Number(_nonplayerBlood.get(victimId)) - bloodLost, 0));
        }
        else {
            _nonplayerBlood.put( victimId, Constants.MAX_BLOOD_NONPLAYERS - bloodLost);
        }
        
        //Update the room location of the nonplayer if necessary
        if( player.room != null) {
            if( player.room.hashCode() != _nonplayer2RoomId.get( victimId )) {
                removeNonPlayerFromAllRooms( victimId );
            }
            //Put the nonplayer in the new room
            player.room._nonplayers.add( victimId );
            _nonplayer2RoomId.put( victimId, player.room.hashCode());  
            
//            setIntoRoomProperties(player.room);
        }
    }
    
    protected function setIntoRoomProperties( room :Room ) :void
    {
        var data :Array = new Array();
        room._nonplayers.forEach( function( nonplayerId :int) :void {
            if( _nonplayerBlood.containsKey( nonplayerId )) {
                data.put( nonplayerId);
                data.put( _nonplayerBlood.get(nonplayerId));
            }
        });
        
//        if( !ArrayUtil.equals(room.ctrl.props.get( Codes.ROOM_PROP_BLOOD_NON_PLAYERS ), data)) {
//            room.ctrl.props.get( Codes.ROOM_PROP_BLOOD_NON_PLAYERS, data);
//        }
        
    }
    
    
    protected function removeNonPlayerFromAllRooms( nonplayerId :int ) :void
    {
        //Remove the nonplayer from its old room
        if( VServer.isRoom( _nonplayer2RoomId.get( nonplayerId ))) {
            var room :Room = VServer.getRoom( _nonplayer2RoomId.get( nonplayerId ));
            room._nonplayers.remove( nonplayerId );
        }
        _nonplayer2RoomId.remove( nonplayerId );
    }
    
    public function tick( dt :Number ) :void
    {
        //Allow the non-players to regenerate
        var keys :Array = _nonplayerBlood.keys();
        for each( var userId :int in keys) {
            var blood :Number = _nonplayerBlood.get( userId );
            blood += Constants.THRALL_BLOOD_REGENERATION_RATE * dt;
            if( blood >= Constants.MAX_BLOOD_NONPLAYERS) {//If they have regained all blood, remove from counter.
                _nonplayerBlood.remove( userId );
            }
            else {
                _nonplayerBlood.put( userId, blood );
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

    
    //Non-players can only be fed occasionally
    protected var _nonplayerBlood :HashMap = new HashMap();
    protected var _nonplayer2RoomId :HashMap = new HashMap();
    
    //We use this too keep players and non-players seperate, even if a player quits.
    public var _playerIdsThatHavePlayedEver :HashSet = new HashSet();

}
}