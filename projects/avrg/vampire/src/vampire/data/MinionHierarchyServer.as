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
    
    
    protected function isPlayerDataEqual( player :Player ) :Boolean
    {
        if( player.sire != getSireId( player.playerId) ) {
            return false;
        }
        var minionsInThisHierarchy :HashSet = getMinionIds( player.playerId );
        var minionsStoredInPlayerProps :Array = player.minions;
        if( minionsInThisHierarchy.size() != minionsStoredInPlayerProps.length) {
            return false;
        }
        
        for each( var minionId :int in minionsStoredInPlayerProps) {
            if( !minionsInThisHierarchy.contains(minionId)) {
                return false;
            }
        }
        return true;
    }
    
    
    
    protected function loadPlayerFromDB( playerId :int ) :void
    {
        log.debug(Constants.DEBUG_MINION + " loadPlayerFromDB(" + playerId + ")...");
        ServerContext.ctrl.loadOfflinePlayer(playerId, 
            function (props :OfflinePlayerPropertyControl) :void {
                var name :String = String(props.get(Codes.PLAYER_PROP_PREFIX_NAME));
                var sireId :int = int(props.get(Codes.PLAYER_PROP_PREFIX_SIRE));
                log.debug(Constants.DEBUG_MINION + " loadPlayerFromDB(), props.getUserProps(), name=" + name + ", sire=" + sireId);
                
                setPlayerName( playerId, name );
                setPlayerSire( playerId, sireId );
                loadConnectingPlayersFromPropsRecursive( sireId );
                
                updateIntoRoomProps();
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
        log.debug(Constants.DEBUG_MINION + " playerEnteredRoom(), hierarchy=" + ServerContext.minionHierarchy.toString());
        
        if( player == null || room == null) {
            log.error(Constants.DEBUG_MINION + " playerEnteredRoom(), player == null || room == null");
            return;
        }
        
        var avatar :AVRGameAvatar = room.ctrl.getAvatarInfo( player.playerId );
        if( avatar == null) {
            log.error(Constants.DEBUG_MINION + " playerEnteredRoom(), avatar == null");
            return;
        }
        
        var avatarname :String = room.ctrl.getAvatarInfo( player.playerId).name;
        if( avatarname == null) {
            log.error(Constants.DEBUG_MINION + " playerEnteredRoom(), playername == null");
            return;
        }
        
        var isHierarchyAltered :Boolean = false;
        
        if(!isPlayer( player.playerId )) {
            isHierarchyAltered = true;
            log.debug(Constants.DEBUG_MINION + " playerEnteredRoom, player not in hierarchy");
        }
        else if( !_playerId2Name.containsKey( player.playerId) || 
            _playerId2Name.get( player.playerId) != avatarname ||
            avatarname != player.name) {
            isHierarchyAltered = true; 
            log.debug(Constants.DEBUG_MINION + " playerEnteredRoom, player name changed");
        }
        else if( !isPlayerDataEqual(player) ) {
            isHierarchyAltered = true;
            log.debug(Constants.DEBUG_MINION + " playerEnteredRoom, player data changed");
        }
        else if( player.sire > 0 && !isPlayerName( player.sire ) ){
            isHierarchyAltered = true;
            log.debug(Constants.DEBUG_MINION + " playerEnteredRoom, sire has no name");
        }
        
        if( isHierarchyAltered ) {//Something doesn't match.  Update all the data, and propagate
            //Update names
            setPlayerName( player.playerId,  avatarname);
            
            if( avatarname != player.name) {
                player.setName( avatarname );
            }
            
            //Update hierarchy data
            setPlayerSire( player.playerId, player.sire );
            
            log.debug(Constants.DEBUG_MINION + " before we load the sire data(just added this player), the hierarchy is=" + this.toString());
            loadConnectingPlayersFromPropsRecursive( player.sire );
            updateIntoRoomProps();
            
            
        }
        else {
            log.debug(Constants.DEBUG_MINION + " hierarchy is not altered, sending unchanged.");
        }
            
    }
    
    
    public function updateIntoRoomProps() :void
    {
        
        log.debug(Constants.DEBUG_MINION + "updateIntoRoomProps()...");
        _vserver.rooms.forEach( function( roomId :int, room :Room) :void {
            if( room != null && room.ctrl != null && room.ctrl.isConnected() ) {
                
                //Get the subtree containing all trees of all players in the room
                var playerTree :HashMap = new HashMap();
                room.players.forEach( function( playerId :int, player :Player) :void {
                    getMapOfSiresAndMinions( player.playerId, playerTree );
                    
                });
                
                //Get the existing subtree
                var roomDict :Dictionary = room.ctrl.props.get(Codes.ROOM_PROP_MINION_HIERARCHY) as Dictionary;
                if (roomDict == null) {
                    roomDict = new Dictionary();
                    room.ctrl.props.set(Codes.ROOM_PROP_MINION_HIERARCHY, roomDict);
                }
                
                //Update the playerId keys
                var allPlayerIdsOld :Array = room.ctrl.props.get(Codes.ROOM_PROP_MINION_HIERARCHY_ALL_PLAYER_IDS) as Array;
                var allPlayerIdsNew :Array = playerTree.keys();
                if ( allPlayerIdsNew == null || allPlayerIdsOld == null || !ArrayUtil.equals(allPlayerIdsNew, allPlayerIdsOld) ) {
                    log.debug(Constants.DEBUG_MINION + "updateIntoRoomProps(), set(" +Codes.ROOM_PROP_MINION_HIERARCHY_ALL_PLAYER_IDS + ", " +allPlayerIdsNew + ")");
                    room.ctrl.props.set(Codes.ROOM_PROP_MINION_HIERARCHY_ALL_PLAYER_IDS, allPlayerIdsNew);
                }
                
                //Update the room props for individual player data
                playerTree.forEach( function( playerId :int, nameAndSire :Array) :void {
                    if ( !ArrayUtil.equals(roomDict[playerId], nameAndSire) ) {
                        log.debug(Constants.DEBUG_MINION + "updateIntoRoomProps(), setIn(" +Codes.ROOM_PROP_MINION_HIERARCHY + ", " +playerId + "=" +  nameAndSire + ")");
                        room.ctrl.props.setIn(Codes.ROOM_PROP_MINION_HIERARCHY, playerId, nameAndSire);
                    }
                });
                
            }    
        });
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
        else if( _vserver.isPlayerOnline( playerId )) {
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
        if( _vserver.isPlayerOnline( playerId )) {
            _vserver.getPlayer( playerId ).setSire( getSireId( playerId ) );
        }
    }
    
    
    protected var _vserver :VServer;
    protected static const log :Log = Log.getLog( MinionHierarchyServer );
        
}
}