package vampire.data
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.avrg.RoomSubControlServer;
import com.whirled.net.NetConstants;
import com.whirled.net.PropertySubControl;

import flash.utils.Dictionary;

import vampire.server.Player;


/**
 * Shared player state recored to the 
 * players permanent record and shared 
 * by the rooms
 * 
 */
public class SharedPlayerStateServer //implements IExternalizable
{
    
    protected static const log :Log = Log.getLog( SharedPlayerStateServer );
    
    /** Pplayer name.  Needed even when player is offline*/
    public static const PLAYER_PROP_PREFIX_NAME:String = NetConstants.makePersistent("playerName");
    
    /** Current amount of blood*/
    public static const PLAYER_PROP_PREFIX_BLOOD :String = NetConstants.makePersistent("blood");
    
    /** Max blood for the given level.  This could probably just be computed...? Possibly remove later.*/
//    public static const PLAYER_PROP_PREFIX_MAXBLOOD :String = NetConstants.makePersistent("maxblood");
    
    /** Current level.  This controls the max amount of blood*/
    public static const PLAYER_PROP_PREFIX_LEVEL :String = NetConstants.makePersistent("level");
    
    /** 
    * Blood slowly drains away, even when you are asleep.  When starting a game, lose an amount
    * of blood proportional to how long you have been asleep. 
    * 
    * In addition, new players have a value == 1.  This allows new players to be detected by
    * the client so e.g. the intro screen can be shown.
    */
    public static const PLAYER_PROP_PREFIX_LAST_TIME_AWAKE :String = NetConstants.makePersistent("time_last_awake");
    
    /** 
    * List of minions (people you invite into the game).
    */
    public static const PLAYER_PROP_PREFIX_MINIONS :String = NetConstants.makePersistent("minions");
    
    /** 
    * The vampire who makes you into a vampire.
    */
    public static const PLAYER_PROP_PREFIX_SIRE :String = NetConstants.makePersistent("sire");
    
    /** 
    * Player(s) currently bloodbonded to you.  Bloodbonding is romantic with minor game effects.
    */
    public static const PLAYER_PROP_PREFIX_BLOODBONDED :String = NetConstants.makePersistent("bloodbonded");
    
    /** 
    * Current player action.
    */
//    public static const PLAYER_PROP_PREFIX_ACTION :String = NetConstants.makePersistent("action");
    
    
    /**
     * Whether or not this player is taking active part in the game. This property is
     * persistently stored in that player's property space.
     */
    public static const PROP_IS_PLAYING :String = NetConstants.makePersistent("playing");





        /**
     * The prefix for the PLAYER dictionary container which summarizes the current state
     * of a player in a room (currently health and max health). The full room property name
     * is constructed by appending the player's numerical id.
     */
    internal static const ROOM_PROP_PREFIX_PLAYER_DICT :String = "p";

    /**
    * Attributes stored in the room properties for each player.  Each entry in the array
    * corresponds to the index of the player dictionary.
    * 
    */
    public static const ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD :int = 0;
    public static const ROOM_PROP_PLAYER_DICT_INDEX_NAME :int = 1;
    public static const ROOM_PROP_PLAYER_DICT_INDEX_LEVEL :int = 2;
    public static const ROOM_PROP_PLAYER_DICT_INDEX_PREVIOUS_TIME_AWAKE :int = 3;
    public static const ROOM_PROP_PLAYER_DICT_INDEX_MINIONS :int = 4;
    public static const ROOM_PROP_PLAYER_DICT_INDEX_SIRE :int = 5;
    public static const ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED :int = 6;
    public static const ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_ACTION :int = 7;
    public static const ROOM_PROP_PLAYER_DICT_INDEX_MAX_BLOOD :int = 8;
    
    
    
    public function SharedPlayerStateServer( props :PropertySubControl)
    {
        _props = props;
        if( props == null ) {
            log.error("props == null!!!!!");
        }
        
        _action = Constants.GAME_MODE_NOTHING;
        
        log.debug("Getting level");
        _level = int(_props.get(PLAYER_PROP_PREFIX_LEVEL));


        log.debug("Getting blood");
        var blood :Object = _props.get(PLAYER_PROP_PREFIX_BLOOD);
        if (blood != null) {
            _blood = Number(blood);

        } else {
            // blood should always be set if level is set, but let's play it safe
//            log.debug("Repairing player blood", "playerId", ctrl.getPlayerId());
            log.debug("   setting blood=" + Constants.MAX_BLOOD_FOR_LEVEL( this.level ));
            setBlood(Constants.MAX_BLOOD_FOR_LEVEL( this.level ), true);
        }
        
        log.debug("Getting bloodbonded");
        var bloodbonded :Object = _props.get(PLAYER_PROP_PREFIX_BLOODBONDED);
        if (bloodbonded != null) {
            _bloodbonded = bloodbonded as Array;
            if( _bloodbonded == null) {
                log.error("Despite the bloodbonded key containing something, it's not an array.  Setting bloodbonded=[]");
                _bloodbonded = [];
            }

        } else {
            // bloodbonded should at least be an empty array
//            log.debug("Repairing player bloodbonded", "playerId", ctrl.getPlayerId());
            log.debug("   setting bloodbonded=[]");
            setBloodBonded([]);
        }
        
        log.debug("Getting ", "time", new Date(_props.get(PLAYER_PROP_PREFIX_LAST_TIME_AWAKE)).toTimeString());
        _timePlayerPreviouslyQuit = Number(_props.get(PLAYER_PROP_PREFIX_LAST_TIME_AWAKE));
        if( _timePlayerPreviouslyQuit == 0) {
            log.info("Repairing", "time", _props.get(PLAYER_PROP_PREFIX_LAST_TIME_AWAKE));
            var time :Number = new Date().time;
            setTime(time);
            log.info("  now", "time", _props.get(PLAYER_PROP_PREFIX_LAST_TIME_AWAKE));
        }
        
        log.debug("Getting minions");
        var minions :Object = _props.get(PLAYER_PROP_PREFIX_MINIONS);
        if (minions != null) {
            _minions = minions as Array;
            if( _minions == null) {
                log.error("Despite the minions key containing something, it's not an array.  Setting _minions=[]");
                _minions = [];
            }

        } else {
            // bloodbonded should at least be an empty array
//            log.debug("Repairing player bloodbonded", "playerId", ctrl.getPlayerId());
            log.debug("   setting _minions=[]");
            setMinions([]);
        }
        log.debug("Getting sire");
        _sire = int(_props.get(PLAYER_PROP_PREFIX_SIRE));
        if( _sire == 0 ) {
            _sire = -1;
        }
    }

    public function setAction (action :String, force :Boolean = false) :void
    {
        // update our runtime state
        if (!force && action == _action) {
            return;
        }
        _action = action;

        // persist it, too
//        _props.set(PLAYER_PROP_PREFIX_ACTION, _action, true);
    }
    
    public function setName (name :String, force :Boolean = false) :void
    {
        // update our runtime state
        if (!force && name == _name) {
            return;
        }
        _name = name;
        log.debug("Persisting name in player props");
        // persist it, too
        _props.set(PLAYER_PROP_PREFIX_NAME, _name, true);
    }

    public function setBlood (blood :Number, force :Boolean = false) :void
    {
        // update our runtime state
        if (!force && blood == _blood) {
            return;
        }
        _blood = blood;
        log.debug("Persisting blood in player props");
        // persist it, too
        _props.set(PLAYER_PROP_PREFIX_BLOOD, _blood, true);
    }
    
    public function setLevel (level :int, force :Boolean = false) :void
    {
        // update our runtime state
        if (!force && level == _level) {
            return;
        }
        _level = level;

        // persist it, too
        _props.set(PLAYER_PROP_PREFIX_LEVEL, _level, true);
    }
    
    public function setTime (time :Number, force :Boolean = false) :void
    {
        log.info("setTime()", "time", new Date(time).toTimeString());
        
        // update our runtime state
        if (!force && time == _timePlayerPreviouslyQuit) {
            return;
        }
        _timePlayerPreviouslyQuit = time;

        // persist it, too
        _props.set(PLAYER_PROP_PREFIX_LAST_TIME_AWAKE, _timePlayerPreviouslyQuit, true);
        log.info("now ", "time", new Date(_props.get(PLAYER_PROP_PREFIX_LAST_TIME_AWAKE)).toTimeString());
    }
    
//    public function addBloodBond( blondbondedPlayerId :int ) :void
//    {
//        if( ArrayUtil.contains( _bloodbonded, blondbondedPlayerId) ) {
//            return;
//        }
//        _bloodbonded.push( blondbondedPlayerId );
//        setBloodBonded( _bloodbonded, true );
//    }
//    
//    public function removeBloodBond( blondbondedPlayerId :int ) :void
//    {
//        if( !ArrayUtil.contains( _bloodbonded, blondbondedPlayerId) ) {
//            return;
//        }
//        _bloodbonded.splice( ArrayUtil.indexOf( _bloodbonded, blondbondedPlayerId), 1 );
//        setBloodBonded( _bloodbonded, true );
//    }
    
    public function setBloodBonded (bloodbonded :Array) :void
    {
        _bloodbonded = bloodbonded;
        // persist it, too
        _props.set(PLAYER_PROP_PREFIX_BLOODBONDED, _bloodbonded, true);
    }
    
    public function setMinions (minions :Array) :void
    {
        _minions = minions;
        // persist it, too
        _props.set(PLAYER_PROP_PREFIX_MINIONS, _minions, true);
    }
    
    public function setSire (sire :int, force :Boolean = false) :void
    {
        // update our runtime state
        if (!force && sire == _sire) {
            return;
        }
        _sire = sire;

        // persist it, too
        log.debug("setSire", "sire", sire);
        _props.set(PLAYER_PROP_PREFIX_SIRE, _sire, true);
        log.debug("setSire after ", "sire", _props.get(PLAYER_PROP_PREFIX_SIRE));
    }
    
    public function setMaxBlood (maxBlood :int, force :Boolean = false) :void
    {
        // update our runtime state
        if (!force && maxBlood == _maxBlood) {
            return;
        }
        _maxBlood = maxBlood;

        // persist it, too
//        _props.set(PLAYER_PROP_PREFIX_MAXBLOOD, _maxBlood, true);
    }
    
    
    

    
    public function toString() :String
    {
        var d :Date = new Date(time);
        return "SharedPlayerState[ " + name + ", _level=" + level + ", blood=" + blood + "/" + maxBlood + ", time=" + d.toLocaleTimeString() + " " + d.toLocaleDateString() + ", sire=" + sire + ", minions=" + minions + ", bloodbonded=" + bloodbonded + "]";
    }
    
    public function get action () :String
    {
        return _action;
    }
    
    public function get name () :String
    {
        return _name;
    }
    
    public function get level () :int
    {
        return _level;
    }
    
    public function get blood () :Number
    {
        return _blood;
    }
    
    public function get maxBlood () :Number
    {
        return Constants.MAX_BLOOD_FOR_LEVEL( level );
    }
    
    public function get bloodbonded () :Array
    {
        return _bloodbonded.slice();
    }
    
    public function get minions () :Array
    {
        return _minions.slice();
    }
    
    public function get sire () :int
    {
        return _sire;
    }
    
    public function get time () :Number
    {
        return _timePlayerPreviouslyQuit;
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

        var key :String = SharedPlayerStateServer.ROOM_PROP_PREFIX_PLAYER_DICT + player.playerId;
        
        var dict :Dictionary = roomctrl.props.get(key) as Dictionary;
        if (dict == null) {
            dict = new Dictionary(); 
        }

        if (dict[ROOM_PROP_PLAYER_DICT_INDEX_LEVEL] != player.level) {
            roomctrl.props.setIn(key, SharedPlayerStateServer.ROOM_PROP_PLAYER_DICT_INDEX_LEVEL, player.level);
        }
        if (dict[ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD] != player.blood) {
            roomctrl.props.setIn(key, SharedPlayerStateServer.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD, player.blood);
        }
        if (dict[ROOM_PROP_PLAYER_DICT_INDEX_MAX_BLOOD] != player.maxBlood) {
            roomctrl.props.setIn(key, SharedPlayerStateServer.ROOM_PROP_PLAYER_DICT_INDEX_MAX_BLOOD, player.maxBlood);
        }
        
        if (dict[ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_ACTION] != player.action) {
            roomctrl.props.setIn(key, SharedPlayerStateServer.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_ACTION, player.action);
        }
        
        if (!ArrayUtil.equals( dict[ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED], player.bloodbonded )) {
            roomctrl.props.setIn(key, SharedPlayerStateServer.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED, player.bloodbonded);
        }
        
//        if (!ArrayUtil.equals( dict[ROOM_PROP_PLAYER_DICT_INDEX_MINIONS], player.minions )) {
//            roomctrl.props.setIn(key, SharedPlayerStateServer.ROOM_PROP_PLAYER_DICT_INDEX_MINIONS, player.minions);
//        }
        
//        if (dict[ROOM_PROP_PLAYER_DICT_INDEX_SIRE] != player.sire) {
//            roomctrl.props.setIn(key, SharedPlayerStateServer.ROOM_PROP_PLAYER_DICT_INDEX_SIRE, player.sire);
//        }
        
        if (dict[ROOM_PROP_PLAYER_DICT_INDEX_PREVIOUS_TIME_AWAKE] != player.time) {
            log.info("Setting into room props", "time", new Date(player.time).toTimeString());
            roomctrl.props.setIn(key, SharedPlayerStateServer.ROOM_PROP_PLAYER_DICT_INDEX_PREVIOUS_TIME_AWAKE, player.time);
        }
    }
    
    
    protected var _props :PropertySubControl
    
    protected var _name :String;
    protected var _level :int;
    protected var _blood :Number;
    protected var _maxBlood :Number;
    protected var _action :String;
    
    protected var _bloodbonded :Array;
    
    protected var _sire :int;
    protected var _minions :Array;
    
    protected var _timePlayerPreviouslyQuit :Number;
    
    
    
//    public function writeExternal(output:IDataOutput):void
//    {
//        output.writeInt( level );
//        output.writeInt( currentBlood );
//        output.writeInt( maxBlood );
//    }
//    
//    public function readExternal(input:IDataInput):void
//    {
//        _level = input.readInt();
//        _currentBlood = input.readInt();
//        _maxBlood = input.readInt();
//    }
//    
//    public function toBytes (bytes :ByteArray = null) :ByteArray
//    {
//        bytes = (bytes != null ? bytes : new ByteArray());
//        this.writeExternal( bytes );
//        return bytes;
//    }
//
//    public static function fromBytes (bytes :ByteArray) :SharedPlayerState
//    {
//        bytes.position = 0;
//        var state :SharedPlayerState = new SharedPlayerState(0);
//        state.readExternal( bytes );
//        return state;
//    }
    
}
}