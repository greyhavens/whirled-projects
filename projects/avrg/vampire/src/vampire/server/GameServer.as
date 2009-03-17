//
// $Id$

package vampire.server {

import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.threerings.util.Random;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.avrg.PlayerSubControlServer;
import com.whirled.contrib.avrg.probe.ServerStub;
import com.whirled.contrib.simplegame.ObjectDB;
import com.whirled.net.MessageReceivedEvent;

import flash.utils.getTimer;
import flash.utils.setInterval;

import vampire.data.Codes;
import vampire.feeding.FeedingServer;

public class GameServer extends ObjectDB
{
//    public static const FRAMES_PER_SECOND :int = 30;

    public static var log :Log = Log.getLog(GameServer);


    public var random :Random = new Random();

    public function get control () :AVRServerGameControl
    {
        return _ctrl;
    }

    public function isAdmin (playerId :int) :Boolean
    {
        // we might want to make this dynamic later
        return playerId < 20
            || playerId == 14088    // cirrus
            || playerId == 14128    // nimbus
            || playerId == 16444    // equinox
            || playerId == 14001    // sirrocco
            || playerId == 14137    // coriolis
            || playerId == 14134    // sunshine
            || playerId == 23340    //me (ragbeard)
            ;
    }

    public function GameServer ()
    {
        log.info("Vampire Server initializing...");
        if( ServerContext.ctrl == null ) {
            log.error("AVRServerGameControl should of been initialized already");
            return;
        }
        ServerContext.server = this;

        _ctrl = ServerContext.ctrl;

//        _ctrl.game.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, handleMessage);
        registerListener(_ctrl.game, AVRGameControlEvent.PLAYER_JOINED_GAME, playerJoinedGame);
        registerListener(_ctrl.game, AVRGameControlEvent.PLAYER_QUIT_GAME, playerQuitGame);

//        ServerContext.msg = new VMessageManager( _ctrl );
//        registerListener(ServerContext.msg, MessageReceivedEvent.MESSAGE_RECEIVED, handleMessage );
        registerListener(_ctrl.game, MessageReceivedEvent.MESSAGE_RECEIVED, handleMessage);

        _startTime = getTimer();
        _lastTickTime = _startTime;
        setInterval(tick, SERVER_TICK_UPDATE_MILLISECONDS);

        ServerContext.lineage = new LineageServer( this );
        addObject( ServerContext.lineage );

//        ServerContext.trophies = new Trophies(this, ServerContext.minionHierarchy);

        ServerContext.nonPlayersBloodMonitor = new NonPlayerAvatarsBloodMonitor();
        addObject( ServerContext.nonPlayersBloodMonitor );

        //Tim's bloodbond game server
        FeedingServer.init( _ctrl );

//        _stub = new ServerStub(_ctrl);\

        //Update the players time
//        var playerTimeUpdater :SimpleTimer = new SimpleTimer(UPDATE_PLAYER_TIME,
//            updatePlayersCurrentTime, true);
//        addObject( playerTimeUpdater );

    }

//    /**
//    * Update the current time of all the players.  THis is handled seperately because it's not
//    * critical and only occurs every couple of seconds.
//    */
//    protected function updatePlayersCurrentTime(...ignored) :void
//    {
//        _players.forEach( function( playerId :int, player :Player) :void {
//            //Update the players time, unless they are a new player (time==0)
//            if( player.time != 0) {
//                player.setTime( ServerContext.time );
//            }
//        });
//
//    }




    public function getRoom (roomId :int) :Room
    {
        if (roomId == 0) {
            throw new Error("Bad argument to getRoom [roomId=0]");
        }
        var room :Room = _rooms.get(roomId);
        if (room == null) {


            try {
                room = new Room(roomId);
                _rooms.put(roomId, room );
                addObject( room );
            }
            catch(err :Error ) {
                log.error("Attempted to get a room with no players.  Throws error.  Use isRoom()");
            }
        }
        return room;
    }

    public function isRoom( roomId :int) :Boolean
    {
        return _rooms.containsKey( roomId );
    }

    public function getPlayer (playerId :int) :PlayerData
    {
        return _players.get(playerId) as PlayerData;
    }


    protected function removeStaleRooms() :void
    {
        for each( var roomId :int in _rooms.keys()) {
            var room :Room = _rooms.get( roomId ) as Room;
            if( room == null || room.isStale ) {
                log.debug("Removed room from VServer " + roomId);
                _rooms.remove( roomId );
            }
        }
    }
    protected function tick () :void
    {
        var time :int = getTimer();
        var dT :int = time - _lastTickTime;
        _lastTickTime = time;
        var dT_seconds :Number = dT / 1000.0;

        //Store the current (enough) time so all the PlayerData objects don't have to create another.
        ServerContext.time = new Date().time;

        //We don't want ot be updating stale rooms
        removeStaleRooms();

        //Add the global messages to each room
        _rooms.forEach( function( roomId :int, room :Room) :void {

                for each( var globalMessage :String in _globalFeedback) {
                    room.addFeedback( globalMessage, 0);
                }
            });
        //Then empty the global message queue
        _globalFeedback.splice(0);

        //Batch up the updates, so all the network traffic is sent as one lump
        _ctrl.doBatch(function () :void {
            update(dT_seconds);
        });

    }



    // a message comes in from a player, figure out which PlayerData instance will handle it
    protected function handleMessage (evt :MessageReceivedEvent) :void
    {
        try {
//            log.debug("handleMessage", "evt", evt);
            var player :PlayerData = getPlayer(evt.senderId);
            if (player == null) {
                log.warning("Received message for non-existent player [evt=" + evt + "]");
                log.warning("playerids=" + _players.keys());
                return;
            }
            _ctrl.doBatch(function () :void {
                ServerLogic.handleMessage(player, evt.name, evt.value);
            });
        }
        catch( err :Error ) {
            log.error(err + "\n" + err.getStackTrace());
        }
    }

    // when players enter the game, we create a local record for them
    protected function playerJoinedGame (evt :AVRGameControlEvent) :void
    {
        try {
            log.info("playerJoinedGame() " + evt);
            var playerId :int = int(evt.value);

            //Add to the permanent record of players.
//            if( playerId > 0 ) {
//                _playerIds.add( playerId );
//            }

            if (_players.containsKey(playerId)) {
                log.warning("Joining player already known", "playerId", playerId);
                return;
            }


    //        log.info("!!!!!Before player created", "player time", _ctrl.getPlayer(playerId).props.get( Codes.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE));
            log.info("!!!!!Before player created", "player time", new Date(_ctrl.getPlayer(playerId).props.get( Codes.PLAYER_PROP_LAST_TIME_AWAKE)).toTimeString());

            var pctrl :PlayerSubControlServer = _ctrl.getPlayer(playerId);
            if (pctrl == null) {
                throw new Error("Could not get PlayerSubControlServer for player!");
            }
    //
    //        log.info("!!!!!After player created", "player time", _ctrl.getPlayer(playerId).props.get( Codes.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE));
            log.info("!!!!!AFter player control created", "player time", new Date(_ctrl.getPlayer(playerId).props.get( Codes.PLAYER_PROP_LAST_TIME_AWAKE)).toTimeString());


            var hierarchyChanged :Boolean = false;

            _ctrl.doBatch(function () :void {
                var player :PlayerData = new PlayerData(pctrl);
                _players.put(playerId, player);
                ServerContext.nonPlayersBloodMonitor.addNewPlayer( playerId );
            });

            //Keep a record of player ids to distinguish players and non-players
            //even when the players are not actively playing.

            log.debug("Sucessfully created Player object.");
        }
        catch( err :Error ) {
            log.error(err + "\n" + err.getStackTrace());
        }
    }



    // when they leave, clean up
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

    //        log.info("!!!!!After player quit the game", "player time", _ctrl.getPlayer(playerId).props.get( Codes.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE));
            log.info("!!!!!After player quit the game", "player time", new Date(_ctrl.getPlayer(playerId).props.get( Codes.PLAYER_PROP_LAST_TIME_AWAKE)).toTimeString());
        }
        catch( err :Error ) {
            log.error(err + "\n" + err.getStackTrace());
        }
    }

    public function get rooms() :HashMap
    {
        return _rooms;
    }

    public function addGlobalFeedback( msg :String ) :void
    {
        _globalFeedback.push( msg );
    }



    public function isPlayer( playerId :int ) :Boolean
    {
        return _players.containsKey( playerId );
    }


    protected var _startTime :int;
    protected var _lastTickTime :int;

    protected var _ctrl :AVRServerGameControl;
    protected var _rooms :HashMap = new HashMap();
    protected var _players :HashMap = new HashMap();

    protected var _globalFeedback :Array = new Array();

    protected var _stub :ServerStub;

    public static const SERVER_TICK_UPDATE_MILLISECONDS :int = 400;

}
}

