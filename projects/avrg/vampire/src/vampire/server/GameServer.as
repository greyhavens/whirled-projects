//
// $Id$

package vampire.server {

import com.threerings.util.ClassUtil;
import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.avrg.PlayerSubControlServer;
import com.whirled.contrib.simplegame.net.Message;
import com.whirled.contrib.simplegame.objects.BasicGameObject;
import com.whirled.net.MessageReceivedEvent;

import flash.events.Event;

import vampire.data.Codes;
import vampire.feeding.FeedingServer;
import vampire.quest.server.QuestServer;
import vampire.server.feeding.FeedingContext;
import vampire.server.feeding.FeedingManager;
import vampire.server.feeding.LeaderBoardServer;
import vampire.server.feeding.LogicFeeding;

[Event(name="playerMoved", type="vampire.server.GameEvent")]
[Event(name="playerJoinedGame", type="com.whirled.avrg.AVRGameControlEvent")]
[Event(name="playerJoinedGame", type="com.whirled.avrg.AVRGameControlEvent")]
public class GameServer extends BasicGameObject
{
    public function GameServer ()
    {
        log.info("Vampire Server initializing...");
        if(ServerContext.ctrl != null) {
            ServerContext.server = this;

            _ctrl = ServerContext.ctrl;

            registerListener(_ctrl.game, AVRGameControlEvent.PLAYER_JOINED_GAME, playerJoinedGame);
            registerListener(_ctrl.game, AVRGameControlEvent.PLAYER_QUIT_GAME, playerQuitGame);
            registerListener(_ctrl.game, MessageReceivedEvent.MESSAGE_RECEIVED, handleMessage);

            //Add the lineage server
            ServerContext.lineage = new LineageServer(this);

            //Tim's bloodbond game server
            FeedingServer.init(_ctrl);

            // The Quest server
            QuestServer.init(_ctrl);

            //Add the room population updater
            new LoadBalancerServer(this);

            //Add the feeding leaderboard server
            FeedingContext.leaderBoardServer = new LeaderBoardServer(this);

            //Add stats monitoring
//            addObject(new AnalyserServer());

            //Add the Feedback notifier
            ServerContext.feedback = new Feedback();

            ServerContext.feedingManager = new FeedingManager(this);

            //Add this time to the list of server reboots
            recordBootTime();

            registerListener(_ctrl, Event.UNLOAD, shutdown);
        }
        else {
            log.error(ClassUtil.tinyClassName(GameServer) + ": no AVRServerGameControl!!");
            log.error("Are we running locally???");
        }

    }

    override public function shutdown (...ignored) :void
    {
        _players.forEach(function (playerId :int, player :PlayerData) :void {
            player.shutdown();
        });
        _rooms.forEach(function (roomId :int, room :Room) :void {
            room.shutdown();
        });
        super.shutdown();
    }

    protected function recordBootTime () :void
    {
        var reboottimes :Array = _ctrl.props.get(Codes.AGENT_PROP_SERVER_REBOOTS) as Array;
        if (reboottimes == null) {
            reboottimes = [];
        }
        reboottimes.push(new Date().time);
        _ctrl.props.set(Codes.AGENT_PROP_SERVER_REBOOTS, reboottimes, true);
    }

    public function get ctrl () :AVRServerGameControl
    {
        return _ctrl;
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
                room = new Room(roomId, removeRoomCallback);
                _rooms.put(roomId, room);
            }
            catch(err :Error) {
                log.error("Attempted to get a room with no players.  Throws error.  Use isRoom()");
            }
        }
        return room;
    }

    protected function removeRoomCallback (room :Room) :void
    {
         if (room != null) {
             room.shutdown();
             _rooms.remove(room.roomId);
             dispatchEvent(new GameEvent(GameEvent.ROOM_SHUTDOWN, null, room));
         }
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
                var msg :Message = ServerContext.msg.deserializeMessage(evt.name, evt.value);
                if (msg != null) {
                    LogicServer.handleMessage(player, msg);
                    LogicFeeding.handleMessage(player, msg);
                }
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
                //Notify other listeners that the PlayerData is loaded.
                dispatchEvent(new AVRGameControlEvent(AVRGameControlEvent.PLAYER_JOINED_GAME,
                    null, player.playerId));
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

            log.info("Player quit the game", "player", player);

            _ctrl.doBatch(function () :void {
                player.shutdown();
            });
        }
        catch(err :Error) {
            log.error(err + "\n" + err.getStackTrace());
        }
    }

    public function isPlayer (playerId :int) :Boolean
    {
        return _players.containsKey(playerId);
    }

    public function get rooms () :HashMap
    {
        return _rooms;
    }

    public function get players () :HashMap
    {
        return _players;
    }

    protected var _ctrl :AVRServerGameControl;
    protected var _rooms :HashMap = new HashMap();
    protected var _players :HashMap = new HashMap();

    public static var log :Log = Log.getLog(GameServer);
}
}

