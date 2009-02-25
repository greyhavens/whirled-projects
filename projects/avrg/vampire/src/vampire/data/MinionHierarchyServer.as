package vampire.data
{
    import com.threerings.util.ArrayUtil;
    import com.threerings.util.HashMap;
    import com.threerings.util.HashSet;
    import com.threerings.util.Log;
    import com.whirled.avrg.AVRGameAvatar;
    import com.whirled.avrg.OfflinePlayerPropertyControl;
    
    import flash.utils.Dictionary;
    
    import vampire.server.Player;
    import vampire.server.Room;
    import vampire.server.ServerContext;
    import vampire.server.VServer;
    
public class MinionHierarchyServer extends MinionHierarchy
{
    public function MinionHierarchyServer( vserver :VServer ) 
    {
        _vserver = vserver;
    }
    
    /**
    * Updates on server ticks.  This should only be in the order of a few updates per second.
    * 
    */
    override protected function update(dt:Number) :void
    {
        //Check players to update.  If they have a room, update the room and remove the playerId
        var i :int = 0;
        while( i < _playerIdsNeedingUpdate.length ) {
            var playerId :int = int(_playerIdsNeedingUpdate[i]);
            //If the the player is offline, we don't want to update
            if( !_vserver.isPlayer( playerId ) ) {
                _playerIdsNeedingUpdate.splice(i, 1);
                continue;
            }
            var player :Player = _vserver.getPlayer( playerId );
            if( player.room != null) {
                _roomsNeedingUpdate.add( player.room.roomId );
                _playerIdsNeedingUpdate.splice(i, 1);
                continue;
            }
            //Somehow the player doesn't have a room, so we'll keep it in the update list for now.
            i++;
        }
        
        
        
        _roomsNeedingUpdate.forEach( function( roomId :int ) :void {
        
            var room :Room = _vserver.getRoom( roomId );
            if( room != null && room.ctrl != null ) {
                updateIntoRoomProps( room );
            }    
        });
        
        
        _roomsNeedingUpdate.clear();
    }
    
    protected function isPlayerDataEqual( player :Player ) :Boolean
    {
        if( player.sire != getSireId( player.playerId) ) {
            return false;
        }
//        var minionsInThisHierarchy :HashSet = getMinionIds( player.playerId );
//        var minionsStoredInPlayerProps :Array = player.minions;
//        if( minionsInThisHierarchy.size() != minionsStoredInPlayerProps.length) {
//            return false;
//        }
//        
//        for each( var minionId :int in minionsStoredInPlayerProps) {
//            if( !minionsInThisHierarchy.contains(minionId)) {
//                return false;
//            }
//        }
        return true;
    }
    
    
    
    protected function loadPlayerFromDB( playerId :int ) :void
    {
        log.debug(VConstants.DEBUG_MINION + " loadPlayerFromDB(" + playerId + ")...");
        ServerContext.ctrl.loadOfflinePlayer(playerId, 
            function (props :OfflinePlayerPropertyControl) :void {
                var name :String = String(props.get(Codes.PLAYER_PROP_NAME));
                var sireId :int = int(props.get(Codes.PLAYER_PROP_SIRE));
                log.debug(VConstants.DEBUG_MINION + " loadPlayerFromDB(), props.getUserProps(), name=" + name + ", sire=" + sireId);
                
                setPlayerName( playerId, name );
                setPlayerSire( playerId, sireId );
                loadConnectingPlayersFromPropsRecursive( sireId );
                
                updatePlayer( playerId );
//                updateIntoRoomProps();
            },
            function (failureCause :Object) :void {
                log.warning("Eek! Sending message to offline player failed!", "cause", failureCause); ;
            });
    }
    
    
    /**
    * Called by Player.  That way, we are sure that Player has updated its room member.
    */
    public function playerEnteredRoom( player :Player, room :Room ) :void
    {
        log.debug(VConstants.DEBUG_MINION + " playerEnteredRoom(), hierarchy=" + ServerContext.minionHierarchy.toString());
        
        if( player == null || room == null) {
            log.error(VConstants.DEBUG_MINION + " playerEnteredRoom(), player == null || room == null");
            return;
        }
        
        var avatar :AVRGameAvatar = room.ctrl.getAvatarInfo( player.playerId );
        if( avatar == null) {
            log.error(VConstants.DEBUG_MINION + " playerEnteredRoom(), avatar == null");
            return;
        }
        
        var avatarname :String = room.ctrl.getAvatarInfo( player.playerId).name;
        if( avatarname == null) {
            log.error(VConstants.DEBUG_MINION + " playerEnteredRoom(), playername == null");
            return;
        }
        
        var isHierarchyAltered :Boolean = false;
        
        if(!isPlayer( player.playerId )) {
            isHierarchyAltered = true;
            log.debug(VConstants.DEBUG_MINION + " playerEnteredRoom, player not in hierarchy");
        }
        else if( !_playerId2Name.containsKey( player.playerId) || 
            _playerId2Name.get( player.playerId) != avatarname ||
            avatarname != player.name) {
            isHierarchyAltered = true; 
            log.debug(VConstants.DEBUG_MINION + " playerEnteredRoom, player name changed");
        }
        else if( !isPlayerDataEqual(player) ) {
            isHierarchyAltered = true;
            log.debug(VConstants.DEBUG_MINION + " playerEnteredRoom, player data changed");
        }
        else if( player.sire > 0 && !isPlayerName( player.sire ) ){
            isHierarchyAltered = true;
            log.debug(VConstants.DEBUG_MINION + " playerEnteredRoom, sire has no name");
        }
        
        if( isHierarchyAltered ) {//Something doesn't match.  Update all the data, and propagate
            //Update names
            setPlayerName( player.playerId,  avatarname);
            
            if( avatarname != player.name) {
                player.setName( avatarname );
            }
            
            //Update hierarchy data
            setPlayerSire( player.playerId, player.sire );
            
            log.debug(VConstants.DEBUG_MINION + " before we load the sire data(just added this player), the hierarchy is=" + this.toString());
            loadConnectingPlayersFromPropsRecursive( player.sire );
            updatePlayer( player.playerId );
//            updateIntoRoomProps();
            
            
        }
        else {
            log.debug(VConstants.DEBUG_MINION + " hierarchy is not altered, sending unchanged.");
        }
            
    }
    
    protected function updateRoom( roomId :int ) : void
    {
        _roomsNeedingUpdate.add( roomId );
    }
    
    /**
    * Mark this player and all sires and minions for an update.  This updates the lineage
    * in all rooms with the players.
    * 
    */
    public function updatePlayer( playerId :int ) : void
    {
        var relatedPlayersToUpdate :Array = new Array();
        
        getAllMinionsAndSubminions( playerId ).forEach( function( minionId :int) :void {
            relatedPlayersToUpdate.push( minionId );
        });
        
        getAllSiresAndGrandSires( playerId ).forEach( function( sireId :int) :void {
            relatedPlayersToUpdate.push( sireId );
        });
        
        relatedPlayersToUpdate.push( playerId );
        
        for each( var idToUpdate :int in relatedPlayersToUpdate) {
            if( _vserver.isPlayer( idToUpdate ) ) {
                var player :Player = _vserver.getPlayer( idToUpdate );
                //If the player is in a room, update the room
                if( player.room != null ) {
                    updateRoom( player.room.roomId );
                }
                //Otherwise, store the player to update at a later time, hopefully then with 
                //an associated room.
                else {
                    _playerIdsNeedingUpdate.push( idToUpdate );
                }
            }
            else {
                log.error("updatePlayer(), but no Player in server", "playerId", idToUpdate);
            }
        }
        
        
    }
    
    
    protected function updateIntoRoomProps( room :Room ) :void
    {
        try {
            if( room != null && room.ctrl != null && room.ctrl.isConnected() 
                && room.players != null && room.players.size() > 0 ) {
                
                log.debug(VConstants.DEBUG_MINION + "updateIntoRoomProps( roomId=" + room.roomId + ")...");
                //Get the subtree containing all trees of all players in the room
                var playerTree :HashMap = new HashMap();
                log.debug(VConstants.DEBUG_MINION + "updateIntoRoomProps(), subtree containing all trees of all players in the room");
                room.players.forEach( function( playerId :int, player :Player) :void {
                    getMapOfSiresAndMinions( player.playerId, playerTree );
                });
                
                //Get the existing subtree
                var roomDict :Dictionary = room.ctrl.props.get(Codes.ROOM_PROP_MINION_HIERARCHY) as Dictionary;
                if (roomDict == null) {
                    roomDict = new Dictionary();
                    room.ctrl.props.set(Codes.ROOM_PROP_MINION_HIERARCHY, roomDict);
                }
                
//                //Update the playerId keys
//                var allPlayerIdsOld :Array = room.ctrl.props.get(Codes.ROOM_PROP_MINION_HIERARCHY_ALL_PLAYER_IDS) as Array;
//                var allPlayerIdsNew :Array = playerTree.keys();
//                if ( allPlayerIdsNew == null || allPlayerIdsOld == null || !ArrayUtil.equals(allPlayerIdsNew, allPlayerIdsOld) ) {
//                    log.debug(VConstants.DEBUG_MINION + "updateIntoRoomProps(), set(" +Codes.ROOM_PROP_MINION_HIERARCHY_ALL_PLAYER_IDS + ", " +allPlayerIdsNew + ")");
//                    room.ctrl.props.set(Codes.ROOM_PROP_MINION_HIERARCHY_ALL_PLAYER_IDS, allPlayerIdsNew);
//                }
                
                //Remove keys not present anymore
                var keysToRemove :Array = new Array();
                for (var key:Object in roomDict) {//Where key==playerId
                    if( !playerTree.containsKey( key ) ) {
                        keysToRemove.push( key );
                    } 
                }
                for each( var playerIdToRemove :int in keysToRemove ) {
                    delete roomDict[playerIdToRemove];
                }
                
                //Update the room props for individual player data
                playerTree.forEach( function( playerId :int, nameAndSire :Array) :void {
                    if ( !ArrayUtil.equals(roomDict[playerId], nameAndSire) ) {
                        log.debug(VConstants.DEBUG_MINION + "updateIntoRoomProps(), setIn(" +Codes.ROOM_PROP_MINION_HIERARCHY + ", " +playerId + "=" +  nameAndSire + ")");
                        room.ctrl.props.setIn(Codes.ROOM_PROP_MINION_HIERARCHY, playerId, nameAndSire);
                    }
                });
                
            }
            else {
                log.debug(VConstants.DEBUG_MINION + "updateIntoRoomProps( roomId=" + room.roomId + ") failed");
            }    
        }catch (err :Error ) {
            log.error("Problem in updateIntoRoomProps()", "room", room);
            log.error(err.getStackTrace());
        }
    }
        
        
    
    
    /**
    * We assume that if the player name is present, they have been loaded (and all
    * their children and sire).
    * 
    * ATM we only load sires and upwards.
    * 
    */
    protected function loadConnectingPlayersFromPropsRecursive( playerId :int) :void
    {
//        log.debug(Constants.DEBUG_MINION + "loadConnectingPlayersFromPropsRecursive(" + playerId + ")")
        //If our name is present, we assume that we are already loaded.
        if( isPlayerName( playerId )) {
            return;
        }
        
        if( playerId <= 0 ) {
            return;
        }
        
        if( isPlayerName(playerId )) {
            //Player already loaded
        }
        else if( _vserver.isPlayer( playerId )) {
            var playerName :String = _vserver.getPlayer( playerId ).name;
            var sireId :int = _vserver.getPlayer( playerId ).sire;
            setPlayerName( playerId, playerName);
            setPlayerSire( playerId, sireId);
            loadConnectingPlayersFromPropsRecursive( sireId );
        }
        else {
            loadPlayerFromDB( playerId );
        }
        
    } 
    
    override public function toString():String
    {
        return super.toString();
    }
    
    
    override public function setPlayerSire( playerId :int, sireId :int) :void
    {
        super.setPlayerSire( playerId, sireId );
        //Update the player props
        if( _vserver.isPlayer( playerId )) {
            _vserver.getPlayer( playerId ).setSire( getSireId( playerId ) );
        }
    }
    
    
    
    protected var _vserver :VServer;
    protected var _roomsNeedingUpdate :HashSet = new HashSet();
    protected var _playerIdsNeedingUpdate :Array = new Array();
    
    protected static const log :Log = Log.getLog( MinionHierarchyServer );
        
}
}