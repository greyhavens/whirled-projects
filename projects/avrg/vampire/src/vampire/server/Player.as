//
// $Id$

package vampire.server {

import com.threerings.flash.MathUtil;
import com.threerings.flash.Vector2;
import com.threerings.util.ArrayUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.Hashable;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.OfflinePlayerPropertyControl;
import com.whirled.avrg.PlayerSubControlServer;
import com.whirled.contrib.EventHandlerManager;

import flash.utils.ByteArray;
import flash.utils.Dictionary;

import vampire.Util;
import vampire.client.events.PlayerArrivedAtLocationEvent;
import vampire.data.Codes;
import vampire.data.Logic;
import vampire.data.VConstants;
import vampire.feeding.PlayerFeedingData;
import vampire.net.IGameMessage;
import vampire.net.messages.BloodBondRequestMessage;
import vampire.net.messages.FeedRequestMessage2;
import vampire.net.messages.NonPlayerIdsInRoomMessage;
import vampire.net.messages.RequestActionChangeMessage;
import vampire.net.messages.ShareTokenMessage;

/**
 * Actions:
 *  When baring, your avatar goes into the
 */
public class Player extends EventHandlerManager
    implements Hashable
{

    public function Player (ctrl :PlayerSubControlServer)

    {
        if( ctrl == null ) {
            log.error("Bad!  Player(null).  What happened to the PlayerSubControlServer?  Expect random failures everywhere.");
            return;
        }

        _ctrl = ctrl;
        _playerId = ctrl.getPlayerId();

        registerListener( _ctrl, AVRGamePlayerEvent.ENTERED_ROOM, enteredRoom);
        registerListener( _ctrl, AVRGamePlayerEvent.LEFT_ROOM, leftRoom);


        //Start in the default state
        _action = VConstants.GAME_MODE_NOTHING;



        //Get last time awake
        log.debug("Getting ", "time", new Date(_ctrl.props.get(Codes.PLAYER_PROP_LAST_TIME_AWAKE)).toTimeString());
        _timePlayerPreviouslyQuit = Number(_ctrl.props.get(Codes.PLAYER_PROP_LAST_TIME_AWAKE));



        //Get experience
        _xp = Number(_ctrl.props.get(Codes.PLAYER_PROP_XP));
        if( isNaN( _xp )) {
            setXP( 0 );
        }

        log.debug("Getting xp=" + _xp);

        //Get blood
        _blood = Number(_ctrl.props.get(Codes.PLAYER_PROP_BLOOD));
        if(_timePlayerPreviouslyQuit == 0) {
            // blood should always be set if level is set, but let's play it safe
            log.debug("   setting blood=" + VConstants.MAX_BLOOD_FOR_LEVEL( 1));
            setBlood(VConstants.MAX_BLOOD_FOR_LEVEL( 1 ));

        }

        //In the current game, we don't let you die.
        if( _blood < 1 ) {
            setBlood( 1 );
        }


        log.debug("Getting blood="+_blood);

        //Get bloodbonded data
        _bloodbonded = int( _ctrl.props.get(Codes.PLAYER_PROP_BLOODBONDED));
        if( _bloodbonded > 0) {
            _bloodbondedName = _ctrl.props.get(Codes.PLAYER_PROP_BLOODBONDED_NAME) as String;
        }
        log.debug("Getting bloodbonded=" + _bloodbonded);



        _sire = int(_ctrl.props.get(Codes.PLAYER_PROP_SIRE));

        log.debug("Getting sire=" + _sire);

        setAction( VConstants.GAME_MODE_NOTHING );

        //If we have previously been awake, reduce our blood proportionally to the time since we last played.
        log.debug("Getting time=" + time);
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
            var bloodReduction :Number = VConstants.BLOOD_LOSS_HOURLY_RATE_WHILE_SLEEPING * hoursSinceLastAwake * maxBlood;
            log.debug("bloodReduction=" + bloodReduction);
            bloodReduction = Math.min( bloodReduction, this.blood - 1);
            addFeedback( "Blood lost during sleep: " + Util.formatNumberForFeedback(bloodReduction));
            damage( bloodReduction );

//            log.debug("bloodnow=" + bloodnow, "in props", blood);

        }
        else {
            log.debug("We have not played before, so not computing blood reduction");
        }

        log.info("Logging in", "playerId", playerId, "blood", blood, "maxBlood",
                 maxBlood, "level", level, "sire", sire, "time", new Date(time).toTimeString());

        //Create feeding data if there is none
        if( _ctrl.props.get(Codes.PLAYER_PROP_FEEDING_DATA) == null ) {
            var feedingData :PlayerFeedingData = new PlayerFeedingData();
            _ctrl.props.set(Codes.PLAYER_PROP_FEEDING_DATA, feedingData.toBytes() );
        }

        //Load/Create minionIds
        _minionsForTrophies = _ctrl.props.get(Codes.PLAYER_PROP_MINIONIDS) as Array;
        if( _minionsForTrophies == null ) {
            _minionsForTrophies = new Array();
        }

        _inviteTally = int(_ctrl.props.get(Codes.PLAYER_PROP_INVITES));

        updateAvatarState();

    }

    public function addFeedback( msg :String ) :void
    {
        if( _room != null ) {
            _room.addFeedback( msg, playerId );
        }
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
        return "Player [playerId=" + _playerId
            + ", name=" + name
            + ", roomId=" +
            (room != null ? room.roomId : "null") + ", level=" + level + ", blood=" + blood + "/" + maxBlood + ", bloodbonds=" + bloodbonded
            + ", targetId=" + targetId
            + ", sire=" + sire
            + ", xp=" + xp
            + ", time=" + new Date(time).toTimeString()
            + "]";
    }

    public function isDead () :Boolean
    {
        return blood <= 0;
    }

    public function shutdown () :void
    {
        freeAllHandlers();
//        log.debug( Constants.DEBUG_MINION + " Player shutdown, on database=" + toString());

//        log.info("\nshutdown() {{{", "player", toString());
//        log.debug("hierarchy=" + ServerContext.minionHierarchy);


        var currentTime :Number = new Date().time;
//        log.info("shutdown()", "currentTime", new Date(currentTime).toTimeString());
        setTime( currentTime, true );
        setSire( ServerContext.minionHierarchy.getSireId( playerId ) );
//        log.info("before player shutdown", "time", new Date(_ctrl.props.get( Codes.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE)).toTimeString());
        setAction( VConstants.GAME_MODE_NOTHING );
        updateAvatarState();
        setIntoPlayerProps();
//        setIntoRoomProps();
//        _ctrl.removeEventListener(AVRGamePlayerEvent.ENTERED_ROOM, enteredRoom);
//        _ctrl.removeEventListener(AVRGamePlayerEvent.LEFT_ROOM, leftRoom);
//        log.info("end of player shutdown", "time", new Date(_ctrl.props.get( Codes.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE)).toTimeString());
//        log.info("props actually in the database", "props", new SharedPlayerStateServer(_ctrl.props).toString());
//        log.info("}}}");
    }

    /**
    * Returns actual damage.  If feeding, always have 1 left over.
    */
    public function damage (damage :Number, isFeeding :Boolean = true) :Number
    {

        var actualDamage :Number = (blood - 1) >= damage ? damage : blood - 1;

        setBlood(blood - damage); // note: setBlood clamps this to [0, maxBlood]

        return actualDamage;

    }

    public function addBlood (amount :Number) :void
    {
        setBlood(blood + amount); // note: setBlood clamps this to [0, maxBlood]
    }

    public function increaseLevel() :void
    {
        var xpNeededForNextLevel :Number = Logic.xpNeededForLevel( level + 1 );
        log.debug("xpNeededForNextLevel" + xpNeededForNextLevel);
        var missingXp :Number = xpNeededForNextLevel - xp;
        log.debug("missingXp" + missingXp);
        addXP( missingXp );
        ServerContext.vserver.awardSiresXpEarned( this, missingXp );
    }

    public function decreaseLevel() :void
    {
        if( level > 1 ) {
            var xpNeededForCurrentLevel :int = Logic.xpNeededForLevel( level );
            var missingXp :Number = -(xp - xpNeededForCurrentLevel) - 1;
            addXP( missingXp )
        }
    }

    public function removeBlood (amount :Number) :void
    {
        if (!isDead()) {
            setBlood(blood - amount); // note: setBlood clamps this to [0, maxBlood]
        }
    }

    public function setBlood (blood :Number) :void
    {
        blood = MathUtil.clamp(blood, 1, maxBlood);
        _blood = blood;
    }

    protected function setXP (xp :Number) :void
    {
        _xp = xp;
        _xp = Math.min( _xp, Logic.maxXPGivenXPAndInvites(_xp, invites));
    }


    public function addXP( bonus :Number) :void
    {
        var currentLevel :int = Logic.levelGivenCurrentXpAndInvites( xp, invites );


        _xp += bonus;
        _xp = Math.max( _xp, 0);
        var newLevel :int = Logic.levelGivenCurrentXpAndInvites( xp, invites );
//        var maxXpForCurrentLevel :int = Logic.xpNeededForLevel( newLevel + 1 );

        _xp = Math.min( _xp, Logic.maxXPGivenXPAndInvites(_xp, invites));

        if( newLevel > currentLevel) {
            _blood = Math.min( _blood, 0.1 * maxBlood);
        }

        var levelWithMaxInvites :int = Logic.levelGivenCurrentXpAndInvites( xp, 100000 );
        if( levelWithMaxInvites > newLevel ) {
            var invitesNeededForNextLevel :int = Logic.invitesNeededForLevel( newLevel + 1 );
            invitesNeededForNextLevel = Math.max(0, invitesNeededForNextLevel - invites );
            addFeedback("You've reached level " + newLevel + ", but your Lineage isn't diverse "
            + "enough to handle your growing power.  Recruit " + invitesNeededForNextLevel +
            " new player" + (invitesNeededForNextLevel > 1 ? "s":"")
            + " from outside Whirled to support your new potency.");
        }

        //"



        // update our runtime state
        // persist it, too
//        _ctrl.props.set(Codes.PLAYER_PROP_XP, _xp, true);

//        var newLevel :int = Logic.levelGivenCurrentXpAndInvites( xp );
        //Check if we made a new level
//        if( newLevel > currentLevel) {
////            _level = Logic.levelGivenCurrentXp( _xp );
////            _ctrl.props.set(Codes.PLAYER_PROP_PREFIX_LEVEL, _level, true);
//
//            _blood = 0.1 * maxBlood;
////            _ctrl.props.set(Codes.PLAYER_PROP_BLOOD, _blood, true);
//        }

//        if( newLevel < currentLevel && blood > maxBlood) {
////            _ctrl.props.set(Codes.PLAYER_PROP_BLOOD, maxBlood, true);
//        }

        //If our vampire state changed, send a message to the avatar
//        if( isVampire() != vampireState) {
//            handleChangeColorScheme( (isVampire() ? VConstants.COLOR_SCHEME_VAMPIRE : VConstants.COLOR_SCHEME_HUMAN) );
//        }

//        addFeedback( "You gained " + bonus + " experience points!" );


        // always update our avatar state
//        updateAvatarState();

        // and if we're in a room, update the room properties
//        if (_room != null) {
//            _room.playerUpdated(this);
//        }
    }

    public function setAvatarState (s :String, force :Boolean = false) :void
    {
        _avatarState = s;
    }
    public function setAction (action :String) :void
    {
        _action = action;
    }

    public function setName (name :String) :void
    {
        _name = name;
    }

    public function roomStateChanged () :void
    {
        updateAvatarState();
    }

    // called from Server
    public function handleMessage (name :String, value :Object) :void
    {
        try{
            if( value is NonPlayerIdsInRoomMessage ) {
                return;
            }
            // handle messages that make (at least some) sense even if we're between rooms
            log.debug(playerId + " handleMessage() ", "name", name, "value", value);

            if( name == VConstants.NAMED_EVENT_BLOOD_UP ) {
                addBlood(20 );
            }
            else if( name == VConstants.NAMED_EVENT_BLOOD_DOWN ) {
                damage( 20 );
            }

            if( name == VConstants.NAMED_EVENT_ADD_XP ) {
                addXP( 500 );
            }
            else if( name == VConstants.NAMED_EVENT_LOSE_XP ) {
                addXP( -500 );
            }
            else if( name == VConstants.NAMED_EVENT_LEVEL_UP ) {
                increaseLevel();
            }
            else if( name == VConstants.NAMED_EVENT_LEVEL_DOWN ) {
                decreaseLevel();
            }
            else if( name == VConstants.NAMED_EVENT_ADD_INVITE ) {
                _inviteTally++;
            }
            else if( name == VConstants.NAMED_EVENT_LOSE_INVITE ) {
                _inviteTally = Math.max(0, _inviteTally--);
            }
            else if( name == VConstants.NAMED_EVENT_FEED ) {
                feed(int(value));
            }
            else if( name == VConstants.NAMED_EVENT_MAKE_SIRE ) {
                makeSire(int(value));
            }
            else if( name == VConstants.NAMED_EVENT_MAKE_MINION ) {
                makeMinion(int(value));
            }
            else if( name == VConstants.NAMED_EVENT_QUIT ) {
                var now :Number = new Date().time;
                setTime( now , true);
            }
            else if( name == PlayerArrivedAtLocationEvent.PLAYER_ARRIVED ) {

                log.debug(playerId + " message " + PlayerArrivedAtLocationEvent.PLAYER_ARRIVED);
                if( action == VConstants.GAME_MODE_MOVING_TO_FEED_ON_PLAYER ) {
                    log.debug(playerId + " changing to " + VConstants.GAME_MODE_FEED_FROM_PLAYER);
                    actionChange( VConstants.GAME_MODE_FEED_FROM_PLAYER );
                }
                else if( action == VConstants.GAME_MODE_MOVING_TO_FEED_ON_NON_PLAYER ){
                    log.debug(playerId + " changing to " + VConstants.GAME_MODE_FEED_FROM_NON_PLAYER);
                    actionChange( VConstants.GAME_MODE_FEED_FROM_NON_PLAYER );
                }

            }
            else if( name == VConstants.NAMED_EVENT_UPDATE_FEEDING_DATA ) {
                var bytes :ByteArray = value as ByteArray;
                if( bytes != null) {
                    //Not sure if ByteArray comparison is meaningful or efficient
//                    if( _ctrl.props.get( Codes.PLAYER_PROP_FEEDING_DATA ) != bytes ) {
                        log.debug("Setting new feeding data");
                        _ctrl.props.set( Codes.PLAYER_PROP_FEEDING_DATA, bytes );
//                    }
                }
            }
            else if( name == VConstants.NAMED_EVENT_SHARE_TOKEN ) {
                var inviterId :int = int( value );
                log.debug( playerId + " received inviter id=" + inviterId);
                if( sire == 0 ) {
                    log.info( playerId + " setting sire=" + inviterId);
                    makeSire( inviterId );
                    //Tally the successful invites for trophies
                    ServerContext.vserver.playerInvitedByPlayer( playerId, inviterId );
                }
                else {
                    log.warning("handleShareTokenMessage, but our sire is already != 0" );
                }
            }
            else if( name == VConstants.NAMED_MESSAGE_CHOOSE_FEMALE ) {
                trace(VConstants.NAMED_MESSAGE_CHOOSE_FEMALE + " awarding female");
                _ctrl.awardPrize( Trophies.BASIC_AVATAR_FEMALE );
                setTimeToCurrentTime();
            }
            else if( name == VConstants.NAMED_MESSAGE_CHOOSE_MALE ) {
                trace(VConstants.NAMED_MESSAGE_CHOOSE_MALE + " awarding male");
                _ctrl.awardPrize( Trophies.BASIC_AVATAR_MALE );
                setTimeToCurrentTime();
            }

            else if( value is IGameMessage) {

                if( value is RequestActionChangeMessage) {
                    handleRequestActionChange( RequestActionChangeMessage(value) );
                }
                else if( value is BloodBondRequestMessage) {
                    handleBloodBondRequest( BloodBondRequestMessage(value) );
                }
                else if( value is FeedRequestMessage2) {
                    handleFeedRequestMessage( FeedRequestMessage2(value) );
                }
                else if( value is ShareTokenMessage) {
                    handleShareTokenMessage( ShareTokenMessage(value) );
                }
                else {
                    log.debug("Cannot handle IGameMessage ", "player", playerId, "type", value );
                    log.debug("  Classname=" + ClassUtil.getClassName(value) );
                }
            }
        }
        catch( err :Error ) {
            log.error(err.getStackTrace());
        }

    }

    protected function setTimeToCurrentTime() :void
    {
        var currentTime :Number = new Date().time;
        setTime( currentTime, true );
    }

    protected function handleShareTokenMessage( e :ShareTokenMessage ) :void
    {
        var inviterId :int = e.inviterId;
        log.debug( playerId + " received inviter id=" + inviterId);
        if( sire != 0 ) {
            log.info( playerId + " setting sire=" + inviterId);
            setSire( inviterId );
        }
        else {
            log.warning("handleShareTokenMessage, but our sire != 0", "e", e );
        }
    }
    protected function handleFeedRequestMessage( e :FeedRequestMessage2 ) :void
    {
        var game :BloodBloomGameRecord;

        if( action == VConstants.GAME_MODE_BARED ) {
            setAction( VConstants.GAME_MODE_NOTHING );
            return;
        }

        if( !isVampire() ) {
            if( e.targetPlayer == 0 ) {
                //Practise feeding
                //Add ourselves to a game.  We'll check this later, when we arrive at our location
                game = _room._bloodBloomGameManager.requestFeed(
                    e.playerId,
                    -1,
                    false,
                    [0, 0, 0] );//Prey location
                game.startGame();
            }
            else {
                addFeedback("Only Vampires may feed.");
                return;
            }
        }
        else {

            //Set info useful for later
            setTargetId( e.targetPlayer );
            setTargetLocation( [e.targetX, e.targetY, e.targetZ] );


            //Add ourselves to a game.  We'll check this later, when we arrive at our location
            game = _room._bloodBloomGameManager.requestFeed(
                e.playerId,
                (e.targetPlayer != 0 ? e.targetPlayer : -1),//BB used -1 as the AI player
                e.isAllowingMultiplePredators,
                [e.targetX, e.targetY, e.targetZ] );//Prey location


            if( !game.isStarted ) {

                if( _room.isPlayer( e.targetPlayer ) ) {
                    actionChange( VConstants.GAME_MODE_MOVING_TO_FEED_ON_PLAYER );
                }
                else {
                    actionChange( VConstants.GAME_MODE_MOVING_TO_FEED_ON_NON_PLAYER );
                }
            }
        }

    }


    public function makeSire(targetPlayerId :int ) :void
    {
        if( targetPlayerId == sire) {
            return;
        }
        var oldSire :int = sire;
        log.info(playerId + " makeSire(" + targetPlayerId + ")");


        ServerContext.minionHierarchy.setPlayerSire( playerId, targetPlayerId);
        log.info(playerId + " then setting sire(" + ServerContext.minionHierarchy.getSireId( playerId ) + ")");
        setSire( ServerContext.minionHierarchy.getSireId( playerId ) );

//        ServerContext.minionHierarchy.updatePlayer( targetPlayerId );
        ServerContext.minionHierarchy.updatePlayer( playerId );
//        ServerContext.minionHierarchy.updateIntoRoomProps();

        if( oldSire > 0 ) {
            ServerContext.minionHierarchy.updatePlayer( oldSire );
        }
    }

    protected function makeMinion(targetPlayerId :int ) :void
    {
        log.info("makeMinion(" + targetPlayerId + ")");
        ServerContext.minionHierarchy.setPlayerSire( targetPlayerId, playerId);

        setSire( ServerContext.minionHierarchy.getSireId( playerId ) );

        ServerContext.minionHierarchy.updatePlayer( playerId );
//        ServerContext.minionHierarchy.updateIntoRoomProps();
    }

    protected function feed(targetPlayerId :int ) :void
    {
        var eaten :Player = ServerContext.vserver.getPlayer( targetPlayerId );
        if( eaten == null) {
            log.warning("feed( " + targetPlayerId + " ), player is null");
            return;
        }


        if( eaten.action != VConstants.GAME_MODE_BARED) {
            log.warning("feed( " + targetPlayerId + " ), eatee is not in mode=" + VConstants.GAME_MODE_BARED);
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
        ServerContext.vserver.playerGainedBlood( this, bloodEaten, targetPlayerId);
        eaten.removeBlood( bloodEaten );
    }



    /**
    * Here we check if we are allowed to change action.
    * ATM we just allow it.
    */
    protected function handleBloodBondRequest( e :BloodBondRequestMessage) :void
    {
        var targetPlayer :Player = ServerContext.vserver.getPlayer( e.targetPlayer );

        if( targetPlayer == null) {
            log.debug("Cannot perform blood bond request unless both players are in the same room");
            return;
        }

        if( e.add ) {

            setBloodBonded( e.targetPlayer )
        }
    }


    protected function handleRequestActionChange( e :RequestActionChangeMessage) :void
    {
        log.debug("handleRequestActionChange(..), e.action=" + e.action);
        actionChange( e.action );
    }

    /**
    * Here we check if we are allowed to change action.
    * ATM we just allow it.
    */
    public function actionChange( newAction :String ) :void
    {
        log.debug("actionChange(" + newAction + ")");
        var angleRadians :Number;
        var degs :Number;
        var game :BloodBloomGameRecord;
        var predLocIndex :int;
        var newLocation :Array;
        var targetX :Number;
        var targetY :Number;
        var targetZ :Number;

        switch( newAction ) {
            case VConstants.GAME_MODE_BARED:

                //If I'm feeding, just break off the feed.
                if( _room._bloodBloomGameManager.isPredatorInGame( playerId )) {
                    _room._bloodBloomGameManager.playerQuitsGame( playerId );
                    setAction( VConstants.GAME_MODE_NOTHING );
                    break;
                }

                //If we are alrady in bare mode, toggle it, unless we are in a game.
                //Then we should quit the game to get out of bared mode
                if( action == VConstants.GAME_MODE_BARED ) {
                    if( !_room._bloodBloomGameManager.isPreyInGame( playerId )) {
                        setAction( VConstants.GAME_MODE_NOTHING );
                        break;
                    }
                }

                //Otherwise, go into bared mode.  Whay not?
                setAction( newAction );
                break;


            case VConstants.GAME_MODE_MOVING_TO_FEED_ON_PLAYER:
            case VConstants.GAME_MODE_MOVING_TO_FEED_ON_NON_PLAYER:

                //Make sure we don't overwrite existing feeding.
                if( !(action == VConstants.GAME_MODE_FEED_FROM_NON_PLAYER ||
                    action == VConstants.GAME_MODE_FEED_FROM_PLAYER) ) {

                    setAction( newAction );
                    }

                game = _room._bloodBloomGameManager.getGame( playerId );
                if( game == null ) {
                    log.error("actionChange(" + newAction + ") but no game. We should have already registered.");
                    log.error("no game hmmm.  here is the bbmanager:" + _room._bloodBloomGameManager);
                    break;
                }

                angleRadians = new Vector2( targetLocation[0] - avatar.x, targetLocation[2] - avatar.z).angle;
                degs = convertStandardRads2GameDegrees( angleRadians );
                predLocIndex = MathUtil.clamp(game.predators.size() - 1, 0,
                    PREDATOR_LOCATIONS_RELATIVE_TO_PREY.length - 1 );

                //If we are the first predator, we go directly behind the prey
                //Otherwise, take a a place
                targetX = targetLocation[0] + PREDATOR_LOCATIONS_RELATIVE_TO_PREY[predLocIndex][0] * VConstants.FEEDING_LOGICAL_X_OFFSET;
                targetY = targetLocation[1] + PREDATOR_LOCATIONS_RELATIVE_TO_PREY[predLocIndex][1] * VConstants.FEEDING_LOGICAL_X_OFFSET;
                targetZ = targetLocation[2] + PREDATOR_LOCATIONS_RELATIVE_TO_PREY[predLocIndex][2] * VConstants.FEEDING_LOGICAL_X_OFFSET;

                //If the avatar is already at the location, the client will dispatch a
                //PlayerArrivedAtLocation event, as the location doesn't change.

//                if( targetX == avatar.x &&
//                    targetY == avatar.y &&
//                    targetZ == avatar.z ) {
//
//                    setAction( newAction );
//                }
//                else {


                    updateAvatarState();
                    ctrl.setAvatarLocation( targetX, targetY, targetZ, degs);
//                }


                break;

            case VConstants.GAME_MODE_FEED_FROM_PLAYER:
            case VConstants.GAME_MODE_FEED_FROM_NON_PLAYER:

                game = _room._bloodBloomGameManager.getGame( playerId );
                if( game == null ) {
                    log.error("actionChange(" + newAction + ") but no game. We should have already registered.");
                    log.error("_room._bloodBloomGameManager=" + _room._bloodBloomGameManager);
                    break;
                }

                if( !game.isPredator( playerId )) {
                    log.error("actionChange(" + newAction + ") but not predator in game. We should have already registered.");
                    log.error("_room._bloodBloomGameManager=" + _room._bloodBloomGameManager);
                    break;
                }

                setAction( newAction );
                updateAvatarState();

                if( game.multiplePredators ) {
                    if( !game.isCountDownTimerStarted ) {
                        game.startCountDownTimer();
                    }
                }
                else {
                    game.startGame();
                }



                //Make sure the player is facing the same direction as the prey when they arrive


                break;



                //Check if the closest vampire is also closest to you, and they are in bare mode

//                var game :BloodBloomGameRecord = _bloodBloomGameManager.requestFeed(
//                    e.playerId,
//                    e.targetPlayer,
//                    e.isAllowingMultiplePredators,
//                    [e.targetX, e.targetY, e.targetZ] );//Prey location



//                if( ServerContext.vserver.isPlayer( targetId ) ) {
//
//                    var potentialVictim :Player = ServerContext.vserver.getPlayer( targetId );
//                    if( potentialVictim != null
//                        && potentialVictim.targetId == playerId
//                        && potentialVictim.action == VConstants.GAME_MODE_BARED) {
//
//                        var victimAvatar :AVRGameAvatar = room.ctrl.getAvatarInfo( targetId );
//                        if( victimAvatar != null && avatar != null) {
//
//                            angleRadians = new Vector2( victimAvatar.x - avatar.x, victimAvatar.z - avatar.z).angle;
//                            degs = convertStandardRads2GameDegrees( angleRadians );
//                            ctrl.setAvatarLocation( victimAvatar.x, victimAvatar.y, victimAvatar.z + 0.01, degs);
//                        }
//
//                        setAction( VConstants.GAME_MODE_MOVING_TO_FEED_ON_PLAYER );
//                        break;
//                    }
//                }
//                else {
//                    if( targetLocation != null && targetLocation.length >= 3 && avatar != null) {
//                        if( targetLocation[0] < avatar.x) {
//                            angleRadians = new Vector2( (targetLocation[0] + 0.16)- avatar.x, targetLocation[2] - avatar.z).angle;
//                            degs = convertStandardRads2GameDegrees( angleRadians );
//                            ctrl.setAvatarLocation( targetLocation[0] + 0.1, targetLocation[1], targetLocation[2], degs);
//                        }
//                        else {
//                            angleRadians = new Vector2( (targetLocation[0] - 0.16)- avatar.x, targetLocation[2] - avatar.z).angle;
//                            degs = convertStandardRads2GameDegrees( angleRadians );
//                            ctrl.setAvatarLocation( targetLocation[0] - 0.1, targetLocation[1], targetLocation[2], degs);
//                        }
//                        setAction( VConstants.GAME_MODE_MOVING_TO_FEED_ON_NON_PLAYER );
//                        break;
//                    }
//                }

            case VConstants.GAME_MODE_FIGHT:
            default:
                setAction( VConstants.GAME_MODE_NOTHING );
//                if( isTargetTargetingMe && targetPlayer.action == VConstants.GAME_MODE_BARED) {
//                    targetPlayer.setAction( VConstants.GAME_MODE_NOTHING );
//                }


        }

        function convertStandardRads2GameDegrees( rad :Number ) :Number
        {
            return MathUtil.toDegrees( MathUtil.normalizeRadians(rad + Math.PI / 2) );
        }

    }

    protected function get targetPlayer() :Player
    {
        if( ServerContext.vserver.isPlayer( targetId )) {
            return ServerContext.vserver.getPlayer( targetId );
        }
        return null;
    }

    protected function get isTargetPlayer() :Boolean
    {
        return ServerContext.vserver.isPlayer( targetId );
    }

    protected function get avatar() :AVRGameAvatar
    {
        if( room == null || room.ctrl == null) {
            return null;
        }
        return room.ctrl.getAvatarInfo( playerId );
    }

    protected function get targetOfTargetPlayer() :int
    {
        if( !isTargetPlayer ) {
            return 0;
        }
        return targetPlayer.targetId;
    }

    protected function get isTargetTargetingMe() :Boolean
    {
        if( !isTargetPlayer ) {
            return false;
        }
        return targetPlayer.targetId == playerId;
    }


    protected function enteredRoom (evt :AVRGamePlayerEvent) :void
    {

        log.info(VConstants.DEBUG_MINION + " Player entered room {{{", "player", toString());
        log.debug(VConstants.DEBUG_MINION + " hierarchy=" + ServerContext.minionHierarchy);

//        log.debug( Constants.DEBUG_MINION + " Player enteredRoom, already on the database=" + toString());
//        log.debug( Constants.DEBUG_MINION + " Player enteredRoom, hierarch=" + ServerContext.minionHierarchy);

            var thisPlayer :Player = this;
            _room = ServerContext.vserver.getRoom(int(evt.value));
            ServerContext.vserver.control.doBatch(function () :void {
                try {
                    if( _room != null) {
//                        var minionsBytes :ByteArray = ServerContext.minionHierarchy.toBytes();
//                        ServerContext.serverLogBroadcast.log("enteredRoom, sending hierarchy=" + ServerContext.minionHierarchy);
//                        _room.ctrl.props.set( Codes.ROOM_PROP_MINION_HIERARCHY, minionsBytes );

                        _room.playerEntered(thisPlayer);
                        ServerContext.minionHierarchy.playerEnteredRoom( thisPlayer, _room);
                        updateAvatarState();
                    }
                    else {
                        log.error("WTF, enteredRoom called, but room == null???");
                    }
                }
                catch( err:Error)
                {
                    log.error(err.getStackTrace());
                }
            });

        //Make sure we are the right color when we enter a room.
//        handleChangeColorScheme( (isVampire() ? VConstants.COLOR_SCHEME_VAMPIRE : VConstants.COLOR_SCHEME_HUMAN) );
//        setIntoRoomProps();

        log.debug(VConstants.DEBUG_MINION + "after _room.playerEntered");
        log.debug(VConstants.DEBUG_MINION + "hierarchy=" + ServerContext.minionHierarchy);

    }



    public function isVampire() :Boolean
    {
        return true;
//        return level >= VConstants.MINIMUM_VAMPIRE_LEVEL;
    }

    protected function leftRoom (evt :AVRGamePlayerEvent) :void
    {
        var thisPlayer :Player = this;
        ServerContext.vserver.control.doBatch(function () :void {
            if (_room != null) {

                _room.playerLeft(thisPlayer);

                if (_room.roomId == evt.value) {
                    _room = null;
                } else {
                    log.warning("The room we're supposedly leaving is not the one we think we're in",
                                "ourRoomId", _room.roomId, "eventRoomId", evt.value);
                }
            }

        });
    }


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

    protected function updateAvatarState() :void
    {
//        if (_room == null || _room.ctrl == null || !_room.ctrl.isConnected()) {
//            return;
//        }
//        else {
//            var avatar :AVRGameAvatar = _room.ctrl.getAvatarInfo( playerId );
//            if( avatar == null) {
//                return;
//            }

//            log.debug("Updating avatar state", "action", action, "avatar.state", avatar.state);

            var newState :String = "Default";


            if( action == VConstants.GAME_MODE_BARED) {
                newState = action;
            }

            if( action == VConstants.GAME_MODE_FEED_FROM_PLAYER ||
                action == VConstants.GAME_MODE_FEED_FROM_NON_PLAYER ) {
                newState = VConstants.GAME_MODE_FEED_FROM_PLAYER;
            }

            if( newState != avatarState ) {
                log.debug(playerId + " updateAvatarState(" + newState + "), when action=" + action);
                setAvatarState(newState);
            }


//            if( newState != avatar.state ) {
////                log.debug("_ctrl.setAvatarState(" + newState + ")");
//                _ctrl.setAvatarState(newState);
//            }
//        }
    }


    public function setIntoRoomProps() :void
    {
        try {

            if( _ctrl == null || !_ctrl.isConnected() ) {
                log.error("setIntoRoomProps() but ", "_ctrl", _ctrl);
                return;
            }

            if( _room == null || _room.ctrl == null || !_room.ctrl.isConnected()) {
                log.error("setIntoRoomProps() but ", "room", room);
                return;
            }

            var key :String = Codes.ROOM_PROP_PREFIX_PLAYER_DICT + playerId;

            var dict :Dictionary = room.ctrl.props.get(key) as Dictionary;
            if (dict == null) {
                dict = new Dictionary();
            }

            if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD] != blood && !isNaN(blood)) {
                room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD, blood);
            }

            if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_ACTION] != action) {
                log.debug("Setting " + playerId + " action=" + action + " into room props");
                room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_ACTION, action);
            }

            if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED] != bloodbonded ) {
                room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED, bloodbonded);
            }

            if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED_NAME] != bloodbondedName ) {
                room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED_NAME, bloodbondedName);
            }

            if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_PREVIOUS_TIME_AWAKE] != time && !isNaN(time)) {
                room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_PREVIOUS_TIME_AWAKE, time);
            }
            if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP] != xp && !isNaN(xp)) {
                log.debug("Setting " + playerId + " xp=" + xp + " into room props");
                room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP, xp);
            }

            if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_INVITES] != invites) {
                log.debug("Setting " + playerId + " invites=" + invites + " into room props");
                room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_INVITES, invites);
            }

            if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_AVATAR_STATE] != avatarState ) {
                log.debug("Setting " + playerId + " avatar state=" + avatarState + " into room props");
                room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_AVATAR_STATE, avatarState);
            }

        }
        catch( err :Error) {
            log.error(err.getStackTrace());
        }
    }


    /**
    * Called periodically to set into the permanent props.
    *
    *
    */
    protected function setIntoPlayerProps() :void
    {
        try {
        //Permanent props
            if( _ctrl == null || _ctrl.props == null || !_ctrl.isConnected() ) {
                return;
            }

            if( _ctrl.props.get(Codes.PLAYER_PROP_BLOOD) != blood ) {
                _ctrl.props.set(Codes.PLAYER_PROP_BLOOD, blood, true);
            }

            if( _ctrl.props.get(Codes.PLAYER_PROP_NAME) != name ) {
                _ctrl.props.set(Codes.PLAYER_PROP_NAME, name, true);
            }

            if( _ctrl.props.get(Codes.PLAYER_PROP_XP) != xp ) {
                _ctrl.props.set(Codes.PLAYER_PROP_XP, xp, true);
            }

            if( _ctrl.props.get(Codes.PLAYER_PROP_LAST_TIME_AWAKE) != time ) {
                _ctrl.props.set(Codes.PLAYER_PROP_LAST_TIME_AWAKE, time, true);
            }

            if( _ctrl.props.get(Codes.PLAYER_PROP_SIRE) != sire ) {
                _ctrl.props.set(Codes.PLAYER_PROP_SIRE, sire, true);
            }

            if( _ctrl.props.get(Codes.PLAYER_PROP_BLOODBONDED) != bloodbonded ) {
                _ctrl.props.set(Codes.PLAYER_PROP_BLOODBONDED, bloodbonded, true);


                if( _bloodbonded > 0) {//Set the name too
                    var bloodBondedPlayer :Player = ServerContext.vserver.getPlayer( _bloodbonded );
                    if( bloodBondedPlayer != null ) {
                        _bloodbondedName = bloodBondedPlayer.name;
                        _ctrl.props.set(Codes.PLAYER_PROP_BLOODBONDED_NAME, _bloodbondedName, true);
                    }
                    else {
                        log.error("Major error: setBloodBonded( " + _bloodbonded + "), but no Player, so cannot set name");
                    }
                }

            }

            if( _ctrl.props.get(Codes.PLAYER_PROP_SIRE) != sire ) {
                _ctrl.props.set(Codes.PLAYER_PROP_SIRE, sire, true);
            }

            if( _ctrl.props.get(Codes.PLAYER_PROP_MINIONIDS) == null ||
                !ArrayUtil.equals(_ctrl.props.get(Codes.PLAYER_PROP_MINIONIDS) as Array, _minionsForTrophies )) {
                _ctrl.props.set(Codes.PLAYER_PROP_MINIONIDS, _minionsForTrophies, true);
                Trophies.checkMinionTrophies( this );
            }

            if( _ctrl.props.get(Codes.PLAYER_PROP_INVITES) != invites ) {
                _ctrl.props.set(Codes.PLAYER_PROP_INVITES, invites, true);
                Trophies.checkInviteTrophies( this );
            }



        }
        catch( err :Error) {
            log.error(err.getStackTrace());
        }


    }

    public function updateMinions( minions :Array ) :void
    {
        if( _minionsForTrophies.length >= 25 ) {
            return;
        }
        for each( var newMinionId :int in minions ) {
            if( !ArrayUtil.contains( _minionsForTrophies, newMinionId ) ) {
                _minionsForTrophies.push( newMinionId );
                if( _minionsForTrophies.length >= 25 ) {
                    break;
                }
            }
        }
    }

    public function setTargetId (id :int) :void
    {
        _targetId = id;

        //If we have a new target, reset the chatting record.
//        if( _targetId != id) {
//            _chatTimesWithTarget.splice(0);
//        }

    }

    public function setTargetLocation (location :Array) :void
    {
        _targetLocation = location;
    }

    protected function setTime (time :Number, force :Boolean = false) :void
    {
        log.info("setTime()", "time", new Date(time).toTimeString());

        // update our runtime state
        if (!force && time == _timePlayerPreviouslyQuit) {
            return;
        }
        _timePlayerPreviouslyQuit = time;

        _ctrl.props.set(Codes.PLAYER_PROP_LAST_TIME_AWAKE, _timePlayerPreviouslyQuit, true);
    }

    public function addToInviteTally( addition :int = 1 ) :void
    {
        _inviteTally += addition;
    }

    public function setBloodBonded (bloodbonded :int, force :Boolean = false) :void
    {
        // update our runtime state
        if (!force && bloodbonded == _bloodbonded) {
            return;
        }

        var oldBloodBond :int = _bloodbonded;
        _bloodbonded = bloodbonded;

        if( oldBloodBond != 0) {//Remove the blood bond from the other player.
            if( ServerContext.vserver.isPlayer( oldBloodBond )) {
                var oldPartner :Player = ServerContext.vserver.getPlayer( oldBloodBond );
                oldPartner.setBloodBonded( 0 );
            }
            else {//Load from database
                ServerContext.ctrl.loadOfflinePlayer(oldBloodBond,
                    function (props :OfflinePlayerPropertyControl) :void {
                        props.set(Codes.PLAYER_PROP_BLOODBONDED, 0);
                    },
                    function (failureCause :Object) :void {
                        log.warning("Eek! Sending message to offline player failed!", "cause", failureCause); ;
                    });


            }

        }


        if( _bloodbonded != 0) {//Set the name too
            var bloodBondedPlayer :Player = ServerContext.vserver.getPlayer( _bloodbonded );
            if( bloodBondedPlayer != null ) {
                _bloodbondedName = bloodBondedPlayer.name;
//                _ctrl.props.set(Codes.PLAYER_PROP_BLOODBONDED_NAME, _bloodbondedName, true);
            }
            else {
                log.error("Major error: setBloodBonded( " + _bloodbonded + "), but no Player, so cannot set name");
            }
        }
        else {
            _bloodbondedName = "No blood bond";
        }

        // and if we're in a room, update the room properties
//        if (_room != null) {
//            _room.playerUpdated(this);
//        }
    }


    public function setSire (sire :int) :void
    {
        _sire = sire;
        //Set immediately into props, as it's important and not often set.
        if( _ctrl.props.get(Codes.PLAYER_PROP_SIRE) != sire ) {
            _ctrl.props.set(Codes.PLAYER_PROP_SIRE, sire, true);
        }
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
        return Logic.levelGivenCurrentXpAndInvites( xp );
    }

    public function get xp () :Number
    {
        return _xp;
    }

    public function get blood () :Number
    {
        return _blood;
    }

    public function get maxBlood () :Number
    {
        return VConstants.MAX_BLOOD_FOR_LEVEL( level );
    }

    public function get bloodbonded () :int
    {
        return _bloodbonded;
    }

    public function get bloodbondedName () :String
    {
        return _bloodbondedName;
    }

    public function get avatarState () :String
    {
        return _avatarState;
    }

    public function get sire () :int
    {
        return _sire;
    }

    public function get invites () :int
    {
        return _inviteTally;
    }

    public function get targetId() :int
    {
        return _targetId;
    }
    public function get targetLocation() :Array
    {
        return _targetLocation;
    }

    public function get minionsIds() :Array
    {
        return _minionsForTrophies;
    }


    public function get time () :Number
    {
        return _timePlayerPreviouslyQuit;
    }

    public function get location () :Array
    {
        if( room == null || room.ctrl == null || room.ctrl.getAvatarInfo(playerId) == null) {
            return null;
        }
        var avatar :AVRGameAvatar = room.ctrl.getAvatarInfo( playerId );
        return [avatar.x, avatar.y, avatar.z, avatar.orientation];
    }

    //This update comes from the server and only occurs a few times per second.
    public function update( dt :Number) :void
    {
        _bloodUpdateTime += dt;
        if( _bloodUpdateTime >= UPDATE_BLOOD_INTERVAL ) {
            //Vampires lose blood
            if( isVampire() ) {
                if( blood > 1 ) {
                    damage( dt * VConstants.VAMPIRE_BLOOD_LOSS_RATE);
                    //But not below 1
                    if( blood < 1 ) {
                        setBlood( 1 );
                    }
                }
            }
            //Thralls regenerate blood
            else {
                if( blood < maxBlood ) {
                    addBlood( dt * VConstants.THRALL_BLOOD_REGENERATION_RATE);
                }
            }
            _bloodUpdateTime = 0;
        }

        //Change the avatar state depending on our current action
        updateAvatarState();
        //Save our state into the permanent props
        setIntoPlayerProps();
        //And also into the room props so all clients can see our state
        setIntoRoomProps();


    }

    public function get mostRecentVictimIds() :Array
    {
        return _mostRecentVictimIds;
    }

    public function addMostRecentVictimIds( id :int ) :void
    {
        _mostRecentVictimIds.push( id );
    }

    public function clearVictimIds() :void
    {
        _mostRecentVictimIds.splice(0);
    }

    public function isVictim() :Boolean
    {
        if( action != VConstants.GAME_MODE_BARED) {
            return false;
        }

        var predator :Player = ServerContext.vserver.getPlayer( targetId );
        if( predator == null ) {
            return false;
        }

        if( predator.action == VConstants.GAME_MODE_FEED_FROM_PLAYER && predator.targetId == playerId) {
            return true;
        }
        return false;
    }

    /**
    * If the avatar moves, break off the feeding/baring.
    */
    public function handleAvatarMoved( userIdMoved :int ) :void
    {
        //Moving nullifies any action we are currently doing, except if we are heading to
        //feed.

        switch( action ) {

            case VConstants.GAME_MODE_MOVING_TO_FEED_ON_PLAYER:

            case VConstants.GAME_MODE_MOVING_TO_FEED_ON_NON_PLAYER:
                break;//Don't change our state if we are moving into position

            case VConstants.GAME_MODE_FEED_FROM_PLAYER:
                var victim :Player = ServerContext.vserver.getPlayer( targetId );
                if( victim != null ) {
//                    victim.setTargetId(0);
                    victim.setAction( VConstants.GAME_MODE_NOTHING );
                }
                else {
                    log.error("avatarMoved(), we shoud be breaking off a victim, but there is no victim.");
                }
                setAction( VConstants.GAME_MODE_NOTHING );
                break;

            case VConstants.GAME_MODE_BARED:
                var predator :Player = ServerContext.vserver.getPlayer( targetId );
                if( predator != null ) {
//                    predator.setTargetId(0);
                    predator.setAction( VConstants.GAME_MODE_NOTHING );
                }
                else {
                    log.error("avatarMoved(), we shoud be breaking off a victim, but there is no victim.");
                }
                setAction( VConstants.GAME_MODE_NOTHING );
                break;


            case VConstants.GAME_MODE_FEED_FROM_NON_PLAYER:
            default :
                setAction( VConstants.GAME_MODE_NOTHING );
                userIdMoved
        }
    }


    protected var _name :String;
    protected var _blood :Number;
    protected var _xp :Number;
    protected var _action :String;

    protected var _avatarState :String = "Default";

    protected var _bloodbonded :int;
    protected var _bloodbondedName :String;

    protected var _sire :int;
    /**Hold max 25 player ids for recording minions for trophies.*/
    protected var _minionsForTrophies :Array;

    protected var _timePlayerPreviouslyQuit :Number;

    protected var _targetId :int;
    protected var _targetLocation :Array;

    protected var _inviteTally :int;


//    protected var _chatTimesWithTarget :Array = [];

    /** Records who we eat, and who eats us, for determining blood bond status.*/
    protected var _mostRecentVictimIds :Array = new Array();

    /** Player data for BloodBloom*/
//    protected var _feedingData :PlayerFeedingData;


    protected var _room :Room;
    protected var _ctrl :PlayerSubControlServer;
    protected var _playerId :int;



//    protected static const RADIUS :Number = 0.1;
    protected static const p4 :Number = Math.cos( Math.PI/4);
    protected static const PREDATOR_LOCATIONS_RELATIVE_TO_PREY :Array = [
        [  0, 0,  VConstants.FEEDING_LOGICAL_Z_OFFSET], //Behind
        [  1, 0,  0], //Left
        [ -1, 0,  0], //right
        [ p4, 0, p4], //North east
        [-p4, 0, p4],
        [ p4, 0,-p4],
        [-p4, 0,-p4],
        [ -2, 0,  0],
        [  2, 0,  0],
        [ -3, 0,  0],
        [  3, 0,  0],
        [ -4, 0,  0],
        [  5, 0,  0],
        [ -6, 0,  0],
        [  6, 0,  0]
    ];

    protected var _bloodUpdateTime :Number = 0;
    protected static const UPDATE_BLOOD_INTERVAL :Number = 3;
    protected static const log :Log = Log.getLog( Player );
//    protected var _minions
}
}
