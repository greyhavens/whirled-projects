package vampire.client
{
    import com.threerings.util.ArrayUtil;
    import com.threerings.util.Log;
    import com.threerings.util.StringUtil;

    import flash.utils.Dictionary;

    import vampire.data.Codes;
    import vampire.data.Logic;
    import vampire.data.VConstants;


/**
* Read-only player state information.
*/
public class SharedPlayerStateClient
{
    protected static const log :Log = Log.getLog( SharedPlayerStateClient );

    public static function getBlood (playerId :int) :Number
    {
        var blood :Number = Number(playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD));
        if( !isNaN(blood) && blood >= 1 ) {
            return blood;
        }
        //Check if we are a non player.  They might not have any blood value set in the room props yet
        //If not, then they have max blood.
        if( !isPlayer( playerId )) {
            return VConstants.MAX_BLOOD_NONPLAYERS;
        }
        return blood;
    }

    public static function isPlayer( playerId :int ) :Boolean
    {
        return ArrayUtil.contains( ClientContext.ctrl.room.getPlayerIds(), playerId );
    }

    public static function getMaxBlood (playerId :int) :Number
    {
        return VConstants.MAX_BLOOD_FOR_LEVEL( getLevel(playerId) );
    }

    public static function getLevel (playerId :int) :int
    {
        return Math.max(1, Logic.levelGivenCurrentXpAndInvites( getXP( playerId ), getInvites(playerId)));
    }

    public static function getBloodType (playerId :int) :int
    {
        return Logic.getPlayerBloodStrain( playerId );
    }

    public static function getXP (playerId :int) :Number
    {
        var xp :Number = Number(playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP));
        if( isNaN( xp )) {
            return 0;
        }
        return xp;
    }

    public static function getInvites (playerId :int) :int
    {
        return int(playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_INVITES));
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

//    public static function getTargetName (playerId :int) :String
//    {
//        return playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_NAME) as String;
//    }
//
//    public static function getTargetHotspot (playerId :int) :Array
//    {
//        return playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_HOTSPOT) as Array;
//    }
//
//    public static function getTargetBlood (playerId :int) :Number
//    {
//        return playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_BLOOD) as Number;
//    }
//
//    public static function getTargetMaxBlood (playerId :int) :Number
//    {
//        return playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_MAXBLOOD) as Number;
//    }

    public static function getTargetLocation (playerId :int) :Array
    {
        return playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_LOCATION) as Array;
    }

    public static function getCurrentState (playerId :int) :String
    {
        if( playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_STATE) !== undefined) {
            return String(playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_STATE));
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

//    public static function getMinions (playerId :int) :Array
//    {
//        return playerData(playerId, Codes.ROOM_PROP_PLAYER_DICT_INDEX_MINIONS) as Array;
//    }

    protected static function playerData (playerId :int, ix :int) :*
    {
        var dict :Dictionary =
            ClientContext.ctrl.room.props.get(Codes.playerRoomPropKey(playerId)) as Dictionary;
        return (dict != null) ? dict[ix] : undefined;
    }

    public static function isVampire(playerId :int) :Boolean
    {
        return getLevel(playerId) >= VConstants.MINIMUM_VAMPIRE_LEVEL;
    }


    public static function isProps( playerId :int ) :Boolean
    {
        return ClientContext.ctrl.room.props.get(Codes.playerRoomPropKey(playerId)) != null;
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
        return playerId + ", blood=" + getBlood( playerId ) + ", level=" + getLevel( playerId ) + ", action=" + getCurrentState( playerId ) + ", bloodbonded=" + getBloodBonded( playerId ) + ", bloodbondname=" + getBloodBondedName(playerId) + ", time=" + new Date(getTime( playerId )).toTimeString()
//            + ", closestUserId=" + getClosestUserData( playerId )
            ;
    }

}
}