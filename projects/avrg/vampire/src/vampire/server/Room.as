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

import vampire.data.SharedPlayerStateClient;

public class Room
    implements Hashable
{
    public static var log :Log = Log.getLog(Room);

    public function Room (roomId :int)
    {
        _roomId = roomId;
//        _state = Codes.STATE_SEEKING;

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

    public function get state () :String
    {
        return _state;
    }

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

//        _ctrl.props.set(Codes.DICT_PFX_PLAYER + player.playerId, null, true);
    }

    public function checkState (... expected) :Boolean
    {
        if (ArrayUtil.contains(expected, _state)) {
            return true;
        }
        log.debug("State mismatch", "expected", expected, "actual", _state);
        return false;
    }


    public function tick (frame :int, newSecond :Boolean) :void
    {
        // if we're shut down due to excessive errors, or the room is unloaded, do nothing
        if (isShutdown || _ctrl == null) {
            return;
        }

        try {
            _tick(frame, newSecond);

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


    internal function playerUpdated (player :Player) :void
    {
        if (_ctrl == null) {
            log.warning("Null room control", "action", "player update",
                        "playerId", player.playerId);
            return;
        }

        log.debug("Updating player room props=" + player);
        
//        var key :String = Codes.ROOM_PROP_PREFIX_PLAYER_DICT + player.playerId;
//        _ctrl.props.set(key, player.playerState.toBytes()); 
        
        
        SharedPlayerStateClient.setIntoRoomProps( player, _ctrl );
        
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

    protected function _tick (frame :int, newSecond :Boolean) :void
    {
//        switch(_state) {
//        case Codes.STATE_SEEKING:
//            seekTick(frame, newSecond);
//            break;
//
//        case Codes.STATE_APPEARING:
//            if (_transitionFrame == 0) {
//                log.warning("In APPEAR without transitionFrame", "id", this.roomId);
//            }
//            // let's add a 1-second grace period on the transition
//            if (frame >= _transitionFrame + Server.FRAMES_PER_SECOND) {
//                ghostFullyAppeared();
//                _transitionFrame = 0;
//            }
//            break;
//
//        case Codes.STATE_FIGHTING:
//            fightTick(frame, newSecond);
//            break;
//
//        case Codes.STATE_GHOST_TRIUMPH:
//        case Codes.STATE_GHOST_DEFEAT:
//            if (_transitionFrame == 0) {
//                log.warning("In TRIUMPH/DEFEAT without transitionFrame", "id", this.roomId);
//            }
//            // let's add a 1-second grace period on the transition
//            if (frame >= _transitionFrame + Server.FRAMES_PER_SECOND) {
//                ghostFullyGone();
//                _transitionFrame = 0;
//            }
//            break;
//        }
    }





    protected function maybeLoadControl () :void
    {
        if (_ctrl == null) {
            _ctrl = Server.control.getRoom(_roomId);

            log.debug("Export my state to new control", "state", _state);

            // export the room state to room properties
//            _ctrl.props.set(Codes.PROP_STATE, _state, true);

            // if there's a ghost in here, re-export it too
//            if (_ghost != null) {
//                _ghost.reExport();
//            }

            var handleUnload :Function;
            handleUnload = function (evt :Event) :void {
                _ctrl.removeEventListener(AVRGameRoomEvent.ROOM_UNLOADED, handleUnload);
                _ctrl = null;

                if (_players.size() != 0) {
                    log.warning("Eek! Room unloading with players still here!",
                                "players", _players.toArray());
                } else {
                    log.debug("Unloaded room", "roomId", roomId);
                }
            };

            _ctrl.addEventListener(AVRGameRoomEvent.ROOM_UNLOADED, handleUnload);
        }
    }

    protected var _roomId :int;
    protected var _ctrl :RoomSubControlServer;

    protected var _state :String;
    protected var _players :HashSet = new HashSet();

    protected var _errorCount :int = 0;

    // each player's contribution to a ghost's eventual defeat is accumulated here, by player
//    protected var _stats :HashMap = new HashMap();

    // a dictionary of dictionaries of number of times each minigame was used by each player
//    protected var _minigames :HashMap = new HashMap();

    // new ghost every 10 minutes -- force players to actually hunt for ghosts, not slaughter them
//    protected static const GHOST_RESPAWN_MINUTES :int = 10;
}
}
