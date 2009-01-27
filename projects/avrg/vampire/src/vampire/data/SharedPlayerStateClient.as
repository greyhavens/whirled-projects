package vampire.data
{
    import com.threerings.util.Log;
    import com.threerings.util.StringUtil;
    
    import flash.utils.Dictionary;
    
    import vampire.client.ClientContext;
    
    
/**
* Read-only player state information.
*/
public class SharedPlayerStateClient
{
    protected static const log :Log = Log.getLog( SharedPlayerStateClient );
    
    public static function getBlood (playerId :int) :Number
    {
        return Number(playerData(playerId, SharedPlayerStateServer.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD));
    }
    
    public static function getMaxBlood (playerId :int) :Number
    {
        return Number(playerData(playerId, SharedPlayerStateServer.ROOM_PROP_PLAYER_DICT_INDEX_MAX_BLOOD));
    }
    
    public static function getLevel (playerId :int) :int
    {
        return int(playerData(playerId, SharedPlayerStateServer.ROOM_PROP_PLAYER_DICT_INDEX_LEVEL));
    }
    
    public static function getBloodBonded (playerId :int) :Array
    {
        return playerData(playerId, SharedPlayerStateServer.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED) as Array;
    }
    
    public static function getCurrentAction (playerId :int) :String
    {
        if( playerData(playerId, SharedPlayerStateServer.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_ACTION) !== undefined) {
            return String(playerData(playerId, SharedPlayerStateServer.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_ACTION));
        }
        else {
            return "none";
        }
    }
    
    public static function getSire (playerId :int) :int
    {
        return playerData(playerId, SharedPlayerStateServer.ROOM_PROP_PLAYER_DICT_INDEX_SIRE) as int;
    }

    public static function getTime (playerId :int) :Number
    {
        return playerData(playerId, SharedPlayerStateServer.ROOM_PROP_PLAYER_DICT_INDEX_PREVIOUS_TIME_AWAKE);
    }
    
    public static function getMinions (playerId :int) :Array
    {
        return playerData(playerId, SharedPlayerStateServer.ROOM_PROP_PLAYER_DICT_INDEX_MINIONS) as Array;
    }
    
    protected static function playerData (playerId :int, ix :int) :*
    {
        var dict :Dictionary =
            ClientContext.gameCtrl.room.props.get(SharedPlayerStateServer.ROOM_PROP_PREFIX_PLAYER_DICT + playerId) as Dictionary;
//            log.debug("playerData(), dict=" + dict)
        return (dict != null) ? dict[ix] : undefined;
    }
    

    
    
    public static function isProps( playerId :int ) :Boolean
    {
        return ClientContext.gameCtrl.room.props.get(SharedPlayerStateServer.ROOM_PROP_PREFIX_PLAYER_DICT + playerId) != null;
    }
    
    public static function parsePlayerIdFromPropertyName (prop :String) :int
    {
        if (StringUtil.startsWith(prop, SharedPlayerStateServer.ROOM_PROP_PREFIX_PLAYER_DICT)) {
            var num :Number = parseInt(prop.slice(SharedPlayerStateServer.ROOM_PROP_PREFIX_PLAYER_DICT.length));
            if (!isNaN(num)) {
                return num;
            }
        }
        return -1;
    }
    
    public static function toStringForPlayer( playerId :int ) :String
    {
        return playerId + ", blood=" + getBlood( playerId ) + ", level=" + getLevel( playerId ) + ", action=" + getCurrentAction( playerId ) + ", bloodbonded=" + getBloodBonded( playerId ) + ", time=" + new Date(getTime( playerId )).toTimeString();
    }

}
}