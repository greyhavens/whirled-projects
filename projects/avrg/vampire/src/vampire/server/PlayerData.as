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

import vampire.Util;
import vampire.data.Codes;
import vampire.data.Logic;
import vampire.data.VConstants;
import vampire.feeding.Constants;
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
        if(ctrl == null) {
            log.error("Bad! PlayerData(null).  What happened to the PlayerSubControlServer?  Expect random failures everywhere.");
            return;
        }

        _ctrl = ctrl;
        _playerId = ctrl.getPlayerId();

        registerListener(_ctrl, AVRGamePlayerEvent.ENTERED_ROOM, enteredRoom);
        registerListener(_ctrl, AVRGamePlayerEvent.LEFT_ROOM, leftRoom);


        //Start in the default state
        _state = VConstants.AVATAR_STATE_DEFAULT;

        //Get last time awake
//        log.debug("Getting ", "time", new Date(_ctrl.props.get(Codes.PLAYER_PROP_LAST_TIME_AWAKE)).toTimeString());
//        _timePlayerPreviouslyQuit = Number(_ctrl.props.get(Codes.PLAYER_PROP_LAST_TIME_AWAKE));

        //Get experience
        _xp = Number(_ctrl.props.get(Codes.PLAYER_PROP_XP));
        if(isNaN(_xp)) {
            setXP(0);
        }
        log.debug("Getting xp=" + _xp);






        //For now we ignore blood.
        //Get blood
//        _blood = Number(_ctrl.props.get(Codes.PLAYER_PROP_BLOOD));
//        if(_timePlayerPreviouslyQuit == 0) {
//            // blood should always be set if level is set, but let's play it safe
//            log.debug("   setting blood=" + VConstants.MAX_BLOOD_FOR_LEVEL(1));
//            setBlood(VConstants.MAX_BLOOD_FOR_LEVEL(1));
//
//        }
//
//        //In the current game, we don't let you die.
//        if(_blood < 1) {
//            setBlood(1);
//        }
//        log.debug("Getting blood="+_blood);

        //Get bloodbonded data
        _bloodbonded = int(_ctrl.props.get(Codes.PLAYER_PROP_BLOODBONDED));
        if(_bloodbonded > 0) {
            _bloodbondedName = _ctrl.props.get(Codes.PLAYER_PROP_BLOODBONDED_NAME) as String;
        }
        log.debug("Getting bloodbonded=" + _bloodbonded);



        _sire = int(_ctrl.props.get(Codes.PLAYER_PROP_SIRE));
        //Correction for older versions
        if (_sire == -1) {
            _sire = 0;
        }

        log.debug("Getting sire=" + _sire);

        setState(VConstants.AVATAR_STATE_DEFAULT);

        //If we have previously been awake, reduce our blood proportionally to the time since we last played.
//        log.debug("Getting time=" + time);
//        if(time > 1) {
//            var date :Date = new Date();
//            var now :Number = date.time;
//            var millisecondsSinceLastAwake :Number = now - time;
//            if(millisecondsSinceLastAwake < 0) {
//                log.error("Computing time since last awake, but < 0, now=" + now + ", time=" + time);
//            }
//            var daysSinceLastAwake :Number = millisecondsSinceLastAwake / (1000*60*60*24);
//            log.debug("daysSinceLastAwake=" + daysSinceLastAwake);
//            log.debug("secondSinceLastAwake=" + (millisecondsSinceLastAwake/1000));
//            var bloodReduction :Number = VConstants.BLOOD_LOSS_DAILY_RATE_WHILE_SLEEPING * daysSinceLastAwake;
//            log.debug("bloodReduction=" + bloodReduction);
////            bloodReduction = Math.min(bloodReduction, this.blood - 1);
//            var actualBloodLost :Number = damage(bloodReduction);
//            addFeedback("Blood lost during sleep: " + Util.formatNumberForFeedback(actualBloodLost));
//
////            log.debug("bloodnow=" + bloodnow, "in props", blood);
//
//        }
//        else {
//            log.debug("We have not played before, so not computing blood reduction");
//        }

        log.info("Logging in", "playerId", playerId,
//                "blood", blood,
//                "maxBlood",  maxBlood,
                "xp",  xp,
                "level", level,
                "sire", sire
                );//, "time", new Date(time).toTimeString()

        //Create feeding data if there is none
        var feedingData :PlayerFeedingData = new PlayerFeedingData();
        if(_ctrl.props.get(Codes.PLAYER_PROP_FEEDING_DATA) == null) {
            _ctrl.props.set(Codes.PLAYER_PROP_FEEDING_DATA, feedingData.toBytes());
        }
        try {
            var bytes :ByteArray = _ctrl.props.get(Codes.PLAYER_PROP_FEEDING_DATA) as ByteArray;
            if(bytes != null) {
                bytes.position = 0;
                feedingData.fromBytes(bytes);

                //We had a problem with trophies.  Check the player has the correct trophies
                //when they log in.
                for (var strain :int = 0; strain < VConstants.UNIQUE_BLOOD_STRAINS; ++strain) {
                    if (feedingData.getStrainCount(strain) >= Constants.MAX_COLLECTIONS_PER_STRAIN) {
                        var trophyName :String = Trophies.getHunterTrophyName(strain);
                        Trophies.doAward(this, trophyName);
                    }
                }
            }
        }
        catch(err :Error) {
            log.error("Error in feeding data, old version?  Resetting...");
            log.error(err.getStackTrace());
            feedingData = new PlayerFeedingData();
            _ctrl.props.set(Codes.PLAYER_PROP_FEEDING_DATA, feedingData.toBytes());
        }
        log.debug("Getting feeding data=" + feedingData);

        //Load/Create minionIds
        _progenyForTrophies = _ctrl.props.get(Codes.PLAYER_PROP_PROGENY_IDS) as Array;
        if(_progenyForTrophies == null) {
            _progenyForTrophies = new Array();
        }
        Trophies.checkMinionTrophies(this);

        _inviteTally = int(_ctrl.props.get(Codes.PLAYER_PROP_INVITES));
        Trophies.checkInviteTrophies(this);


    }

    public function addBlood (amount :Number) :void
    {
        setBlood(blood + amount); // note: setBlood clamps this to [0, maxBlood]
    }

    public function addFeedback (msg :String) :void
    {
        _feedback.push(msg);
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
//            + ", time=" + new Date(time).toTimeString()
            + "]";
    }

//    public function isDead () :Boolean
//    {
//        return blood <= 0;
//    }

    public function shutdown () :void
    {
        freeAllHandlers();

        //Make sure the player has left any feeding games
        if (_room != null) {
            _room.playerLeft(this);
//            _room.bloodBloomGameManager.playerQuitsGame(playerId);
        }

//        var currentTime :Number = new Date().time;
        if(_room != null && _room.ctrl != null && _room.ctrl.isConnected()) {
//            setTime(currentTime);
//            setIntoPlayerProps();
//            if(_ctrl != null && _ctrl.isConnected()) {
//                _ctrl.setAvatarState(VConstants.AVATAR_STATE_DEFAULT);
//            }
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
        _xp = Math.min(_xp, Logic.maxXPGivenXPAndInvites(_xp, invites));
    }

    public function setState (action :String) :void
    {
        if (action != _state) {
            log.debug(name + " state => " + action);
        }
        _state = action;
    }

    protected function get targetPlayer () :PlayerData
    {
        if(ServerContext.server.isPlayer(targetId)) {
            return ServerContext.server.getPlayer(targetId);
        }
        return null;
    }

    protected function get isTargetPlayer () :Boolean
    {
        return ServerContext.server.isPlayer(targetId);
    }

    public function get avatar () :AVRGameAvatar
    {
        if(room == null || room.ctrl == null || !room.ctrl.isConnected() ||
            !room.ctrl.isPlayerHere(playerId) || _ctrl == null || !_ctrl.isConnected()) {
            return null;
        }
        return room.ctrl.getAvatarInfo(playerId);
    }

    protected function get targetOfTargetPlayer() :int
    {
        if(!isTargetPlayer) {
            return 0;
        }
        return targetPlayer.targetId;
    }

    protected function get isTargetTargetingMe() :Boolean
    {
        if(!isTargetPlayer) {
            return false;
        }
        return targetPlayer.targetId == playerId;
    }


    protected function enteredRoom (evt :AVRGamePlayerEvent) :void
    {

        log.info(" Player entered room", "player", toString());

        var thisPlayer :PlayerData = this;
        _room = ServerContext.server.getRoom(int(evt.value));
        ServerContext.server.control.doBatch(function () :void {
            try {
                if(_room != null) {
                    _room.playerEntered(thisPlayer);
                    ServerContext.lineage.playerEnteredRoom(thisPlayer, _room);
                    thisPlayer.setState(VConstants.PLAYER_STATE_DEFAULT);
                    ServerLogic.updateAvatarState(thisPlayer);
                }
                else {
                    log.error("WTF, enteredRoom called, but room == null???");
                }
            }
            catch(err:Error)
            {
                log.error(err.getStackTrace());
            }
        });
    }


    protected function leftRoom (evt :AVRGamePlayerEvent) :void
    {
        log.debug(name + " leftRoom");
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
        _room = null;
    }



    public function get room () :Room
    {
        return _room;
    }

    public function setIntoRoomProps() :void
    {
        try {

            if(_ctrl == null || !_ctrl.isConnected()) {
                log.error("setIntoRoomProps() but ", "_ctrl", _ctrl);
                return;
            }

            if(_room == null || _room.ctrl == null || !_room.ctrl.isConnected()) {
                log.error("setIntoRoomProps() but ", "room", room);
                return;
            }

            var key :String = Codes.ROOM_PROP_PREFIX_PLAYER_DICT + playerId;

            var dict :Dictionary = room.ctrl.props.get(key) as Dictionary;
            if (dict == null) {
                dict = new Dictionary();
            }

            //For now we ignore blood.
//            if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD] != blood && !isNaN(blood)) {
//                room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD, blood);
//            }

            if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_STATE] != state) {
                room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_STATE, state);
            }

            if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED] != bloodbonded) {
                room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED, bloodbonded);
            }

            if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED_NAME] != bloodbondedName) {
                room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED_NAME, bloodbondedName);
            }

            if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP] != xp && !isNaN(xp)) {
                room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP, xp);
            }

            if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_INVITES] != invites) {
                room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_INVITES, invites);
            }

            //Copy the feedback to the room
            for each (var msg :String in _feedback) {
                room.addFeedback(msg, playerId);
            }
            _feedback.splice(0);

        }
        catch(err :Error) {
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
            if(_ctrl == null || _ctrl.props == null || !_ctrl.isConnected()) {
                return;
            }

            //For now we ignore blood.
//            if(_ctrl.props.get(Codes.PLAYER_PROP_BLOOD) != blood) {
//                _ctrl.props.set(Codes.PLAYER_PROP_BLOOD, blood, true);
//            }

            if(_ctrl.props.get(Codes.PLAYER_PROP_NAME) != name) {
                _ctrl.props.set(Codes.PLAYER_PROP_NAME, name, true);
            }

            if(_ctrl.props.get(Codes.PLAYER_PROP_XP) != xp) {
                _ctrl.props.set(Codes.PLAYER_PROP_XP, xp, true);
            }

            if(_ctrl.props.get(Codes.PLAYER_PROP_SIRE) != sire) {
                _ctrl.props.set(Codes.PLAYER_PROP_SIRE, sire, true);
            }

            if(_ctrl.props.get(Codes.PLAYER_PROP_BLOODBONDED) != bloodbonded) {
                _ctrl.props.set(Codes.PLAYER_PROP_BLOODBONDED, bloodbonded, true);


                if(_bloodbonded > 0) {//Set the name too
                    var bloodBondedPlayer :PlayerData = ServerContext.server.getPlayer(_bloodbonded);
                    if(bloodBondedPlayer != null) {
                        _bloodbondedName = bloodBondedPlayer.name;
                        _ctrl.props.set(Codes.PLAYER_PROP_BLOODBONDED_NAME, _bloodbondedName, true);
                    }
                    else {
                        log.error("Major error: setBloodBonded(" + _bloodbonded + "), but no Player, so cannot set name");
                    }
                }

            }

            if(_ctrl.props.get(Codes.PLAYER_PROP_BLOODBONDED_NAME) != bloodbondedName) {
                _ctrl.props.set(Codes.PLAYER_PROP_BLOODBONDED_NAME, bloodbondedName, true);
            }

            if(_ctrl.props.get(Codes.PLAYER_PROP_PROGENY_IDS) == null ||
                !ArrayUtil.equals(_ctrl.props.get(Codes.PLAYER_PROP_PROGENY_IDS) as Array, _progenyForTrophies)) {
                _ctrl.props.set(Codes.PLAYER_PROP_PROGENY_IDS, _progenyForTrophies, true);
                Trophies.checkMinionTrophies(this);
            }

            if(_ctrl.props.get(Codes.PLAYER_PROP_INVITES) != invites) {
                _ctrl.props.set(Codes.PLAYER_PROP_INVITES, invites, true);
                Trophies.checkInviteTrophies(this);
            }



        }
        catch(err :Error) {
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
        _ctrl.props.set(Codes.PLAYER_PROP_FEEDING_DATA, bytes);
    }

    public function addToInviteTally (addition :int = 1) :void
    {
        _inviteTally += addition;
    }

    public function removeBloodBond () :void
    {
        _bloodbonded = 0;
        _bloodbondedName = null;
    }

    public function setBloodBonded (bloodbonded :int) :void
    {
        // update our runtime state
        if (bloodbonded == _bloodbonded) {
            log.debug("setBloodBonded ignoring: " + bloodbonded + "==" + _bloodbonded);
            return;
        }

        var oldBloodBond :int = _bloodbonded;
        _bloodbonded = bloodbonded;

        if(oldBloodBond != 0 && _bloodbonded != oldBloodBond) {//Remove the blood bond from the other player.
            if(ServerContext.server.isPlayer(oldBloodBond)) {
                var oldPartner :PlayerData = ServerContext.server.getPlayer(oldBloodBond);
                oldPartner.removeBloodBond();
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


        if(_bloodbonded != 0) {//Set the name too
            var bloodBondedPlayer :PlayerData = ServerContext.server.getPlayer(_bloodbonded);
            if(bloodBondedPlayer != null) {
                _bloodbondedName = bloodBondedPlayer.name;
            }
            else {
                log.error("Major error: setBloodBonded(" + _bloodbonded + "), but no Player, so cannot set name");
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

    public function get state () :String
    {
        return _state;
    }

    public function get name () :String
    {
        if (_ctrl != null && _ctrl.isConnected()) {
            return _ctrl.getPlayerName();
        }
        return "";
    }

    public function get level () :int
    {
        return Logic.levelGivenCurrentXpAndInvites(xp);
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
        return Logic.maxBloodForLevel(level);
    }

    public function get bloodbonded () :int
    {
        return _bloodbonded;
    }

    public function get bloodbondedName () :String
    {
        //Update with the current name if the player is online
        if (_bloodbonded != 0 && ServerContext.server.isPlayer(_bloodbonded)) {
            return ServerContext.server.getPlayer(_bloodbonded).name;
        }
        return _bloodbondedName;
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
        return _progenyForTrophies;
    }

    public function get location () :Array
    {
        if(room == null || room.ctrl == null || room.ctrl.getAvatarInfo(playerId) == null) {
            return null;
        }
        var avatar :AVRGameAvatar = room.ctrl.getAvatarInfo(playerId);
        return [avatar.x, avatar.y, avatar.z, avatar.orientation];
    }

    //This update comes from the server and only occurs a few times per second.
    public function update (dt :Number) :void
    {
        //Bundle up the xp notifications
        _xpFeedbackTime += dt;
        if (_xpFeedbackTime >= VConstants.NOTIFICATION_TIME_XP) {
            _xpFeedbackTime = 0;
            if (_xpFeedback >= 1) {
                addFeedback("You gained " + Util.formatNumberForFeedback(_xpFeedback) +
                        " experience from your descendents!");
                _xpFeedback = 0;
            }
        }


//        _bloodUpdateTime += dt;
//        if(_bloodUpdateTime >= UPDATE_BLOOD_INTERVAL) {
//            //Vampires lose blood
//            if(blood > 1) {
//                ServerLogic.damage(this, dt * VConstants.VAMPIRE_BLOOD_LOSS_RATE, false);
//                //But not below 1
//                if(blood < 1) {
//                    setBlood(1);
//                }
//            }
//            _bloodUpdateTime = 0;
//        }

        //Change the avatar state depending on our current player state
//        ServerLogic.updateAvatarState(this);
        //Save our state into the permanent props
        setIntoPlayerProps();
        //And also into the room props so all clients can see our state
        setIntoRoomProps();


    }

    public function updateProgeny(progeny :Array) :void
    {
        if(_progenyForTrophies.length >= 25) {
            return;
        }
        for each(var newProgenyId :int in progeny) {
            if(!ArrayUtil.contains(_progenyForTrophies, newProgenyId)) {
                _progenyForTrophies.push(newProgenyId);
                _progenyForTrophies = _progenyForTrophies.sort();
                if(_progenyForTrophies.length >= 25) {
                    break;
                }
            }
        }
    }

    public function isVictim() :Boolean
    {
        if(state != VConstants.AVATAR_STATE_BARED) {
            return false;
        }

        var predator :PlayerData = ServerContext.server.getPlayer(targetId);
        if(predator == null) {
            return false;
        }

        if(predator.state == VConstants.AVATAR_STATE_FEEDING && predator.targetId == playerId) {
            return true;
        }
        return false;
    }

    public function addXPBonusNotification (bonus :Number) :void
    {
        _xpFeedback += bonus;
    }



    protected var _blood :Number;
    protected var _xp :Number;
    protected var _state :String;

    protected var _bloodbonded :int;
    protected var _bloodbondedName :String;

    protected var _sire :int;
    /**Hold max 25 player ids for recording minions for trophies.*/
    protected var _progenyForTrophies :Array = new Array();

    protected var _targetId :int;
    protected var _targetLocation :Array;

    protected var _inviteTally :int;


    protected var _room :Room;
    protected var _ctrl :PlayerSubControlServer;
    protected var _playerId :int;

    protected var _feedback :Array = [];

    protected var _xpFeedbackTime :Number = 0;
    protected var _xpFeedback :Number = 0;

    protected static const log :Log = Log.getLog(PlayerData);

}
}