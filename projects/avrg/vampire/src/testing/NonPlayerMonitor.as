package vampire.avatar
{
    import com.threerings.util.ArrayUtil;
    import com.threerings.util.HashMap;
    import com.threerings.util.Log;
    import com.threerings.util.StringBuilder;
    import com.whirled.ControlEvent;
    import com.whirled.avrg.AVRGameRoomEvent;
    import com.whirled.avrg.RoomSubControlBase;
    import com.whirled.contrib.simplegame.EventCollecter;
    
    import vampire.client.events.AvatarUpdatedEvent;
    import vampire.data.VConstants;
    
    
    
/**
 * Listens to the signals from the game avatar and notifies relevant changes in non-player status.
 * 
 * Tracks non-player locations, and implicitly, the existance of non-players.
 * 
 * Each room has an instance, and the client has an instance.
 * 
 * Blood for the NPAvatars is tracked seperately.
 * 
 */
public class NonPlayerMonitor extends EventCollecter
{
    public function NonPlayerMonitor(roomCtrl :RoomSubControlBase)
    {
        _room = roomCtrl;
        registerListener(_room, AVRGameRoomEvent.SIGNAL_RECEIVED, handleSignalReceived);
    }
    
    
    /**
    * Intercept signals from the avatar reporting location info about the room non-player avatars.
    */
    public function handleSignalReceived (e :ControlEvent) :void
    {
        var data :Array;
        switch(e.name) {
            
            case VConstants.SIGNAL_PLAYER_IDS:
                //Remove any non-players that are now players
                var playerIds :Array = e.value as Array;
                playerIds.forEach(function(playerId :int, ...ignored) :void {
                    _nonPlayerLocations.remove(playerId);
                });
                break;
            case VConstants.SIGNAL_AVATAR_MOVED:
                data = e.value as Array;
                var playerId :int = int(data[0]);
                var location :Array = data[1] as Array;
                var hotspot :Array = data[2] as Array;
                
                if(location != null) {
                    if(!ArrayUtil.equals(_nonPlayerLocations.get(playerId), location)) {
                        _nonPlayerLocations.put(playerId, location);
                        _nonPlayerHotspots.put(playerId, hotspot);
                        dispatchEvent(new AvatarUpdatedEvent(playerId));
                    } 
                }
                else {
                    _nonPlayerLocations.remove(playerId);
                    _nonPlayerHotspots.remove(playerId);
                    dispatchEvent(new AvatarUpdatedEvent(playerId));
                }
                log.debug("handleSignalReceived() e=" + e + "\n" + toString());
                break;
            default:
                break;
        }
    }
    
    public function destroySelf() :void
    {
        _events.freeAllHandlers();
        _room = null;
    }
    
    public function get nonPlayersIds() :Array
    {
        return _nonPlayerLocations.keys();
    }
    
    public function isNonPlayer(playerId :int) :Boolean
    {
        return _nonPlayerLocations.containsKey(playerId);
    }
    
    override public function toString() :String
    {
        var sb :StringBuilder = new StringBuilder("Nonplayer Locations:");
        for each(var id :int in _nonPlayerLocations.keys()) {
            sb.append(id + ", loc=" + _nonPlayerLocations.get(id) + ", hot=" + _nonPlayerHotspots.get(id) + "\n");
        }
        return sb.toString();
    }
    
    
    protected var _nonPlayerLocations :HashMap = new HashMap();
    protected var _nonPlayerHotspots :HashMap = new HashMap();
    
    protected var _room :RoomSubControlBase;
    protected static const log :Log = Log.getLog(NonPlayerMonitor);

}
}