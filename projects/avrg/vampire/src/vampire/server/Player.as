//
// $Id$

package vampire.server {

import com.threerings.flash.MathUtil;
import com.threerings.util.ArrayUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.Hashable;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.avrg.PlayerSubControlServer;

import flash.utils.Dictionary;

import vampire.data.Codes;
import vampire.data.Constants;
import vampire.data.Logic;
import vampire.net.IGameMessage;
import vampire.net.messages.BloodBondRequestMessage;
import vampire.net.messages.FeedRequestMessage;
import vampire.net.messages.RequestActionChangeMessage;
import vampire.net.messages.SuccessfulFeedMessage;


public class Player
    implements Hashable
{

    public function Player (ctrl :PlayerSubControlServer)
    {
        if( ctrl == null ) {
            log.error("Bad!  Player(null).  What happened to the PlayerSubControlServer?  Expect random failures everywhere.");
            return;
        }
        log.info("\nPlayer() {{{");
        
        _ctrl = ctrl;
        _playerId = ctrl.getPlayerId();

        _ctrl.addEventListener(AVRGamePlayerEvent.ENTERED_ROOM, enteredRoom);
        _ctrl.addEventListener(AVRGamePlayerEvent.LEFT_ROOM, leftRoom);
        
        
        
        _action = Constants.GAME_MODE_NOTHING;
        
        _level = int(_ctrl.props.get(Codes.PLAYER_PROP_PREFIX_LEVEL));
        log.debug("Getting level=" + _level);


        var blood :Object = _ctrl.props.get(Codes.PLAYER_PROP_PREFIX_BLOOD);
        if (blood != null) {
            _blood = Number(blood);

        } else {
            // blood should always be set if level is set, but let's play it safe
//            log.debug("Repairing player blood", "playerId", ctrl.getPlayerId());
            log.debug("   setting blood=" + Constants.MAX_BLOOD_FOR_LEVEL( this.level ));
            setBlood(Constants.MAX_BLOOD_FOR_LEVEL( this.level ), true);
        }
        log.debug("Getting blood="+_blood);
        
        var bloodbonded :Object = _ctrl.props.get(Codes.PLAYER_PROP_PREFIX_BLOODBONDED);
        if (bloodbonded != null) {
            _bloodbonded = bloodbonded as Array;
            if( _bloodbonded == null) {
                log.error("Despite the bloodbonded key containing something, it's not an array.  Setting bloodbonded=[]");
                _bloodbonded = [];
            }

        } else {
            // bloodbonded should at least be an empty array
//            log.debug("Repairing player bloodbonded", "playerId", ctrl.getPlayerId());
            log.debug("   setting bloodbonded=[]");
            setBloodBonded([]);
        }
        log.debug("Getting bloodbonded=" + _bloodbonded);
        
        log.debug("Getting ", "time", new Date(_ctrl.props.get(Codes.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE)).toTimeString());
        _timePlayerPreviouslyQuit = Number(_ctrl.props.get(Codes.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE));
        if( _timePlayerPreviouslyQuit == 0) {
            log.info("Repairing", "time", _ctrl.props.get(Codes.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE));
            var time :Number = new Date().time;
            setTime(time);
            log.info("  now", "time", _ctrl.props.get(Codes.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE));
        }
        
        var minions :Object = _ctrl.props.get(Codes.PLAYER_PROP_PREFIX_MINIONS);
        if (minions != null) {
            _minions = minions as Array;
            if( _minions == null) {
                log.error("Despite the minions key containing something, it's not an array.  Setting _minions=[]");
                _minions = [];
            }

        } else {
            // bloodbonded should at least be an empty array
//            log.debug("Repairing player bloodbonded", "playerId", ctrl.getPlayerId());
            log.debug("   setting _minions=[]");
            setMinions([]);
        }
        log.debug("Getting minions=" + _minions);
        
        _sire = int(_ctrl.props.get(Codes.PLAYER_PROP_PREFIX_SIRE));
        
        if( _sire == 0 ) {
            _sire = -1;
        }
        log.debug("Getting sire=" + _sire);
        
        
        _xp = int(_ctrl.props.get(Codes.PLAYER_PROP_PREFIX_XP));
        
        if( level > 1 && _xp <  Logic.levelGivenCurrentXp(_xp)) {
            _xp = Logic.xpNeededForLevel(level);
        }
        
        log.debug("Getting xp=" + _xp);
        
        
        
        
        
        //For testing purposes testing
        if( playerId == 35282) {
            setLevel( 0, true);
        }
        
//        if( !isVampire() ) {//If you are not a vampire, you must be fed upon.
//            setBlood( 0, true );
//        }
        
        if (level == 0) {
            log.debug("Player has never player before ", "playerId", ctrl.getPlayerId());
            setLevel(1, true);
            setBloodBonded([]);
            setBlood( 0 );
            setXP( 0 );
            setSire( VServer.getSireFromInvitee( _playerId ) );
            setTime( 1 );//O means no props loaded, 1 means new player
            
        } 
        
        setAction( Constants.GAME_MODE_NOTHING );
        

//        log.debug("Setting blood at 10%, blood=" + maxBlood * 0.1);
//        setBlood( blood, true);
        
        //If we have previously been awake, reduce our blood proportionally to the time since we last played.
        if( time > 1) {
            var date :Date = new Date();
            var now :Number = date.time;
            var millisecondsSinceLastAwake :Number = now - time;
            if( millisecondsSinceLastAwake < 0) {
                log.error("Computing time since last awake, but < 0, now=" + now + ", time=" + time);
            }
            var hoursSinceLastAwake :Number = millisecondsSinceLastAwake / (1000*60*60);
            log.debug("hoursSinceLastAwake=" + hoursSinceLastAwake);
            log.debug("secondSinceLastAwake=" + (millisecondsSinceLastAwake/1000));
            var bloodReduction :Number = Constants.BLOOD_LOSS_HOURLY_RATE_WHILE_SLEEPING * hoursSinceLastAwake * maxBlood;
            log.debug("bloodReduction=" + bloodReduction);
            bloodReduction = Math.min( bloodReduction, this.blood - 1);
            sendChat( "Blood lost during sleep: " + bloodReduction);
            damage( bloodReduction );
            
//            log.debug("bloodnow=" + bloodnow, "in props", blood);
            
        }
        else {
            log.debug("We have not played before, so not computing blood reduction");
        }

        log.info("Logging in", "playerId", playerId, "blood", blood, "maxBlood",
                 maxBlood, "level", level, "sire", sire, "minions", minions, "time", new Date(time).toTimeString());
            
            
//        _closestUserData = null;
        
        if (_room != null) {
            _room.playerUpdated(this);
        }
        
        
        log.debug("end of Player()=" + toString());
        log.info("end }}}\n");
        
        
        
        
        
        
    }
    
    public function sendChat( msg :String ) :void
    {
        log.debug("Sending CHAT: " + msg);
        _ctrl.sendMessage( Constants.NAMED_EVENT_CHAT, msg); 
    }

    public function get ctrl () :PlayerSubControlServer
    {
        return _ctrl;
    }

    public function get playerId () :int
    {
        return _playerId;
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
        return Player(other).playerId == _playerId;
    }

    // from Hashable
    public function hashCode () :int
    {
        return _playerId;
    }

    public function toString () :String
    {
        return "Player [playerId=" + _playerId + ", roomId=" +
            (room != null ? room.roomId : "null") + ", level=" + level + ", blood=" + blood + "/" + maxBlood + ", bloodbonds=" + bloodbonded 
            + ", sire=" + sire
            + ", minions=" + minions
            + ", xp=" + xp
            + ", time=" + new Date(time).toTimeString() 
//            + ", closestUserData=" + closestUserData
            + "]";
    }

    public function isDead () :Boolean
    {
        return blood <= 0;
    }

    public function shutdown () :void
    {
        log.debug( Constants.DEBUG_MINION + " Player shutdown, on database=" + toString());
        
        log.info("\nshutdown() {{{", "player", toString());
        log.debug("hierarchy=" + ServerContext.minionHierarchy);
        
        
        var currentTime :Number = new Date().time;
        log.info("shutdown()", "currentTime", new Date(currentTime).toTimeString());
        setTime( currentTime, true );
        
        log.info("before player shutdown", "time", new Date(_ctrl.props.get( Codes.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE)).toTimeString());
//        setAction( Constants.GAME_MODE_NOTHING, true );
        setIntoRoomProps( room );
        _ctrl.removeEventListener(AVRGamePlayerEvent.ENTERED_ROOM, enteredRoom);
        _ctrl.removeEventListener(AVRGamePlayerEvent.LEFT_ROOM, leftRoom);
        log.info("end of player shutdown", "time", new Date(_ctrl.props.get( Codes.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE)).toTimeString());
//        log.info("props actually in the database", "props", new SharedPlayerStateServer(_ctrl.props).toString());
        log.info("}}}");
    }

    public function damage (damage :Number) :void
    {
//        log.debug("Damaging player", "playerId", _playerId, "damage", damage, "blood", _blood);

        // let the clients in the room know of the attack
//        _room.ctrl.sendMessage(Codes.SMSG_PLAYER_ATTACKED, _playerId);
        // play the reel animation for ourselves!
//        _ctrl.playAvatarAction("Reel");

        setBlood(blood - damage); // note: setBlood clamps this to [0, maxBlood]
    }

    public function addBlood (amount :Number) :void
    {
//        if (!isDead()) {
            setBlood(blood + amount); // note: setBlood clamps this to [0, maxBlood]
//        }

//        if( blood >= maxBlood) {
//            increaseLevel();
//        }
    }
    
    public function increaseLevel() :void
    {
        var newlevel :int = level + 1;
        log.debug("Increasing level", "oldlevel", level, "newlevel", newlevel);
        setLevel( newlevel );
        setBlood( 0.1 * maxBlood );//Also updates the room
        
        // always update our avatar state
        updateAvatarState();

        // and if we're in a room, update the room properties
        if (_room != null) {
            _room.playerUpdated(this);
        }
    }
    
    public function removeBlood (amount :Number) :void
    {
        if (!isDead()) {
            setBlood(blood - amount); // note: setBlood clamps this to [0, maxBlood]
        }
    }
    
    protected function setBlood (blood :Number, force :Boolean = false) :void
    {
        // update our runtime state
//        blood = MathUtil.clamp(blood, 0, maxBlood);
        blood = MathUtil.clamp(blood, 0, maxBlood);
        if (!force && blood == _blood) {
            return;
        }
        
        _blood = blood;
//        log.debug("Persisting blood in player props");
        // persist it, too
        _ctrl.props.set(Codes.PLAYER_PROP_PREFIX_BLOOD, _blood, true);
        
        // always update our avatar state
        updateAvatarState();

        // and if we're in a room, update the room properties
        if (_room != null) {
            _room.playerUpdated(this);
        }
    }
    
    protected function setXP (xp :Number, force :Boolean = false) :void
    {
        // update our runtime state
        if (!force && xp == _xp) {
            return;
        }
        
        _xp = xp;
        // persist it, too
        _ctrl.props.set(Codes.PLAYER_PROP_PREFIX_XP, _xp, true);
        
        // always update our avatar state
        updateAvatarState();

        // and if we're in a room, update the room properties
        if (_room != null) {
            _room.playerUpdated(this);
        }
    }
    
    protected function addXP( bonus :int) :void
    {
        // update our runtime state
        _xp += bonus;
        // persist it, too
        _ctrl.props.set(Codes.PLAYER_PROP_PREFIX_XP, _xp, true);
        
        //Check if we made a new level
        if( _level != Logic.levelGivenCurrentXp( _xp )) {
            _level = Logic.levelGivenCurrentXp( _xp );
            _ctrl.props.set(Codes.PLAYER_PROP_PREFIX_LEVEL, _level, true);
            
            _blood = 0.1 * maxBlood;
            _ctrl.props.set(Codes.PLAYER_PROP_PREFIX_BLOOD, _blood, true);
        }
        
        // always update our avatar state
        updateAvatarState();

        // and if we're in a room, update the room properties
        if (_room != null) {
            _room.playerUpdated(this);
        }
    }
    
    protected function setAction (action :String, force :Boolean = false) :void
    {
        // update our runtime state
        if (!force && action == _action) {
            return;
        }
        
        _action = action;

        // Don't bother persisting it
        
        // always update our avatar state
        updateAvatarState();

        // and if we're in a room, update the room properties
        if (_room != null) {
            _room.playerUpdated(this);
        }
    }
    
    public function setName (name :String, force :Boolean = false) :void
    {
        // update our runtime state
        if (!force && name == _name) {
            return;
        }
        _name = name;
        
        // persist it, too
        _ctrl.props.set(Codes.PLAYER_PROP_PREFIX_NAME, _name, true);
        
        updateAvatarState();
        
        // and if we're in a room, update the room properties
        if (_room != null) {
            _room.playerUpdated(this);
        }
    }

    public function roomStateChanged () :void
    {
        updateAvatarState();
    }

    // called from Server
    public function handleMessage (name :String, value :Object) :void
    {
        // handle messages that make (at least some) sense even if we're between rooms
        log.debug("handleMessage() ", "name", name, "value", value);
        if( name == Constants.NAMED_EVENT_BLOOD_UP ) {
            addBlood(20 );
        }
        else if( name == Constants.NAMED_EVENT_BLOOD_DOWN ) {
            damage( 20 );
//            setBlood( blood - 20 );
        }
        else if( name == Constants.NAMED_EVENT_FEED ) {
            feed(int(value));
        }
        else if( name == Constants.NAMED_EVENT_MAKE_SIRE ) {
            makeSire(int(value));
        }
        else if( name == Constants.NAMED_EVENT_MAKE_MINION ) {
            makeMinion(int(value));
        }
        else if( name == Constants.NAMED_EVENT_QUIT ) {
            var now :Number = new Date().time;
            setTime( now , true);
        }
        
        else if( value is IGameMessage) {
            
            if( value is RequestActionChangeMessage) {
                handleRequestActionChange( RequestActionChangeMessage(value) );
            }
            else if( value is BloodBondRequestMessage) {
                handleBloodBondRequest( BloodBondRequestMessage(value) );
            }
            else if( value is FeedRequestMessage) {
                handleFeedRequestMessage( FeedRequestMessage(value) );
            }
            else if( value is SuccessfulFeedMessage) {
                handleSuccessfulFeedMessage( SuccessfulFeedMessage(value) );
            }
            else {
                log.debug("Cannot handle IGameMessage ", "player", playerId, "type", value );
                log.debug("  Classname=" + ClassUtil.getClassName(value) );
            }
        }
        
    }
    
    protected function handleSuccessfulFeedMessage( e :SuccessfulFeedMessage ) :void
    {
        var bloodIncrement :Number = Constants.BLOOD_LOSS_FROM_THRALL_OR_NO_FROM_FEED;
        var bloodGained :Number = 0;
        
        
        if( !isVampire() || action != Constants.GAME_MODE_FEED || e.eatenPlayerId == 0) {
            log.error("handleSuccessfulFeedMessage, but not a vampire or feeding, or eaten==0.", "SuccessfulFeedMessage", e);
            return;
        }
        
        //Different result depending if victim is human (playing the game or not), or vampire.
        if( !room.isPlayer(e.eatenPlayerId)) {//Vampire feeding from a non-player
            log.warning("handleSuccessfulFeedMessage " + e);
            bloodGained = bloodIncrement;
            ServerContext.nonPlayers.playerFeedsFromNonPlayer( this, e.eatenPlayerId, bloodGained);
                   
            //Update the room properties that show other players blood         
            setTargetBlood( ServerContext.nonPlayers.bloodAvailableFromNonPlayer( e.eatenPlayerId ) );
            setTargetMaxBlood( Constants.MAX_BLOOD_NONPLAYERS );
            
        }
        else {
            
            var victim :Player = VServer.getPlayer( e.eatenPlayerId );
            if( victim == null ) {
                log.error("handleSuccessfulFeedMessage,no victim.", "SuccessfulFeedMessage", e);
                return;
            }
            
            log.warning("handleSuccessfulFeedMessage " + e);
            if( victim.isVampire()) {
                //You can only take blood that they have to give
                var bloodTakenFromVampire :Number = Logic.bloodLostPerFeed( victim.level);
                
                if( victim.blood < bloodTakenFromVampire + 1) {
                    bloodTakenFromVampire = victim.blood - 1;
                }
                victim.damage( bloodTakenFromVampire );
                bloodGained = Logic.bloodgGainedVampireVampireFeeding( level, victim.level, bloodTakenFromVampire);
                
                //If there is not sufficient blood for another feed, break off feeding.
                if( victim.blood <= 1) {
                    setAction( Constants.GAME_MODE_NOTHING );
                    victim.setAction( Constants.GAME_MODE_NOTHING );
                }
                
                //Update the room properties that show other players blood         
                setTargetBlood( victim.blood );
                setTargetMaxBlood( victim.maxBlood );
            }
            else {//Human thrall.  They get 'blood' too, except it isn't blood.  It's wannabe vampire juice
//                log.warning(" added joy ");

                var bloodTakenFromThrall :Number = bloodIncrement;
                if( victim.blood < bloodTakenFromThrall + 1) {
                    bloodTakenFromThrall = victim.blood - 1;
                }
                victim.damage( bloodTakenFromThrall );
                victim.addXP( Constants.XP_GAINED_FROM_FEEDING_PER_BLOOD_UNIT * bloodTakenFromThrall);
                bloodGained = bloodTakenFromThrall;
                
                //If there is not sufficient blood for another feed, break off feeding.
                if( victim.blood <= 1) {
                    setAction( Constants.GAME_MODE_NOTHING );
                    victim.setAction( Constants.GAME_MODE_NOTHING );
                }
                
                //Update the room properties that show other players blood         
                setTargetBlood( victim.blood );
                setTargetMaxBlood( victim.maxBlood );
                
            }
            
        }
        
        if( bloodGained > 0) {
            addBlood( bloodGained );
            addXP( Constants.XP_GAINED_FROM_FEEDING_PER_BLOOD_UNIT * bloodGained);
        }
        setTargetVisible(true, true);
    }
    protected function makeSire(targetPlayerId :int ) :void
    {
        log.info("makeSire(" + targetPlayerId + ")");
        ServerContext.minionHierarchy.setPlayerSire( playerId, targetPlayerId);
        
        setMinions( ServerContext.minionHierarchy.getMinionIds( playerId ).toArray() );
        setSire( ServerContext.minionHierarchy.getSireId( playerId ) ); 
//        if( ServerContext.minionHierarchy.getSire( targetPlayerId ) == playerId) {
//            ServerContext.minionHierarchy.setPlayerSire( targetPlayerId, -1);    
//        }

        VServer.updateHierarchyInAllRooms();
//        room.ctrl.props.set( Codes.ROOM_PROP_MINION_HIERARCHY, ServerContext.minionHierarchy.toBytes() );
//        sendChat( ServerContext.minionHierarchy.toString() );
        
    }
    
    protected function makeMinion(targetPlayerId :int ) :void
    {
        log.info("makeMinion(" + targetPlayerId + ")");
        ServerContext.minionHierarchy.setPlayerSire( targetPlayerId, playerId);
        
        setMinions( ServerContext.minionHierarchy.getMinionIds( playerId ).toArray() );
        setSire( ServerContext.minionHierarchy.getSireId( playerId ) );
        
        VServer.updateHierarchyInAllRooms();
//        room.ctrl.props.set( Codes.ROOM_PROP_MINION_HIERARCHY, ServerContext.minionHierarchy.toBytes() );
//        sendChat( ServerContext.minionHierarchy.toString() );
    }
    
    protected function feed(targetPlayerId :int ) :void
    {
        var eaten :Player = VServer.getPlayer( targetPlayerId );
        if( eaten == null) {
            log.warning("feed( " + targetPlayerId + " ), player is null");
            return;
        }
        
        
        if( eaten.action != Constants.GAME_MODE_EAT_ME) {
            log.warning("feed( " + targetPlayerId + " ), eatee is not in mode=" + Constants.GAME_MODE_EAT_ME);
            return;
        }
        
        if( eaten.blood <= 1) {
            log.warning("feed( " + targetPlayerId + " ), eatee has only blood=" + eaten.blood);
            return;
        }
        
        var bloodEaten :Number = 10;
        if( eaten.blood <= 10) {
            bloodEaten = eaten.blood - 1;
        }
        log.debug("Sucessful feed.");
        addBlood( bloodEaten );
        VServer.playerGainedBlood( this, bloodEaten, targetPlayerId);
        eaten.removeBlood( bloodEaten );
    }
    
    /**
    * Handle a feed request.
    */
    protected function handleFeedRequestMessage( e :FeedRequestMessage) :void
    {
        var targetPlayer :Player = VServer.getPlayer( e.targetPlayer );
        var isTargetVictim :Boolean = e.isTargetPlayerTheVictim;
        
        
    }
    
    
    /**
    * Here we check if we are allowed to change action.
    * ATM we just allow it.
    */
    protected function handleBloodBondRequest( e :BloodBondRequestMessage) :void
    {
        var targetPlayer :Player = VServer.getPlayer( e.targetPlayer );
        
        if( targetPlayer == null) {
            log.debug("Cannot perform blood bond request unless both players are in the same room");
            return;
        }
        
        if( e.add ) {
            addBloodBond( e.targetPlayer, e.targetPlayerName, true );
            if( targetPlayer != null) {
                targetPlayer.addBloodBond( playerId, ServerContext.getPlayerName(playerId), true );
            }
            else {
                log.error("You can't add a blood bond to an offline ");
                
//                VServer.control.loadOfflinePlayer(e.targetPlayer, 
//                    function (props :PropertySpaceObject) :void {
//                        
//                        var bloodbonds :Array = props.getUserProps().get( Codes.PLAYER_PROP_PREFIX_BLOODBONDED) as Array;
//                        if( bloodbonds == null) {
//                            bloodbonds = new Array();
//                        }
//                        bloodbonds.push( playerId );
//                        bloodbonds.push( target_ctrl. );
//                        props.getUserProps().set(Codes.PLAYER_PROP_PREFIX_BLOODBONDED, bloodbonds); 
//                    }, 
//                    function (failureCause :String) :void { 
//                        log.warning("Eek! Sending message to offline player failed!", "cause", failureCause); 
//                    });
                
            }
        }
        else {
            removeBloodBond( e.targetPlayer, true );
            
            if( targetPlayer != null) {
                targetPlayer.removeBloodBond( playerId, true );
            }
            else {
                log.error("You can't remove a blood bond to an offline ");
//                VServer.control.loadOfflinePlayer(e.targetPlayer, 
//                    function (props :PropertySpaceObject) :void {
//                        
//                        var bloodbonds :Array = props.getUserProps().get( Codes.PLAYER_PROP_PREFIX_BLOODBONDED) as Array;
//                        if( bloodbonds == null) {
//                            bloodbonds = new Array();
//                        }
//                        if( ArrayUtil.contains( bloodbonds, e.targetPlayer)) {
//                            bloodbonds.splice( ArrayUtil.indexOf( bloodbonds, e.targetPlayer), 1);
//                        }
//                        props.getUserProps().set(Codes.PLAYER_PROP_PREFIX_BLOODBONDED, bloodbonds); 
//                    }, 
//                    function (failureCause :String) :void { 
//                        log.warning("Eek! Sending message to offline player failed!", "cause", failureCause); 
//                    });
                
            }
            
            
        }
    }
    
    
    public function addBloodBond( blondbondedPlayerId :int, playerName :String, force :Boolean = false ) :void
    {
        if( !force && ArrayUtil.contains( bloodbonded, blondbondedPlayerId) ) {
            return;
        }
        var bloodbonded :Array = this.bloodbonded;
        if( !ArrayUtil.contains( bloodbonded, blondbondedPlayerId) ) {
            bloodbonded.push( blondbondedPlayerId );
            bloodbonded.push( playerName );
        }
        
        setBloodBonded( bloodbonded );
        
        updateAvatarState();

        // and if we're in a room, update the room properties
        if (_room != null) {
            _room.playerUpdated(this);
        }
    }
    
    public function removeBloodBond( blondbondedPlayerId :int, force :Boolean = false ) :void
    {
        if( !force && !ArrayUtil.contains( bloodbonded, blondbondedPlayerId) ) {
            return;
        }
        var bloodbonded :Array = this.bloodbonded;
        if( ArrayUtil.contains( bloodbonded, blondbondedPlayerId) ) {
            bloodbonded.splice( ArrayUtil.indexOf( bloodbonded, blondbondedPlayerId), 2 );
        }
        setBloodBonded( bloodbonded );
        
        updateAvatarState();

        // and if we're in a room, update the room properties
        if (_room != null) {
            _room.playerUpdated(this);
        }
    }
    
    
    
    
    
    
    /**
    * Here we check if we are allowed to change action.
    * ATM we just allow it.
    */
    protected function handleRequestActionChange( e :RequestActionChangeMessage) :void
    {
        log.debug("handleRequestActionChange(..), e.action=" + e.action);
        setAction( e.action );
    }


    protected function enteredRoom (evt :AVRGamePlayerEvent) :void
    {
        
        log.info("\nPlayer entered room {{{", "player", toString());
        log.debug("hierarchy=" + ServerContext.minionHierarchy);
        
        log.debug( Constants.DEBUG_MINION + " Player enteredRoom, already on the database=" + toString());
        log.debug( Constants.DEBUG_MINION + " Player enteredRoom, hierarch=" + ServerContext.minionHierarchy);
        
        var thisPlayer :Player = this;
        _room = VServer.getRoom(int(evt.value));
        VServer.control.doBatch(function () :void {
            _room.playerEntered(thisPlayer);
            ServerContext.minionHierarchy.playerEnteredRoom( this, _room);
            updateAvatarState();
        });

        log.debug("after _room.playerEntered");
        log.debug("hierarchy=" + ServerContext.minionHierarchy);
        log.info("player" + toString());
        log.info("}}}");
        
    }
    
    public function handleSignalReceived( e :AVRGameRoomEvent ) :void
    {
        //Update the target information. Propagate to the client.
        if( e.name == Constants.SIGNAL_CLOSEST_ENTITY) {
            var signalArray :Array = e.value as Array;
            if( signalArray != null && signalArray.length >= 2 && signalArray[0] == playerId) {
                log.debug(name + " handleSignalReceived() " + e);
                
                var closestUserId :int = int(signalArray[1]);
                var closestUserName :String = String(signalArray[2]);
                var closestUserLocation :Array = signalArray[3] as Array;
                var closestUserHeight :Number = Number(signalArray[4]);
                var targetLocation :Array = signalArray[5] as Array;
                if( closestUserId > 0 ) {
                    //Only change target if this player is not involved in an action 
                    //that requires maintaining the current target.
                    
                    switch( action ) {
                        
                        case Constants.GAME_MODE_FEED:
                        case Constants.GAME_MODE_BLOODBOND:
                        case Constants.GAME_MODE_EAT_ME:
                            //Update the target data if our target has moved, but don't change 
                            //our target
                            if( closestUserId == targetId) {
                                setTargetLocation( closestUserLocation );
                                setTargetHeight( closestUserHeight );
                                setTargetName( closestUserName );
                            }
                            else {
                                setTargetLocation( targetLocation );
                            }
                            setTargetVisible(true, true);
                            break;
                            
                        default://Otherwise, change our target
                            setTargetId( closestUserId );
                            if( room != null) {
                                room.ctrl.sendSignal( Constants.SIGNAL_PLAYER_TARGET, [playerId, targetId]);
                            }
                            setTargetLocation( closestUserLocation );
                            setTargetHeight( closestUserHeight );
                            setTargetName( closestUserName );
                            
                            var targetsBlood :Number;
                            var targetsMaxBlood :Number;
                            if( room.isPlayer( closestUserId )) {
                                var targetPlayer :Player = VServer.getPlayer(closestUserId);
                                if( targetPlayer != null) {
                                    targetsBlood = targetPlayer.blood;
                                    targetsMaxBlood = targetPlayer.maxBlood;
                                }
                                else {
                                    log.error("handleSignalReceived(), new target=" + closestUserId + ", should be a player, but player from server is null");
                                }
                            }
                            else {//Target is non-player
                                targetsBlood = ServerContext.nonPlayers.bloodAvailableFromNonPlayer( closestUserId );
                                targetsMaxBlood = Constants.MAX_BLOOD_NONPLAYERS;
                            }
                            
                            setTargetBlood( targetsBlood );
                            setTargetMaxBlood( targetsMaxBlood );
                            setTargetVisible(true, true);
                            break;
                    }
                }
                else {//There is no-one closest.  That means remove the target
                    setTargetVisible(false, true);
                }
            }
        }
    }
    
    
    public function isVampire() :Boolean
    {
        return level >= Constants.MINIMUM_VAMPIRE_LEVEL;
    }

    protected function leftRoom (evt :AVRGamePlayerEvent) :void
    {
        var thisPlayer :Player = this;
        VServer.control.doBatch(function () :void {
            _room.playerLeft(thisPlayer);
        });
        if (_room != null) {
            if (_room.roomId == evt.value) {
                _room = null;
            } else {
                log.warning("The room we're supposedly leaving is not the one we think we're in",
                            "ourRoomId", _room.roomId, "eventRoomId", evt.value);
            }
        }
    }

    protected function handleDebugRequest (request :String) :void
    {
        log.info("Incoming debug request", "request", request);

        // just send back the original request to indicate it was handled successfully
//        ctrl.sendMessage(Codes.SMSG_DEBUG_RESPONSE, request);
    }



//    protected function setPlaying (playing :Boolean, force :Boolean = false) :void
//    {
//        if (!force && playing == _playing) {
//            return;
//        }
//        _playing = playing;
//        
//        _ctrl.props.set(Codes.PROP_IS_PLAYING, _playing, true);
//    }

    
    
    /**
    * Vampires lose blood when asleep.  The game does not update vampires e.g. hourly, 
    * rather, computes the blood loss from when they last played.
    * 
    * Blood is also accumulated from minions exploits, so this may not be that dramatic for older vampires.
    */
    protected function updateBloodFromStartingNewGame() :void
    {
//        if( level >= Constants.MINIMUM_VAMPIRE_LEVEL) {
//            var previousTimeAwake :int = int(_ctrl.props.get(Codes.PLAYER_PROP_PREFIX_PREVIOUS_TIME_AWAKE));
//            var now :int = getTimer();
//            var hoursAsleep :Number = (((now - previousTimeAwake) / 1000) / 60) / 60.0;
//            var currentBlood :int = blood;
//            currentBlood -= hoursAsleep * Constants.BLOOD_LOSS_HOURLY_RATE * maxBlood;
//            currentBlood = Math.max(1, currentBlood);
//            setBlood( currentBlood );
//        }
    }

    public function get room () :Room
    {
        return _room;
    }
    
    protected function updateAvatarState () :void
    {
        if (_room == null) {
            return;
        }
        else {
            _ctrl.setAvatarState(_action);
        }
    }
    
//    public function setStateToPlayerProps() :void
//    {
//        var state :SharedPlayerStateServer = sharedPlayerState;
//        log.debug("Setting state to props=" + state);
//        _ctrl.props.set(Codes.PLAYER_FULL_STATE_KEY, state.toBytes());
//        
//        //if we're in a room, update the room properties
//        if (_room != null) {
//            _room.playerUpdated(this);
//        }
//    }
    
    
//    /**
//    * Saved to room properties and distributed to the clients.
//    */
//    public function get sharedPlayerState () :SharedPlayerStateServer
//    {
//        var state :SharedPlayerStateServer = new SharedPlayerStateServer();
//        
//        state._playerId = hashCode();
//        state.level = level;
//        state.blood = blood;
//        state.maxBlood = maxBlood;
//        
//        return state;
//    }
    
    
//    /**
//    * The full state of the  
//    * Saved to permanent properties, and distributed to the room, but not updated 
//    * as often as the shared player state.
//    */
//    public function get fullPlayerState () :SharedPlayerStateServer
//    {
//        var state :FullPlayerState = new FullPlayerState();
//        
//        state._playerId = hashCode();
//        state.level = level;
//        state.blood = blood;
//        state.maxBlood = maxBlood;
//        
//        return state;
//    }
    
    public function setIntoRoomProps( room :Room ) :void
    {
        if( room == null || room.ctrl == null) {
            log.error("setIntoRoomProps() but ", "room", room);
            return;
        }
            
        var key :String = Codes.ROOM_PROP_PREFIX_PLAYER_DICT + playerId;
        
        var dict :Dictionary = room.ctrl.props.get(key) as Dictionary;
        if (dict == null) {
            dict = new Dictionary(); 
        }

        if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_LEVEL] != level) {
            room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_LEVEL, level);
        }
        if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD] != blood) {
            room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD, blood);
        }
//        if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_MAX_BLOOD] != maxBlood) {
//            room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_MAX_BLOOD, maxBlood);
//        }
        
        if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_ACTION] != action) {
            room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_ACTION, action);
        }
        
        if (!ArrayUtil.equals( dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED], bloodbonded )) {
            room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED, bloodbonded);
        }
        
//        if (!ArrayUtil.equals( dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_MINIONS], minions )) {
//            room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_MINIONS, minions);
//        }
        
//        if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_SIRE] != sire) {
//            room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_SIRE, sire);
//        }
        
        if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_PREVIOUS_TIME_AWAKE] != time) {
            log.info("Setting into room props", "time", new Date(time).toTimeString());
            room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_PREVIOUS_TIME_AWAKE, time);
        }
        if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP] != xp) {
            room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP, xp);
        }
        
//        if (!ArrayUtil.equals(dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_CLOSEST_USERID], closestUserData)) {
//            room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_CLOSEST_USERID, closestUserData);
//        }
//        
        
        //Target and closest user properties
        if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_ID] != targetId) {
            room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_ID, targetId);
        }
        if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_NAME] != targetName) {
            room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_NAME, targetName);
        }
        if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_HEIGHT] != targetHeight) {
            room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_HEIGHT, targetHeight);
        }
        if (!ArrayUtil.equals( dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_LOCATION], targetLocation )) {
            room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_LOCATION, targetLocation);
        }
        if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_BLOOD] != targetBlood) {
            room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_BLOOD, targetBlood);
        }
        if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_MAXBLOOD] != targetMaxBlood) {
            room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_MAXBLOOD, targetMaxBlood);
        }
        if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_DISPLAY_VISIBLE] != isTargetVisible) {
            room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_DISPLAY_VISIBLE, isTargetVisible);
        }    
            
            
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    public function setLevel (level :int, force :Boolean = false) :void
    {
        // update our runtime state
        if (!force && level == _level) {
            return;
        }
        _level = level;

        // persist it, too
        _ctrl.props.set(Codes.PLAYER_PROP_PREFIX_LEVEL, _level, true);
        
        updateAvatarState();

        // and if we're in a room, update the room properties
        if (_room != null) {
            _room.playerUpdated(this);
        }
    }
    
    public function setTargetVisible (targetVisible :Boolean, force :Boolean = false) :void
    {
        // update our runtime state
        if (!force && targetVisible == _isTargetVisible) {
            return;
        }
        _isTargetVisible = targetVisible;

//        updateAvatarState();

        // and if we're in a room, update the room properties
        if (_room != null) {
            _room.playerUpdated(this);
        }
    }
    
    
    
    
    public function setTargetId (id :int, force :Boolean = false) :void
    {
        // update our runtime state
        if (!force && id == _targetId) {
            return;
        }
        _targetId = id;
        
//        updateAvatarState();
//
//        // and if we're in a room, update the room properties
//        if (_room != null) {
//            _room.playerUpdated(this);
//        }
    }
    
    public function setTargetName (name :String, force :Boolean = false) :void
    {
        // update our runtime state
        if (!force && name == _targetName) {
            return;
        }
        _targetName = name;
        
//        updateAvatarState();

        // and if we're in a room, update the room properties
//        if (_room != null) {
//            _room.playerUpdated(this);
//        }
    }
    
    public function setTargetHeight (height :Number, force :Boolean = false) :void
    {
        // update our runtime state
        if (!force && _targetHeight == height) {
            return;
        }
        _targetHeight = height;
        
//        updateAvatarState();
//
//        // and if we're in a room, update the room properties
//        if (_room != null) {
//            _room.playerUpdated(this);
//        }
    }
    
    /**
    * Only changes the (HUD) view of the targets blood, not the actual value.
    */
    public function setTargetBlood (targetBlood :Number, force :Boolean = false) :void
    {
        // update our runtime state
        if (!force && _targetBlood == targetBlood) {
            return;
        }
        _targetBlood = targetBlood;
        
//        updateAvatarState();
//
//        // and if we're in a room, update the room properties
//        if (_room != null) {
//            _room.playerUpdated(this);
//        }
    }
    
    public function setTargetMaxBlood (targetMaxBlood :Number, force :Boolean = false) :void
    {
        // update our runtime state
        if (!force && _targetMaxBlood == targetMaxBlood) {
            return;
        }
        _targetMaxBlood = targetMaxBlood;
        
//        updateAvatarState();
//
//        // and if we're in a room, update the room properties
//        if (_room != null) {
//            _room.playerUpdated(this);
//        }
    }
    
    public function setTargetLocation (location :Array, force :Boolean = false) :void
    {
        // update our runtime state
        if (!force && ArrayUtil.equals(_targetLocation, location)) {
            return;
        }
        _targetLocation = location;
        
//        updateAvatarState();
//
//        // and if we're in a room, update the room properties
//        if (_room != null) {
//            _room.playerUpdated(this);
//        }
    }
    
    public function setClosestUserId (id :int) :void
    {
        _closestUserId = id;
//        if (!force && id == _closestUserId) {
//            return;
//        }
//        
//        updateAvatarState();
//
//        // and if we're in a room, update the room properties
//        if (_room != null) {
//            _room.playerUpdated(this);
//        }
    }
    public function setClosestUserName (name :String) :void
    {
        _closestUserName = name;
//        // update our runtime state
//        if (!force && name == _closestUserName) {
//            return;
//        }
//        
//        updateAvatarState();
//
//        // and if we're in a room, update the room properties
//        if (_room != null) {
//            _room.playerUpdated(this);
//        }
    }
    

    
//    public function setClosestUserData(userData :Array, force :Boolean = false) :void
//    {
//        log.info("setClosestUserData()", "userData", userData);
//        // update our runtime state
//        if (!force && ArrayUtil.equals(userData, _closestUserData)) {
//            return;
//        }
//        _closestUserData = userData;
//
//        // persist it, too
//        _ctrl.props.set(Codes.PLAYER_PROP_PREFIX_CLOSEST_USER_DATA, _closestUserData, true);
//        log.info("afterwards ", "closestUserData", _ctrl.props.get(Codes.PLAYER_PROP_PREFIX_CLOSEST_USER_DATA));
//    }
    
    
    public function setClosestAvatarHeight (height :Number, force :Boolean = false) :void
    {
        // update our runtime state
        if (!force && time == _timePlayerPreviouslyQuit) {
            return;
        }
        _targetHeight = time;

        // persist it, too
        _ctrl.props.set(Codes.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE, _timePlayerPreviouslyQuit, true);
        log.info("now ", "time", new Date(_ctrl.props.get(Codes.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE)).toTimeString());
    }
    
    
    public function setTime (time :Number, force :Boolean = false) :void
    {
        log.info("setTime()", "time", new Date(time).toTimeString());
        
        // update our runtime state
        if (!force && time == _timePlayerPreviouslyQuit) {
            return;
        }
        _timePlayerPreviouslyQuit = time;

        // persist it, too
        _ctrl.props.set(Codes.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE, _timePlayerPreviouslyQuit, true);
        log.info("now ", "time", new Date(_ctrl.props.get(Codes.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE)).toTimeString());
    }
    
//    public function addBloodBond( blondbondedPlayerId :int ) :void
//    {
//        if( ArrayUtil.contains( _bloodbonded, blondbondedPlayerId) ) {
//            return;
//        }
//        _bloodbonded.push( blondbondedPlayerId );
//        setBloodBonded( _bloodbonded, true );
//    }
//    
//    public function removeBloodBond( blondbondedPlayerId :int ) :void
//    {
//        if( !ArrayUtil.contains( _bloodbonded, blondbondedPlayerId) ) {
//            return;
//        }
//        _bloodbonded.splice( ArrayUtil.indexOf( _bloodbonded, blondbondedPlayerId), 1 );
//        setBloodBonded( _bloodbonded, true );
//    }
    
    public function setBloodBonded (bloodbonded :Array) :void
    {
        _bloodbonded = bloodbonded;
        // persist it, too
        _ctrl.props.set(Codes.PLAYER_PROP_PREFIX_BLOODBONDED, _bloodbonded, true);
    }
    
    public function setMinions (minions :Array) :void
    {
        _minions = minions;
        // persist it, too
        _ctrl.props.set(Codes.PLAYER_PROP_PREFIX_MINIONS, _minions, true);
    }
    
    public function setSire (sire :int, force :Boolean = false) :void
    {
        // update our runtime state
        if (!force && sire == _sire) {
            return;
        }
        _sire = sire;

        // persist it, too
        log.debug("setSire", "sire", sire);
        _ctrl.props.set(Codes.PLAYER_PROP_PREFIX_SIRE, _sire, true);
        log.debug("setSire after ", "sire", _ctrl.props.get(Codes.PLAYER_PROP_PREFIX_SIRE));
    }
    
    public function get action () :String
    {
        return _action;
    }
    
    public function get name () :String
    {
        return _name;
    }
    
    public function get level () :int
    {
        return _level;
    }
    
    public function get xp () :int
    {
        return _xp;
    }
    
    public function get blood () :Number
    {
        return _blood;
    }
    
    public function get isTargetVisible () :Boolean
    {
        return _isTargetVisible;
    }
    
    
    
    public function get maxBlood () :Number
    {
        return Constants.MAX_BLOOD_FOR_LEVEL( level );
    }
    
    public function get bloodbonded () :Array
    {
        return _bloodbonded.slice();
    }
    
    public function get minions () :Array
    {
        return _minions.slice();
    }
    
    public function get sire () :int
    {
        return _sire;
    }
    
//    public function get closestUserData () :Array
//    {
//        return _closestUserData;
//    }
    
    public function get targetId() :int
    {
        return _targetId;
    }
    public function get targetName() :String
    {
        return _targetName;
    }
    public function get targetHeight() :Number
    {
        return _targetHeight;
    }
    public function get targetLocation() :Array
    {
        return _targetLocation;
    }
    public function get targetBlood() :Number
    {
        return _targetBlood;
    }
    public function get targetMaxBlood() :Number
    {
        return _targetMaxBlood;
    }
    

    
    public function get closestUserId() :int
    {
        return _closestUserId;
    }
    public function get closestUserName() :String
    {
        return _closestUserName;
    }
    
    public function get time () :Number
    {
        return _timePlayerPreviouslyQuit;
    }
    
    public function tick( dt :Number) :void
    {
        //Vampires lose blood
        if( isVampire() ) {
            damage( dt * Constants.VAMPIRE_BLOOD_LOSS_RATE);
        }
        //Thralls regenerate blood
        else {
            addBlood( dt * Constants.THRALL_BLOOD_REGENERATION_RATE);
        }
        
        //Update target blood
        if( targetId > 0 && room != null) {
            if( !room.isPlayer(targetId)) {//Nom a non-player
                setTargetBlood( ServerContext.nonPlayers.bloodAvailableFromNonPlayer( targetId ) );
                setTargetMaxBlood( Constants.MAX_BLOOD_NONPLAYERS );
            }
            else {
                var targetPlayer :Player = VServer.getPlayer( targetId );
                if( targetPlayer != null ) {
                    setTargetBlood( targetPlayer.blood );
                    setTargetMaxBlood( targetPlayer.maxBlood );
                }
                else {
                    log.error("tick, null target player, although there shouldn't be");
                }
            }       
        }
    }
    
    
    protected var _name :String;
    protected var _level :int;
    protected var _blood :Number;
    protected var _xp :Number;
    protected var _action :String;
    
    protected var _bloodbonded :Array;
    
    protected var _sire :int;
    protected var _minions :Array;
    
    protected var _timePlayerPreviouslyQuit :Number;

    protected var _targetId :int;
    protected var _targetName :String;
    protected var _targetLocation :Array;
    protected var _targetHeight :Number;
    protected var _targetBlood :Number;
    protected var _targetMaxBlood :Number;
    protected var _isTargetVisible :Boolean;//Show the target overlay?
    
    protected var _closestUserName :String;
    protected var _closestUserId :int;
    
    
    protected var _timeSinceLastBloodRegenerate :Number;//In seconds









    protected var _room :Room;
    protected var _ctrl :PlayerSubControlServer;
    protected var _playerId :int;
//    protected var _sharedState :SharedPlayerStateServer;
    
//    protected var _level :int;
//    protected var _blood :int;
//    protected var _maxBlood :int;
//    protected var _playing :Boolean;
    
    protected static const log :Log = Log.getLog( Player );
//    protected var _minions
}
}
