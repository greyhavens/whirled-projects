package vampire.server
{

import com.threerings.flash.MathUtil;
import com.threerings.flash.Vector2;
import com.threerings.util.ClassUtil;
import com.threerings.util.HashSet;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.OfflinePlayerPropertyControl;
import com.whirled.contrib.platformer.net.GameMessage;
import com.whirled.contrib.simplegame.net.Message;

import flash.utils.ByteArray;

import vampire.Util;
import vampire.client.events.PlayerArrivedAtLocationEvent;
import vampire.data.Codes;
import vampire.data.Logic;
import vampire.data.VConstants;
import vampire.net.messages.BloodBondRequestMsg;
import vampire.net.messages.FeedConfirmMsg;
import vampire.net.messages.FeedRequestMsg;
import vampire.net.messages.NonPlayerIdsInRoomMsg;
import vampire.net.messages.RequestActionChangeMsg;
import vampire.net.messages.ShareTokenMsg;



public class ServerLogic
{


    /**
    * When a player gains blood, his sires all share a portion of the gain
    *
    */
    public static function playerGainedBlood( player :PlayerData, blood :Number, sourcePlayerId :int = 0 ) :void
    {
        var bloodShared :Number = VConstants.BLOOD_GAIN_FRACTION_SHARED_WITH_SIRES * blood;
        var allsires :HashSet = ServerContext.lineage.getAllSiresAndGrandSires( player.playerId );

        if( allsires.size() == 0 ) {
            log.debug("no sires");
            return;
        }

        var bloodForEachSire :Number = bloodShared / allsires.size();
        allsires.forEach( function ( sireId :int) :void {
            if( ServerContext.server.isPlayer( sireId )) {
                var sire :PlayerData = ServerContext.server.getPlayer( sireId );
                sire.addBlood( bloodForEachSire );
            }
        });
    }

    /**
    * When a player gains blood, his sires all share a portion of the gain
    *
    */
    public static function awardSiresXpEarned( player :PlayerData, xp :Number ) :void
    {
        log.debug("awardSiresXpEarned(" + player.name + ", xp=" + xp);

        var allsires :HashSet = ServerContext.lineage.getAllSiresAndGrandSires( player.playerId );
        if( allsires.size() == 0 ) {
            log.debug("no sires");
            return;
        }

        //Check if we are part of the Lineage (with Ubervamp as the grandsire).  Only then
        //are we allowed to collect minion xp.
        if( !allsires.contains( VConstants.UBER_VAMP_ID )) {
            player.addFeedback("You must be part of the Lineage to earn XP from your minions");
            return;
        }

        var immediateSire :int = ServerContext.lineage.getSireId( player.playerId );

        function awardXP( sireId :int, awardXP :Number ) :void {
            if( ServerContext.server.isPlayer( sireId )) {
                var sire :PlayerData = ServerContext.server.getPlayer( sireId );
                addXP( sire.playerId, awardXP );
                log.debug("awarding sire " + sire.name + ", xp=" + awardXP);
                sire.addFeedback( "You gained " + Util.formatNumberForFeedback(awardXP) + " experience from minion " + player.name );
            }
            else {//Add to offline database
                ServerContext.ctrl.loadOfflinePlayer(sireId,
                    function (props :OfflinePlayerPropertyControl) :void {
                        var currentXP :Number = Number(props.get(Codes.PLAYER_PROP_XP));

                        if( !isNaN(currentXP) && currentXP >= Logic.xpNeededForLevel( VConstants.MINIMUM_VAMPIRE_LEVEL ) ) {
                            props.set(Codes.PLAYER_PROP_XP, currentXP + awardXP);
                        }
                    },
                    function (failureCause :Object) :void {
                        log.warning("Eek! Sending message to offline player failed!", "cause", failureCause);
                    });
            }
        }
        allsires.forEach( function ( sireId :int) :void {
            if( sireId == immediateSire) {
                awardXP( sireId, xp * 0.1);//Immediate sires get 10%
            }
            else {
                awardXP( sireId, xp * 0.05);//Immediate sires get 10%
            }
        });
    }

    /**
    * When a player gains blood, his sires all share a portion of the gain
    *
    */
    public static function awardBloodBondedXpEarned( player :PlayerData, xp :Number ) :void
    {
        log.debug("awardBloodBondedXpEarned(" + player.name + ", xp=" + xp);
        if( player.bloodbonded <= 0 ) {
            return;
        }
        var bloodBondedPlayer :PlayerData =ServerContext.server.getPlayer( player.bloodbonded );
        var xpBonus :Number = xp * VConstants.BLOOD_BOND_FEEDING_XP_BONUS;
        var xBonusFormatted :String = Util.formatNumberForFeedback(xpBonus);

        if( bloodBondedPlayer != null ) {
            addXP( bloodBondedPlayer.playerId,  xpBonus );
            bloodBondedPlayer.addFeedback( "You gained " + xBonusFormatted + " experience from your bloodbond " + player.name );
            log.debug("awarding bloodbond " + bloodBondedPlayer.name + ", xp=" + xpBonus);
        }
        else {
            //Add to offline database
            ServerContext.ctrl.loadOfflinePlayer(player.bloodbonded,
                function (props :OfflinePlayerPropertyControl) :void {
                    var currentXP :Number = Number(props.get(Codes.PLAYER_PROP_XP));
                    if( !isNaN(currentXP)) {
                        props.set(Codes.PLAYER_PROP_XP, currentXP + xpBonus);
                    }
                },
                function (failureCause :Object) :void {
                    log.warning("Eek! Sending message to offline player failed!", "cause", failureCause);
                });
        }
    }


     /**
    * When a player gains blood, his sires all share a portion of the gain
    *
    */
    public static function awardBloodBondedBloodEarned( player :PlayerData, blood :Number ) :void
    {
        log.debug("awardBloodBondedBloodEarned(" + player.name + ", blood=" + blood);
        if( player.bloodbonded <= 0 ) {
            return;
        }
        var bloodBondedPlayer :PlayerData =ServerContext.server.getPlayer( player.bloodbonded );
        var bloodBonus :Number = blood * VConstants.BLOOD_BOND_FEEDING_XP_BONUS;
        var bloodBonusFormatted :String = Util.formatNumberForFeedback(Math.abs(bloodBonus));

        if( bloodBondedPlayer != null ) {
            bloodBondedPlayer.addBlood( bloodBonus );
            bloodBondedPlayer.addFeedback( "You " + (blood > 0 ? "gained ":"lost ") + bloodBonusFormatted + " blood from your bloodbond." );
            log.debug("awarding bloodbond " + bloodBondedPlayer.name + ", blood=" + bloodBonus);
        }
        else {
            //Add to offline database
            ServerContext.ctrl.loadOfflinePlayer(player.bloodbonded,
                function (props :OfflinePlayerPropertyControl) :void {
                    var currentBlood :Number = Number(props.get(Codes.PLAYER_PROP_BLOOD));
                    if( !isNaN(currentBlood)) {
                        props.set(Codes.PLAYER_PROP_BLOOD, Math.max(1, currentBlood + bloodBonus));
                    }
                },
                function (failureCause :Object) :void {
                    log.warning("Eek! Sending message to offline player failed!", "cause", failureCause);
                });
        }
    }


    public static function addBloodToPlayer( playerId :int, blood :Number ) :void
    {
        if( ServerContext.server.isPlayer( playerId ) ) {
            var player :PlayerData = ServerContext.server.getPlayer( playerId );
            player.addBlood( blood );
        }
        else {

            //Add to offline database
            ServerContext.ctrl.loadOfflinePlayer(playerId,
                function (props :OfflinePlayerPropertyControl) :void {
                    var currentBlood :Number = Number(props.get(Codes.PLAYER_PROP_BLOOD));
                    if( !isNaN(currentBlood)) {
                        props.set(Codes.PLAYER_PROP_BLOOD, currentBlood + blood);
                    }
                },
                function (failureCause :Object) :void {
                    log.warning("Eek! Sending message to offline player failed!", "cause", failureCause);
                });
        }
    }


    public static function checkBloodBondFormation( preyId :int, predatorIds :Array) :void
    {
        if( !ServerContext.server.isPlayer( preyId )) {
            return;
        }

        var prey :PlayerData = ServerContext.server.getPlayer( preyId );
        //At the moment, it's 2 alternate feedings each
        //EXCEPT the alternate is not checked
        //I.e. Player 1 eats Player 2, 2 eats 1, 1 eats 2, 2 eats 1.
        var minfeedings :int = 2;
        var preyVictims :Array = prey.mostRecentVictimIds;

        if( preyVictims.length < minfeedings) {
            return;
        }
        for each(var predId :int in predatorIds) {

            if( !ServerContext.server.isPlayer( predId)) {
                log.error("checkBloodBondFormation, no pred for id=" + predId );
                continue;
            }
            var predator :PlayerData = ServerContext.server.getPlayer( predId );
            var predVictims :Array = predator.mostRecentVictimIds;
            if( predVictims.length < minfeedings) {
                continue;
            }
            predator.addFeedback("Your most recent victims=" + predVictims);

            if( preyVictims[preyVictims.length - 1] == predator.playerId &&
                preyVictims[preyVictims.length - 2] == predator.playerId &&
                predVictims[predVictims.length - 1] == prey.playerId &&
                predVictims[predVictims.length - 2] == prey.playerId){


                //Break previous bonds
                prey.setBloodBonded( predator.playerId );//This also sets the name
                predator.setBloodBonded( prey.playerId );
                log.debug("Creating new bloodbond=" + predator.name + " + " + prey.name);
                prey.addFeedback( "You are now bloodbonded with " + predator.name);
                predator.addFeedback( "You are now bloodbonded with " + prey.name);
                ServerContext.server.addGlobalFeedback(prey.name + " is now bloodbonded with " + predator.name);
                //Reset the tallies.
                preyVictims.splice(0);
                predVictims.splice(0);
                continue;
            }
        }
    }

    /**
    * Returns actual damage.  If feeding, always have 1 left over.
    */
    public static function damage (player :PlayerData, damage :Number, isFeeding :Boolean = true) :Number
    {
        var actualDamage :Number = (player.blood - 1) >= damage ? damage : player.blood - 1;

        player.setBlood(player.blood - damage); // note: setBlood clamps this to [0, maxBlood]

        return actualDamage;

    }

    public static function increaseLevel(player :PlayerData) :void
    {
        var xpNeededForNextLevel :Number = Logic.xpNeededForLevel( player.level + 1 );
        log.debug("xpNeededForNextLevel" + xpNeededForNextLevel);
        var missingXp :Number = xpNeededForNextLevel - player.xp;
        log.debug("missingXp" + missingXp);
        addXP( player.playerId, missingXp );
        awardSiresXpEarned( player, missingXp );
    }

    public static function decreaseLevel(player :PlayerData) :void
    {
        if( player.level > 1 ) {
            var xpNeededForCurrentLevel :int = Logic.xpNeededForLevel( player.level );
            var missingXp :Number = -(player.xp - xpNeededForCurrentLevel) - 1;
            addXP( player.playerId, missingXp )
        }
    }

    public static function removeBlood( player :PlayerData, amount :Number) :void
    {
        if (!player.isDead()) {
            player.setBlood(player.blood - amount); // note: setBlood clamps this to [0, maxBlood]
        }
    }


    public static function addXP( playerId :int, bonus :Number) :void
    {
         if( ServerContext.server.isPlayer( playerId ) ) {
            var player :PlayerData = ServerContext.server.getPlayer( playerId );

            var currentLevel :int = Logic.levelGivenCurrentXpAndInvites( player.xp, player.invites );

            var xp :Number = player.xp;
            xp += bonus;
            xp = Math.max( xp, 0);
            var newLevel :int = Logic.levelGivenCurrentXpAndInvites( xp, player.invites );

            player.setXP( Math.min( xp, Logic.maxXPGivenXPAndInvites(xp, player.invites)) );

            if( newLevel > currentLevel) {
                player.setBlood( Math.min( player.blood, 0.1 * player.maxBlood));
            }

            var levelWithMaxInvites :int = Logic.levelGivenCurrentXpAndInvites( xp, 100000 );
            if( levelWithMaxInvites > newLevel ) {
                var invitesNeededForNextLevel :int = Logic.invitesNeededForLevel( newLevel + 1 );
                invitesNeededForNextLevel = Math.max(0, invitesNeededForNextLevel - player.invites );
                player.addFeedback("You've reached level " + newLevel + ", but your Lineage isn't diverse "
                + "enough to handle your growing power.  Recruit " + invitesNeededForNextLevel +
                " new player" + (invitesNeededForNextLevel > 1 ? "s":"")
                + " from outside Whirled to support your new potency.");
            }


        }
        else {

            //Add to offline database
            ServerContext.ctrl.loadOfflinePlayer(playerId,
                function (props :OfflinePlayerPropertyControl) :void {
                    var currentXP :Number = Number(props.get(Codes.PLAYER_PROP_XP));
                    if( !isNaN(currentXP)) {
                        props.set(Codes.PLAYER_PROP_XP, currentXP + xp);
                    }
                },
                function (failureCause :Object) :void {
                    log.warning("Eek! Sending message to offline player failed!", "cause", failureCause);
                });
        }

    }


    // called from Server
    public static function handleMessage (player :PlayerData, name :String, value :Object) :void
    {
        var room :Room = player.room;
        var playerId :int = player.playerId;

        try{
            if( value is NonPlayerIdsInRoomMsg ) {
                return;
            }
            // handle messages that make (at least some) sense even if we're between rooms
            log.debug(playerId + " handleMessage() ", "name", name, "value", value);

            if( name == VConstants.NAMED_EVENT_BLOOD_UP ) {
                player.addBlood(20 );
            }
            else if( name == VConstants.NAMED_EVENT_BLOOD_DOWN ) {
                damage( player, 20 );
            }

            else if( name == VConstants.NAMED_MESSAGE_DEBUG_GIVE_BLOOD_ALL_ROOM ) {
                if( room != null) {
                    room.players.forEach( function(playerId :int, player :PlayerData) :void {
                        player.addBlood( 20 );
                    });
                }
            }

            if( name == VConstants.NAMED_MESSAGE_DEBUG_RESET_MY_SIRE ) {
                makeSire(player, 0);
            }

            if( name == VConstants.NAMED_EVENT_ADD_XP ) {
                addXP(player.playerId, 500 );
            }
            else if( name == VConstants.NAMED_EVENT_LOSE_XP ) {
                addXP(player.playerId, -500 );
            }
            else if( name == VConstants.NAMED_EVENT_LEVEL_UP ) {
                increaseLevel(player);
            }
            else if( name == VConstants.NAMED_EVENT_LEVEL_DOWN ) {
                decreaseLevel(player);
            }
            else if( name == VConstants.NAMED_EVENT_ADD_INVITE ) {
                player.addToInviteTally();
            }
            else if( name == VConstants.NAMED_EVENT_LOSE_INVITE ) {
                player.setInviteTally( Math.max(0, player.invites - 1));
            }
            else if( name == VConstants.NAMED_EVENT_MAKE_SIRE ) {
                makeSire(player, int(value));
            }
//            else if( name == VConstants.NAMED_EVENT_MAKE_MINION ) {
//                makeMinion(player, int(value));
//            }
            else if( name == VConstants.NAMED_EVENT_QUIT ) {
                var now :Number = new Date().time;
                player.setTime( now , true);
            }
            else if( name == PlayerArrivedAtLocationEvent.PLAYER_ARRIVED ) {

                log.debug(playerId + " message " + PlayerArrivedAtLocationEvent.PLAYER_ARRIVED);
                if( player.action == VConstants.GAME_MODE_MOVING_TO_FEED_ON_PLAYER ) {
                    log.debug(playerId + " changing to " + VConstants.GAME_MODE_FEED_FROM_PLAYER);
                    actionChange(player,  VConstants.GAME_MODE_FEED_FROM_PLAYER );
                }
                else if( player.action == VConstants.GAME_MODE_MOVING_TO_FEED_ON_NON_PLAYER ){
                    log.debug(playerId + " changing to " + VConstants.GAME_MODE_FEED_FROM_NON_PLAYER);
                    actionChange(player, VConstants.GAME_MODE_FEED_FROM_NON_PLAYER );
                }

            }
            else if( name == VConstants.NAMED_EVENT_UPDATE_FEEDING_DATA ) {
                var bytes :ByteArray = value as ByteArray;
                if( bytes != null) {
                    log.debug("Setting new feeding data");
                    player.setFeedingData( bytes );
                }
            }
            else if( name == VConstants.NAMED_EVENT_SHARE_TOKEN ) {
                var inviterId :int = int( value );
                log.debug( playerId + " received inviter id=" + inviterId);
                if( player.sire == 0 ) {
                    log.info( playerId + " setting sire=" + inviterId);
                    makeSire( player, inviterId );
                    //Tally the successful invites for trophies
                    playerInvitedByPlayer( playerId, inviterId );
                }
                else {
                    log.warning("handleShareTokenMessage, but our sire is already != 0" );
                }
            }
            else if( name == VConstants.NAMED_MESSAGE_CHOOSE_FEMALE ) {
                trace(VConstants.NAMED_MESSAGE_CHOOSE_FEMALE + " awarding female");
                player.ctrl.awardPrize( Trophies.BASIC_AVATAR_FEMALE );
                player.setTimeToCurrentTime();
            }
            else if( name == VConstants.NAMED_MESSAGE_CHOOSE_MALE ) {
                trace(VConstants.NAMED_MESSAGE_CHOOSE_MALE + " awarding male");
                player.ctrl.awardPrize( Trophies.BASIC_AVATAR_MALE );
                player.setTimeToCurrentTime();
            }

            else if( value is GameMessage) {

                var msg :Message = ServerContext.msg.deserializeMessage(name, value);

                log.debug(playerId + " handleMessage() GameMessage: ", "name", name, "value", msg);

                if( value is RequestActionChangeMsg) {
                    handleRequestActionChange( player, RequestActionChangeMsg(msg) );
                }
                else if( value is BloodBondRequestMsg) {
                    handleBloodBondRequest( player, BloodBondRequestMsg(msg) );
                }
                else if( value is FeedRequestMsg) {
                    handleFeedRequestMessage( player, FeedRequestMsg(msg) );
                }
                else if( value is ShareTokenMsg) {
                    handleShareTokenMessage( player, ShareTokenMsg(msg) );
                }
                else if( value is FeedConfirmMsg) {
                    var feedConform :FeedConfirmMsg = FeedConfirmMsg(msg);
                    var requestingPlayer :PlayerData = getPlayer( feedConform.playerId );
                    handleFeedConfirmMessage( requestingPlayer, feedConform );
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


    /**
    * Keep track of invites for trophies.
    * NB this does *not* check if the invited player already has a sire, it is assumed that
    * this check has already been made, and this function is called only after the first
    * time the sire is newly set.
    *
    */
    public static function playerInvitedByPlayer( newPlayerId :int, inviterId :int ) :void
    {
        var newbie :PlayerData = ServerContext.server.getPlayer( newPlayerId );
        if( newbie == null ) {
            log.error("playerInvitedByPlayer", "newPlayerId", newPlayerId, "inviterId", inviterId);
            return;
        }

        if( ServerContext.server.isPlayer( inviterId )) {
            var inviter :PlayerData = ServerContext.server.getPlayer( inviterId );
            inviter.addToInviteTally();
            Trophies.checkInviteTrophies( inviter );
        }
        else {
            //Add to offline database
            ServerContext.ctrl.loadOfflinePlayer(inviterId,
                function (props :OfflinePlayerPropertyControl) :void {
                    var currentInvites :int = int(props.get(Codes.PLAYER_PROP_INVITES));
                    props.set(Codes.PLAYER_PROP_INVITES, currentInvites + 1);
                },
                function (failureCause :Object) :void {
                    log.warning("Eek! Sending message to offline player failed!", "cause", failureCause);
                });
        }
    }


    public static function handleShareTokenMessage( player :PlayerData, e :ShareTokenMsg ) :void
    {
        var inviterId :int = e.inviterId;
        log.debug( player.playerId + " received inviter id=" + inviterId);
        if( player.sire != 0 ) {
            log.info( player.playerId + " setting sire=" + inviterId);
            makeSire( player, inviterId );
//            setSire( inviterId );
        }
        else {
            log.warning("handleShareTokenMessage, but our sire != 0", "e", e );
        }
    }
    public static function handleFeedRequestMessage( player :PlayerData, e :FeedRequestMsg ) :void
    {
        var game :BloodBloomGameRecord;

//        if( player.action == VConstants.GAME_MODE_BARED ) {
//            player.setAction( VConstants.GAME_MODE_NOTHING );
//            return;
//        }


        //Set info useful for later
        player.setTargetId( e.targetPlayer );
        player.setTargetLocation( [e.targetX, e.targetY, e.targetZ] );

        //If a game lobby already exists, add ourselves to that game, and move into position.
        //Otherwise, first ask the prey.


        //Prey is already in a game, add ourselves.
        if(player.room.bloodBloomGameManager.isPreyInGame( e.targetPlayer )){
            //Add ourselves to a game.  We'll check this later, when we arrive at our location
            game = player.room.bloodBloomGameManager.requestFeed(
                e.playerId,
                (e.targetPlayer != 0 ? e.targetPlayer : -1),//BB used -1 as the AI player
                e.isAllowingMultiplePredators,
                [e.targetX, e.targetY, e.targetZ] );//Prey location

            if( !game.isStarted ) {

                if( player.room.isPlayer( e.targetPlayer ) ) {
                    actionChange( player, VConstants.GAME_MODE_MOVING_TO_FEED_ON_PLAYER );
                }
                else {
                    actionChange( player, VConstants.GAME_MODE_MOVING_TO_FEED_ON_NON_PLAYER );
                }
            }
        }
        else {
            //Ask the prey first.
            var preyPlayer :PlayerData = getPlayer( e.targetPlayer );
            if(preyPlayer != null) {
                log.debug(player.name + " is asking " + preyPlayer.name + " to feed");
                preyPlayer.ctrl.sendMessage( e.name, e.toBytes());
            }
        }

    }

    public static function handleFeedConfirmMessage( player :PlayerData, e :FeedConfirmMsg ) :void
    {
        log.debug("handleFeedConfirmMessage");
        var game :BloodBloomGameRecord = player.room.bloodBloomGameManager.requestFeed(
                player.playerId,
                (player.targetId != 0 ? player.targetId : -1),//BB used -1 as the AI player
                true,
                player.targetLocation );//Prey location

        if( !game.isStarted ) {

            if( player.room.isPlayer( player.targetId ) ) {
                actionChange( player, VConstants.GAME_MODE_MOVING_TO_FEED_ON_PLAYER );
            }
            else {
                actionChange( player, VConstants.GAME_MODE_MOVING_TO_FEED_ON_NON_PLAYER );
            }
        }
    }

    public static function getPlayer( playerId :int ) :PlayerData
    {
        return ServerContext.server.getPlayer( playerId );
    }


    public static function makeSire(player :PlayerData, targetPlayerId :int ) :void
    {
        if( targetPlayerId == player.sire) {
            return;
        }
        var oldSire :int = player.sire;
        log.info(player.playerId + " makeSire(" + targetPlayerId + ")");


        ServerContext.lineage.setPlayerSire( player.playerId, targetPlayerId);
        log.info(player.playerId + " then setting sire(" + ServerContext.lineage.getSireId( player.playerId ) + ")");
        player.setSire( ServerContext.lineage.getSireId( player.playerId ) );

//        ServerContext.minionHierarchy.updatePlayer( targetPlayerId );
        ServerContext.lineage.updatePlayer( player.playerId );
//        ServerContext.minionHierarchy.updateIntoRoomProps();

        if( oldSire != 0 ) {
            ServerContext.lineage.updatePlayer( oldSire );
        }
    }

//    public static function makeMinion(player :PlayerData, targetPlayerId :int ) :void
//    {
//        log.info("makeMinion(" + targetPlayerId + ")");
//        ServerContext.lineage.setPlayerSire( targetPlayerId, playerId);
//
//        player.setSire( ServerContext.lineage.getSireId( playerId ) );
//
//        ServerContext.lineage.updatePlayer( playerId );
////        ServerContext.minionHierarchy.updateIntoRoomProps();
//    }




    /**
    * Here we check if we are allowed to change action.
    * ATM we just allow it.
    */
    public static function handleBloodBondRequest( player :PlayerData, e :BloodBondRequestMsg) :void
    {
        var targetPlayer :PlayerData = ServerContext.server.getPlayer( e.targetPlayer );

        if( targetPlayer == null) {
            log.debug("Cannot perform blood bond request unless both players are in the same room");
            return;
        }

        if( e.add ) {

            player.setBloodBonded( e.targetPlayer )
        }
    }


    public static function handleRequestActionChange( player :PlayerData, e :RequestActionChangeMsg) :void
    {
        log.debug("handleRequestActionChange(..), e.action=" + e.action);
        actionChange( player, e.action );
    }

    /**
    * Here we check if we are allowed to change action.
    * ATM we just allow it.
    */
    public static function actionChange( player :PlayerData, newAction :String ) :void
    {
        log.debug("actionChange(" + newAction + ")");
        if( player == null || player.room == null) {
            log.error("room null");
            return;
        }
        var angleRadians :Number;
        var degs :Number;
        var game :BloodBloomGameRecord;
        var predLocIndex :int;
        var newLocation :Array;
        var targetX :Number;
        var targetY :Number;
        var targetZ :Number;
        var playerId :int = player.playerId;
        var room :Room = player.room;

        switch( newAction ) {
            case VConstants.GAME_MODE_BARED:

                //If I'm feeding, just break off the feed.
                if( room.bloodBloomGameManager.isPredatorInGame( playerId )) {
                    room.bloodBloomGameManager.playerQuitsGame( playerId );
                    player.setAction( VConstants.GAME_MODE_NOTHING );
                    break;
                }

                //If we are alrady in bare mode, toggle it, unless we are in a game.
                //Then we should quit the game to get out of bared mode
                if( player.action == VConstants.GAME_MODE_BARED ) {
                    if( !room.bloodBloomGameManager.isPreyInGame( playerId )) {
                        player.setAction( VConstants.GAME_MODE_NOTHING );
                        break;
                    }
                }

                //Otherwise, go into bared mode.  Whay not?
                player.setAction( newAction );
                break;


            case VConstants.GAME_MODE_MOVING_TO_FEED_ON_PLAYER:
            case VConstants.GAME_MODE_MOVING_TO_FEED_ON_NON_PLAYER:

                //Make sure we don't overwrite existing feeding.
                if( !(player.action == VConstants.GAME_MODE_FEED_FROM_NON_PLAYER ||
                    player.action == VConstants.GAME_MODE_FEED_FROM_PLAYER) ) {

                    player.setAction( newAction );
                    }

                game = room.bloodBloomGameManager.getGame( playerId );
                if( game == null ) {
                    log.error("actionChange(" + newAction + ") but no game. We should have already registered.");
                    log.error("no game hmmm.  here is the bbmanager:" + room.bloodBloomGameManager);
                    break;
                }
                var targetLocation :Array = player.targetLocation;
                var avatar :AVRGameAvatar = player.avatar;

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


//                    updateAvatarState();
                    player.ctrl.setAvatarLocation( targetX, targetY, targetZ, degs);
//                }


                break;

            case VConstants.GAME_MODE_FEED_FROM_PLAYER:
            case VConstants.GAME_MODE_FEED_FROM_NON_PLAYER:

                game = room.bloodBloomGameManager.getGame( playerId );
                if( game == null ) {
                    log.error("actionChange(" + newAction + ") but no game. We should have already registered.");
                    log.error("_room._bloodBloomGameManager=" + room.bloodBloomGameManager);
                    break;
                }

                if( !game.isPredator( playerId )) {
                    log.error("actionChange(" + newAction + ") but not predator in game. We should have already registered.");
                    log.error("_room._bloodBloomGameManager=" + room.bloodBloomGameManager);
                    break;
                }

                player.setAction( newAction );
//                plaupdateAvatarState();

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
                player.setAction( VConstants.GAME_MODE_NOTHING );
//                if( isTargetTargetingMe && targetPlayer.action == VConstants.GAME_MODE_BARED) {
//                    targetPlayer.setAction( VConstants.GAME_MODE_NOTHING );
//                }


        }

        function convertStandardRads2GameDegrees( rad :Number ) :Number
        {
            return MathUtil.toDegrees( MathUtil.normalizeRadians(rad + Math.PI / 2) );
        }

    }



//    public static function enteredRoom (player :PlayerData, evt :AVRGamePlayerEvent) :void
//    {
//
//        log.info(VConstants.DEBUG_MINION + " Player entered room {{{", "player", toString());
//        log.debug(VConstants.DEBUG_MINION + " hierarchy=" + ServerContext.lineage);
//
////        log.debug( Constants.DEBUG_MINION + " Player enteredRoom, already on the database=" + toString());
////        log.debug( Constants.DEBUG_MINION + " Player enteredRoom, hierarch=" + ServerContext.minionHierarchy);
//
////            var thisPlayer :PlayerData = this;
//            var room :Room = ServerContext.vserver.getRoom(int(evt.value));
//            ServerContext.vserver.control.doBatch(function () :void {
//                try {
//                    if( room != null) {
////                        var minionsBytes :ByteArray = ServerContext.minionHierarchy.toBytes();
////                        ServerContext.serverLogBroadcast.log("enteredRoom, sending hierarchy=" + ServerContext.minionHierarchy);
////                        _room.ctrl.props.set( Codes.ROOM_PROP_MINION_HIERARCHY, minionsBytes );
//
//                        room.playerEntered(player);
//                        ServerContext.lineage.playerEnteredRoom( player, room);
//                        player.updateAvatarState();
//                    }
//                    else {
//                        log.error("WTF, enteredRoom called, but room == null???");
//                    }
//                }
//                catch( err:Error)
//                {
//                    log.error(err.getStackTrace());
//                }
//            });
//
//        //Make sure we are the right color when we enter a room.
////        handleChangeColorScheme( (isVampire() ? VConstants.COLOR_SCHEME_VAMPIRE : VConstants.COLOR_SCHEME_HUMAN) );
////        setIntoRoomProps();
//
//        log.debug(VConstants.DEBUG_MINION + "after _room.playerEntered");
//        log.debug(VConstants.DEBUG_MINION + "hierarchy=" + ServerContext.lineage);
//
//    }

    public static function updateAvatarState(player :PlayerData) :void
    {
        var newState :String = "Default";

        if( player.action == VConstants.GAME_MODE_BARED) {
            newState = player.action;
        }

        if( player.action == VConstants.GAME_MODE_FEED_FROM_PLAYER ||
            player.action == VConstants.GAME_MODE_FEED_FROM_NON_PLAYER ) {
            newState = VConstants.GAME_MODE_FEED_FROM_PLAYER;
        }

        if( newState != player.avatarState ) {
            log.debug(player.playerId + " updateAvatarState(" + newState + "), when action=" + player.action);
            player.setAvatarState(newState);
        }
    }

    /**
    * If the avatar moves, break off the feeding/baring.
    */
    public static function handleAvatarMoved( player :PlayerData, userIdMoved :int ) :void
    {
        //Moving nullifies any action we are currently doing, except if we are heading to
        //feed.

        switch( player.action ) {

            case VConstants.GAME_MODE_MOVING_TO_FEED_ON_PLAYER:

            case VConstants.GAME_MODE_MOVING_TO_FEED_ON_NON_PLAYER:
                break;//Don't change our state if we are moving into position

            case VConstants.GAME_MODE_FEED_FROM_PLAYER:
                var victim :PlayerData = ServerContext.server.getPlayer( player.targetId );
                if( victim != null ) {
                    victim.setAction( VConstants.GAME_MODE_NOTHING );
                }
                else {
                    log.error("avatarMoved(), we shoud be breaking off a victim, but there is no victim.");
                }
                player.setAction( VConstants.GAME_MODE_NOTHING );
                break;

            case VConstants.GAME_MODE_BARED:
                var predator :PlayerData = ServerContext.server.getPlayer( player.targetId );
                if( predator != null ) {
                    predator.setAction( VConstants.GAME_MODE_NOTHING );
                }
                else {
                    log.error("avatarMoved(), we shoud be breaking off a victim, but there is no victim.");
                }
                player.setAction( VConstants.GAME_MODE_NOTHING );
                break;


            case VConstants.GAME_MODE_FEED_FROM_NON_PLAYER:
            default :
                player.setAction( VConstants.GAME_MODE_NOTHING );
        }
    }

   public static function bloodBloomRoundOver( gameRecord :BloodBloomGameRecord ) :void
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

        var srv :GameServer = ServerContext.server;
        var room :Room = gameRecord.room;
        //Check if it's a human practising
//        if( srv.getPlayer(gameRecord.primaryPredatorId) != null &&
//            !srv.getPlayer(gameRecord.primaryPredatorId).isVampire() ) {
//
//            addFeedback( "Find a vampire to feed for real.", gameRecord.primaryPredatorId);
//            return;
//        }

        //Update the highest possible score.  We use this to scale the coin payout
        ServerContext.topBloodBloomScore = Math.max( ServerContext.topBloodBloomScore,
            gameRecord.gameServer.lastRoundScore );

        var preyIsPlayer :Boolean = srv.isPlayer( gameRecord.preyId );
        var preyPlayer :PlayerData;
        var bloodGained :Number = 0;
        var preyId :int = gameRecord.preyId;
        var damage :Number = VConstants.BLOOD_LOSS_FROM_THRALL_OR_NONPLAYER_FROM_FEED;
        //Each predator damages the prey
        damage = damage * gameRecord.predators.size();

        //Handle the prey loss of blood
        if( preyIsPlayer ) {
            log.debug("Prey is player");
            preyPlayer = srv.getPlayer( gameRecord.preyId );
            bloodGained = Math.abs( ServerLogic.damage( preyPlayer, damage ));
            awardBloodBondedBloodEarned( preyPlayer, bloodGained);
            preyPlayer.addFeedback( "You lost " + Util.formatNumberForFeedback(bloodGained) + " from feeding");
        }
        else {
            log.debug("Prey is nonplayer");
            bloodGained = Math.abs(ServerContext.nonPlayersBloodMonitor.damageNonPlayer( gameRecord.preyId, damage, room.roomId ));
        }
        log.debug("Prey lost " + bloodGained + " blood");

        //You get half the blood lost
        bloodGained = 0.5 * bloodGained;

        //Predators gain blood from the prey, divvied up
        var bloodGainedPerPredator :Number = bloodGained / gameRecord.predators.size();
        var bloodGainedPerPredatorFormatted :String = Util.formatNumberForFeedback(bloodGainedPerPredator);


        for each( var predatorId :int in gameRecord.predators.toArray()) {
            var pred :PlayerData = srv.getPlayer( predatorId );
            if( pred == null ) {
                log.error("adding blood, but no pred", "predatorId", predatorId);
                continue;
            }
            pred.addMostRecentVictimIds( gameRecord.preyId );

            pred.addBlood( bloodGainedPerPredator );
            //The bloodbonded also gains a fraction
            awardBloodBondedBloodEarned( pred, bloodGainedPerPredator);
            log.debug(predatorId + " gained " + bloodGainedPerPredatorFormatted);
            pred.addFeedback( "You gained " + bloodGainedPerPredatorFormatted + " blood!");

            if( preyIsPlayer && preyPlayer != null ) {

                //Check if we don't have a sire.  The prey vampire becomes it.
                if( pred.sire == 0 ) {


                    if( true || ServerContext.lineage.isMemberOfLineage( preyId )) {
                        makeSire( pred,  preyPlayer.playerId );
                        pred.addFeedback( preyPlayer.name + " has become your sire ");

                        //Award coins to the sire
                        preyPlayer.ctrl.completeTask( Codes.TASK_ACQUIRE_MINION_ID,
                            Codes.TASK_ACQUIRE_MINION_SCORE );


                        for each( var sireId :int in
                            ServerContext.lineage.getAllSiresAndGrandSires( pred.playerId ).toArray() ) {

                            if( srv.isPlayer( sireId )
                                && srv.getPlayer( sireId ).room != null) {

                                //Tell the sire she's got children
                                srv.getPlayer( sireId ).room.addFeedback(
                                    pred.name + " has become your minion ", sireId);

                                //Award coins to the sire(s)
                                preyPlayer.ctrl.completeTask( Codes.TASK_ACQUIRE_MINION_ID,
                                    Codes.TASK_ACQUIRE_MINION_SCORE/10 );

                            }
                        }
                    }
                    else {
                        pred.addFeedback( preyPlayer.name + " is not part of the Lineage (Minions of Übervamp).  Feed from a Lineage member to join.");
                        preyPlayer.addFeedback( "You are not part of the Lineage (Minions of Übervamp), so " + preyPlayer.name + " cannot become your minion. "
                            + " Feed on a member of the Lineage to join.");
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


        //Check for blood bonds
        if( preyIsPlayer ) {
            checkBloodBondFormation( gameRecord.preyId, gameRecord.predators.toArray());
        }

        //Then handle experience.  ATM everyone gets xp=score
        var xpGained :Number = gameRecord.gameServer.lastRoundScore;
        var xpFormatted :String = Util.formatNumberForFeedback( xpGained );

        function awardXP( playerId :int, xp :Number, xpFormatted :String ) :void
        {
            var p :PlayerData = ServerContext.server.getPlayer( playerId );
            if( p != null ) {
                addXP( p.playerId, xp );
                p.addFeedback("You gained " + xpFormatted + " experience!");
                //Add some bonus xp to your blood bond, if they are online
                awardBloodBondedXpEarned( p, xp );
                //Add some bonus xp to your sires
                awardSiresXpEarned( p, xp );
                var feedingScore :Number = gameRecord.gameServer.lastRoundScore / ServerContext.topBloodBloomScore
                p.ctrl.completeTask( Codes.TASK_FEEDING_ID, feedingScore );
            }
        }

        if( preyIsPlayer && preyPlayer != null) {
            awardXP( gameRecord.preyId, xpGained, xpFormatted);
        }

        gameRecord.predators.forEach( function( predId :int) :void {
            awardXP( predId, xpGained, xpFormatted);
        });
    }


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

    protected static const log :Log = Log.getLog( ServerLogic );

}
}