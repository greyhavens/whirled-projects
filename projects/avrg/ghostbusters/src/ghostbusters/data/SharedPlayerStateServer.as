package vampire.data
{
import com.threerings.util.Log;
import com.whirled.avrg.PlayerSubControlServer;
import com.whirled.net.NetConstants;


/**
 * Shared player state recored to the 
 * players permanent record and shared 
 * by the rooms
 * 
 */
public class SharedPlayerStateServer //implements IExternalizable
{
    
    protected static const log :Log = Log.getLog( SharedPlayerStateServer );
    
    /** Current amount of blood*/
    public static const PLAYER_PROP_PREFIX_BLOOD :String = NetConstants.makePersistent("blood");
    
    public static const PLAYER_PROP_PREFIX_MAXBLOOD :String = NetConstants.makePersistent("maxblood");
    
    /** Current level.  This controls the max amount of blood*/
    public static const PLAYER_PROP_PREFIX_LEVEL :String = NetConstants.makePersistent("level");
    
    /** 
    * Blood slowly drains away, even when you are asleep.  When starting a game, lose an amount
    * of blood proportional to how long you have been asleep. 
    */
    public static const PLAYER_PROP_PREFIX_LAST_TIME_AWAKE :String = NetConstants.makePersistent("time");
    
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
     * Whether or not this player is taking active part in the game. This property is
     * persistently stored in that player's property space.
     */
    public static const PROP_IS_PLAYING :String = NetConstants.makePersistent("playing");

    
    
    public function SharedPlayerStateServer( ctrl :PlayerSubControlServer)
    {
        _ctrl = ctrl;

        var level :Object = _ctrl.props.get(PLAYER_PROP_PREFIX_LEVEL);
        if (level != null) {
            _level = int(level);

        } else {
            log.debug("Repairing player level", "playerId", ctrl.getPlayerId());
            setLevel(1, true);
        }

        var blood :Object = _ctrl.props.get(PLAYER_PROP_PREFIX_BLOOD);
        if (blood != null) {
            _blood = int(blood);

        } else {
            // blood should always be set if level is set, but let's play it safe
            log.debug("Repairing player blood", "playerId", ctrl.getPlayerId());
            log.debug("   setting blood=" + Constants.MAX_BLOOD_FOR_LEVEL( this.level ));
            setLevel(Constants.MAX_BLOOD_FOR_LEVEL( this.level ), true);
        }
        
    }


    public function setBlood (blood :int, force :Boolean = false) :void
    {
        // update our runtime state
        if (!force && blood == _blood) {
            return;
        }
        _blood = blood;
        log.debug("Persisting blood in player props");
        // persist it, too
        _ctrl.props.set(PLAYER_PROP_PREFIX_BLOOD, _blood, true);
    }
    
    public function setLevel (level :int, force :Boolean = false) :void
    {
        // update our runtime state
        if (!force && level == _level) {
            return;
        }
        _level = level;

        // persist it, too
        _ctrl.props.set(PLAYER_PROP_PREFIX_LEVEL, _level, true);
    }
    
    public function setMaxBlood (maxBlood :int, force :Boolean = false) :void
    {
        // update our runtime state
        if (!force && maxBlood == _maxBlood) {
            return;
        }
        _maxBlood = maxBlood;

        // persist it, too
        _ctrl.props.set(PLAYER_PROP_PREFIX_MAXBLOOD, _maxBlood, true);
    }
    
    
    

    
    public function toString() :String
    {
        return "SharedPlayerState[ _level=" + level + ", _currentBlood=" + blood + ", _maxBlood=" + maxBlood + "]";
    }
    
    public function get level () :int
    {
        return _level;
    }
    
    public function get blood () :int
    {
        return _blood;
    }
    
    public function get maxBlood () :int
    {
        return Constants.MAX_BLOOD_FOR_LEVEL( level );
    }
    
    
    
    protected var _ctrl :PlayerSubControlServer
    
    protected var _level :int;
    protected var _blood :int;
    protected var _maxBlood :int;
    
    
    
    
    
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