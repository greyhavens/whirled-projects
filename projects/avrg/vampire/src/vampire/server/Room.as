//
// $Id$

package vampire.server {

import com.threerings.util.ArrayUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.HashMap;
import com.threerings.util.HashSet;
import com.threerings.util.Hashable;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.avrg.RoomSubControlServer;
import com.whirled.contrib.simplegame.server.ObjectDBThane;
import com.whirled.contrib.simplegame.server.SimObjectThane;

import vampire.data.Constants;
import vampire.net.messages.FeedRequestMessage;

public class Room extends SimObjectThane
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
    
    override public function get objectName():String
    {
        return "Room " + _roomId;
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

    override public function toString () :String
    {
        return "Room [roomId=" + _roomId + "]";
    }

    public function playerEntered (player :Player) :void
    {
        
        if (!_players.put(player.playerId, player)) {
            log.warning("Arriving player already existed in room", "roomId", this.roomId,
                        "playerId", player.playerId);
        }

        maybeLoadControl(); 
        
        var playername :String = _ctrl.getAvatarInfo( player.playerId) != null ? _ctrl.getAvatarInfo( player.playerId).name : "" + player.playerId;
        
        log.info("Setting " + playername + " props into room, player=" + player);
        player.setIntoRoomProps( this );
        
        //Let the avatars know who is who, so they don't spam us with movement updates
        ctrl.sendSignal( Constants.SIGNAL_PLAYER_IDS, playerIds );

    }

    public function playerLeft (player :Player) :void
    {
//        _entityLocations.remove( player.playerId );
        
        if (!_players.remove(player)) {
            log.warning("Departing player did not exist in room", "roomId", this.roomId,
                        "playerId", player.playerId);
        }

        if (_ctrl == null) {
            log.warning("Null room control", "action", "player departing",
                        "playerId", player.playerId);
            return;
        }
        
        //Let the avatars know who is who, so they don't spam us with movement updates
        ctrl.sendSignal( Constants.SIGNAL_PLAYER_IDS, playerIds );
        
        //Broadcast the players in the room
//        _ctrl.sendSignal(Constants.ROOM_SIGNAL_ENTITYID_REPONSE, _players.toArray().map( function( p :Player) :int { return p.playerId}));
        

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
    override protected function update (dt :Number) :void
    {
        // if we're shut down due to excessive errors, or the room is unloaded, do nothing
        if (isShutdown || _ctrl == null) {
            return;
        }

        try {
            _players.forEach( function( playerId :int, p :Player) :void{ p.tick(dt)});
//            _bloodBloomGameStarter.update( dt );


            //Send queued avatar movement messages.
            var playersMoved :HashSet = new HashSet();
            
            while( _avatarMovedSignalQueue.length > 0 ) {
                var data :Array = _avatarMovedSignalQueue.pop() as Array;
                var userId :int = int(data[0]);
                if( !playersMoved.contains( userId ) ) {
                    playersMoved.add( userId );
                    log.info("sending room message "  
                        + Constants.NAMED_EVENT_AVATAR_MOVED_SIGNAL_FROM_SERVER + " " + data);
                    _ctrl.sendMessage( Constants.NAMED_EVENT_AVATAR_MOVED_SIGNAL_FROM_SERVER, data);
                    
                }
            }
            

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

        
//        ServerContext.serverLogBroadcast.log("Updating player room props=" + player);
        
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

//    internal function reset () :void
//    {
//        if (_ctrl == null) {
//            log.warning("Null room control", "action", "reset");
//            return;
//        }
//
////        _stats.clear();
////        _minigames.clear();
//    }

//    internal function setState (state :String) :void
//    {
//        if (_ctrl == null) {
//            log.warning("Null room control", "action", "state set", "state", state);
//            return;
//        }
//
////        _state = state;
////
////        _ctrl.props.set(Codes.PROP_STATE, state, true);
////
////        _players.forEach(function (player :Player) :void {
////            player.roomStateChanged();
////        });
//        log.debug("Room state set", "roomId", this.roomId, "state", state);
//    }

//    protected function _tick (dt :Number) :void
//    {
//        _players.forEach( function( playerId :int, p :Player) :void{ p.tick(dt)});
//        _bloodBloomGameStarter.update( dt );
//    }

    protected function maybeLoadControl () :void
    {
        if (_ctrl == null) {
            _ctrl = ServerContext.ctrl.getRoom(_roomId);
            
            if( _ctrl == null ) {
                log.warning("maybeLoadControl(), but RoomSubControl is still null!!!");
            }

            // export the room state to room properties
//            log.info("Starting room, setting hierarchy in props=" + ServerContext.minionHierarchy);
//            _ctrl.props.set(Codes.ROOM_PROP_MINION_HIERARCHY, ServerContext.minionHierarchy.toBytes());
//            log.debug("Export my state to new control", "state", _state);

//            _nonplayerMonitor = new NonPlayerMonitor( _ctrl );
//            _locationTracker = new LocationTracker( this );
            registerListener(_ctrl, AVRGameRoomEvent.ROOM_UNLOADED, destroySelf);
//            registerListener(_ctrl, AVRGameRoomEvent.PLAYER_MOVED, handlePlayerMoved);
            registerListener(_ctrl, AVRGameRoomEvent.SIGNAL_RECEIVED, handleSignalReceived);
            
            _bloodBloomGameStarter = new BloomBloomManager( this );
            _roomDB.addObject( _bloodBloomGameStarter );
            
        }
    }
    
    protected function handleSignalReceived( e :AVRGameRoomEvent ) :void
    {
        log.debug("handleSignalReceived ", "e", e);
        var data :Array;
//        var nonPlayer :PlayerAvatar;
        var playerId :int;
        switch( e.name ) {
            
            //IF there is no NonPlayerAvatar for this signal, create one.
            case Constants.SIGNAL_AVATAR_MOVED:
                data = e.value as Array;
                playerId = int(data[0]);
                if( !ServerContext.vserver.isPlayer( playerId ) ) {
                    ServerContext.nonPlayersBloodMonitor.setUserRoom( playerId, roomId );
                }
                
                
                _avatarMovedSignalQueue.push( e.value );
                //Temp hack: 
//                log.info("sending room message "  
//                    + Constants.NAMED_EVENT_AVATAR_MOVED_SIGNAL_FROM_SERVER + " " + e.value);
//                _ctrl.sendMessage( Constants.NAMED_EVENT_AVATAR_MOVED_SIGNAL_FROM_SERVER, e.value);
            
//                
//                
//                
//                //We ignore data about players, since we can grab it anytime.
////                if( _players.containsKey( playerId ) ) {
////                    return;
////                }
//                
//                var location :Array = data[1] as Array;
//                var hotspot :Array = data[2] as Array;
//                
//                var avatarManager :AvatarManager = ServerContext.avatarManager;
//                
//                var avatar :PlayerAvatar;
//                if( !avatarManager.isAvatar( playerId) ) {
//                    avatar = new PlayerAvatar( isPlayer( playerId ), playerId );
//                    avatarManager.addAvatar( avatar );
//                }
//                else {
//                    avatar = avatarManager.getAvatar( playerId );
//                }
//                
//                avatar.setLocation( location
//                 
//                
//                nonPlayer = ServerContext.vserver.getNonPlayer( playerId, this );
//                log.debug("handleSignalReceived() ", "e", e, "nonPlayer", nonPlayer, "nonPlayerManager", ServerContext.vserver.avatarManager);
//                //Get, or create the non-player
//                
//                //Update location and hotspot
//                nonPlayer.setLocation( location );
//                if( hotspot != null ) {
//                    nonPlayer.setHotspot( hotspot );
//                }
//                
//                
//                if( !ArrayUtil.contains( _nonPlayerIds, playerId )) {
//                    _nonPlayerIds.push( playerId );
//                }
//                setNonpPlayerIds( _nonPlayerIds );
//                
//                nonPlayer.setIntoRoomProps();
//                
//                nonPlayer.setRoomControlServer( _ctrl );
//                if( location == null ) {
//                    nonPlayer.setRoomControlServer( null );    
//                    ArrayUtil.removeAll( _nonPlayerIds, playerId );
//                }
//                else {
//                }
//                
                
                
//                log.debug("NonPlayers: (_nonPlayerIds=" + _nonPlayerIds + ")");
//                
//                log.debug("   after handleSignalReceived: (nonPlayerManager=" + ServerContext.vserver.avatarManager + ")");
                
                
                break;
//            case Constants.SIGNAL_NON_PLAYER_LEFT_ROOM:
//                playerId = int( e.value );
//                
//                nonPlayer = ServerContext.vserver.getNonPlayer( playerId, this );
//                //If the nonplayer was in this room, remove the ctrl, which will eventually destroy it.
//                //It takes a while, since we wait until the blood is regenerated, as the avatar
//                //might be moving between rooms.
//                if( nonPlayer.roomCtrl != null && nonPlayer.roomCtrl.getRoomId() == _ctrl.getRoomId() ) {
//                    nonPlayer.setRoomControlServer( null );
//                }
//                
//                break;
            default:
                break;
        }
    }
    
    override protected function destroyed () :void
    {
        //Remove the reference to ourselves from the non-players.
//        for each( var npId :int in _nonPlayerIds ) {
//            if( ServerContext.vserver.isNonPlayer( npId ) ) {
//                var np :PlayerAvatar = ServerContext.vserver.getNonPlayer( npId, this );
//                if( np.roomCtrl != null && np.roomCtrl.getRoomId() == roomId ) {
//                    np.setRoomControlServer( null );
//                }
//            } 
//        }
        
//        _nonplayerMonitor.destroySelf();
        
        _roomDB.shutdown();
        
        _ctrl = null;
        if (_players.size() != 0) {
            log.warning("Eek! Room unloading with players still here!",
                        "players", _players.values());
        } else {
            log.debug("Unloaded room", "roomId", roomId);
        }
    }
    
    protected function handlePlayerMoved( e :AVRGameRoomEvent ) :void
    {
        log.debug("handlePlayerMoved() " + e);
        
        
        _players.forEach( function(playerId :int, p :Player) :void {
            if( p.playerId == int(e.value)) {
               p.handleAvatarMoved(int(e.value) ); 
            }
        });
    }
    
//    protected function handleSignalReceived( e :AVRGameRoomEvent ) :void
//    {
//        log.debug("handleSignalReceived() " + e);
//        
//        
//        //Record all non-players movements.
//        if( e.name == Constants.SIGNAL_NON_PLAYER_MOVED ) {
//            var data :Array = e.value as Array;
//            var userId :int = int(data[0]);
//            var location :Array = data[1] as Array;
//            
//            if( location == null ) {
//                _entityLocations.remove( userId );
//            }
//            else {
//                _entityLocations.put( userId, location );
//            }
//                
//        }
//        
//        _players.forEach( function(playerId :int, p :Player) :void {
//           p.handleSignalReceived( e ); 
//        });
//    }
    
//    public function getLocation( userId :int ) :Array
//    {
//        if( ServerContext.vserver.isPlayerOnline( userId ) ) {
//            return ServerContext.vserver.getPlayer( userId ).location;
//        }
//        if( _entityLocations.containsKey( userId )) {
//            return _entityLocations.get( userId ) as Array;
//        }
//        return null;
//    }
    
    public function getCurrentBlood( userId :int ) :Number
    {
        if( ServerContext.vserver.isPlayerOnline( userId ) ) {
            return ServerContext.vserver.getPlayer( userId ).blood;
        }
        return ServerContext.nonPlayersBloodMonitor.bloodAvailableFromNonPlayer( userId );
    }
    
    public function getMaxBlood( userId :int ) :Number
    {
        if( ServerContext.vserver.isPlayerOnline( userId ) ) {
            return ServerContext.vserver.getPlayer( userId ).maxBlood;
        }
        return ServerContext.nonPlayersBloodMonitor.maxBloodFromNonPlayer( userId );
    }
    
    public function bloodBloomGameOver( gameRecord :BloodBloomGameRecord ) :void
    {
        log.debug("bloodBloomGameOver");
        var preyIsPlayer :Boolean = isPlayer( gameRecord._preyId );
        var victim :Player;
        if( preyIsPlayer ) {
            victim = getPlayer( gameRecord._preyId );
            if( victim.isVampire() ) {
                victim.damage( Constants.BLOOD_FRACTION_LOST_PER_FEED * victim.maxBlood );
            }
            else {
                victim.damage( Constants.BLOOD_LOSS_FROM_THRALL_OR_NONPLAYER_FROM_FEED );
            }
        }
        else {
            ServerContext.nonPlayersBloodMonitor.nonplayerLosesBlood( gameRecord._preyId, Constants.BLOOD_LOSS_FROM_THRALL_OR_NONPLAYER_FROM_FEED );
        }
        
        for each( var predatorId :int in gameRecord._predators.toArray()) {
            var pred :Player = getPlayer( predatorId );
            pred.mostRecentVictimId = gameRecord._preyId;
            pred.addBlood( 20 );
        }
    }
    
    public function handleFeedRequest(  e :FeedRequestMessage ) :void
    {
        
        _bloodBloomGameStarter.requestFeed( e.playerId, e.targetPlayer, e.isAllowingMultiplePredators );
        
//        var playerIds :Array = playerIds;
//        if( playerIds.length >= 2 ) {
//            _bloodBloomGameStarter.requestFeed( playerIds[0], playerIds[1] );
//            _bloodBloomGameStarter.predatorBeginsGame( playerIds[0] );
//        }
        
//        if( _players.size() == 2) {
//            _bloodBloomGameStarter.predatorBeginsGame( e.playerId );
//        }
        
//        if( isPlayerPredatorInBloodBloomGame( player.playerId )) {
//            return;
//        }
//        
//        
//        var victimId :int = getClosestVictim( player );
//        var victimLocation :Array = getLocation( victimId );
//        player.setTargetLocation( victimLocation );
//        player.setTargetId( victimId );
//        
//        player.ctrl.setAvatarLocation( victimLocation[0], victimLocation[1], victimLocation[2] , 1);
//        
//        //Join an existing feed
//        if( isPreyInBloodBloomGame( victimId )) {
//            
//        }
//        else {//Start your feed as leas predator
//        }
//        

    }
    
    

    

    
    public function get players() :HashMap
    {
        return _players;
    }
    
    public function getPlayer( playerId :int ) :Player
    {
        return _players.get( playerId ) as Player;
    }
    
    public function get playerIds() :Array
    {
        return _players.keys();
//        var ids :Array = new Array();
//        _players.forEach( function(playerId :int, p :Player) :void {
//            ids.push( p.playerId );
//        });
//        return ids;
    }
    
    public function get roomDB () :ObjectDBThane
    {
        return _roomDB;
    }
    
//    public function isPlayerPredatorInBloodBloomGame( playerId :int ) :Boolean
//    {
//        for each( var g :BloodBloomGameRecord in _bloodBloomGames) {
//            if( g.isPredator( playerId )) {
//                return true;
//            }    
//        }
//        return false;
//    }
//    
//    public function isPreyInBloodBloomGame( playerId :int ) :Boolean
//    {
//        for each( var g :BloodBloomGameRecord in _bloodBloomGames) {
//            if( g.isPrey( playerId )) {
//                return true;
//            }    
//        }
//        return false;
//    }
    
//    public function setNonpPlayerIds (ids :Array) :void
//    {
//        // update our runtime state
//        log.debug("setNonpPlayerIds( " + ids + "), _nonPlayerIds=" + _nonPlayerIds);
//        if ( ArrayUtil.equals(_nonPlayerIds, ids) && ids != null) {
//            log.warning("Er, why aren't we setting ids into room props?", "_nonPlayerIds", _nonPlayerIds, "ids", ids);
//            return;
//        }
//        _nonPlayerIds = ids;
//        // and if we're in a room, update the room properties
//        log.debug("Setting into room props( " + Codes.ROOM_PROP_NON_PLAYERS + ":" + _nonPlayerIds +")");
//        _ctrl.props.set(Codes.ROOM_PROP_NON_PLAYERS, _nonPlayerIds);
//    }
    
//    public function get location() :LocationTracker
//    {
//        return _locationTracker;
//    }
    
//    public function get nonPlayerAvatarIds() :Array
//    {
//        return location.nonPlayerAvatarIds;
//    }


    protected var _roomDB :ObjectDBThane = new ObjectDBThane();
    
    protected var _roomId :int;
    protected var _ctrl :RoomSubControlServer;

//    protected var _state :String;
    protected var _players :HashMap = new HashMap();
    
//    protected var _nonPlayerIds :Array = new Array();
    
//    public var _nonplayers :HashSet = new HashSet();
    
    public var _bloodBloomGameStarter :BloomBloomManager;
    
//    public var _bloodBloomGames :Array = new Array();
    
//    protected var _nonplayerMonitor :NonPlayerMonitor;
    
//    public var _locationTracker :LocationTracker;
    
//    protected var _entityLocations :HashMap = new HashMap();
    
//    protected var _playerEntityIds :HashSet = new HashSet();

    protected var _errorCount :int = 0;
    
    
    //temp signal fix
    protected var _avatarMovedSignalQueue :Array = new Array();

    // each player's contribution to a ghost's eventual defeat is accumulated here, by player
//    protected var _stats :HashMap = new HashMap();

    // a dictionary of dictionaries of number of times each minigame was used by each player
//    protected var _minigames :HashMap = new HashMap();

    // new ghost every 10 minutes -- force players to actually hunt for ghosts, not slaughter them
//    protected static const GHOST_RESPAWN_MINUTES :int = 10;
}
}
