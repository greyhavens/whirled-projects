//
// $Id$

package vampire.server {

import com.threerings.util.HashMap;
import com.threerings.util.HashSet;
import com.threerings.util.Log;
import com.threerings.util.Random;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.avrg.PlayerSubControlServer;
import com.whirled.contrib.avrg.probe.ServerStub;
import com.whirled.contrib.simplegame.server.ObjectDBThane;
import com.whirled.net.MessageReceivedEvent;

import flash.utils.getTimer;
import flash.utils.setInterval;

import vampire.data.Codes;
import vampire.data.Constants;
import vampire.data.MinionHierarchyServer;
import vampire.feeding.FeedingGameServer;
import vampire.net.MessageManager;

public class VServer extends ObjectDBThane
{
    public static const FRAMES_PER_SECOND :int = 30;

    public static var log :Log = Log.getLog(VServer);
    
    
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

    public function VServer ()
    {
        log.info("Vampire Server initializing...");
        if( ServerContext.ctrl == null ) {
            log.error("AVRServerGameControl should of been initialized already");
            return;
        }
        ServerContext.vserver = this;
        _ctrl = ServerContext.ctrl;

//        _ctrl.game.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, handleMessage);
        registerListener(_ctrl.game, AVRGameControlEvent.PLAYER_JOINED_GAME, playerJoinedGame);
        registerListener(_ctrl.game, AVRGameControlEvent.PLAYER_QUIT_GAME, playerQuitGame);

        ServerContext.msg = new MessageManager( _ctrl );
        registerListener(ServerContext.msg, MessageReceivedEvent.MESSAGE_RECEIVED, handleMessage );
        
        _startTime = getTimer();
        _lastTickTime = _startTime;
        setInterval(tick, Constants.SERVER_TICK_UPDATE_MILLISECONDS);
        
        ServerContext.minionHierarchy = new MinionHierarchyServer( this );
        
        ServerContext.nonPlayersBloodMonitor = new NonPlayerAvatarsBloodMonitor();
        addObject( ServerContext.nonPlayersBloodMonitor ); 

        //Tim's bloodbond game server
        FeedingGameServer.init( _ctrl );
        
        _stub = new ServerStub(_ctrl);
    }


    
    
    public function getRoom (roomId :int) :Room
    {
        if (roomId == 0) {
            throw new Error("Bad argument to getRoom [roomId=0]");
        }
        var room :Room = _rooms.get(roomId);
        if (room == null) {
            _rooms.put(roomId, room = new Room(roomId));
            addObject( room );
        }
        return room;
    }
    
    public function isRoom( roomId :int) :Boolean
    {
        return _rooms.containsKey( roomId );
    }

    public function getPlayer (playerId :int) :Player
    {
        return Player(_players.get(playerId));
    }
    
//    override public function update(dt:Number):void
//    {
//        
//    }

    protected function tick () :void
    {
        var time :int = getTimer();
        var dT :int = time - _lastTickTime;
        _lastTickTime = time;
        var dT_seconds :Number = dT / 1000.0;
        
//        var frame :int = dT * (FRAMES_PER_SECOND / 1000);
//        var second :int = dT / 1000;

        //Update the non-players blood levels.
//        ServerContext.nonPlayers.tick( dT_seconds );
        
//        ServerContext.minionHierarchy.tick();
//        _avatarManager.update( dT_seconds );
        
        _ctrl.doBatch(function () :void {
            
            update( dT_seconds );
            
//            _rooms.forEach(function (roomId :int, room :Room) :void {
//                try {
//                    room.tick(dT_seconds);
//
//                } catch (error :Error) {
//                    log.warning("Error in room.tick()", "roomId", roomId, error);
//                }
//            });
        });
        
        
//        //Remove stale non-players.
//        for each(var np :NonPlayerAvatar in getObjectsInGroup(NonPlayerAvatar.GROUP)) {
//            if( np.isStale ) {
//                np.destroySelf();
//                _nonplayers.remove( np.playerId );
//            }
//        }

        
    }

    // a message comes in from a player, figure out which Player instance will handle it
    protected function handleMessage (evt :MessageReceivedEvent) :void
    {
        try {
            var player :Player = getPlayer(evt.senderId);
            if (player == null) {
                log.warning("Received message for non-existent player [evt=" + evt + "]");
                log.warning("playerids=" + _players.keys());
                return;
            }
            _ctrl.doBatch(function () :void {
                player.handleMessage(evt.name, evt.value);
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
            if( playerId > 0 ) {
                _playerIds.add( playerId );
            }
            
            if (_players.containsKey(playerId)) {
                log.warning("Joining player already known", "playerId", playerId);
                return;
            }
    
    
    //        log.info("!!!!!Before player created", "player time", _ctrl.getPlayer(playerId).props.get( Codes.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE));
            log.info("!!!!!Before player created", "player time", new Date(_ctrl.getPlayer(playerId).props.get( Codes.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE)).toTimeString());
    
            var pctrl :PlayerSubControlServer = _ctrl.getPlayer(playerId);
            if (pctrl == null) {
                throw new Error("Could not get PlayerSubControlServer for player!");
            }
    //        
    //        log.info("!!!!!After player created", "player time", _ctrl.getPlayer(playerId).props.get( Codes.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE));
            log.info("!!!!!AFter player control created", "player time", new Date(_ctrl.getPlayer(playerId).props.get( Codes.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE)).toTimeString());
    
            
            var hierarchyChanged :Boolean = false;
            
            _ctrl.doBatch(function () :void {
                var player :Player = new Player(pctrl);
                _players.put(playerId, player);
            });
            
            //Keep a record of player ids to distinguish players and non-players
            //even when the players are not actively playing.    
            ServerContext.nonPlayersBloodMonitor.addNewPlayer( playerId );
            
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
    
            var player :Player = _players.remove(playerId);
            if (player == null) {
                log.warning("Quitting player not known", "playerId", playerId);
                return;
            }
            _ctrl.doBatch(function () :void {
                player.shutdown();
            });
    
            log.info("Player quit the game", "player", player);
            
    //        log.info("!!!!!After player quit the game", "player time", _ctrl.getPlayer(playerId).props.get( Codes.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE));
            log.info("!!!!!After player quit the game", "player time", new Date(_ctrl.getPlayer(playerId).props.get( Codes.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE)).toTimeString());
        }
        catch( err :Error ) {
            log.error(err + "\n" + err.getStackTrace());
        }
    }
    
    public function getSireFromInvitee( playerId :int) :int
    {
        log.warning("getSireFromInvitee not implemented yet, returning -1")
        return -1;
    }
    
    public function get rooms() :HashMap
    {
        return _rooms;
    }
    
    /**
    * When a player gains blood, his sires all share a portion of the gain
    * 
    */
    public function playerGainedBlood( player :Player, blood :Number, sourcePlayerId :int = 0 ) :void
    {
        var bloodShared :Number = Constants.BLOOD_GAIN_FRACTION_SHARED_WITH_SIRES * blood;
        var allsires :HashSet = ServerContext.minionHierarchy.getAllSiresAndGrandSires( player.playerId );
        var bloodForEachSire :Number = bloodShared / allsires.size();
        allsires.forEach( function ( sireId :int) :void {
            if( isPlayerOnline( sireId )) {
                var sire :Player = getPlayer( sireId );
                sire.addBlood( bloodForEachSire );
            }
        });
    }
    
//    public function getNonPlayer( playerId :int, room :Room ) :PlayerAvatar
//    {
//        return _avatarManager.getNonPlayer( playerId, room.ctrl );
////        if( !_nonplayers.containsKey( playerId ) ) {
////            var np :NonPlayerAvatar = new NonPlayerAvatar(playerId, room.ctrl );
////            np.setServerNonPlayerHashMap( _nonplayers );
////            addObject( np );
////        }
////        return _nonplayers.get( playerId ) as NonPlayerAvatar;
//    }
//    public function isNonPlayer( playerId :int ) :Boolean
//    {
//        return _avatarManager.isNonPlayer( playerId );
//    }    
    
    
    public function isPlayerOnline( playerId :int ) :Boolean
    {
        return _players.containsKey( playerId );
    }
    
    public function isPlayer( playerId :int ) :Boolean
    {
        return _playerIds.contains( playerId );
    }
    
//    public function get avatarManager() :AvatarManager
//    {
//        return _avatarManager;
//    }
    

    

    
    
    
    
    
    

    protected var _startTime :int;
    protected var _lastTickTime :int;

    protected var _ctrl :AVRServerGameControl;
    protected var _rooms :HashMap = new HashMap();
    protected var _players :HashMap = new HashMap();
    
    protected var _playerIds :HashSet = new HashSet();
    
//    protected var _avatarManager :AvatarManager = new AvatarManager();
//    public static var _nonplayers :HashMap = new HashMap();
    
    protected var _stub :ServerStub;
    

}
}

