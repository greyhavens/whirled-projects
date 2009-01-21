//
// $Id$

package vampire.server {

import com.threerings.util.ClassUtil;
import com.threerings.util.Hashable;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.PlayerSubControlServer;

import vampire.data.Constants;
import vampire.data.SharedPlayerStateServer;
import vampire.net.IGameMessage;
import vampire.net.messages.RequestActionChangeMessage;


public class Player
    implements Hashable
{

    public function Player (ctrl :PlayerSubControlServer)
    {
        _ctrl = ctrl;
        _playerId = ctrl.getPlayerId();

        _ctrl.addEventListener(AVRGamePlayerEvent.ENTERED_ROOM, enteredRoom);
        _ctrl.addEventListener(AVRGamePlayerEvent.LEFT_ROOM, leftRoom);
        
        _sharedState = new SharedPlayerStateServer( ctrl );
        //if we're in a room, update the room properties
        if (_room != null) {
            _room.playerUpdated(this);
        }
//        log.debug("Setting blood at 10%, blood=" + maxBlood * 0.1);
        setBlood( blood, true);
        
        
//        var bytes :ByteArray = _ctrl.props.get(Codes.PLAYER_FULL_STATE_KEY) as ByteArray;
//        
//        if( bytes == null) {
//            log.info("Initializing new player", "playerId", playerId);
//            _level = 1;
//            _blood = getMaxBloodForLevel(1);
//            _maxBlood = getMaxBloodForLevel(1);
////            setPlaying( true );
////            _playing = true;
////            setLevel(1, true);
////            setBlood(getMaxBloodForLevel(1), true);
//            setPlaying(false, true);
//            setStateToPlayerProps();
//        }
//        else {
//            var state :SharedPlayerStateServer = SharedPlayerStateServer.fromBytes( bytes );
//            _level = state.level;
//            _blood = state.blood;
//            _maxBlood = state.maxBlood;
//            _playing = true;
//            
//            //if we're in a room, update the room properties
//            if (_room != null) {
//                _room.playerUpdated(this);
//            }
//        }
//        
        
        
        
        
//        _level = int(_ctrl.props.get(Codes.PLAYER_PROP_PREFIX_LEVEL));
//        if (_level == 0) {
//            // this person has never played Vampire before
//            log.info("Initializing new player", "playerId", playerId);
//            setLevel(1, true);
//            setBlood(getMaxBloodForLevel(1), true);
//            setPlaying(false, true);///?
//
//        } else {
//            updateBloodFromStartingNewGame()
//
//            var playingValue :Object = _ctrl.props.get(Codes.PROP_IS_PLAYING);
//            if (playingValue != null) {
//                _playing = Boolean(playingValue);
//
//            } else {
//                log.debug("Repairing player isPlaying", "playerId", playerId);
//                setPlaying(false, true);
//            }
//
//            var bloodValue :Object = _ctrl.props.get(Codes.PLAYER_PROP_PREFIX_BLOOD);
//            if (bloodValue != null) {
//                _blood = int(bloodValue);
//
//            } else {
//                // blood should always be set if level is set, but let's play it safe
//                log.debug("Repairing player blood", "playerId", playerId);
//                setBlood(1, true);
//            }
//            
//            var levelValue :Object = _ctrl.props.get(Codes.PLAYER_PROP_PREFIX_LEVEL);
//            if (levelValue != null) {
//                _level = int(levelValue);
//
//            } else {
//                // blood should always be set if level is set, but let's play it safe
//                log.debug("Repairing player level", "playerId", playerId);
//                setLevel(1, true);
//            }
//        }


        log.info("Logging in", "playerId", playerId, "blood", blood, "maxBlood",
                 maxBlood, "level", level);
            
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

    public function get blood () :int
    {
        return _sharedState.blood
//        return _blood;
    }

    public function get maxBlood () :int
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
            (room != null ? room.roomId : "null") + ", level=" + level + ", blood=" + blood + "/" + maxBlood + "]";
    }

    public function isDead () :Boolean
    {
        return blood == 0;
    }

    public function shutdown () :void
    {
        _ctrl.removeEventListener(AVRGamePlayerEvent.ENTERED_ROOM, enteredRoom);
        _ctrl.removeEventListener(AVRGamePlayerEvent.LEFT_ROOM, leftRoom);
    }

    public function damage (damage :int) :void
    {
//        log.debug("Damaging player", "playerId", _playerId, "damage", damage, "blood", _blood);

        // let the clients in the room know of the attack
//        _room.ctrl.sendMessage(Codes.SMSG_PLAYER_ATTACKED, _playerId);
        // play the reel animation for ourselves!
//        _ctrl.playAvatarAction("Reel");

        setBlood(blood - damage); // note: setBlood clamps this to [0, maxBlood]
    }

    public function addBlood (amount :int) :void
    {
        if (!isDead()) {
            setBlood(blood + amount); // note: setBlood clamps this to [0, maxBlood]
        }
    }
    
    protected function setBlood (blood :int, force :Boolean = false) :void
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
        if( name == Constants.NAMED_EVENT_BLOOD_UP ) {
            setBlood( blood + 10 );
        }
        else if( name == Constants.NAMED_EVENT_BLOOD_DOWN ) {
            setBlood( blood - 10 );
        }
        
        else if( value is IGameMessage) {
            
            if( value is RequestActionChangeMessage) {
                handleRequestActionChange( RequestActionChangeMessage(value) );
            }
            else {
                log.debug("Cannot handle IGameMessage ", "player", playerId, "type", value );
            }
        }
        
    }
    
    /**
    * Here we check if we are allowed to change action.
    * ATM we just allow it.
    */
    protected function handleRequestActionChange( e :RequestActionChangeMessage) :void
    {
        setAction( e.action );
    }


    protected function enteredRoom (evt :AVRGamePlayerEvent) :void
    {
        var thisPlayer :Player = this;
        _room = Server.getRoom(int(evt.value));
        Server.control.doBatch(function () :void {
            _room.playerEntered(thisPlayer);
            updateAvatarState();
        });
        
    }

    protected function leftRoom (evt :AVRGamePlayerEvent) :void
    {
        var thisPlayer :Player = this;
        Server.control.doBatch(function () :void {
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
