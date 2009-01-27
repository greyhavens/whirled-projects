//
// $Id$

package vampire.server {

import com.threerings.util.ArrayUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.Hashable;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.PlayerSubControlServer;

import vampire.data.Constants;
import vampire.data.SharedPlayerStateServer;
import vampire.net.IGameMessage;
import vampire.net.messages.BloodBondRequestMessage;
import vampire.net.messages.FeedRequestMessage;
import vampire.net.messages.RequestActionChangeMessage;


public class Player
    implements Hashable
{

    public function Player (ctrl :PlayerSubControlServer)
    {
        if( ctrl == null ) {
            log.error("Bad!  Player(null).  What happened to the PlayerSubControlServer?  Expect random failures everywhere.");
            return;
        }
        
        _ctrl = ctrl;
        _playerId = ctrl.getPlayerId();

        _ctrl.addEventListener(AVRGamePlayerEvent.ENTERED_ROOM, enteredRoom);
        _ctrl.addEventListener(AVRGamePlayerEvent.LEFT_ROOM, leftRoom);
        
        _sharedState = new SharedPlayerStateServer( ctrl.props );
        
        
        if (level == 0) {
            log.debug("Player has never player before ", "playerId", ctrl.getPlayerId());
            _sharedState.setLevel(1, true);
            _sharedState.setBloodBonded([]);
            _sharedState.setBlood( _sharedState.maxBlood, true );
            _sharedState.setSire( VServer.getSireFromInvitee( _playerId ) );
        } 
        
        log.debug("In Player, _sharedState=" + _sharedState);
        
        setAction( Constants.GAME_MODE_NOTHING );
        //if we're in a room, update the room properties
        if (_room != null) {
            _room.playerUpdated(this);
        }
//        log.debug("Setting blood at 10%, blood=" + maxBlood * 0.1);
        setBlood( blood, true);
        
        //If we have previously been awake, reduce our blood proportionally to the time since we last played.
        if( _sharedState.time != 0) {
            var date :Date = new Date();
            var now :Number = date.time;
            var millisecondsSinceLastAwake :Number = now - _sharedState.time;
            if( millisecondsSinceLastAwake < 0) {
                log.error("Computing time since last awake, but < 0, now=" + now + ", _sharedState.time=" + _sharedState.time);
            }
            var hoursSinceLastAwake :Number = millisecondsSinceLastAwake / (1000*60*60);
            log.debug("hoursSinceLastAwake=" + hoursSinceLastAwake);
            log.debug("secondSinceLastAwake=" + (millisecondsSinceLastAwake/1000));
            var bloodReduction :Number = Constants.BLOOD_LOSS_HOURLY_RATE * hoursSinceLastAwake;
            log.debug("bloodReduction=" + bloodReduction);
            var bloodnow :Number = blood;
            bloodnow -= bloodReduction;
            bloodnow = Math.max( Constants.MINMUM_BLOOD_AFTER_SLEEPING, bloodnow);
            setBlood( bloodnow );
            
            log.debug("bloodnow=" + bloodnow, "in props", blood);
            
        }

        log.info("Logging in", "playerId", playerId, "blood", blood, "maxBlood",
                 maxBlood, "level", level, "sire", sire, "minions", minions, "time", new Date(time).toTimeString());
            
        if (_room != null) {
            _room.playerUpdated(this);
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


    public function get playing () :Boolean
    {
        return true;//_playing;
    }

    public function get blood () :Number
    {
        return _sharedState.blood
//        return _blood;
    }

    public function get maxBlood () :Number
    {
        return _sharedState.maxBlood;
//        return getMaxBloodForLevel( level );
    }

    public function get level () :int
    {
        return _sharedState.level;
//        return _level;
    }
    
    public function get action () :String
    {
        return _sharedState.action;
    }
    
    public function get bloodbonded () :Array
    {
        return _sharedState.bloodbonded;
    }
    
    public function get minions () :Array
    {
        return _sharedState.minions;
    }

    public function get sire () :int
    {
        return _sharedState.sire;
    }
    
    public function get time () :Number
    {
        return _sharedState.time;
    }

    protected function XXXsetLevel (level :int, force :Boolean = false) :void
    {
//        level = Math.max(1, level);
//        if (!force && level == _level) {
//            return;
//        }
//
//        log.info("Level changed!", "playerId", playerId, "oldLevel", _level, "newLevel", level);
//
//        _level = level;
//        _ctrl.props.set(Codes.PLAYER_PROP_PREFIX_LEVEL, _level, true);
//
//        // update our max blood
//        _maxBlood = getMaxBloodForLevel( _level );

        // heal us, too
//        heal(_maxBlood);

        // if we're in a room, update the room properties
//        if (_room != null) {
//            _room.playerUpdated(this);
//        }
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
        return Player(other).playerId == _playerId;
    }

    // from Hashable
    public function hashCode () :int
    {
        return _playerId;
    }

    public function toString () :String
    {
        return "Player [playerId=" + _playerId + ", roomId=" +
            (room != null ? room.roomId : "null") + ", level=" + level + ", blood=" + blood + "/" + maxBlood + ", bloodbonds=" + bloodbonded + ", time=" + new Date(time).toTimeString() + "]";
    }

    public function isDead () :Boolean
    {
        return blood <= 0;
    }

    public function shutdown () :void
    {
        var currentTime :Number = new Date().time;
        log.info("shutdown()", "currentTime", new Date(currentTime).toTimeString());
        _sharedState.setTime( currentTime, true );
        
        log.info("before player shutdown", "time", new Date(_ctrl.props.get( SharedPlayerStateServer.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE)).toTimeString());
//        _sharedState.setAction( Constants.GAME_MODE_NOTHING, true );
        setIntoRoomProps( room );
        _ctrl.removeEventListener(AVRGamePlayerEvent.ENTERED_ROOM, enteredRoom);
        _ctrl.removeEventListener(AVRGamePlayerEvent.LEFT_ROOM, leftRoom);
        log.info("end of player shutdown", "time", new Date(_ctrl.props.get( SharedPlayerStateServer.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE)).toTimeString());
    }

    public function damage (damage :Number) :void
    {
//        log.debug("Damaging player", "playerId", _playerId, "damage", damage, "blood", _blood);

        // let the clients in the room know of the attack
//        _room.ctrl.sendMessage(Codes.SMSG_PLAYER_ATTACKED, _playerId);
        // play the reel animation for ourselves!
//        _ctrl.playAvatarAction("Reel");

        setBlood(blood - damage); // note: setBlood clamps this to [0, maxBlood]
    }

    public function addBlood (amount :Number) :void
    {
        if (!isDead()) {
            setBlood(blood + amount); // note: setBlood clamps this to [0, maxBlood]
        }
    }
    
    public function removeBlood (amount :Number) :void
    {
        if (!isDead()) {
            setBlood(blood - amount); // note: setBlood clamps this to [0, maxBlood]
        }
    }
    
    protected function setBlood (blood :Number, force :Boolean = false) :void
    {
        // update our runtime state
//        blood = MathUtil.clamp(blood, 0, maxBlood);
        blood = Math.max(blood, 0);
        if (!force && blood == this.blood) {
            return;
        }
        _sharedState.setBlood( blood );
        
//        _blood = blood;
//        setStateToPlayerProps();
        // persist it, too
//        _ctrl.props.set(Codes.PLAYER_PROP_PREFIX_BLOOD, _blood, true);

        // if we just died, let the trophy code know
//        if (_blood == 0) {
//            try {
//                Trophies.handlePlayerDied(this);
//            } catch (e :Error) {
//                log.warning("Error in handlePlayerDied", "playerId", _playerId, e);
//            }
//        }

        // always update our avatar state
        updateAvatarState();

        // and if we're in a room, update the room properties
        if (_room != null) {
            _room.playerUpdated(this);
        }
    }
    
    protected function setAction (action :String, force :Boolean = false) :void
    {
        if (!force && action == this.action) {
            return;
        }
        _sharedState.setAction( action );
        
        // always update our avatar state
        updateAvatarState();

        // and if we're in a room, update the room properties
        if (_room != null) {
            _room.playerUpdated(this);
        }
    }

    public function roomStateChanged () :void
    {
        updateAvatarState();
    }

    // called from Server
    public function handleMessage (name :String, value :Object) :void
    {
        // handle messages that make (at least some) sense even if we're between rooms
        log.debug("handleMessage() ", "name", name, "value", value);
        trace("handleMessage() ", "name", name, "value", value);
        if( name == Constants.NAMED_EVENT_BLOOD_UP ) {
            setBlood( blood + 10 );
        }
        else if( name == Constants.NAMED_EVENT_BLOOD_DOWN ) {
            setBlood( blood - 10 );
        }
        else if( name == Constants.NAMED_EVENT_FEED ) {
            feed(int(value));
        }
        
        else if( value is IGameMessage) {
            
            if( value is RequestActionChangeMessage) {
                handleRequestActionChange( RequestActionChangeMessage(value) );
            }
            else if( value is BloodBondRequestMessage) {
                handleBloodBondRequest( BloodBondRequestMessage(value) );
            }
            else if( value is FeedRequestMessage) {
                handleFeedRequestMessage( FeedRequestMessage(value) );
            }
            else {
                log.debug("Cannot handle IGameMessage ", "player", playerId, "type", value );
                log.debug("  Classname=" + ClassUtil.getClassName(value) );
            }
        }
        
    }
    
    protected function feed(targetPlayerId :int ) :void
    {
        var eatenPlayer :Player = VServer.getPlayer( targetPlayerId );
        if( eatenPlayer == null) {
            log.warning("feed( " + targetPlayerId + " ), player is null");
            return;
        }
        
        
        if( eatenPlayer.action != Constants.GAME_MODE_EAT_ME) {
            log.warning("feed( " + targetPlayerId + " ), eatee is not in mode=" + Constants.GAME_MODE_EAT_ME);
            return;
        }
        
        if( eatenPlayer.blood <= 1) {
            log.warning("feed( " + targetPlayerId + " ), eatee has only blood=" + eatenPlayer.blood);
            return;
        }
        
        var bloodEaten :Number = 10;
        if( eatenPlayer.blood <= 10) {
            bloodEaten = eatenPlayer.blood - 1;
        }
        log.debug("Sucessful feed.");
        addBlood( bloodEaten );
        eatenPlayer.removeBlood( bloodEaten );
    }
    
    /**
    * Handle a feed request.
    */
    protected function handleFeedRequestMessage( e :FeedRequestMessage) :void
    {
        var targetPlayer :Player = VServer.getPlayer( e.targetPlayer );
        var isTargetVictim :Boolean = e.isTargetPlayerTheVictim;
        
        
    }
    
    
    /**
    * Here we check if we are allowed to change action.
    * ATM we just allow it.
    */
    protected function handleBloodBondRequest( e :BloodBondRequestMessage) :void
    {
        var targetPlayer :Player = VServer.getPlayer( e.targetPlayer );
        
        if( targetPlayer == null) {
            log.debug("Cannot perform blood bond request unless both players are in the same room");
            return;
        }
        
        if( e.add ) {
            addBloodBond( e.targetPlayer, e.targetPlayerName, true );
            if( targetPlayer != null) {
                targetPlayer.addBloodBond( playerId, ServerContext.getPlayerName(playerId), true );
            }
            else {
                log.error("You can't add a blood bond to an offline player.");
                
//                VServer.control.loadOfflinePlayer(e.targetPlayer, 
//                    function (props :PropertySpaceObject) :void {
//                        
//                        var bloodbonds :Array = props.getUserProps().get( SharedPlayerStateServer.PLAYER_PROP_PREFIX_BLOODBONDED) as Array;
//                        if( bloodbonds == null) {
//                            bloodbonds = new Array();
//                        }
//                        bloodbonds.push( playerId );
//                        bloodbonds.push( targetPlayer._ctrl. );
//                        props.getUserProps().set(SharedPlayerStateServer.PLAYER_PROP_PREFIX_BLOODBONDED, bloodbonds); 
//                    }, 
//                    function (failureCause :String) :void { 
//                        log.warning("Eek! Sending message to offline player failed!", "cause", failureCause); 
//                    });
                
            }
        }
        else {
            removeBloodBond( e.targetPlayer, true );
            
            if( targetPlayer != null) {
                targetPlayer.removeBloodBond( playerId, true );
            }
            else {
                log.error("You can't remove a blood bond to an offline player.");
//                VServer.control.loadOfflinePlayer(e.targetPlayer, 
//                    function (props :PropertySpaceObject) :void {
//                        
//                        var bloodbonds :Array = props.getUserProps().get( SharedPlayerStateServer.PLAYER_PROP_PREFIX_BLOODBONDED) as Array;
//                        if( bloodbonds == null) {
//                            bloodbonds = new Array();
//                        }
//                        if( ArrayUtil.contains( bloodbonds, e.targetPlayer)) {
//                            bloodbonds.splice( ArrayUtil.indexOf( bloodbonds, e.targetPlayer), 1);
//                        }
//                        props.getUserProps().set(SharedPlayerStateServer.PLAYER_PROP_PREFIX_BLOODBONDED, bloodbonds); 
//                    }, 
//                    function (failureCause :String) :void { 
//                        log.warning("Eek! Sending message to offline player failed!", "cause", failureCause); 
//                    });
                
            }
            
            
        }
    }
    
    
    public function addBloodBond( blondbondedPlayerId :int, playerName :String, force :Boolean = false ) :void
    {
        if( !force && ArrayUtil.contains( bloodbonded, blondbondedPlayerId) ) {
            return;
        }
        var bloodbonded :Array = this.bloodbonded;
        if( !ArrayUtil.contains( bloodbonded, blondbondedPlayerId) ) {
            bloodbonded.push( blondbondedPlayerId );
            bloodbonded.push( playerName );
        }
        
        _sharedState.setBloodBonded( bloodbonded );
        
        updateAvatarState();

        // and if we're in a room, update the room properties
        if (_room != null) {
            _room.playerUpdated(this);
        }
    }
    
    public function removeBloodBond( blondbondedPlayerId :int, force :Boolean = false ) :void
    {
        if( !force && !ArrayUtil.contains( bloodbonded, blondbondedPlayerId) ) {
            return;
        }
        var bloodbonded :Array = this.bloodbonded;
        if( ArrayUtil.contains( bloodbonded, blondbondedPlayerId) ) {
            bloodbonded.splice( ArrayUtil.indexOf( bloodbonded, blondbondedPlayerId), 2 );
        }
        _sharedState.setBloodBonded( bloodbonded );
        
        updateAvatarState();

        // and if we're in a room, update the room properties
        if (_room != null) {
            _room.playerUpdated(this);
        }
    }
    
    
    
    
    
    
    /**
    * Here we check if we are allowed to change action.
    * ATM we just allow it.
    */
    protected function handleRequestActionChange( e :RequestActionChangeMessage) :void
    {
        log.debug("handleRequestActionChange(..), e.action=" + e.action);
        setAction( e.action );
    }


    protected function enteredRoom (evt :AVRGamePlayerEvent) :void
    {
        var thisPlayer :Player = this;
        _room = VServer.getRoom(int(evt.value));
        VServer.control.doBatch(function () :void {
            _room.playerEntered(thisPlayer);
            updateAvatarState();
        });
        
    }

    protected function leftRoom (evt :AVRGamePlayerEvent) :void
    {
        var thisPlayer :Player = this;
        VServer.control.doBatch(function () :void {
            _room.playerLeft(thisPlayer);
        });
        if (_room != null) {
            if (_room.roomId == evt.value) {
                _room = null;
            } else {
                log.warning("The room we're supposedly leaving is not the one we think we're in",
                            "ourRoomId", _room.roomId, "eventRoomId", evt.value);
            }
        }
    }

    protected function handleDebugRequest (request :String) :void
    {
        log.info("Incoming debug request", "request", request);

        // just send back the original request to indicate it was handled successfully
//        ctrl.sendMessage(Codes.SMSG_DEBUG_RESPONSE, request);
    }



//    protected function setPlaying (playing :Boolean, force :Boolean = false) :void
//    {
//        if (!force && playing == _playing) {
//            return;
//        }
//        _playing = playing;
//        
//        _ctrl.props.set(Codes.PROP_IS_PLAYING, _playing, true);
//    }

    
    
    /**
    * Vampires lose blood when asleep.  The game does not update vampires e.g. hourly, 
    * rather, computes the blood loss from when they last played.
    * 
    * Blood is also accumulated from minions exploits, so this may not be that dramatic for older vampires.
    */
    protected function updateBloodFromStartingNewGame() :void
    {
//        if( level >= Constants.MINIMUM_VAMPIRE_LEVEL) {
//            var previousTimeAwake :int = int(_ctrl.props.get(Codes.PLAYER_PROP_PREFIX_PREVIOUS_TIME_AWAKE));
//            var now :int = getTimer();
//            var hoursAsleep :Number = (((now - previousTimeAwake) / 1000) / 60) / 60.0;
//            var currentBlood :int = blood;
//            currentBlood -= hoursAsleep * Constants.BLOOD_LOSS_HOURLY_RATE * maxBlood;
//            currentBlood = Math.max(1, currentBlood);
//            setBlood( currentBlood );
//        }
    }

    public function get room () :Room
    {
        return _room;
    }
    
    protected function updateAvatarState () :void
    {
//        if (_room == null) {
//            return;
//        }
//        if (isDead()) {
//            _ctrl.setAvatarState(ST_PLAYER_DEFEAT);
//
//        } else if (_room.state == Codes.STATE_SEEKING || _room.state == Codes.STATE_APPEARING) {
//            _ctrl.setAvatarState(ST_PLAYER_DEFAULT);
//
//        } else {
//            _ctrl.setAvatarState(ST_PLAYER_FIGHT);
//        }
    }
    
//    public function setStateToPlayerProps() :void
//    {
//        var state :SharedPlayerStateServer = sharedPlayerState;
//        log.debug("Setting state to props=" + state);
//        _ctrl.props.set(Codes.PLAYER_FULL_STATE_KEY, state.toBytes());
//        
//        //if we're in a room, update the room properties
//        if (_room != null) {
//            _room.playerUpdated(this);
//        }
//    }
    
    
//    /**
//    * Saved to room properties and distributed to the clients.
//    */
//    public function get sharedPlayerState () :SharedPlayerStateServer
//    {
//        var state :SharedPlayerStateServer = new SharedPlayerStateServer();
//        
//        state._playerId = hashCode();
//        state.level = level;
//        state.blood = blood;
//        state.maxBlood = maxBlood;
//        
//        return state;
//    }
    
    
//    /**
//    * The full state of the player. 
//    * Saved to permanent properties, and distributed to the room, but not updated 
//    * as often as the shared player state.
//    */
//    public function get fullPlayerState () :SharedPlayerStateServer
//    {
//        var state :FullPlayerState = new FullPlayerState();
//        
//        state._playerId = hashCode();
//        state.level = level;
//        state.blood = blood;
//        state.maxBlood = maxBlood;
//        
//        return state;
//    }
    
    public function setIntoRoomProps( room :Room ) :void
    {
        if( room != null) {
            SharedPlayerStateServer.setIntoRoomProps( this, room.ctrl );
        }
        else {
            log.warning("setIntoRoomProps( room ), but room is null");
        }
    }

    protected var _room :Room;
    protected var _ctrl :PlayerSubControlServer;
    protected var _playerId :int;
    protected var _sharedState :SharedPlayerStateServer;
    
//    protected var _level :int;
//    protected var _blood :int;
//    protected var _maxBlood :int;
//    protected var _playing :Boolean;
    
    protected static const log :Log = Log.getLog( Player );
//    protected var _minions
}
}
