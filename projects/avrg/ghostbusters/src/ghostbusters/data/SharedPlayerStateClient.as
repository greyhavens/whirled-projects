package vampire.data
{
    import com.threerings.util.Log;
    import com.whirled.avrg.RoomSubControlServer;
    
    import flash.utils.Dictionary;
    
    import vampire.client.ClientContext;
    import vampire.server.Player;
    
    
/**
* Read-only player state information.
*/
public class SharedPlayerStateClient
{
    protected static const log :Log = Log.getLog( SharedPlayerStateClient );
    
    /**
     * The prefix for the PLAYER dictionary container which summarizes the current state
     * of a player in a room (currently health and max health). The full room property name
     * is constructed by appending the player's numerical id.
     */
    public static const ROOM_PROP_PREFIX_PLAYER_DICT :String = "p";

    /**
    * Attributes stored in the room properties for each player.  Each entry in the array
    * corresponds to the index of the player dictionary.
    * 
    */
    public static const ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD :int = 0;
    public static const ROOM_PROP_PLAYER_DICT_INDEX_MAX_BLOOD :int = 1;
    public static const ROOM_PROP_PLAYER_DICT_INDEX_LEVEL :int = 2;
    public static const ROOM_PROP_PLAYER_DICT_INDEX_PREVIOUS_TIME_AWAKE :int = 3;
    public static const ROOM_PROP_PLAYER_DICT_INDEX_MINIONS :int = 4;
    public static const ROOM_PROP_PLAYER_DICT_INDEX_SIRE :int = 5;
    public static const ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED :int = 6;
    
    
    public static function getBlood (playerId :int) :int
    {
        return int(playerData(playerId, ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD));
    }
    
    public static function getMaxBlood (playerId :int) :int
    {
        return int(playerData(playerId, ROOM_PROP_PLAYER_DICT_INDEX_MAX_BLOOD));
    }
    
    public static function getLevel (playerId :int) :int
    {
        return int(playerData(playerId, ROOM_PROP_PLAYER_DICT_INDEX_LEVEL));
    }

    
    protected static function playerData (playerId :int, ix :int) :*
    {
        var dict :Dictionary =
            ClientContext.gameCtrl.room.props.get(ROOM_PROP_PREFIX_PLAYER_DICT + playerId) as Dictionary;
            log.debug("playerData(), dict=" + dict)
        return (dict != null) ? dict[ix] : undefined;
    }
    
    /**
    * For convenience, only called on the server.
    * With this method, no other classes need to reference all the code constants.
    * 
    */
    public static function setIntoRoomProps( player :Player, roomctrl :RoomSubControlServer) :void
    {
        if (roomctrl == null) {
            log.warning("Null room control", "action", "setIntoRoomProps",
                        "playerId", player.playerId);
            return;
        }

        var key :String = ROOM_PROP_PREFIX_PLAYER_DICT + player.playerId;
        
        var dict :Dictionary = roomctrl.props.get(key) as Dictionary;
        if (dict == null) {
            dict = new Dictionary();
        }

        if (dict[ROOM_PROP_PLAYER_DICT_INDEX_LEVEL] != player.level) {
            roomctrl.props.setIn(key, ROOM_PROP_PLAYER_DICT_INDEX_LEVEL, player.level);
        }
        if (dict[ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD] != player.blood) {
            log.debug("Setting blood in props: " + key+ "[" + ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD + "]=" + player.blood);
            roomctrl.props.setIn(key, ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD, player.blood);
        }
        if (dict[ROOM_PROP_PLAYER_DICT_INDEX_MAX_BLOOD] != player.maxBlood) {
            roomctrl.props.setIn(key, ROOM_PROP_PLAYER_DICT_INDEX_MAX_BLOOD, player.maxBlood);
        }
    }
    
    

}
}