package vampire.server
{
    import com.threerings.flash.MathUtil;
    import com.threerings.util.ClassUtil;
    import com.threerings.util.HashMap;
    import com.threerings.util.Log;
    import com.whirled.avrg.AVRGameRoomEvent;
    import com.whirled.contrib.simplegame.server.SimObjectThane;
    
    import vampire.data.VConstants;
    
public class LocationTracker extends SimObjectThane
{
    public function LocationTracker(room :Room)
    {
        _room = room;
        
        registerListener(room.ctrl, AVRGameRoomEvent.ROOM_UNLOADED, destroySelf);
        registerListener(room.ctrl, AVRGameRoomEvent.SIGNAL_RECEIVED, handleSignalReceived);
        registerListener(room.ctrl, AVRGameRoomEvent.PLAYER_MOVED, handlePlayerMoved);
        registerListener(room.ctrl, AVRGameRoomEvent.PLAYER_ENTERED, handlePlayerEntered); 
        registerListener(room.ctrl, AVRGameRoomEvent.PLAYER_LEFT, handlePlayerLeft);    
    }
    
    override public function destroySelf () :void
    {
        super.destroySelf();
        _room = null;
    }
    
    protected function handlePlayerEntered(e :AVRGameRoomEvent) :void
    {
        var playerId :int = int(e.value);
        if(_room.getPlayer(playerId)) {
            var player :Player = _room.getPlayer(playerId);
            _entityLocations.put(playerId, player.location); 
        }
        log.debug("handlePlayerEntered(" + e + ") " + this);
        
        _room.players.forEach(function(id :int, p :Player):void {
            p.handleAvatarMoved(playerId);
        });
    }
    
    protected function handlePlayerLeft(e :AVRGameRoomEvent) :void
    {
        _entityLocations.remove(int(e.value));
        log.debug("handlePlayerLeft(" + e + ") " + this);
    }
    
    protected function handlePlayerMoved(e :AVRGameRoomEvent) :void
    {
        var playerId :int = int(e.value);
        if(_room.getPlayer(playerId)) {
            var player :Player = _room.getPlayer(playerId);
            _entityLocations.put(playerId, player.location);
            
            _room.players.forEach(function(id :int, p :Player):void {
                p.handleAvatarMoved(playerId);
            }); 
        }
        log.debug("handlePlayerMoved(" + e + ") " + this);
    }
    
    
    /**
    * Game avatars are used to signal non-player movements
    */
    protected function handleSignalReceived(e :AVRGameRoomEvent) :void
    {
//        log.debug("handleSignalReceived() " + e);
        //Record all non-players movements.
        if(e.name == VConstants.SIGNAL_AVATAR_MOVED) {
            var data :Array = e.value as Array;
            var userId :int = int(data[0]);
            var location :Array = data[1] as Array;
            
            if(location == null) {
                _entityLocations.remove(userId);
            }
            else {
                _entityLocations.put(userId, location);
            }
            
            _room.players.forEach(function(id :int, p :Player):void {
                p.handleAvatarMoved(userId);
            }); 
        }
        log.debug("handleSignalReceived(" + e + ") " + this);
    }
    
    public function getLocation(userId :int) :Array
    {
        if(_room.getPlayer(userId)) {
            return _room.getPlayer(userId).location;
        }
        if(_entityLocations.containsKey(userId)) {
            return _entityLocations.get(userId) as Array;
        }
        return null;
    }
    
    public function getClosestVictim(p :Player) :int
    {
        function invalidVictim(id :int) :Boolean
        {
            return _room.getPlayer(id) 
                && _room.getPlayer(id).state != VConstants.AVATAR_STATE_BARED;
        }
        return getClosestUserId(p, invalidVictim);
    }
    public function getClosestUserId(player :Player, filter :Function = null) :int
    {
        var currentDistance :Number = Number.MAX_VALUE;
        var currentClosestUserId :int = -1;
        var playerLocation :Array = player.location;
        log.debug("getClosestUserId, Checking non-players");
        _entityLocations.forEach(function(userId :int, location :Array) :void {
            
            if(filter != null && filter(userId)) {
                log.debug("   " + userId + " filtered");
                return;
            }
            
            if(userId == player.playerId) {
                return;
            }
            var distance :Number = distanceLocations(playerLocation, location);
            log.debug("  " + userId + " distance=" + distance);
            if(distance < currentDistance) {
                currentDistance = distance;
                currentClosestUserId = userId;
            }
        });
        log.debug("Checking players");
        _room.players.forEach(function(id :int, otherPlayer :Player) :void {
            
            var userId :int = otherPlayer.playerId;
            
            if(filter != null && filter(userId)) {
                log.debug("   " + userId + " filtered");
                return;
            }
            
            if(otherPlayer.playerId == userId) {
                return;
            }
            var location :Array = otherPlayer.location;
            var distance :Number = distanceLocations(playerLocation, location);
            log.debug("  " + userId + " distance=" + distance);
            if(distance < currentDistance) {
                currentDistance = distance;
                currentClosestUserId = userId;
            }
        });
        
        return currentClosestUserId;
    }
    
    public function get nonPlayerAvatarIds() :Array
    {
        var ids :Array = new Array();
        _entityLocations.forEach(function(userId :int, loc :Array) :void {
            if(!_room.getPlayer(userId)) {
                ids.push(userId);
            }
        });
        return ids;
    }
    
    protected function distanceLocations(loc1 :Array, loc2 :Array) :Number
    {
        if(loc1 == null || loc2 == null) {
            return Number.MAX_VALUE;
        }
        return MathUtil.distance(loc1[0], loc1[2], loc2[0], loc2[2]);
    }
    
    override public function toString() :String
    {
        return ClassUtil.tinyClassName(this) + " ids=" + _entityLocations.keys() + ", locs=" + _entityLocations.values();
    }

    
    protected var _entityLocations :HashMap = new HashMap();
    protected var _room :Room;
    protected static const log :Log = Log.getLog(LocationTracker);

}
}