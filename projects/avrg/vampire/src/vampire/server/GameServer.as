//
// $Id$

package vampire.server {

import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.avrg.PlayerSubControlServer;
import com.whirled.contrib.simplegame.ObjectDB;
import com.whirled.contrib.simplegame.ObjectMessage;
import com.whirled.net.MessageReceivedEvent;

import flash.utils.getTimer;
import flash.utils.setInterval;

import vampire.feeding.FeedingServer;

public class GameServer extends ObjectDB
{
    public function GameServer ()
    {
        trace("Vampire Server initializing...");
        log.info("Vampire Server initializing...");
        if(ServerContext.ctrl == null) {
            log.error("AVRServerGameControl should of been initialized already");
            return;
        }
        ServerContext.server = this;

        _ctrl = ServerContext.ctrl;

        registerListener(_ctrl.game, AVRGameControlEvent.PLAYER_JOINED_GAME, playerJoinedGame);
        registerListener(_ctrl.game, AVRGameControlEvent.PLAYER_QUIT_GAME, playerQuitGame);
        registerListener(_ctrl.game, MessageReceivedEvent.MESSAGE_RECEIVED, handleMessage);

        _startTime = getTimer();
        _lastTickTime = _startTime;
        setInterval(tick, SERVER_TICK_UPDATE_MILLISECONDS);

//        ServerContext.lineage = new LineageServer2(this);
        addObject(new LineageServer2(this));

//        addObject(new LineageServer2(null));

        //Tim's bloodbond game server
        FeedingServer.init(_ctrl);

        //Add the room population updater
        addObject(new LoadBalancerServer(this));

        //Add the feeding leaderboard server
//        addObject(new LeaderBoardServer(_ctrl));

    }

    public function get control () :AVRServerGameControl
    {
        return _ctrl;
    }

    public function get lineage () :LineageServer2
    {
        return getObjectNamed(LineageServer2.NAME) as LineageServer2;
    }

    /**
    * Get the room with the roomID.  Attempts to create the room if no room
    * currently exists.
    */
    public function getRoom (roomId :int) :Room
    {
        if (roomId == 0) {
            throw new Error("Bad argument to getRoom [roomId=0]");
        }
        var room :Room = _rooms.get(roomId);
        if (room == null) {


            try {
                room = new Room(roomId);
                _rooms.put(roomId, room);
                addObject(room);
            }
            catch(err :Error) {
                log.error("Attempted to get a room with no players.  Throws error.  Use isRoom()");
            }
        }
        return room;
    }

    public function isRoom (roomId :int) :Boolean
    {
        return _rooms.containsKey(roomId);
    }

    public function getPlayer (playerId :int) :PlayerData
    {
        return _players.get(playerId) as PlayerData;
    }

    /**
    * Rooms with no players, or that are not connected are marked for removal with the
    * isStale flag.
    */
    protected function removeStaleRooms () :void
    {
        for each(var roomId :int in _rooms.keys()) {
            var room :Room = _rooms.get(roomId) as Room;
            if(room == null || room.isStale) {
                log.debug("Removed room from VServer " + roomId);
                _rooms.remove(roomId);
            }
        }
    }

    /**
    * The update method.  All contained simobjects, such as rooms, the lineage server, etc
    * are updated on this pass.  It controls the global, game-wide update, thus controlling
    * network updates.
    */
    protected function tick () :void
    {
        var time :int = getTimer();
        var dT :int = time - _lastTickTime;
        _lastTickTime = time;
        var dt :Number = dT / 1000.0;//Seconds

        //We don't want to update stale rooms
        removeStaleRooms();

        //Add the global messages to each room
        _rooms.forEach(function(roomId :int, room :Room) :void {
            for each(var globalMessage :String in _globalFeedback) {
                room.addFeedback(globalMessage, 0);
            }
        });

        //Then empty the global message queue
        _globalFeedback.splice(0);

        //Batch up the updates, so all the network traffic is sent as one lump
        //The rooms are update in this loop as they are simobjects.
        _ctrl.doBatch(function () :void {
            update(dt);
        });

    }



    /**
    * Pass messages to the ServerLogic object.
    */
    protected function handleMessage (evt :MessageReceivedEvent) :void
    {
        //Only handle the message if the originating player exists.
        try {
            var player :PlayerData = getPlayer(evt.senderId);
            if (player == null) {
                log.warning("Received message for non-existent player [evt=" + evt + "]");
                log.warning("playerids=" + _players.keys());
                return;
            }
            //Batch up the resultant network traffic from the message.
            _ctrl.doBatch(function () :void {
                ServerLogic.handleMessage(player, evt.name, evt.value);
            });
        }
        catch(err :Error) {
            log.error(err + "\n" + err.getStackTrace());
        }
    }

    /**
    * When players enter the game, we create a local record for them
    */
    protected function playerJoinedGame (evt :AVRGameControlEvent) :void
    {
        try {
            log.info("playerJoinedGame() " + evt);
            var playerId :int = int(evt.value);

            if (_players.containsKey(playerId)) {
                log.warning("Joining player already known", "playerId", playerId);
                return;
            }

            var pctrl :PlayerSubControlServer = _ctrl.getPlayer(playerId);
            if (pctrl == null) {
                throw new Error("Could not get PlayerSubControlServer for player!");
            }

            _ctrl.doBatch(function () :void {
                var player :PlayerData = new PlayerData(pctrl);
                _players.put(playerId, player);

                //Tell the lineage that there is a new player.
                sendMessageToNamedObject(
                    new ObjectMessage(LineageServer2.MESSAGE_PLAYER_JOINED_GAME, player),
                    LineageServer2.NAME);
            });



            log.debug("Sucessfully created Player object.");
        }
        catch(err :Error) {
            log.error(err + "\n" + err.getStackTrace());
        }
    }



    /**
    * When players leave, clean up
    */
    protected function playerQuitGame (evt :AVRGameControlEvent) :void
    {
        try {
            log.info("playerQuitGame(" + playerId + ")");
            var playerId :int = int(evt.value);

            var player :PlayerData = _players.remove(playerId) as PlayerData;
            if (player == null) {
                log.warning("Quitting player not known", "playerId", playerId);
                return;
            }

            _ctrl.doBatch(function () :void {
                player.shutdown();
            });

            log.info("Player quit the game", "player", player);
        }
        catch(err :Error) {
            log.error(err + "\n" + err.getStackTrace());
        }
    }

    public function addGlobalFeedback (msg :String) :void
    {
        _globalFeedback.push(msg);
    }

    public function isPlayer (playerId :int) :Boolean
    {
        return _players.containsKey(playerId);
    }

    public function get rooms () :HashMap
    {
        return _rooms;
    }


    protected var _startTime :int;
    protected var _lastTickTime :int;

    protected var _ctrl :AVRServerGameControl;
    protected var _rooms :HashMap = new HashMap();
    protected var _players :HashMap = new HashMap();

    protected var _globalFeedback :Array = new Array();

    public static const SERVER_TICK_UPDATE_MILLISECONDS :int = 500;

    public static var log :Log = Log.getLog(GameServer);

}
}

