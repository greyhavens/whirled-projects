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
import com.whirled.contrib.simplegame.server.ObjectDBThane;
import com.whirled.contrib.simplegame.server.SimObjectThane;

import vampire.Util;
import vampire.data.Codes;
import vampire.data.Logic;
import vampire.data.VConstants;
import vampire.net.messages.FeedRequestMessage2;

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
        return "Room [roomId=" + _roomId + ", playerIds=" + _players.keys() +"]";
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
        
        _players.put( player.playerId, player );
//        player.setIntoRoomProps();
        
        //Let the avatars know who is who, so they don't spam us with movement updates
//        ctrl.sendSignal( VConstants.SIGNAL_PLAYER_IDS, playerIds );

    }

    public function playerLeft (player :Player) :void
    {
//        _entityLocations.remove( player.playerId );
        
        if (!_players.remove(player.playerId)) {
            log.warning("Departing player did not exist in room", "roomId", this.roomId,
                        "playerId", player.playerId);
        }

        if (_ctrl == null) {
            log.warning("Null room control", "action", "player departing",
                        "playerId", player.playerId);
            return;
        }
        
        //Let the avatars know who is who, so they don't spam us with movement updates
//        ctrl.sendSignal( VConstants.SIGNAL_PLAYER_IDS, playerIds );
        
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
            _roomDB.update( dt );
            _players.forEach( function( playerId :int, p :Player) :void{ p.update(dt)});
            
            //Send feedback messages.
            if( _feedbackMessageQueue.length > 0 ) {
                _ctrl.props.set( Codes.ROOM_PROP_FEEDBACK, _feedbackMessageQueue.slice() );
                _feedbackMessageQueue.splice(0);
            }
            
            
//            _bloodBloomGameStarter.update( dt );

            //Send queued avatar movement messages.
//            var playersMoved :HashSet = new HashSet();
//            
//            while( _avatarMovedSignalQueue.length > 0 ) {
//                var data :Array = _avatarMovedSignalQueue.pop() as Array;
//                var userId :int = int(data[0]);
//                if( !playersMoved.contains( userId ) ) {
//                    playersMoved.add( userId );
//                    log.info("sending room message "  
//                        + VConstants.NAMED_EVENT_AVATAR_MOVED_SIGNAL_FROM_SERVER + " " + data);
//                    _ctrl.sendMessage( VConstants.NAMED_EVENT_AVATAR_MOVED_SIGNAL_FROM_SERVER, data);
//                    
//                }
//            }
            

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
        //WE don't update on direct changes, we wait for the server update to batch it.
        return;
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
            registerListener(_ctrl, AVRGameRoomEvent.ROOM_UNLOADED, destroy);
//            registerListener(_ctrl, AVRGameRoomEvent.PLAYER_MOVED, handlePlayerMoved);
//            registerListener(_ctrl, AVRGameRoomEvent.SIGNAL_RECEIVED, handleSignalReceived);
            
            _bloodBloomGameManager = new BloodBloomManager( this );
            _roomDB.addObject( _bloodBloomGameManager );
            
        }
    }
    
    public function destroy(...ignored):void
    {
        destroySelf();
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
//        _ctrl = null;
        if (_players.size() != 0) {
            log.warning("Eek! Room unloading with players still here!",
                        "players", _players.values());
        } else {
            log.debug("Unloaded room", "roomId", roomId);
        }
        _players.clear();
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
//        if( ServerContext.vserver.isPlayer( userId ) ) {
//            return ServerContext.vserver.getPlayer( userId ).location;
//        }
//        if( _entityLocations.containsKey( userId )) {
//            return _entityLocations.get( userId ) as Array;
//        }
//        return null;
//    }
    
    public function getCurrentBlood( userId :int ) :Number
    {
        if( ServerContext.vserver.isPlayer( userId ) ) {
            return ServerContext.vserver.getPlayer( userId ).blood;
        }
        return ServerContext.nonPlayersBloodMonitor.bloodAvailableFromNonPlayer( userId );
    }
    
    public function getMaxBlood( userId :int ) :Number
    {
        if( ServerContext.vserver.isPlayer( userId ) ) {
            return ServerContext.vserver.getPlayer( userId ).maxBlood;
        }
        return ServerContext.nonPlayersBloodMonitor.maxBloodFromNonPlayer( userId );
    }
    
    public function bloodBloomRoundOver( gameRecord :BloodBloomGameRecord ) :void
    {
        log.debug("bloodBloomRoundOver()", "gameRecord", gameRecord);
        
        if( gameRecord == null ) {
            log.error("bloodBloomRoundOver gameRecord==null");
            return;
        }
        if( gameRecord.gameServer == null ) {
            log.error("bloodBloomRoundOver gameRecord.gameServer==null");
            return;
        }
        
        if( gameRecord.gameServer.lastRoundScore == 0 ) {
            log.debug("score==0 so no blood lost or gained.");
            return;
        }
        
        //Update the highest possible score.  We use this to scale the coin payout
        ServerContext.topBloodBloomScore = Math.max( ServerContext.topBloodBloomScore, 
            gameRecord.gameServer.lastRoundScore );
              
        var preyIsPlayer :Boolean = isPlayer( gameRecord.preyId );
        var preyPlayer :Player;
        var damage :Number;
        //Handle the prey loss of blood
        if( preyIsPlayer ) {
            log.debug("Prey is player");
            preyPlayer = getPlayer( gameRecord.preyId );
            if( preyPlayer.isVampire() ) {
                damage = preyPlayer.damage( VConstants.BLOOD_FRACTION_LOST_PER_FEED * preyPlayer.maxBlood );
                addFeedback( "You lost " + Util.formatNumberForFeedback(damage) + " from feeding", preyPlayer.playerId);
            }
            else {
                damage = preyPlayer.damage( VConstants.BLOOD_LOSS_FROM_THRALL_OR_NONPLAYER_FROM_FEED );
            }
            
            var damageFormatted :String = Util.formatNumberForFeedback(damage);
            gameRecord.predators.forEach( function( predId :int) :void {
                var pred :Player = getPlayer( predId );
                if( pred != null ) {
                    addFeedback( preyPlayer.name + " lost " + damageFormatted + " from feeding", pred.playerId);
                }
                else {
                    log.error("gameRecord.predators.forEach() " + predId + " gives no player");
                }
            });
        }
        else {
            log.debug("Prey is nonplayer");
            damage = ServerContext.nonPlayersBloodMonitor.damageNonPlayer( gameRecord.preyId, VConstants.BLOOD_LOSS_FROM_THRALL_OR_NONPLAYER_FROM_FEED, roomId );
        }
        log.debug("Prey lost " + damage + " blood");
        
        //Predators gain blood from the prey
        var bloodGainedPerPredator :Number = damage / gameRecord.predators.size();
        var bloodGainedPerPredatorFormatted :String = Util.formatNumberForFeedback(bloodGainedPerPredator);
        
        for each( var predatorId :int in gameRecord.predators.toArray()) {
            var pred :Player = getPlayer( predatorId );
            if( pred == null ) {
                log.error("adding blood, but no pred", "predatorId", predatorId);
                continue;
            }
            pred.mostRecentVictimId = gameRecord.preyId;
            
            //The amount of blood gained depends on if the prey is a vampire
            var bloodGained :Number = bloodGainedPerPredator;
            if( preyIsPlayer && preyPlayer.isVampire() ) {
                bloodGained = Logic.bloodgGainedVampireVampireFeeding( pred.level, preyPlayer.level, bloodGained )
            }
            
            pred.addBlood( bloodGained );
            log.debug(predatorId + " gained " + bloodGained);
            addFeedback( pred.name + " gained " + Util.formatNumberForFeedback(bloodGained) + " from feeding", pred.playerId);
            
            if( preyIsPlayer && preyPlayer != null ) {
                
                //Check for new bloodbond formation
                //ATM it's just mutual feeding
                if( preyPlayer.mostRecentVictimId == predatorId ) {
                    
                    //Break previous bonds
                    
                    
                    preyPlayer.setBloodBonded( predatorId );//This also sets the name
                    pred.setBloodBonded( preyPlayer.playerId );
                    log.debug("Creating new bloodbond=" + pred.name + " + " + preyPlayer.name);
                    addFeedback( "You are now bloodbonded with " + pred.name, preyPlayer.playerId);
                    addFeedback( "You are now bloodbonded with " + preyPlayer.name, pred.playerId);
                }
                else {
                    log.debug("No bloodbond creation");
                }
                    
                //Check if the prey was a vampire, and we don't have a sire.  The prey vampire becomes it.
                if( pred.sire <= 0 && preyPlayer.isVampire() ) {
                    
                    if( Util.isProgenitor( preyPlayer.playerId ) || preyPlayer.sire > 0 ) {
                        pred.makeSire( preyPlayer.playerId );
                        addFeedback( preyPlayer.name + " has become your sire ", pred.playerId);

                        //Award coins to the sire
                        preyPlayer.ctrl.completeTask( Codes.TASK_ACQUIRE_MINION_ID, 
                            Codes.TASK_ACQUIRE_MINION_SCORE );
                        
                                                
                        for each( var sireId :int in 
                            ServerContext.minionHierarchy.getAllSiresAndGrandSires( pred.playerId ).toArray() ) {
                                
                            if( ServerContext.vserver.isPlayer( sireId ) 
                                && ServerContext.vserver.getPlayer( sireId ).room != null) {
                                
                                //Tell the sire she's got children
                                ServerContext.vserver.getPlayer( sireId ).room.addFeedback(    
                                    pred.name + " has become your minion ", sireId);
                                
                                //Award coins to the sire(s)
                                preyPlayer.ctrl.completeTask( Codes.TASK_ACQUIRE_MINION_ID, 
                                    Codes.TASK_ACQUIRE_MINION_SCORE/10 ); 
                            
                            }
                        }
                    }
                    else {
                        addFeedback( preyPlayer.name + " is not part of a lineage.  Feed from a vampire lineage member to join.", pred.playerId);
                        addFeedback( "You are not part of a lineage, so " + preyPlayer + " cannot join.", preyPlayer.playerId);
                    }
                }
                else {
                    log.debug("Already have sire, or prey not a vampire, so no sire creation");
                }
            }
            else {
                log.debug("Prey was not a player");
            }
        }
        
        //Then handle experience.  ATM everyone gets xp=score
        var xpGained :Number = gameRecord.gameServer.lastRoundScore;
        var xpFormatted :String = Util.formatNumberForFeedback( xpGained );
        
        function awardXP( playerId :int, xp :Number, xpFormatted :String ) :void
        {
            var p :Player = getPlayer( playerId );
            if( p != null ) {
                p.addXP( xp ); 
                addFeedback("You gained " + xpFormatted + " experience from feeding.", p.playerId); 
                //Add some bonus xp to your blood bond, if they are online
                ServerContext.vserver.awardBloodBondedXpEarned( p, xp );
                //Add some bonus xp to your sires
                ServerContext.vserver.awardSiresXpEarned( p, xp );
                var feedingScore :Number = gameRecord.gameServer.lastRoundScore / ServerContext.topBloodBloomScore
                p.ctrl.completeTask( Codes.TASK_FEEDING_ID, feedingScore );
            }
        }
        
        if( preyIsPlayer && preyPlayer != null) {
            
            if( preyPlayer.isVampire() ) {
                awardXP( gameRecord.preyId, xpGained, xpFormatted);
            }
            else {//If we are not a vampire, we don't share our xp 
                preyPlayer.addXP( xpGained );
                addFeedback("You gained " + xpFormatted + " experience from feeding.", preyPlayer.playerId);
            }
        }
            
        gameRecord.predators.forEach( function( predId :int) :void {
            awardXP( predId, xpGained, xpFormatted);
        });
        

        
        
    }
    
    
    protected function awardBloodBloomPoints( points :Number, prey :int, predators :Array ) :void
    {
        var bloodIncrement :Number = VConstants.BLOOD_LOSS_FROM_THRALL_OR_NONPLAYER_FROM_FEED;
        var bloodGained :Number = points;
        
        var victimId :int = -1;
        var victimsMostRecentFeedVictimId :int = -1;
        
        var victimBlood :Number = isPlayer( prey ) ? getPlayer( prey ).blood : 
            ServerContext.nonPlayersBloodMonitor.bloodAvailableFromNonPlayer( prey );
            
        var maxBlood :Number = isPlayer( prey ) ? getPlayer( prey ).maxBlood : 
            ServerContext.nonPlayersBloodMonitor.maxBloodFromNonPlayer( prey );
            
        var bloodLost :Number = Math.max( 0, victimBlood - 1);
        
        var bloodPerPredator :Number = bloodLost / predators.length;
        
        var pointsGained :Number = points * (bloodLost / maxBlood)
        
        var preyPlayer :Player = getPlayer( prey );
        if( preyPlayer != null ) {
            preyPlayer.damage( bloodLost );
            preyPlayer.addXP( pointsGained );
            ServerContext.vserver.awardSiresXpEarned( preyPlayer, pointsGained );
            
            addFeedback( "You lost " + bloodLost + " blood!", prey );
            addFeedback( "You gained " + pointsGained + " experience!", prey );
        }
        else {
            ServerContext.nonPlayersBloodMonitor.damageNonPlayer( prey, bloodLost, roomId );
        }
        
        
        for each( var predId :int in predators ) {
            var predPlayer :Player = getPlayer( predId );
            if( predPlayer == null) {
                log.error("Predator " + predId + " awarding points, but doesn't exist");
            }
            predPlayer.mostRecentVictimId = prey;
            predPlayer.addBlood( bloodPerPredator );
            predPlayer.addXP( pointsGained );
            ServerContext.vserver.awardSiresXpEarned( predPlayer, pointsGained );
            
            addFeedback( "You gained " + bloodPerPredator + " blood!", prey );
            addFeedback( "You gained " + pointsGained + " experience!", prey );
            
            
            if( preyPlayer != null && preyPlayer.mostRecentVictimId == predId) {
                //Become blood bonds
                
                predPlayer.setBloodBonded( prey );
                preyPlayer.setBloodBonded( predId );
                addFeedback( predPlayer.name + " is now Bloodbonded to you.", prey );
                addFeedback( preyPlayer.name + " is now Bloodbonded to you.", predId );
                
                log.info("Creating blood bonds between " + predPlayer.name + " and " + preyPlayer.name);
            }
            
            
            
//            //If there is not sufficient blood for another feed, break off feeding.
//            if( victim.blood <= 1) {
//                setAction( VConstants.GAME_MODE_NOTHING );
//                victim.setAction( VConstants.GAME_MODE_NOTHING );
//            }
                
        }
                   
        
    }
    
    
    
    public function handleFeedRequest(  e :FeedRequestMessage2 ) :void
    {
        

        
                        
                        
        //Arrange the players in order
        //For the first predator, move just behind the prey
//        if( game.predators.size() == 1 ) {
//            pred.ctrl.setAvatarLocation( e.targetX, e.targetY, e.targetZ , 1);
//        }
        
        
        
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
    
    public function addFeedback( msg :String, playerId :int = 0 ) :void
    {
        log.debug(playerId + " " + msg);
        _feedbackMessageQueue.push( [playerId, msg] );
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
    
    public var _bloodBloomGameManager :BloodBloomManager;
    
//    public var _bloodBloomGames :Array = new Array();
    
//    protected var _nonplayerMonitor :NonPlayerMonitor;
    
//    public var _locationTracker :LocationTracker;
    
//    protected var _entityLocations :HashMap = new HashMap();
    
//    protected var _playerEntityIds :HashSet = new HashSet();

    protected var _errorCount :int = 0;
    
    
    //temp signal fix
    protected var _avatarMovedSignalQueue :Array = new Array();
    
    /** 
    * Each value is a array with two values: the message target, and the message itself.  
    * A target <= 0 is a message for all.
    * 
    * */
    protected var _feedbackMessageQueue :Array = new Array();

    // each player's contribution to a ghost's eventual defeat is accumulated here, by player
//    protected var _stats :HashMap = new HashMap();

    // a dictionary of dictionaries of number of times each minigame was used by each player
//    protected var _minigames :HashMap = new HashMap();

    // new ghost every 10 minutes -- force players to actually hunt for ghosts, not slaughter them
//    protected static const GHOST_RESPAWN_MINUTES :int = 10;
}
}
