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
        return Number(playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD));
    }
    
    public static function getMaxBlood (playerId :int) :Number
    {
        return Constants.MAX_BLOOD_FOR_LEVEL( getLevel(playerId) );
    }
    
    public static function getTargetVisible (playerId :int) :Boolean
    {
        return Boolean(playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_DISPLAY_VISIBLE));
    }
    
    public static function getLevel (playerId :int) :int
    {
        return Logic.levelGivenCurrentXp( getXP( playerId ));
//        return int(playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_LEVEL));
    }
    
    public static function getXP (playerId :int) :int
    {
        return int(playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP));
    }
    
    public static function getBloodBonded (playerId :int) :int
    {
        return int(playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED));
    }
    
    public static function getBloodBondedName (playerId :int) :String
    {
        return playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED_NAME) as String;
    }
    
//    public static function getClosestUserData (playerId :int) :Array
//    {
//        return playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_CLOSEST_USERID) as Array;
//    }
    
    //ATM just returns the closest user
    public static function getTargetPlayer (playerId :int) :int
    {
        return playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_ID) as int;
    }
    
    public static function getTargetName (playerId :int) :String
    {
        return playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_NAME) as String;
    }
    
    public static function getTargetHotspot (playerId :int) :Array
    {
        return playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_HOTSPOT) as Array;
    }
    
    public static function getTargetBlood (playerId :int) :Number
    {
        return playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_BLOOD) as Number;
    }
    
    public static function getTargetMaxBlood (playerId :int) :Number
    {
        return playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_MAXBLOOD) as Number;
    }
    
    public static function getTargetLocation (playerId :int) :Array
    {
        return playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_LOCATION) as Array;
    }
    
    public static function getCurrentAction (playerId :int) :String
    {
        if( playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_ACTION) !== undefined) {
            return String(playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_ACTION));
        }
        else {
            return null;
        }
    }
    
    public static function getSire (playerId :int) :int
    {
        return playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_SIRE) as int;
    }

    public static function getTime (playerId :int) :Number
    {
        return playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_PREVIOUS_TIME_AWAKE);
    }
    
    public static function getMinions (playerId :int) :Array
    {
        return playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_MINIONS) as Array;
    }
    
    protected static function playerData (playerId :int, ix :int) :*
    {
        var dict :Dictionary =
            ClientContext.gameCtrl.room.props.get(Codes.playerRoomPropKey(playerId)) as Dictionary;
        return (dict != null) ? dict[ix] : undefined;
    }
    
    public static function isVampire(playerId :int) :Boolean
    {
        return getLevel(playerId) >= Constants.MINIMUM_VAMPIRE_LEVEL;
    }
    
    
    public static function isProps( playerId :int ) :Boolean
    {
        return ClientContext.gameCtrl.room.props.get(Codes.playerRoomPropKey(playerId)) != null;
    }
    
    public static function parsePlayerIdFromPropertyName (prop :String) :int
    {
        if (StringUtil.startsWith(prop, Codes.ROOM_PROP_PREFIX_PLAYER_DICT)) {
            var num :Number = parseInt(prop.slice(Codes.ROOM_PROP_PREFIX_PLAYER_DICT.length));
            if (!isNaN(num)) {
                return num;
            }
        }
        return -1;
    }
    
    public static function toStringForPlayer( playerId :int ) :String
    {
        return playerId + ", blood=" + getBlood( playerId ) + ", level=" + getLevel( playerId ) + ", action=" + getCurrentAction( playerId ) + ", bloodbonded=" + getBloodBonded( playerId ) + ", time=" + new Date(getTime( playerId )).toTimeString()
//            + ", closestUserId=" + getClosestUserData( playerId )
            ;
    }

}
}