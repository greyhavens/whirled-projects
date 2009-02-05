//
// $Id$

package vampire.server {

import com.threerings.util.ArrayUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.HashSet;
import com.threerings.util.Hashable;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.avrg.RoomSubControlServer;

import flash.events.Event;

import vampire.data.Codes;
import vampire.data.Constants;

public class Room
    implements Hashable
{
    public static var log :Log = Log.getLog(Room);

    public function Room (roomId :int)
    {
        _roomId = roomId;
        maybeLoadControl();
    }

    public function get roomId () :int
    {
        return _roomId;
    }

    public function get ctrl () :RoomSubControlServer
    {
        if (_ctrl == null) {
            throw new Error("Aii, no control to hand out in room: " + _roomId);
        }
        return _ctrl;
    }

//    public function get state () :String
//    {
//        return _state;
//    }

    public function get isShutdown () :Boolean
    {
        return _errorCount > 5;
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
        return Room(other).roomId == this.roomId;
    }

    // from Hashable
    public function hashCode () :int
    {
        return this.roomId;
    }

    public function toString () :String
    {
        return "Room [roomId=" + _roomId + "]";
    }

    public function playerEntered (player :Player) :void
    {
        if (!_players.add(player)) {
            log.warning("Arriving player already existed in room", "roomId", this.roomId,
                        "playerId", player.playerId);
        }

        maybeLoadControl(); 
        
        var playername :String = _ctrl.getAvatarInfo( player.playerId) != null ? _ctrl.getAvatarInfo( player.playerId).name : "" + player.playerId;
        
        log.info("Setting " + playername + " props into room");
        player.setIntoRoomProps( this );

        //Broadcast the players in the room
//        _ctrl.sendSignal(Constants.ROOM_SIGNAL_ENTITYID_REPONSE, _players.toArray().map( function( p :Player) :int { return p.playerId}));
        
        
        
        // broadcast the arriving player's data using room properties
//        var dict :Dictionary = new Dictionary();
//        dict[Codes.IX_PLAYER_CUR_HEALTH] = player.health;
//        dict[Codes.IX_PLAYER_MAX_HEALTH] = player.maxHealth;
//        dict[Codes.IX_PLAYER_LEVEL] = player.level;
//        _ctrl.props.set(Codes.DICT_PFX_PLAYER + player.playerId, dict, true);

        // see if there's an undefeated ghost here, else make a new one
    }

    public function playerLeft (player :Player) :void
    {
        if (!_players.remove(player)) {
            log.warning("Departing player did not exist in room", "roomId", this.roomId,
                        "playerId", player.playerId);
        }

        if (_ctrl == null) {
            log.warning("Null room control", "action", "player departing",
                        "playerId", player.playerId);
            return;
        }
        
        //Broadcast the players in the room
        _ctrl.sendSignal(Constants.ROOM_SIGNAL_ENTITYID_REPONSE, _players.toArray().map( function( p :Player) :int { return p.playerId}));
        

//        _ctrl.props.set(Codes.DICT_PFX_PLAYER + player.playerId, null, true);
    }

//    public function checkState (... expected) :Boolean
//    {
//        if (ArrayUtil.contains(expected, _state)) {
//            return true;
//        }
//        log.debug("State mismatch", "expected", expected, "actual", _state);
//        return false;
//    }


    /**
    * dt: Seconds 
    */
    public function tick (dt :Number) :void
    {
        // if we're shut down due to excessive errors, or the room is unloaded, do nothing
        if (isShutdown || _ctrl == null) {
            return;
        }

        try {
            _tick(dt);

        } catch (e :Error) {
            log.error("Tick error", e);

            _errorCount ++;
            if (isShutdown) {
                log.info("Giving up on room tick() due to error overflow", "roomId", this.roomId);
                return;
            }
        }
    }

    // called from Player when a MSG_MINIGAME_RESULT comes in from a client
//    public function minigameCompletion (
//        player :Player, weapon :int, win :Boolean, damageDone :int, healingDone :int) :void
//    {
//        if (_ctrl == null) {
//            log.warning("Null room control", "action", "minigame completion",
//                        "playerId", player.playerId);
//            return;
//        }

////        log.debug("Minigame completion", "playerId", player.playerId, "weapon", weapon, "damage",
////                  damageDone, "healing", healingDone);
//
//        // award 3 points for a win, 1 for a lose
//        _stats.put(player, int(_stats.get(player)) + (win ? 3 : 1));
//
//        // record which minigame was used
//        var dict :Dictionary = _minigames.get(player);
//        if (dict == null) {
//            dict = new Dictionary();
//        }
//        dict[weapon] = int(dict[weapon]) + 1;
//        _minigames.put(player, dict);
//
//        try {
//            Trophies.handleMinigameCompletion(player, weapon, win);
//        } catch (e :Error) {
//            log.warning("Error in handleMinigameCompletion", "roomId", this.roomId, "playerId",
//                        player.playerId, e);
//        }
//
//        // tweak damageDone and healingDone by the player's level
//        var tweak :Number = Formulae.quadRamp(player.level);
//
//        // then actually apply the damage or healing
//        if (damageDone > 0) {
//            damageGhost(damageDone * tweak);
//            _ctrl.sendMessage(Codes.SMSG_GHOST_ATTACKED, player.playerId);
//        }
//        if (healingDone > 0) {
//            doHealPlayers(player, healingDone * tweak);
//        }
//    }

    public function isPlayer( userId :int ) :Boolean
    {
        return ArrayUtil.contains( ctrl.getPlayerIds(), userId );
    }
    internal function playerUpdated (player :Player) :void
    {
        if (_ctrl == null) {
            log.warning("Null room control", "action", "player update",
                        "playerId", player.playerId);
            return;
        }

        
        ServerContext._serverLogBroadcast.log("Updating player room props=" + player);
        
//        var key :String = Codes.ROOM_PROP_PREFIX_PLAYER_DICT + player.playerId;
//        _ctrl.props.set(key, player.playerState.toBytes()); 
        
        
        player.setIntoRoomProps( this );
        
//        _ctrl.props.set("" + player.playerId, player.sharedPlayerState.toBytes()); 
        
//        var dict :Dictionary = _ctrl.props.get(key) as Dictionary;
//        if (dict == null) {
//            dict = new Dictionary();
//        }
//
//        if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_LEVEL] != player.level) {
//            _ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_LEVEL, player.level);
//        }
//        if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_MAX_BLOOD] != player.maxBlood) {
//            _ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_MAX_BLOOD, player.maxBlood);
//        }
//        if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD] != player.health) {
//            _ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD, player.health);
//        }
    }

    internal function reset () :void
    {
        if (_ctrl == null) {
            log.warning("Null room control", "action", "reset");
            return;
        }

//        _stats.clear();
//        _minigames.clear();
    }

    internal function setState (state :String) :void
    {
        if (_ctrl == null) {
            log.warning("Null room control", "action", "state set", "state", state);
            return;
        }

//        _state = state;
//
//        _ctrl.props.set(Codes.PROP_STATE, state, true);
//
//        _players.forEach(function (player :Player) :void {
//            player.roomStateChanged();
//        });
        log.debug("Room state set", "roomId", this.roomId, "state", state);
    }

    protected function _tick (dt :Number) :void
    {
        _players.forEach( function( p :Player) :void{ p.tick(dt)});
    }

    protected function maybeLoadControl () :void
    {
        if (_ctrl == null) {
            _ctrl = VServer.control.getRoom(_roomId);
            
            if( _ctrl == null ) {
                log.warning("maybeLoadControl(), but RoomSubControl is still null!!!");
            }

            // export the room state to room properties
            log.info("Starting room, setting hierarchy in props=" + ServerContext.minionHierarchy);
            _ctrl.props.set(Codes.ROOM_PROP_MINION_HIERARCHY, ServerContext.minionHierarchy.toBytes());
//            log.debug("Export my state to new control", "state", _state);

            // if there's a ghost in here, re-export it too
//            if (_ghost != null) {
//                _ghost.reExport();
//            }

            var handleUnload :Function;
            handleUnload = function (evt :Event) :void {
                _ctrl.removeEventListener(AVRGameRoomEvent.ROOM_UNLOADED, handleUnload);
                
                _ctrl.removeEventListener(AVRGameRoomEvent.SIGNAL_RECEIVED, handleSignalReceived);
                _ctrl = null;

                if (_players.size() != 0) {
                    log.warning("Eek! Room unloading with players still here!",
                                "players", _players.toArray());
                } else {
                    log.debug("Unloaded room", "roomId", roomId);
                }
            };

            _ctrl.addEventListener(AVRGameRoomEvent.ROOM_UNLOADED, handleUnload);
            
            _ctrl.addEventListener(AVRGameRoomEvent.SIGNAL_RECEIVED, handleSignalReceived);
        }
    }
    
    protected function handleSignalReceived( e :AVRGameRoomEvent ) :void
    {
        log.debug("handleSignalReceived() " + e);
        _players.forEach( function(p :Player) :void {
           p.handleSignalReceived( e ); 
        });
    }

    protected var _roomId :int;
    protected var _ctrl :RoomSubControlServer;

//    protected var _state :String;
    protected var _players :HashSet = new HashSet();
    
    public var _nonplayers :HashSet = new HashSet();
    
//    protected var _playerEntityIds :HashSet = new HashSet();

    protected var _errorCount :int = 0;

    // each player's contribution to a ghost's eventual defeat is accumulated here, by player
//    protected var _stats :HashMap = new HashMap();

    // a dictionary of dictionaries of number of times each minigame was used by each player
//    protected var _minigames :HashMap = new HashMap();

    // new ghost every 10 minutes -- force players to actually hunt for ghosts, not slaughter them
//    protected static const GHOST_RESPAWN_MINUTES :int = 10;
}
}
