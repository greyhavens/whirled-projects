package vampire.server
{

import com.threerings.flash.MathUtil;
import com.threerings.util.ArrayUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.Hashable;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.OfflinePlayerPropertyControl;
import com.whirled.avrg.PlayerSubControlServer;
import com.whirled.contrib.EventHandlerManager;

import flash.utils.ByteArray;
import flash.utils.Dictionary;

import vampire.data.Codes;
import vampire.data.Logic;
import vampire.data.VConstants;
import vampire.feeding.PlayerFeedingData;


/**
 * Handles data persistance and event handling, such as listening to enter room events.
 * Current state data is persisted into player and room props on update().  This is called from the
 * VServer a few times per second, reducing unnecessary network traffic.
 *
 */
public class PlayerData extends EventHandlerManager
    implements Hashable
{
    public function PlayerData (ctrl :PlayerSubControlServer)
    {
        if( ctrl == null ) {
            log.error("Bad! PlayerData(null).  What happened to the PlayerSubControlServer?  Expect random failures everywhere.");
            return;
        }

        _ctrl = ctrl;
        _playerId = ctrl.getPlayerId();

        registerListener( _ctrl, AVRGamePlayerEvent.ENTERED_ROOM, enteredRoom);
        registerListener( _ctrl, AVRGamePlayerEvent.LEFT_ROOM, leftRoom);


        //Start in the default state
        _action = VConstants.GAME_MODE_NOTHING;

        //Get last time awake
        log.debug("Getting ", "time", new Date(_ctrl.props.get(Codes.PLAYER_PROP_LAST_TIME_AWAKE)).toTimeString());
        _timePlayerPreviouslyQuit = Number(_ctrl.props.get(Codes.PLAYER_PROP_LAST_TIME_AWAKE));

        //Debugging
        //WhirledDev, 1734==Dion, 1735==Ragbears's Evil Twin
        if( _playerId == 1 ) {
            setTime(0);
        }


        //Get experience
        _xp = Number(_ctrl.props.get(Codes.PLAYER_PROP_XP));
        if( isNaN( _xp )) {
            setXP( 0 );
        }

        log.debug("Getting xp=" + _xp);

        //Get blood
        _blood = Number(_ctrl.props.get(Codes.PLAYER_PROP_BLOOD));
        if(_timePlayerPreviouslyQuit == 0) {
            // blood should always be set if level is set, but let's play it safe
            log.debug("   setting blood=" + VConstants.MAX_BLOOD_FOR_LEVEL( 1));
            setBlood(VConstants.MAX_BLOOD_FOR_LEVEL( 1 ));

        }

        //In the current game, we don't let you die.
        if( _blood < 1 ) {
            setBlood( 1 );
        }


        log.debug("Getting blood="+_blood);

        //Get bloodbonded data
        _bloodbonded = int( _ctrl.props.get(Codes.PLAYER_PROP_BLOODBONDED));
        if( _bloodbonded > 0) {
            _bloodbondedName = _ctrl.props.get(Codes.PLAYER_PROP_BLOODBONDED_NAME) as String;
        }
        log.debug("Getting bloodbonded=" + _bloodbonded);



        _sire = int(_ctrl.props.get(Codes.PLAYER_PROP_SIRE));

        log.debug("Getting sire=" + _sire);

        setAction( VConstants.GAME_MODE_NOTHING );

        //If we have previously been awake, reduce our blood proportionally to the time since we last played.
        log.debug("Getting time=" + time);
//        if( time > 1) {
//            var date :Date = new Date();
//            var now :Number = date.time;
//            var millisecondsSinceLastAwake :Number = now - time;
//            if( millisecondsSinceLastAwake < 0) {
//                log.error("Computing time since last awake, but < 0, now=" + now + ", time=" + time);
//            }
//            var daysSinceLastAwake :Number = millisecondsSinceLastAwake / (1000*60*60*24);
//            log.debug("daysSinceLastAwake=" + daysSinceLastAwake);
//            log.debug("secondSinceLastAwake=" + (millisecondsSinceLastAwake/1000));
//            var bloodReduction :Number = VConstants.BLOOD_LOSS_DAILY_RATE_WHILE_SLEEPING * daysSinceLastAwake;
//            log.debug("bloodReduction=" + bloodReduction);
////            bloodReduction = Math.min( bloodReduction, this.blood - 1);
//            var actualBloodLost :Number = damage( bloodReduction );
//            addFeedback( "Blood lost during sleep: " + Util.formatNumberForFeedback(actualBloodLost));
//
////            log.debug("bloodnow=" + bloodnow, "in props", blood);
//
//        }
//        else {
//            log.debug("We have not played before, so not computing blood reduction");
//        }

        log.info("Logging in", "playerId", playerId, "blood", blood, "maxBlood",
                 maxBlood, "level", level, "sire", sire, "time", new Date(time).toTimeString());

        //Create feeding data if there is none
        var feedingData :PlayerFeedingData = new PlayerFeedingData();
        if( _ctrl.props.get(Codes.PLAYER_PROP_FEEDING_DATA) == null ) {
            _ctrl.props.set(Codes.PLAYER_PROP_FEEDING_DATA, feedingData.toBytes() );
        }
        try {
            var bytes :ByteArray = _ctrl.props.get(Codes.PLAYER_PROP_FEEDING_DATA) as ByteArray;
            if( bytes != null) {
                bytes.position = 0;
                feedingData.fromBytes( bytes );
            }
        }
        catch(err :Error) {
            log.error("Error in feeding data, old version?  Resetting...");
            log.error(err.getStackTrace());
            feedingData = new PlayerFeedingData();
            _ctrl.props.set(Codes.PLAYER_PROP_FEEDING_DATA, feedingData.toBytes() );
        }
        log.debug("Getting feeding data=" + feedingData);

        //Load/Create minionIds
        _minionsForTrophies = _ctrl.props.get(Codes.PLAYER_PROP_MINIONIDS) as Array;
        if( _minionsForTrophies == null ) {
            _minionsForTrophies = new Array();
        }

        _inviteTally = int(_ctrl.props.get(Codes.PLAYER_PROP_INVITES));

        updateAvatarState();

    }

    public function addBlood (amount :Number) :void
    {
        setBlood(blood + amount); // note: setBlood clamps this to [0, maxBlood]
    }

    public function addFeedback( msg :String ) :void
    {
        if( _room != null ) {
            _room.addFeedback( msg, playerId );
        }
    }

    public function get ctrl () :PlayerSubControlServer
    {
        return _ctrl;
    }

    public function get playerId () :int
    {
        return _playerId;
    }


    // from Equalable
    public function equals (other :Object) :Boolean
    {
        if (this == other) {
            return true;
        }
        if (other == null || !ClassUtil.isSameClass(this, other)) {
            return false;
        }
        return PlayerData(other).playerId == _playerId;
    }

    // from Hashable
    public function hashCode () :int
    {
        return _playerId;
    }

    public function toString () :String
    {
        return "Player [playerId=" + _playerId
            + ", name=" + name
            + ", roomId=" +
            (room != null ? room.roomId : "null") + ", level=" + level + ", blood=" + blood + "/" + maxBlood + ", bloodbonds=" + bloodbonded
            + ", targetId=" + targetId
            + ", sire=" + sire
            + ", xp=" + xp
            + ", time=" + new Date(time).toTimeString()
            + "]";
    }

    public function isDead () :Boolean
    {
        return blood <= 0;
    }

    public function shutdown () :void
    {
        freeAllHandlers();

        var currentTime :Number = new Date().time;
        if( _room != null && _room.ctrl != null && _room.ctrl.isConnected()) {
            setTime( currentTime, true );
            setIntoPlayerProps();
            if( _ctrl != null && _ctrl.isConnected() ) {
                _ctrl.setAvatarState( VConstants.GAME_MODE_NOTHING );
            }
        }
        _room = null;
        _ctrl = null;
    }




    public function setBlood (blood :Number) :void
    {
        blood = MathUtil.clamp(blood, 1, maxBlood);
        _blood = blood;
    }

    public function setXP (xp :Number) :void
    {
        _xp = xp;
        _xp = Math.min( _xp, Logic.maxXPGivenXPAndInvites(_xp, invites));
    }

    public function setAvatarState (s :String, force :Boolean = false) :void
    {
        _avatarState = s;
    }
    public function setAction (action :String) :void
    {
        _action = action;
    }

    public function setName (name :String) :void
    {
        _name = name;
    }

    public function setTimeToCurrentTime() :void
    {
        var currentTime :Number = new Date().time;
        setTime( currentTime, true );
    }


    protected function get targetPlayer() :PlayerData
    {
        if( ServerContext.server.isPlayer( targetId )) {
            return ServerContext.server.getPlayer( targetId );
        }
        return null;
    }

    protected function get isTargetPlayer() :Boolean
    {
        return ServerContext.server.isPlayer( targetId );
    }

    public function get avatar() :AVRGameAvatar
    {
        if( room == null || room.ctrl == null) {
            return null;
        }
        return room.ctrl.getAvatarInfo( playerId );
    }

    protected function get targetOfTargetPlayer() :int
    {
        if( !isTargetPlayer ) {
            return 0;
        }
        return targetPlayer.targetId;
    }

    protected function get isTargetTargetingMe() :Boolean
    {
        if( !isTargetPlayer ) {
            return false;
        }
        return targetPlayer.targetId == playerId;
    }


    protected function enteredRoom (evt :AVRGamePlayerEvent) :void
    {

        log.info(VConstants.DEBUG_MINION + " Player entered room {{{", "player", toString());
        log.debug(VConstants.DEBUG_MINION + " hierarchy=" + ServerContext.lineage);

//        log.debug( Constants.DEBUG_MINION + " Player enteredRoom, already on the database=" + toString());
//        log.debug( Constants.DEBUG_MINION + " Player enteredRoom, hierarch=" + ServerContext.minionHierarchy);

            var thisPlayer :PlayerData = this;
            _room = ServerContext.server.getRoom(int(evt.value));
            ServerContext.server.control.doBatch(function () :void {
                try {
                    if( _room != null) {
//                        var minionsBytes :ByteArray = ServerContext.minionHierarchy.toBytes();
//                        ServerContext.serverLogBroadcast.log("enteredRoom, sending hierarchy=" + ServerContext.minionHierarchy);
//                        _room.ctrl.props.set( Codes.ROOM_PROP_MINION_HIERARCHY, minionsBytes );

                        _room.playerEntered(thisPlayer);
                        ServerContext.lineage.playerEnteredRoom( thisPlayer, _room);
                        updateAvatarState();
                    }
                    else {
                        log.error("WTF, enteredRoom called, but room == null???");
                    }
                }
                catch( err:Error)
                {
                    log.error(err.getStackTrace());
                }
            });

        //Make sure we are the right color when we enter a room.
//        handleChangeColorScheme( (isVampire() ? VConstants.COLOR_SCHEME_VAMPIRE : VConstants.COLOR_SCHEME_HUMAN) );
//        setIntoRoomProps();

        log.debug(VConstants.DEBUG_MINION + "after _room.playerEntered");
        log.debug(VConstants.DEBUG_MINION + "hierarchy=" + ServerContext.lineage);

    }


    protected function leftRoom (evt :AVRGamePlayerEvent) :void
    {
        var thisPlayer :PlayerData = this;
        ServerContext.server.control.doBatch(function () :void {
            if (_room != null) {

                _room.playerLeft(thisPlayer);

                if (_room.roomId == evt.value) {
                    _room = null;
                } else {
                    log.warning("The room we're supposedly leaving is not the one we think we're in",
                                "ourRoomId", _room.roomId, "eventRoomId", evt.value);
                }
            }

        });
    }



    public function get room () :Room
    {
        return _room;
    }

    public function setIntoRoomProps() :void
    {
        try {

            if( _ctrl == null || !_ctrl.isConnected() ) {
                log.error("setIntoRoomProps() but ", "_ctrl", _ctrl);
                return;
            }

            if( _room == null || _room.ctrl == null || !_room.ctrl.isConnected()) {
                log.error("setIntoRoomProps() but ", "room", room);
                return;
            }

            var key :String = Codes.ROOM_PROP_PREFIX_PLAYER_DICT + playerId;

            var dict :Dictionary = room.ctrl.props.get(key) as Dictionary;
            if (dict == null) {
                dict = new Dictionary();
            }

            if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD] != blood && !isNaN(blood)) {
                room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD, blood);
            }

            if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_ACTION] != action) {
                log.debug("Setting " + playerId + " action=" + action + " into room props");
                room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_ACTION, action);
            }

            if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED] != bloodbonded ) {
                room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED, bloodbonded);
            }

            if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED_NAME] != bloodbondedName ) {
                room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED_NAME, bloodbondedName);
            }

            if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_PREVIOUS_TIME_AWAKE] != time && !isNaN(time)) {
                room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_PREVIOUS_TIME_AWAKE, time);
            }
            if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP] != xp && !isNaN(xp)) {
                log.debug("Setting " + playerId + " xp=" + xp + " into room props");
                room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP, xp);
            }

            if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_INVITES] != invites) {
                log.debug("Setting " + playerId + " invites=" + invites + " into room props");
                room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_INVITES, invites);
            }

            if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_AVATAR_STATE] != avatarState ) {
                log.debug("Setting " + playerId + " avatar state=" + avatarState + " into room props");
                room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_AVATAR_STATE, avatarState);
            }

        }
        catch( err :Error) {
            log.error(err.getStackTrace());
        }
    }


    /**
    * Called periodically to set into the permanent props.
    *
    *
    */
    protected function setIntoPlayerProps() :void
    {
        try {
        //Permanent props
            if( _ctrl == null || _ctrl.props == null || !_ctrl.isConnected() ) {
                return;
            }

            if( _ctrl.props.get(Codes.PLAYER_PROP_BLOOD) != blood ) {
                _ctrl.props.set(Codes.PLAYER_PROP_BLOOD, blood, true);
            }

            if( _ctrl.props.get(Codes.PLAYER_PROP_NAME) != name ) {
                _ctrl.props.set(Codes.PLAYER_PROP_NAME, name, true);
            }

            if( _ctrl.props.get(Codes.PLAYER_PROP_XP) != xp ) {
                _ctrl.props.set(Codes.PLAYER_PROP_XP, xp, true);
            }

            if( _ctrl.props.get(Codes.PLAYER_PROP_LAST_TIME_AWAKE) != time ) {
                _ctrl.props.set(Codes.PLAYER_PROP_LAST_TIME_AWAKE, time, true);
            }

            if( _ctrl.props.get(Codes.PLAYER_PROP_SIRE) != sire ) {
                _ctrl.props.set(Codes.PLAYER_PROP_SIRE, sire, true);
            }

            if( _ctrl.props.get(Codes.PLAYER_PROP_BLOODBONDED) != bloodbonded ) {
                _ctrl.props.set(Codes.PLAYER_PROP_BLOODBONDED, bloodbonded, true);


                if( _bloodbonded > 0) {//Set the name too
                    var bloodBondedPlayer :PlayerData = ServerContext.server.getPlayer( _bloodbonded );
                    if( bloodBondedPlayer != null ) {
                        _bloodbondedName = bloodBondedPlayer.name;
                        _ctrl.props.set(Codes.PLAYER_PROP_BLOODBONDED_NAME, _bloodbondedName, true);
                    }
                    else {
                        log.error("Major error: setBloodBonded( " + _bloodbonded + "), but no Player, so cannot set name");
                    }
                }

            }

            if( _ctrl.props.get(Codes.PLAYER_PROP_SIRE) != sire ) {
                _ctrl.props.set(Codes.PLAYER_PROP_SIRE, sire, true);
            }

            if( _ctrl.props.get(Codes.PLAYER_PROP_MINIONIDS) == null ||
                !ArrayUtil.equals(_ctrl.props.get(Codes.PLAYER_PROP_MINIONIDS) as Array, _minionsForTrophies )) {
                _ctrl.props.set(Codes.PLAYER_PROP_MINIONIDS, _minionsForTrophies, true);
                Trophies.checkMinionTrophies( this );
            }

            if( _ctrl.props.get(Codes.PLAYER_PROP_INVITES) != invites ) {
                _ctrl.props.set(Codes.PLAYER_PROP_INVITES, invites, true);
                Trophies.checkInviteTrophies( this );
            }



        }
        catch( err :Error) {
            log.error(err.getStackTrace());
        }


    }


    public function setTargetId (id :int) :void
    {
        _targetId = id;
    }

    public function setInviteTally (invites :int) :void
    {
        _inviteTally = invites;
    }

    public function setTargetLocation (location :Array) :void
    {
        _targetLocation = location;
    }

    public function setFeedingData(bytes :ByteArray) :void
    {
        //Set immediately
        _ctrl.props.set( Codes.PLAYER_PROP_FEEDING_DATA, bytes );
    }

    public function setTime (time :Number, force :Boolean = false) :void
    {
        // update our runtime state
        if (!force && time == _timePlayerPreviouslyQuit) {
            return;
        }
        _timePlayerPreviouslyQuit = time;
    }

    public function addToInviteTally( addition :int = 1 ) :void
    {
        _inviteTally += addition;
    }

    public function setBloodBonded (bloodbonded :int, force :Boolean = false) :void
    {
        // update our runtime state
        if (!force && bloodbonded == _bloodbonded) {
            return;
        }

        var oldBloodBond :int = _bloodbonded;
        _bloodbonded = bloodbonded;

        if( oldBloodBond != 0) {//Remove the blood bond from the other player.
            if( ServerContext.server.isPlayer( oldBloodBond )) {
                var oldPartner :PlayerData = ServerContext.server.getPlayer( oldBloodBond );
                oldPartner.setBloodBonded( 0 );
            }
            else {//Load from database
                ServerContext.ctrl.loadOfflinePlayer(oldBloodBond,
                    function (props :OfflinePlayerPropertyControl) :void {
                        props.set(Codes.PLAYER_PROP_BLOODBONDED, 0);
                    },
                    function (failureCause :Object) :void {
                        log.warning("Eek! Sending message to offline player failed!", "cause", failureCause); ;
                    });


            }

        }


        if( _bloodbonded != 0) {//Set the name too
            var bloodBondedPlayer :PlayerData = ServerContext.server.getPlayer( _bloodbonded );
            if( bloodBondedPlayer != null ) {
                _bloodbondedName = bloodBondedPlayer.name;
//                _ctrl.props.set(Codes.PLAYER_PROP_BLOODBONDED_NAME, _bloodbondedName, true);
            }
            else {
                log.error("Major error: setBloodBonded( " + _bloodbonded + "), but no Player, so cannot set name");
            }
        }
        else {
            _bloodbondedName = "No blood bond";
        }

    }


    public function setSire (sire :int) :void
    {
        _sire = sire;
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
        return Logic.levelGivenCurrentXpAndInvites( xp );
    }

    public function get xp () :Number
    {
        return _xp;
    }

    public function get blood () :Number
    {
        return _blood;
    }

    public function get maxBlood () :Number
    {
        return VConstants.MAX_BLOOD_FOR_LEVEL( level );
    }

    public function get bloodbonded () :int
    {
        return _bloodbonded;
    }

    public function get bloodbondedName () :String
    {
        return _bloodbondedName;
    }

    public function get avatarState () :String
    {
        return _avatarState;
    }

    public function get sire () :int
    {
        return _sire;
    }

    public function get invites () :int
    {
        return _inviteTally;
    }

    public function get targetId() :int
    {
        return _targetId;
    }
    public function get targetLocation() :Array
    {
        return _targetLocation;
    }

    public function get minionsIds() :Array
    {
        return _minionsForTrophies;
    }


    public function get time () :Number
    {
        return _timePlayerPreviouslyQuit;
    }

    public function get location () :Array
    {
        if( room == null || room.ctrl == null || room.ctrl.getAvatarInfo(playerId) == null) {
            return null;
        }
        var avatar :AVRGameAvatar = room.ctrl.getAvatarInfo( playerId );
        return [avatar.x, avatar.y, avatar.z, avatar.orientation];
    }

    //This update comes from the server and only occurs a few times per second.
    public function update( dt :Number) :void
    {
        _bloodUpdateTime += dt;
        if( _bloodUpdateTime >= UPDATE_BLOOD_INTERVAL ) {
            //Vampires lose blood
            if( blood > 1 ) {
                ServerLogic.damage(this, dt * VConstants.VAMPIRE_BLOOD_LOSS_RATE, false);
                //But not below 1
                if( blood < 1 ) {
                    setBlood( 1 );
                }
            }
            _bloodUpdateTime = 0;
        }

        //Change the avatar state depending on our current action
        updateAvatarState();
        //Save our state into the permanent props
        setIntoPlayerProps();
        //And also into the room props so all clients can see our state
        setIntoRoomProps();


    }

    public function updateMinions( minions :Array ) :void
    {
        if( _minionsForTrophies.length >= 25 ) {
            return;
        }
        for each( var newMinionId :int in minions ) {
            if( !ArrayUtil.contains( _minionsForTrophies, newMinionId ) ) {
                _minionsForTrophies.push( newMinionId );
                if( _minionsForTrophies.length >= 25 ) {
                    break;
                }
            }
        }
    }

    public function updateAvatarState() :void
    {
        var newState :String = "Default";

        if( action == VConstants.GAME_MODE_BARED) {
            newState = action;
        }

        if( action == VConstants.GAME_MODE_FEED_FROM_PLAYER ||
            action == VConstants.GAME_MODE_FEED_FROM_NON_PLAYER ) {
            newState = VConstants.GAME_MODE_FEED_FROM_PLAYER;
        }

        if( newState != avatarState ) {
            log.debug(playerId + " updateAvatarState(" + newState + "), when action=" + action);
            setAvatarState(newState);
        }
    }

    public function addFeedingRecord( prey :int, predator :int ) :void
    {
//        _feedingRecord.push([ prey, predator]);
//        if( _feedingRecord.length > VConstants.b
    }

    public function get mostRecentVictimIds() :Array
    {
        return _mostRecentVictimIds;
    }

    public function get fedingREcord() :Array
    {
        return _feedingRecord;
    }

    public function addMostRecentVictimIds( id :int ) :void
    {
        _mostRecentVictimIds.push( id );
    }

    public function clearVictimIds() :void
    {
        _mostRecentVictimIds.splice(0);
    }

    public function isVictim() :Boolean
    {
        if( action != VConstants.GAME_MODE_BARED) {
            return false;
        }

        var predator :PlayerData = ServerContext.server.getPlayer( targetId );
        if( predator == null ) {
            return false;
        }

        if( predator.action == VConstants.GAME_MODE_FEED_FROM_PLAYER && predator.targetId == playerId) {
            return true;
        }
        return false;
    }



    protected var _name :String;
    protected var _blood :Number;
    protected var _xp :Number;
    protected var _action :String;

    protected var _avatarState :String = "Default";

    protected var _bloodbonded :int;
    protected var _bloodbondedName :String;

    protected var _sire :int;
    /**Hold max 25 player ids for recording minions for trophies.*/
    protected var _minionsForTrophies :Array = new Array();

    protected var _timePlayerPreviouslyQuit :Number;

    protected var _targetId :int;
    protected var _targetLocation :Array;

    protected var _inviteTally :int;

    /** Records who we eat, and who eats us, for determining blood bond status.*/
    protected var _mostRecentVictimIds :Array = new Array();

    /** Player data for BloodBloom*/
//    protected var _feedingData :PlayerFeedingData;


    protected var _room :Room;
    protected var _ctrl :PlayerSubControlServer;
    protected var _playerId :int;

    protected var _feedingRecord :Array = new Array();

    protected var _bloodUpdateTime :Number = 0;
    protected static const UPDATE_BLOOD_INTERVAL :Number = 3;

    protected static const log :Log = Log.getLog( PlayerData );

}
}