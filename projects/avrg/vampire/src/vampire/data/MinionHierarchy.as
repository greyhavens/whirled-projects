package vampire.data
{
    import com.threerings.util.HashMap;
    import com.threerings.util.HashSet;
    import com.threerings.util.Log;
    import com.threerings.util.StringBuilder;
    
    import flash.utils.ByteArray;
    
    
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
        return null;
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
            sb.append(" " + playerId);
            sb.append(" sire=" + getSireId( playerId ) );
            if( isHavingMinions( playerId ) ) {
                sb.append(" minions=" + player.childrenIds.toArray() );
                sb.append(" subminions=" + getAllMinionsAndSubminions(playerId).toArray());
            }
        }
        return _playerId2Node.keys().length > 0 ? sb.toString() : "MinionHierarchy empty";
    }
    
    public function fromBytes (bytes :ByteArray) :void
    {
        _playerId2Node.clear();
        
//        bytes.uncompress();
        bytes.position = 0;
        var length :int = bytes.readInt();
        for( var i :int = 0; i < length; i++) {
            var playerId :int = bytes.readInt();
            var sireid :int = bytes.readInt();
            setPlayerSire( playerId, sireid );
        }
    }
    
    public function toBytes () :ByteArray
    {
        var bytes :ByteArray = new ByteArray();
        
        var players :Array = _playerId2Node.keys();
        bytes.writeInt( players.length );
        
        for each( var playerid :int in players) {
            bytes.writeInt( playerid );
            bytes.writeInt( getSireId( playerid )  );    
        }
//        bytes.compress();
        
        return bytes;
    } 
    
//    protected var _player2Sire :HashMap = new HashMap();
//    protected var _player2Minions :HashMap = new HashMap();
    
    protected var _playerId2Node :HashMap = new HashMap();
    
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