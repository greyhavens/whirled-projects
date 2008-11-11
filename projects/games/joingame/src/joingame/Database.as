package joingame
{
    import com.threerings.util.ArrayUtil;
    import com.threerings.util.HashMap;
    import com.threerings.util.Log;
    
    /**Stores the moves and results of players, per game.
    * Used for generating statistics and the end of a game.
    */
    public class Database
    {
        protected static const log :Log = Log.getLog( Database );
        /* All the following hashmaps are indexed by the player.  Think all are _player2...*/
        public var _deltas :HashMap;
        public var _horizontal4Joins :HashMap;
        public var _horizontal5Joins :HashMap;
        public var _horizontal6Joins :HashMap;
        public var _horizontal7Joins :HashMap;
        public var _verticalJoins :HashMap;
        protected var _killList :HashMap;
        protected var _totalDamageRecieved :HashMap;
        protected var _damageInflictedOnPlayer :HashMap;
        
        public function Database()
        {
            _deltas = new HashMap();
            _horizontal4Joins = new HashMap();
            _horizontal5Joins = new HashMap();
            _horizontal6Joins = new HashMap();
            _horizontal7Joins = new HashMap();
            _verticalJoins = new HashMap();
            _killList = new HashMap();
            _totalDamageRecieved = new HashMap();
            _damageInflictedOnPlayer = new HashMap();
        }
        
        public function clearAll() :void
        {
            _deltas.clear();
            _horizontal4Joins.clear();
            _horizontal5Joins.clear();
            _horizontal6Joins.clear();
            _horizontal7Joins.clear();
            _verticalJoins.clear();
            _killList.clear();
            _totalDamageRecieved.clear();
            _damageInflictedOnPlayer.clear();
        }
        
        public function addDelta( playerId :int ) :void
        {
            if( !_deltas.containsKey( playerId) ) {
                _deltas.put( playerId, 1);
            }
            else {
                _deltas.put( playerId, _deltas.get( playerId ) + 1);
            }
            
        }
        
        public function addPlayerKilledPlayer( playerId :int, killPlayerId :int ) :void
        {
            if( !_killList.containsKey( playerId) ) {
                _killList.put( playerId, [killPlayerId]);
            }
            else if( !ArrayUtil.contains(_killList.get( playerId),  killPlayerId)) {
                (_killList.get( playerId) as Array).push( killPlayerId);
            }
            else {
                log.error( "addPlayerKilledPlayer( " + playerId + ", " + killPlayerId + "), killed player already present!");
            }
            
        }
        
        public function addDamage( fromPlayer :int, toPlayer :int, damage :int = 1 ) :void
        {
            if( !_damageInflictedOnPlayer.containsKey( fromPlayer) ) {
                _damageInflictedOnPlayer.put( fromPlayer, new HashMap());
                (_damageInflictedOnPlayer.get( fromPlayer) as HashMap).put( toPlayer, damage);
            }
            else {
                var toPlayer2Damage :HashMap = _damageInflictedOnPlayer.get( fromPlayer) as HashMap;
                if( !toPlayer2Damage.containsKey( toPlayer) ) {
                    toPlayer2Damage.put( toPlayer, damage);
                }
                else {
                    toPlayer2Damage.put( toPlayer, toPlayer2Damage.get(toPlayer) + damage);
                }
            }
            
        }
        
        
        
        /* Various stats*/
        
        public function getMeanKillsPerDelta( playerId :int ) :Number
        {
            if( !_deltas.containsKey( playerId ) ) {
                log.error( "getMeanDeltasPerKill(" + playerId + "), _deltas does not contain player");
                return 0;
            }
            var kills :Number = _killList.containsKey(playerId) ? (_killList.get(playerId) as Array).length : 0;
            var deltas :Number = _deltas.containsKey(playerId) ? _killList.get(playerId)  : 0;
            if( deltas == 0) {
                return 0;
            }
            return kills / deltas;
        }

    }
}