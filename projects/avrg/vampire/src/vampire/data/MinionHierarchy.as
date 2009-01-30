package vampire.data
{
    import com.threerings.util.HashMap;
    import com.threerings.util.HashSet;
    import com.threerings.util.Log;
    import com.threerings.util.StringBuilder;
    import com.whirled.avrg.AVRGameAvatar;
    import com.whirled.avrg.AVRServerGameControl;
    
    import flash.utils.ByteArray;
    
    import vampire.server.Player;
    import vampire.server.Room;
    import vampire.server.VServer;
    
    
/**
 * The hierarchy of vampires.  The server can query this to get player info.
 * Currently only returns information of online players.
 * 
 * This is a simple DAG (directed acyclic graph).
 */
public class MinionHierarchy
{
    
    
    public function setPlayerSire( playerId :int, sireId :int) :void
    {
        if( playerId < 1) {
            return;
        }
        
        if( !_playerId2Node.containsKey( playerId) ) {
            _playerId2Node.put( playerId, new Node( playerId ));
        }
        
        if( sireId > 0 && !_playerId2Node.containsKey( sireId) ) {
            _playerId2Node.put( sireId, new Node( sireId ));
        }
        
        var player :Node = _playerId2Node.get( playerId ) as Node;
        var previousSire :Node = player.parent;
        var sire :Node = _playerId2Node.get( sireId ) as Node;
        player.parent = sire;
        
        if( sire != null ) {
            sire.childrenIds.add( player.hashCode() );
            if( sire.parent != null && sire.parent == player) {
                sire.parent = null;
                player.childrenIds.remove( sire.hashCode() );
            }
        }
        
        if( previousSire != null ) {
            previousSire.childrenIds.remove( player.hashCode() );
        }
        
        //Testing: for safety, break all minions.
        if( getAllSiresAndGrandSires( playerId ).contains( playerId ) ) {
            log.error("Circle found, removing all minions");
            //Remove all minions
            for each( var childId :int in player.childrenIds) {
                var child :Node = _playerId2Node.get( childId ) as Node;
                if( child != null) {
                    child.parent = null;
                }
            }
            player.childrenIds.clear();
            
            if( getAllSiresAndGrandSires( playerId ).contains( playerId ) ) {
                log.error("Fuck!! Circle found, removed, but still circle...!!!");    
            }
            
        }
        
        
    }
    
    
    public function getAllMinionsAndSubminions( playerId :int, minions :HashSet = null ) :HashSet
    {
        if( minions == null) {
            minions = new HashSet();
        }
        
        var player :Node = _playerId2Node.get( playerId ) as Node;
        
        if( player == null) {
            return minions;
        }
        
        var minionSet :HashSet = player.childrenIds;
        if( minionSet != null) {
            minionSet.forEach( function( minionId :int) :void
                {
                    if( !minions.contains( minionId ) ) {
                        minions.add( minionId );
                        getAllMinionsAndSubminions( minionId, minions);
                    }
                });
        }
        
        return minions;
    }
    
    public function getSireId( playerId :int) :int
    {
        var player :Node = _playerId2Node.get( playerId ) as Node;
        if( player != null && player.parent != null) {
            return player.parent.hashCode();
        }
        return -1;
    }
    
    public function getMinionIds( playerId :int) :HashSet
    {
        var player :Node = _playerId2Node.get( playerId ) as Node;
        if( player != null) {
            return player.childrenIds;
        }
        return new HashSet();
    }
    
    public function getMinionCount( playerId :int) :int
    {
        var player :Node = _playerId2Node.get( playerId ) as Node;
        if( player != null) {
            return player.childrenIds.size();
        }
        return 0;
    }
    
    public function getSireProgressionCount( playerId :int) :int
    {
        return getAllSiresAndGrandSires(playerId).size();
    }
    
    /**
    * Not returned in any particular order.
    */
    public function getAllSiresAndGrandSires( playerId :int ) :HashSet
    {
        var sires :HashSet = new HashSet();
        
        var parentId :int = getSireId( playerId );
        while( parentId > 0) {
            sires.add( parentId );
            parentId = getSireId( parentId );
            if( sires.contains( parentId )) {
                log.error("getAllSiresAndGrandSires, circle found.");
                break;
            }
        }
        return sires;
    }
    
    public function isSireExisting( playerId :int ) :Boolean
    {
        var player :Node = _playerId2Node.get( playerId ) as Node;
        if( player != null) {
            return player.parent != null;
        }
        return false;
    }
    
    public function isHavingMinions( playerId :int ) :Boolean
    {
        var player :Node = _playerId2Node.get( playerId ) as Node;
        if( player != null) {
            return player.childrenIds.size() > 0;
        }
        return false;
    }

    public function toString() :String
    {
        var sb :StringBuilder = new StringBuilder();
        for each( var playerId :int in _playerId2Node.keys()) {
            
            var player :Node = _playerId2Node.get( playerId ) as Node;
            sb.append("\n");
            sb.append("      " + playerId + " " + (_playerId2Name.containsKey(playerId) ? _playerId2Name.get(playerId) : "no key"));
            sb.append("        sire=" + getSireId( playerId ) );
            if( isHavingMinions( playerId ) ) {
                sb.append("         minions=" + player.childrenIds.toArray() );
                sb.append("         subminions=" + getAllMinionsAndSubminions(playerId).toArray());
            }
        }
        return _playerId2Node.keys().length > 0 ? sb.toString() : "MinionHierarchy empty";
    }
    
    public function fromBytes (bytes :ByteArray) :void
    {
        _playerId2Node.clear();
        _playerId2Name.clear();
        
        var compressSize :Number = bytes.length;
        bytes.uncompress();
        
        bytes.position = 0;
        var length :int = bytes.readInt();
        for( var i :int = 0; i < length; i++) {
            var playerId :int = bytes.readInt();
            var sireid :int = bytes.readInt();
            setPlayerSire( playerId, sireid );
            
            var playerName :String = bytes.readUTF();
            _playerId2Name.put( playerId, playerName );
        }
        
        log.debug("MinionHierarchy compress", "before", bytes.length, "after", compressSize, "%", (compressSize*100/bytes.length));
    }
    
    public function toBytes () :ByteArray
    {
        var bytes :ByteArray = new ByteArray();
        
        var players :Array = _playerId2Node.keys();
        bytes.writeInt( players.length );
        
        for each( var playerid :int in players) {
            bytes.writeInt( playerid );
            bytes.writeInt( getSireId( playerid )  );
            bytes.writeUTF( _playerId2Name.containsKey( playerid ) ?  _playerId2Name.get( playerid ) :"" );  
        }
        bytes.compress();//Yes, compress.  Watch out on the client, that they don't uncompress it twice.
        return bytes;
    } 
    public function get playerIds() :Array
    {
        return _playerId2Node.keys();
    }
    
    /**
     * The hierarchy listens for important game events and modifies stuff accordingly
     */
//    public function serverSideSetup( ctrl :AVRServerGameControl ) :void
//    {
//        _ctrl = ctrl;
//        
//        _ctrl.game.addEventListener(AVRGameControlEvent.PLAYER_JOINED_GAME, playerJoinedGame);
//        _ctrl.game.addEventListener(AVRGameControlEvent.PLAYER_QUIT_GAME, playerQuitGame);
//        
//        
//        //room_ctrl.addEventListener(AVRGameRoomEvent.ROOM_UNLOADED, handleUnload);
//    } 
    
    public function playerEnteredRoom( player :Player, room :Room ) :void
    {
        
        if( player == null || room == null) {
            log.error("playerEnteredRoom(), player == null || room == null");
            return;
        }
        
        var avatar :AVRGameAvatar = room.ctrl.getAvatarInfo( player.playerId );
        if( avatar == null) {
            log.error("playerEnteredRoom(), avatar == null");
            return;
        }
        
        var avatarname :String = room.ctrl.getAvatarInfo( player.playerId).name;
        if( avatarname == null) {
            log.error("playerEnteredRoom(), playername == null");
            return;
        }
        
        var isHierarchyAltered :Boolean = false;
        
        if(!isPlayer( player.playerId )) {
            isHierarchyAltered = true;
        }
        else if( !_playerId2Name.containsKey( player.playerId) || 
            _playerId2Name.get( player.playerId) != avatarname ||
            avatarname != player.name) {
            isHierarchyAltered = true; 
        }
        else if( !isPlayerDataEqual(player) ) {
            isHierarchyAltered = true;
        }
        
        if( isHierarchyAltered ) {//Something doesn't match.  Update all the data, and propagate
            //Update names
            _playerId2Name.put( player.playerId,  avatarname);
            
            if( avatarname != player.name) {
                player.setName( avatarname );
            };
            
//            var playersConnectedBefireAlteringGraph :HashSet = getAllPlayerIdsConnected( player.playerId );
            
            //Update hierarchy data
            setPlayerSire( player.playerId, player.sire );
            var minionsToAddToServerHierarchy :Array = player.minions;
            for each( var minionId :int in minionsToAddToServerHierarchy) {
                setPlayerSire( minionId, player.playerId );
            }
            
            //Copy hierarchy to all rooms
            var bytes :ByteArray = toBytes();
            log.info(Constants.DEBUG_MINION + "Updated hierarchy from player, copying to all rooms", "hierarchy",  toString() );
            VServer.control.doBatch( function() :void {
                VServer.rooms.forEach( function( roomId :int, room :Room) :void {
                    log.info(Constants.DEBUG_MINION + "Setting hierarchy into room", "hierarchy",  toString() );
                    room.ctrl.props.set( Codes.ROOM_PROP_MINION_HIERARCHY, bytes);
                });
            });
        }
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
    
    protected function getAllPlayerIdsConnected( playerId :int ) :HashSet
    {
        var allConnected :HashSet = new HashSet();
        var sires :HashSet = getAllSiresAndGrandSires( playerId );
        var minions :HashSet = getAllMinionsAndSubminions( playerId );
        sires.forEach( function( sireId :int, ...ignored) :void {
            allConnected.add( sireId );
        });
        minions.forEach( function( minionId :int, ...ignored) :void {
            allConnected.add( minionId );
        });
        return allConnected;
    }
    
    
    protected function isPlayer( playerId :int ) :Boolean
    {
        return _playerId2Node.containsKey( playerId );
    }
    
    protected var _playerId2Node :HashMap = new HashMap();
    public var _playerId2Name :HashMap = new HashMap();
    
    //Only needed server-side.
    protected var _ctrl :AVRServerGameControl;
    
    protected static const log :Log = Log.getLog( MinionHierarchy );
}
}
    import com.threerings.util.Hashable;
    import com.threerings.util.HashSet;
    
    

class Node implements Hashable
{
    public function Node( playerid :int)
    {
        _hash = playerid;
    }
    
    public function hashCode () :int
    {
        return _hash;
    }
    
    public function equals (other :Object) :Boolean
    {
        return (other is Node) && (_hash === (other as Node)._hash);
    }
    
    
    
    protected var _hash :int;
    public var parent :Node;
    public var childrenIds :HashSet = new HashSet();
}