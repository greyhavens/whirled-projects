//
// $Id$

package vampire.server {

import com.threerings.util.ArrayUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.HashMap;
import com.threerings.util.Hashable;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.avrg.RoomSubControlServer;
import com.whirled.contrib.simplegame.ObjectDB;
import com.whirled.contrib.simplegame.SimObject;

import vampire.data.Codes;

public class Room extends SimObject
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

    override public function get objectName () :String
    {
        return "Room " + _roomId;
    }


    public function get isStale () :Boolean
    {
        return !isLiveObject || isShutdown || _ctrl == null || !_ctrl.isConnected();
    }


    public function get ctrl () :RoomSubControlServer
    {
        if (_ctrl == null) {
            throw new Error("Aii, no control to hand out in room: " + _roomId);
        }
        return _ctrl;
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

    override public function toString () :String
    {
        return "Room [roomId=" + _roomId + ", playerIds=" + _players.keys() +"]";
    }

    public function playerEntered (player :PlayerData) :void
    {

        if (!_players.put(player.playerId, player)) {
            log.warning("Arriving player already existed in room", "roomId", this.roomId,
                        "playerId", player.playerId);
        }

        maybeLoadControl();

        var playername :String = _ctrl.getAvatarInfo(player.playerId) != null ? _ctrl.getAvatarInfo(player.playerId).name : "" + player.playerId;
    }

    public function playerLeft (player :PlayerData) :void
    {
//        _entityLocations.remove(player.playerId);

        if (!_players.remove(player.playerId)) {
            log.warning("Departing player did not exist in room", "roomId", this.roomId,
                        "playerId", player.playerId);
        }

        if (_ctrl == null) {
            log.warning("Null room control", "action", "player departing",
                        "playerId", player.playerId);
            return;
        }
        _bloodBloomGameManager.playerQuitsGame(player.playerId);
    }

    /**
    * dt: Seconds
    */
    override protected function update (dt :Number) :void
    {
        // if we're shut down due to excessive errors, or the room is unloaded, do nothing
        if (isShutdown || _ctrl == null) {
            return;
        }

        try {
//            roomDB.update(dt);
            //Update PlayerData objects. This means setting them into room props and player props.
            _players.forEach(function(playerId :int, p :PlayerData) :void{ p.update(dt)});

            //Send feedback messages.
            if(_feedbackMessageQueue.length > 0) {
                _ctrl.props.set(Codes.ROOM_PROP_FEEDBACK, _feedbackMessageQueue.slice());
                _feedbackMessageQueue.splice(0);
            }

            //Update the playerIds of players playing the feeding game
            var playerIdsFeedingNow :Array = bloodBloomGameManager.unavailablePlayers;
            //Sort for comparion
            playerIdsFeedingNow.sort();
            var playerIdsFeedingPrevious :Array =
                _ctrl.props.get(Codes.ROOM_PROP_PLAYERS_FEEDING_UNAVAILABLE) as Array;

            if(!ArrayUtil.equals(playerIdsFeedingNow, playerIdsFeedingPrevious)) {
                log.debug("Room " + roomId + ", Setting busy players=" + playerIdsFeedingNow);
                _ctrl.props.set(Codes.ROOM_PROP_PLAYERS_FEEDING_UNAVAILABLE, playerIdsFeedingNow);
            }

            //Update the primary predIds, for the tutorial
            var primaryPreds :Array = bloodBloomGameManager.primaryPreds;
            primaryPreds.sort();
            var primaryPredsPrevious :Array =
                _ctrl.props.get(Codes.ROOM_PROP_PRIMARY_PREDS) as Array;

            if(!ArrayUtil.equals(primaryPreds, primaryPredsPrevious)) {
                log.debug("Room " + roomId + ", Setting primary preds=" + primaryPreds);
                _ctrl.props.set(Codes.ROOM_PROP_PRIMARY_PREDS, primaryPreds);
            }

        }
        catch (e :Error) {
            log.error("Tick error", e);

            _errorCount++;
            if (isShutdown) {
                log.info("Giving up on room tick() due to error overflow", "roomId", this.roomId);
                return;
            }
        }
    }


    public function isPlayer (userId :int) :Boolean
    {
        return ArrayUtil.contains(ctrl.getPlayerIds(), userId);
    }


    protected function maybeLoadControl () :void
    {
        if (_ctrl == null) {
            _ctrl = ServerContext.ctrl.getRoom(_roomId);

            if(_ctrl == null) {
                log.warning("maybeLoadControl(), but RoomSubControl is still null!!!");
            }

            // export the room state to room properties
//            log.info("Starting room, setting hierarchy in props=" + ServerContext.minionHierarchy);
//            _ctrl.props.set(Codes.ROOM_PROP_MINION_HIERARCHY, ServerContext.minionHierarchy.toBytes());
//            log.debug("Export my state to new control", "state", _state);

//            _nonplayerMonitor = new NonPlayerMonitor(_ctrl);
//            _locationTracker = new LocationTracker(this);
            registerListener(_ctrl, AVRGameRoomEvent.ROOM_UNLOADED, destroy);
//            registerListener(_ctrl, AVRGameRoomEvent.PLAYER_MOVED, handlePlayerMoved);
//            registerListener(_ctrl, AVRGameRoomEvent.SIGNAL_RECEIVED, handleSignalReceived);

            _bloodBloomGameManager = new FeedingManager(this);
//            _roomDB.addObject(bloodBloomGameManager);

        }
    }

    public function destroy (...ignored) :void
    {
        if(isLiveObject) {
            destroySelf();
        }
    }


    override protected function destroyed () :void
    {
        try {
//            if(_roomDB != null) {
//                _roomDB.shutdown();
//            }
//            if (_players.size() != 0) {
////                trace("Eek! Room unloading with players still here!",
////                            "players", _players.values());
//            } else {
////                trace("Unloaded room", "roomId", roomId);
//            }
////            if(_players != null) {
////                _players.forEach(function(playerId :int, player :PlayerData) :void {
////                    player.r
////                });
////            }
////            _players.clear();
            _ctrl = null;
        }
        catch(err :Error) {

        }
    }

    public function get players () :HashMap
    {
        return _players;
    }

    public function getPlayer (playerId :int) :PlayerData
    {
        return _players.get(playerId) as PlayerData;
    }

    public function get playerIds () :Array
    {
        return _players.keys();
    }



//    public function get roomDB () :ObjectDB
//    {
//        return _roomDB;
//    }

    public function addFeedback (msg :String, playerId :int = 0) :void
    {
        log.debug(playerId + " " + msg);
        _feedbackMessageQueue.push([playerId, msg]);
    }

    public function get bloodBloomGameManager () :FeedingManager
    {
        return _bloodBloomGameManager;
    }


    /**
    * Holds BloodBloomGameRecord objects.  They have countdown timers so need to be updated.
    */
//    protected var _roomDB :ObjectDB = new ObjectDB();

    protected var _roomId :int;
    protected var _ctrl :RoomSubControlServer;

    protected var _players :HashMap = new HashMap();
    public var _bloodBloomGameManager :FeedingManager;

    protected var _errorCount :int = 0;

    /**
    * Each value is a array with two values: the message target, and the message itself.
    * A target <= 0 is a message for all.
    *
    * */
    protected var _feedbackMessageQueue :Array = new Array();

}
}
