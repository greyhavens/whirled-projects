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
        protected var _deltas :HashMap;
        protected var _horizontalJoins :HashMap;//player -> array indexed by the join length
        protected var _verticalJoins :HashMap;//player -> array indexed by the join length
        protected var _killList :HashMap;
        protected var _totalDamageRecieved :HashMap;
        protected var _damageInflictedOnPlayer :HashMap;
        
        public function Database()
        {
            _deltas = new HashMap();
            _horizontalJoins = new HashMap();
            _verticalJoins = new HashMap();
            _killList = new HashMap();
            _totalDamageRecieved = new HashMap();
            _damageInflictedOnPlayer = new HashMap();
        }
        
        public function clearAll() :void
        {
            _deltas.clear();
            _horizontalJoins.clear();
            _verticalJoins.clear();
            _killList.clear();
            _totalDamageRecieved.clear();
            _damageInflictedOnPlayer.clear();
        }
        
        
        public function addJoin( playerId :int, joinLength :int, isHorizontal :Boolean ) :void
        {
            var joinMap :HashMap = isHorizontal ? _horizontalJoins : _verticalJoins;
            if( !joinMap.containsKey( playerId) ) {
                joinMap.put( playerId, []);
            }
            else {
                var joins :Array = joinMap.get( playerId ) as Array; 
                if( joins.length < joinLength - 1) {
                    joins[ joinLength ] = 1;
                }
                else {
                    joins[ joinLength ] += 1;
                }
            }
            
        }
        
        public function getJoins( playerId :int, isHorizontal :Boolean ) :int
        {
            var joinMap :HashMap = isHorizontal ? _horizontalJoins : _verticalJoins;
            var joins :Array = joinMap.get( playerId ) as Array;
            var total :int = 0; 
            for( var k :int = 0; k < joins.length; k++) {
                total += (joins[k] != undefined ? joins[k] : 0);
            }
            return total;
        }
        
        public function getAllVJoins( playerId :int ) :int
        {
            return getJoins(playerId, false);
        }
        public function getAllHJoins( playerId :int ) :int
        {
            return getJoins(playerId, true);
        }
        
        public function getAllJoins( playerId :int ) :int
        {
            return getJoins(playerId, false) + getJoins(playerId, true);
        }
        
        public function getTotalJoinLength( playerId :int, isHorizontal :Boolean) :int
        {
            var joinMap :HashMap = isHorizontal ? _horizontalJoins : _verticalJoins;
            var joins :Array = joinMap.get( playerId ) as Array;
            var total :int = 0; 
            for( var k :int = 0; k < joins.length; k++) {
                total += (joins[k] != undefined ? joins[k] : 0) * (k + 1);
            }
            return total;
        }
        
        public function getPlayersKilledByPlayer( playerId :int ) :Array
        {
            return _killList.get( playerId ) as Array;
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
                log.warning( "addPlayerKilledPlayer( " + playerId + ", " + killPlayerId + "), killed player already present!");
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
                log.warning( "getMeanDeltasPerKill(" + playerId + "), _deltas does not contain player");
                return 0;
            }
            var kills :Number = _killList.containsKey(playerId) ? (_killList.get(playerId) as Array).length : 0;
            var deltas :Number = _deltas.containsKey(playerId) ? _deltas.get(playerId)  : 0;
            if( deltas == 0) {
                return 0;
            }
            return kills / deltas;
        }

    }
}