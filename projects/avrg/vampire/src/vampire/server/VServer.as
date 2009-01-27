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
import com.whirled.net.MessageReceivedEvent;

import flash.utils.getTimer;

import vampire.data.SharedPlayerStateServer;
import vampire.net.MessageManager;

public class VServer
{
    public static const FRAMES_PER_SECOND :int = 30;

    public static var log :Log = Log.getLog(VServer);
    
    
    public static var random :Random = new Random();

    public static function get control () :AVRServerGameControl
    {
        return _ctrl;
    }

    public static function isAdmin (playerId :int) :Boolean
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

    public function VServer ()
    {
        log.info("Vampire Server initializing...");
        if( ServerContext.ctrl == null ) {
            log.error("AVRServerGameControl should of been initialized already");
            return;
        }
        _ctrl = ServerContext.ctrl;
        
        _serverLogBroadcast = new AVRGAgentLogTarget( _ctrl );
        Log.addTarget( _serverLogBroadcast );
        
        Log.setLevel("", Log.DEBUG);
        
        

//        _ctrl.game.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, handleMessage);
        _ctrl.game.addEventListener(AVRGameControlEvent.PLAYER_JOINED_GAME, playerJoinedGame);
        _ctrl.game.addEventListener(AVRGameControlEvent.PLAYER_QUIT_GAME, playerQuitGame);

        ServerContext.msg = new MessageManager( _ctrl );
        ServerContext.msg.addEventListener( MessageReceivedEvent.MESSAGE_RECEIVED, handleMessage );
        
//        _startTime = getTimer();
//        setInterval(tick, 20);

        _stub = new ServerStub(_ctrl);
    }


    
    
    public static function getRoom (roomId :int) :Room
    {
        if (roomId == 0) {
            throw new Error("Bad argument to getRoom [roomId=0]");
        }
        var room :Room = _rooms.get(roomId);
        if (room == null) {
            _rooms.put(roomId, room = new Room(roomId));
        }
        return room;
    }

    public static function getPlayer (playerId :int) :Player
    {
        return Player(_players.get(playerId));
    }

    protected function tick () :void
    {
        var dT :int = getTimer() - _startTime;
        var frame :int = dT * (FRAMES_PER_SECOND / 1000);
        var second :int = dT / 1000;

        
//        _ctrl.doBatch(function () :void {
//            _rooms.forEach(function (roomId :int, room :Room) :void {
//                try {
//                    room.tick(frame, second > _lastSecond);
//
//                } catch (error :Error) {
//                    log.warning("Error in room.tick()", "roomId", roomId, error);
//                }
//            });
//        });

        _lastSecond = second;
    }

    // a message comes in from a player, figure out which Player instance will handle it
    protected function handleMessage (evt :MessageReceivedEvent) :void
    {
        var player :Player = getPlayer(evt.senderId);
        if (player == null) {
            log.warning("Received message for non-existent player [evt=" + evt + "]");
            log.warning("playerids with Player=" + _players.keys());
            return;
        }
        _ctrl.doBatch(function () :void {
            player.handleMessage(evt.name, evt.value);
        });
    }

    // when players enter the game, we create a local record for them
    protected function playerJoinedGame (evt :AVRGameControlEvent) :void
    {
        var playerId :int = int(evt.value);
        if (_players.containsKey(playerId)) {
            log.warning("Joining player already known", "playerId", playerId);
            return;
        }


//        log.info("!!!!!Before player created", "player time", _ctrl.getPlayer(playerId).props.get( SharedPlayerStateServer.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE));
        log.info("!!!!!Before player created", "player time", new Date(_ctrl.getPlayer(playerId).props.get( SharedPlayerStateServer.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE)).toTimeString());

        var pctrl :PlayerSubControlServer = _ctrl.getPlayer(playerId);
        if (pctrl == null) {
            throw new Error("Could not get PlayerSubControlServer for player!");
        }
        
//        log.info("!!!!!After player created", "player time", _ctrl.getPlayer(playerId).props.get( SharedPlayerStateServer.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE));
        log.info("!!!!!AFter player created", "player time", new Date(_ctrl.getPlayer(playerId).props.get( SharedPlayerStateServer.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE)).toTimeString());

        
        _ctrl.doBatch(function () :void {
            _players.put(playerId, new Player(pctrl));
        });
        log.debug("Sucessfully created Player object.");

        log.info("Player joined the game", "playerId", playerId);
    }

    // when they leave, clean up
    protected function playerQuitGame (evt :AVRGameControlEvent) :void
    {
        var playerId :int = int(evt.value);

        var player :Player = _players.remove(playerId);
        if (player == null) {
            log.warning("Quitting player not known", "playerId", playerId);
            return;
        }
        _ctrl.doBatch(function () :void {
            player.shutdown();
        });

        log.info("Player quit the game", "player", player);
        
//        log.info("!!!!!After player quit the game", "player time", _ctrl.getPlayer(playerId).props.get( SharedPlayerStateServer.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE));
        log.info("!!!!!After player quit the game", "player time", new Date(_ctrl.getPlayer(playerId).props.get( SharedPlayerStateServer.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE)).toTimeString());

    }
    
    public static function getSireFromInvitee( playerId :int) :int
    {
        log.warning("getSireFromInvitee not implemented yet, returning 0")
        return 0;
    }

    protected var _startTime :int;
    protected var _lastSecond :int;

    protected static var _ctrl :AVRServerGameControl;
    protected static var _rooms :HashMap = new HashMap();
    protected static var _players :HashMap = new HashMap();
    
    
    protected var _stub :ServerStub;
    
    protected var _serverLogBroadcast :AVRGAgentLogTarget;
}
}

