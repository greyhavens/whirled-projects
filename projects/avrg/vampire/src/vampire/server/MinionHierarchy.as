package vampire.server
{
    import com.threerings.util.HashMap;
    import com.threerings.util.HashSet;
    import com.threerings.util.Log;
    import com.threerings.util.StringBuilder;
    
    
/**
 * The hierarchy of vampires.  The server can query this to get player info.
 * Currently only returns information of online players.
 * 
 * This is a simple DAG (directed acyclic graph).
 */
public class MinionHierarchy
{
    
    public function MinionHierarchy()
    {
    }
    
    public function addOrUpdatePlayer( playerId :int, sireId :int, minions :Array = null) :void 
    {
        setPlayerSire( playerId, sireId );
        for each( var minionId :int in minions) {
            setPlayerSire( minionId, playerId );
        } 
    }
    
    public function setPlayerSire( playerId :int, sireId :int) :void
    {
        
        //If the sire isn't added, or has no sire
        if( !_player2Sire.containsKey( sireId ) ) {
            _player2Sire.put( sireId, -1 );
        }
        
        
        //Remove yourself from the previous sires minions
        if( _player2Sire.get( playerId ) != sireId) {
            var previousSireMinions :HashSet = _player2Minions.get( _player2Sire.get( playerId ) ) as HashSet;
            if( previousSireMinions != null) {
                previousSireMinions.remove( playerId );
            }
        }
        
        //Add yourself to the new sire's minions
        if( _player2Minions.get( sireId ) == null ) {
            _player2Minions.put( sireId, new HashSet() );
        }
        var newSireMinions :HashSet = _player2Minions.get( sireId ) as HashSet;
        newSireMinions.add( playerId );
        
        //Finally update your sire status.
        _player2Sire.put( playerId, sireId );
    }
    
    
    public function getAllMinionsAndSubminions( playerId :int, minions :Array = null ) :Array
    {
        if( minions == null) {
            minions = new Array();
        }
        
        var minionSet :HashSet = _player2Minions.get( playerId ) as HashSet;
        if( minionSet != null) {
            minionSet.forEach( function( minionId :int) :void
                {
                    minions.push( minionId );
                    getAllMinionsAndSubminions( minionId, minions);
                });
        }
        
        return minions;
    }

    public function toString() :String
    {
        var sb :StringBuilder = new StringBuilder();
        for each( var playerId :int in _player2Sire.keys()) {
            sb.append("\n");
            sb.append(" " + playerId);
            sb.append(" sire=" + _player2Sire.get(playerId));
            if( _player2Minions.get(playerId) != null) {
                sb.append(" minions=" + HashSet(_player2Minions.get(playerId)).toArray() );
            }
            sb.append(" subminions=" + getAllMinionsAndSubminions(playerId));
        }
        return sb.toString();
    }
    
    protected var _player2Sire :HashMap = new HashMap();
    protected var _player2Minions :HashMap = new HashMap();
    
    protected static const log :Log = Log.getLog( MinionHierarchy );
}
}
    

//class Node 
//{
//    public function Node( id :int, parent :Node, children :Array = null)
//    {
//        this.id = id;
//    }
//    
//    public var id :int;
//    public var parent :Node;
//    public var children :Array;
//}