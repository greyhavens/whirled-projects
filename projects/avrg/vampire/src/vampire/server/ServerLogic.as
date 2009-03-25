package vampire.server
{

import com.threerings.flash.MathUtil;
import com.threerings.flash.Vector2;
import com.threerings.util.ArrayUtil;
import com.threerings.util.HashSet;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.OfflinePlayerPropertyControl;
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
import vampire.net.messages.MovePredIntoPositionMsg;
import vampire.net.messages.RequestStateChangeMsg;
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
//            player.addFeedback("You must be part of the Lineage to earn XP from your minions");
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
        var predId :int = predatorIds[0];
        var pred :PlayerData = ServerContext.server.getPlayer( predId );

        if( !ServerContext.server.isPlayer( predId )) {
            return;
        }

        //If there is more than one predator, clear the feeding records of all vamps and return
        if (predatorIds.length > 1) {

            for each (predId in predatorIds) {
                if (isPlayer(predId)) {
                    pred = ServerContext.server.getPlayer( predId );
                    pred.clearFeedingRecord();
                }
            }
            prey.clearFeedingRecord();
            return;
        }

        //If we have other vampires in our feeding record, clear it
        prey.purgeFeedingRecordOfAllExcept(predId);
        pred.purgeFeedingRecordOfAllExcept(preyId);


        //Add the feeding data to all the players
        prey.addFeedingRecord(preyId, predId);
        pred.addFeedingRecord(preyId, predId);

        //The first feed, do nothing.
        if (prey.feedingRecord.length == 1 || pred.feedingRecord.length == 1) {
            return;
        }

        var feedingRecordPrey :Array = prey.feedingRecord;
        var feedingRecordPred :Array = pred.feedingRecord;

        //The arrays should be the same size and equal.  If not we have a problem.
        if (feedingRecordPrey.length != feedingRecordPred.length ||
            !ArrayUtil.equals(feedingRecordPrey, feedingRecordPred)) {

            log.error("checkBloodBondFormation, feeding records not identical",
                "feedingRecordPrey", feedingRecordPrey,
                "feedingRecordPred", feedingRecordPred);
            return;
        }

        //Now check if the records arranged [pred, prey], [prey, pred],...
        //If not, remove all except the last.
        var id1 :int = feedingRecordPrey[0][0];
        var id2 :int = feedingRecordPrey[0][1];
        var recordsOk :Boolean = true;
        for each (var record :Array in feedingRecordPrey) {
            if (record[0] == id1 && record[1] == id2) {
                var temp :int = id1;
                id1 = id2;
                id2 = temp;
                continue;
            }
            else {
                recordsOk = false;
            }
        }

        if (!recordsOk) {
            feedingRecordPrey.splice(0, feedingRecordPrey.length - 1);
            feedingRecordPred.splice(0, feedingRecordPred.length - 1);
            return;
        }

        switch (feedingRecordPrey.length) {
            case 1://Nothing yet
            break;

            case 2://Show a popup with instructions for feeding
            var feedback2 :String = "You have almost created a bloodbond!  To cement the bond, "
                + prey.name + " must now feed on " + pred.name + ", followed by " + pred.name
                + " feeding on " + prey.name;

            prey.addFeedback( Codes.POPUP_PREFIX + feedback2);
            pred.addFeedback( Codes.POPUP_PREFIX + feedback2);
            break;

            case 3://Show a popup with instructions for feeding
            var feedback3 :String = "You have almost created a bloodbond!  To finally cement the "
                + "bond, "
                + prey.name + " must now feed on " + pred.name;

            prey.addFeedback( Codes.POPUP_PREFIX + feedback3);
            pred.addFeedback( Codes.POPUP_PREFIX + feedback3);
            break;

            case 4://Everything checks out, create the bloodbonds
            //Break previous bonds
            prey.setBloodBonded( pred.playerId );//This also sets the name
            pred.setBloodBonded( prey.playerId );
            log.debug("Creating new bloodbond=" + pred.name + " + " + prey.name);
            prey.addFeedback( Codes.POPUP_PREFIX + "You are now bloodbonded with " + pred.name);
            pred.addFeedback( Codes.POPUP_PREFIX + "You are now bloodbonded with " + prey.name);
            ServerContext.server.addGlobalFeedback(prey.name + " is now bloodbonded with " + pred.name);
            //Reset the tallies.
            feedingRecordPrey.splice(0);
            feedingRecordPred.splice(0);
            break;

            default:
            log.error("checkBloodBondFormation", "feedingRecordPrey.length",
                feedingRecordPrey.length);
        }
//
//        pred.addFeedback("Your most recent victims=" + predVictims);
//
//        //At this point, we should only have each other in our feeding records.
//        //Figure out where we are in the bonding process
//        if (prey.get
//
//
//        //At the moment, it's 2 alternate feedings each
//        //EXCEPT the alternate is not checked
//        //I.e. Player 1 eats Player 2, 2 eats 1, 1 eats 2, 2 eats 1.
//        var minfeedings :int = 2;
//        var preyVictims :Array = prey.mostRecentVictimIds;
//
//        if( preyVictims.length < minfeedings) {
//            return;
//        }
//        for each(predId in predatorIds) {
//
//            if( !ServerContext.server.isPlayer( predId)) {
//                log.error("checkBloodBondFormation, no pred for id=" + predId );
//                continue;
//            }
//            pred = ServerContext.server.getPlayer( predId );
//            var predVictims :Array = pred.mostRecentVictimIds;
//            if( predVictims.length < minfeedings) {
//                continue;
//            }
//            pred.addFeedback("Your most recent victims=" + predVictims);
//
//            if( preyVictims[preyVictims.length - 1] == pred.playerId &&
//                preyVictims[preyVictims.length - 2] == pred.playerId &&
//                predVictims[predVictims.length - 1] == prey.playerId &&
//                predVictims[predVictims.length - 2] == prey.playerId){
//
//
//                //Break previous bonds
//                prey.setBloodBonded( pred.playerId );//This also sets the name
//                pred.setBloodBonded( prey.playerId );
//                log.debug("Creating new bloodbond=" + pred.name + " + " + prey.name);
//                prey.addFeedback( "You are now bloodbonded with " + pred.name);
//                pred.addFeedback( "You are now bloodbonded with " + prey.name);
//                ServerContext.server.addGlobalFeedback(prey.name + " is now bloodbonded with " + pred.name);
//                //Reset the tallies.
//                preyVictims.splice(0);
//                predVictims.splice(0);
//                continue;
//            }
//        }
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

//            var levelWithMaxInvites :int = Logic.levelGivenCurrentXpAndInvites( xp, 100000 );
//            if( levelWithMaxInvites > newLevel ) {
//                var invitesNeededForNextLevel :int = Logic.invitesNeededForLevel( newLevel + 1 );
//                invitesNeededForNextLevel = Math.max(0, invitesNeededForNextLevel - player.invites );
//                player.addFeedback("You've reached level " + newLevel + ", but your Lineage isn't diverse "
//                + "enough to handle your growing power.  Recruit " + invitesNeededForNextLevel +
//                " new player" + (invitesNeededForNextLevel > 1 ? "s":"")
//                + " from outside Whirled to support your new potency.");
//            }


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


    /**
    * When a message comes in from a player, figure out which PlayerData instance will handle it
    */
    public static function handleMessage (player :PlayerData, name :String, value :Object) :void
    {
        var room :Room = player.room;
        var playerId :int = player.playerId;

        try{

            // handle messages that make (at least some) sense even if we're between rooms
//            log.debug(playerId + " handleMessage() ", "name", name, "value", value);

            //Attempt to handle Message type message first
            var msg :Message = ServerContext.msg.deserializeMessage(name, value);
            if( msg != null) {
//                log.debug(playerId + " handleMessage() GameMessage: ", "name", name, "value", msg);

                if( msg is RequestStateChangeMsg) {
                    handleRequestActionChange( player, RequestStateChangeMsg(msg) );
                }
                else if( msg is BloodBondRequestMsg) {
                    handleBloodBondRequest( player, BloodBondRequestMsg(msg) );
                }
                else if( msg is FeedRequestMsg) {
                    handleFeedRequestMessage( player, FeedRequestMsg(msg) );
                }
                else if( msg is ShareTokenMsg) {
                    handleShareTokenMessage( player, ShareTokenMsg(msg) );
                }
                else if( msg is FeedConfirmMsg) {
                    var feedConfirm :FeedConfirmMsg = FeedConfirmMsg(msg);
                    var requestingPlayer :PlayerData = getPlayer( feedConfirm.predatorId );
                    handleFeedConfirmMessage( requestingPlayer, feedConfirm );
                }
                else {
//                    log.debug("Cannot handle Message ", "player", playerId, "type", value );
//                    log.debug("  Classname=" + ClassUtil.getClassName(value) );
                }
            }
            else {
                //Then handle named messages.  Most are for debugging/testing.  If the messages are
                //used properly, then we'll migrate them to actual Messages.
                switch( name ) {
                    case VConstants.NAMED_EVENT_BLOOD_UP:
                    player.addBlood(20 );
                    break;


                    case VConstants.NAMED_EVENT_BLOOD_DOWN:
                    damage( player, 20 );
                    break;

                    case VConstants.NAMED_EVENT_BLOOD_UP:

                    break;

                    case VConstants.NAMED_MESSAGE_DEBUG_GIVE_BLOOD_ALL_ROOM:
                    if( room != null) {
                        room.players.forEach( function(playerId :int, player :PlayerData) :void {
                            player.addBlood( 20 );
                        });
                    }
                    break;

                    case VConstants.NAMED_MESSAGE_DEBUG_RESET_MY_SIRE:
                    makeSire(player, 0);
                    break;

                    case VConstants.NAMED_EVENT_ADD_XP:
                    addXP(player.playerId, 500 );
                    break;

                    case VConstants.NAMED_EVENT_LOSE_XP:
                    addXP(player.playerId, -500 );
                    break;

                    case VConstants.NAMED_EVENT_LEVEL_UP:
                    increaseLevel(player);
                    break;

                    case VConstants.NAMED_EVENT_LEVEL_DOWN:
                    decreaseLevel(player);
                    break;

                    case VConstants.NAMED_EVENT_ADD_INVITE:
                    player.addToInviteTally();
                    break;

                    case VConstants.NAMED_EVENT_LOSE_INVITE:
                    player.setInviteTally( Math.max(0, player.invites - 1));
                    break;

                    case VConstants.NAMED_EVENT_MAKE_SIRE:
                    makeSire(player, int(value));
                    break;

                    case VConstants.NAMED_EVENT_QUIT:
                    var now :Number = new Date().time;
                    player.setTime(now);
                    break;

                    case PlayerArrivedAtLocationEvent.PLAYER_ARRIVED:
                    handlePlayerArrivedAtLocation(player);
                    break;

                    case VConstants.NAMED_EVENT_UPDATE_FEEDING_DATA:
                    var bytes :ByteArray = value as ByteArray;
                    if( bytes != null) {
                        log.debug("Setting new feeding data");
                        player.setFeedingData( bytes );
                    }
                    break;

                    case VConstants.NAMED_EVENT_SHARE_TOKEN:
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
                    break;

                    case VConstants.NAMED_MESSAGE_CHOOSE_FEMALE:
                    trace(VConstants.NAMED_MESSAGE_CHOOSE_FEMALE + " awarding female");
                    player.ctrl.awardPrize( Trophies.BASIC_AVATAR_FEMALE );
                    player.setTimeToCurrentTime();
                    break;

                    case VConstants.NAMED_MESSAGE_CHOOSE_MALE:
                    trace(VConstants.NAMED_MESSAGE_CHOOSE_MALE + " awarding male");
                    player.ctrl.awardPrize( Trophies.BASIC_AVATAR_MALE );
                    player.setTimeToCurrentTime();
                    break;


                    default:
//                    log.debug("Message not handled", "name", name);
                }
            }

        }
        catch( err :Error ) {
            log.error(err.getStackTrace());
        }

    }

    protected static function handlePlayerArrivedAtLocation (player :PlayerData) :void
    {
        log.debug(player.playerId + " message " + PlayerArrivedAtLocationEvent.PLAYER_ARRIVED,
            "player", player.playerId, "state", player.state);

        switch (player.state) {
            case VConstants.PLAYER_STATE_MOVING_TO_FEED:
            stateChange(player,  VConstants.PLAYER_STATE_ARRIVED_AT_FEEDING_LOCATION);
            break;

            //If we are in a game or lobby, and we move, break off the game.
//            case VConstants.PLAYER_STATE_FEEDING_PREDATOR:
//            case VConstants.PLAYER_STATE_FEEDING_PREY:
//            case VConstants.PLAYER_STATE_ARRIVED_AT_FEEDING_LOCATION:
//            var game :FeedingRecord = player.room.bloodBloomGameManager.getGame(player.playerId);
//            if (game != null) {
//                game.playerLeavesGame(player.playerId, true);
//                stateChange(player, VConstants.PLAYER_STATE_DEFAULT);
//            }
//            break;

            default:
            log.error(player.playerId + " Received PLAYER_ARRIVED but doing nothing");
            break;
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
        log.debug("handleFeedRequestMessage");
        var game :FeedingRecord;

        //If we're bared, return us the the default state.
//        if( player.state == VConstants.PLAYER_STATE_BARED ) {
//            stateChange(player, VConstants.PLAYER_STATE_DEFAULT );
//            return;
//        }


        //Set info useful for later
        player.setTargetId( e.targetPlayer );
        player.setTargetLocation( [e.targetX, e.targetY, e.targetZ] );

        //If a game lobby already exists, add ourselves to that game, and move into position.
        //Otherwise, first ask the prey.


        //Prey is already in a game, or the prey is a non-player, add ourselves.
        if (player.room.bloodBloomGameManager.isPreyInGame(e.targetPlayer)
            || !isPlayer( e.targetPlayer)) {

            //Make sure the prey immediately goes into bared mode
            if( isPlayer( e.targetPlayer)) {
                stateChange( getPlayer(e.targetPlayer), VConstants.PLAYER_STATE_BARED );
            }

            game = player.room.bloodBloomGameManager.requestFeed(
                e.playerId,
                e.targetPlayer,
                e.targetName,
                [e.targetX, e.targetY, e.targetZ] );//Prey location

            stateChange( player, VConstants.PLAYER_STATE_MOVING_TO_FEED );

//            log.debug("adding to game");
//            //Add ourselves to a game.  We'll check this later, when we arrive at our location
//            game = player.room.bloodBloomGameManager.requestFeed(
//                e.playerId,
//                (e.targetPlayer != 0 ? e.targetPlayer : -1),//BB used -1 as the AI player
//                [e.targetX, e.targetY, e.targetZ] );//Prey location
//
//            if( !game.isStarted ) {
//
//                stateChange( player, VConstants.PLAYER_STATE_MOVING_TO_FEED );
////                if( player.room.isPlayer( e.targetPlayer ) ) {
////                }
////                else {
////                    stateChange( player, VConstants.GAME_MODE_MOVING_TO_FEED_ON_NON_PLAYER );
////                }
//            }
        }
        else {
            //If the prey is a player, ask permission.  Otherwise start up the lobby
            if( getPlayer( e.targetPlayer) != null) {
                log.debug("asking prey permission");
                //Ask the prey first.
                var preyPlayer :PlayerData = getPlayer( e.targetPlayer );
                if(preyPlayer != null) {
                    log.debug(player.name + " is asking " + preyPlayer.name + " to feed");
                    preyPlayer.ctrl.sendMessage( e.name, e.toBytes());
                }
            }
            else {//Not a player?  Walk to the target, on arrival we'll start up the lobby
                log.error("No player? WTF?");
//                actionChange( player, VConstants.GAME_MODE_MOVING_TO_FEED_ON_NON_PLAYER );
            }
        }

    }

    public static function handleFeedConfirmMessage( player :PlayerData, e :FeedConfirmMsg ) :void
    {
        log.debug("handleFeedConfirmMessage", "e", e);

        if( player == null) {
            log.error("handleFeedConfirmMessage", "player", player);
            return;
        }

        var prey :PlayerData = getPlayer( e.playerId );
        if( prey == null ) {
            log.error("handleFeedConfirmMessage", "prey", player);
            return;
        }

        if( e.isAllowedToFeed ) {

            //Make sure the prey immediately goes into bared mode
            stateChange( prey, VConstants.PLAYER_STATE_BARED );

            //Join the game
            var game :FeedingRecord = player.room.bloodBloomGameManager.requestFeed(
                    player.playerId,
                    prey.playerId,
                    e.preyName,
                    player.targetLocation );//Prey location

            stateChange( player, VConstants.PLAYER_STATE_MOVING_TO_FEED );
//            if( !game.isStarted ) {
//            }
        }
        else {
            player.addFeedback(prey.name + " denied your request to feed.");
        }
    }

    public static function getPlayer( playerId :int ) :PlayerData
    {
        return ServerContext.server.getPlayer( playerId );
    }

    public static function isPlayer( playerId :int ) :Boolean
    {
        return ServerContext.server.isPlayer( playerId );
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


    public static function handleRequestActionChange( player :PlayerData, e :RequestStateChangeMsg) :void
    {
        log.debug("handleRequestActionChange(..), e.action=" + e.state);
        stateChange( player, e.state );
    }

    /**
    * Here we check if we are allowed to change action.
    * ATM we just allow it.
    */
    public static function stateChange( player :PlayerData, newState :String ) :void
    {
        log.debug(player.name + " stateChange(" + newState + ")");
        if( player == null || player.room == null) {
            log.error("room null");
            return;
        }
        var angleRadians :Number;
        var degs :Number;
        var game :FeedingRecord;
        var predLocIndex :int;
        var newLocation :Array;
        var targetX :Number;
        var targetY :Number;
        var targetZ :Number;
        var playerId :int = player.playerId;
        var room :Room = player.room;

        switch( newState ) {
            case VConstants.PLAYER_STATE_BARED:

                //If I'm feeding, just break off the feed.
                if( room.bloodBloomGameManager.isPredatorInGame( playerId )) {
                    room.bloodBloomGameManager.playerQuitsGame( playerId );
                    player.setState( VConstants.PLAYER_STATE_DEFAULT );
                    break;
                }

//                //If we are alrady in bare mode, toggle it, unless we are in a game.
//                //Then we should quit the game to get out of bared mode
//                if( player.state == VConstants.PLAYER_STATE_BARED ) {
//                    if( !room.bloodBloomGameManager.isPreyInGame( playerId )) {
//                        player.setState( VConstants.PLAYER_STATE_DEFAULT );
//                        break;
//                    }
//                }

                //Otherwise, go into bared mode.  Whay not?
                player.setState( newState );
                break;


//            case VConstants.AVATAR_STATE_MOVING_TO_FEED:
            case VConstants.PLAYER_STATE_MOVING_TO_FEED:
            /**
            * Move the avatar into position.  Once it's in position, we can join the lobby.
            */


                //Make sure we don't overwrite existing feeding.
                if( player.state != VConstants.PLAYER_STATE_MOVING_TO_FEED ) {
                    player.setState( newState );
                }

                //Check if there are any games existing.
                game = room.bloodBloomGameManager.getGame( player.targetId );
//                if( game == null) {
//                    //No game, ok start one.  This does NOT start a BB game, just inits a record
//                    //so that other players will not stand on the wrong place.
//                    room.bloodBloomGameManager.f
//                }

                if( game == null ) {
                    log.error("actionChange(" + newState + ") but no game. We should have already registered.");
                    log.error("no game hmmm.  here is the bbmanager:" + room.bloodBloomGameManager);
                    break;
                }
                var targetLocation :Array = player.targetLocation;
                var avatar :AVRGameAvatar = player.avatar;

                angleRadians = new Vector2( targetLocation[0] - avatar.x, targetLocation[2] - avatar.z).angle;
                degs = convertStandardRads2GameDegrees( angleRadians );
                var predIndex :int = game == null ? 0 : game.getPredIndex(player.playerId);
                predLocIndex = MathUtil.clamp(predIndex, 0,
                    VConstants.PREDATOR_LOCATIONS_RELATIVE_TO_PREY.length - 1 );

                var msg :MovePredIntoPositionMsg = new MovePredIntoPositionMsg(
                    player.playerId, player.targetId, predLocIndex, targetLocation);

               player.ctrl.sendMessage(msg.name, msg.toBytes());

//                //If we are the first predator, we go directly behind the prey
//                //Otherwise, take a a place
//                targetX = targetLocation[0] +
//                    VConstants.PREDATOR_LOCATIONS_RELATIVE_TO_PREY[predLocIndex][0] *
//                    VConstants.FEEDING_LOGICAL_X_OFFSET;
//                targetY = targetLocation[1] +
//                    VConstants.PREDATOR_LOCATIONS_RELATIVE_TO_PREY[predLocIndex][1] *
//                    VConstants.FEEDING_LOGICAL_X_OFFSET;
//                targetZ = targetLocation[2] +
//                    VConstants.PREDATOR_LOCATIONS_RELATIVE_TO_PREY[predLocIndex][2] *
//                    VConstants.FEEDING_LOGICAL_X_OFFSET;
//
//                //If the avatar is already at the location, the client will dispatch a
//                //PlayerArrivedAtLocation event, as the location doesn't change.
//                if( targetX == avatar.x &&
//                    targetY == avatar.y &&
//                    targetZ == avatar.z ) {
//                    log.error("Player already at location, changing to feed mode");
//                    handlePlayerArrivedAtLocation( player );
//                }
//                else {
//                    player.ctrl.setAvatarLocation( targetX, targetY, targetZ, degs);
//                }


                break;

            case VConstants.PLAYER_STATE_ARRIVED_AT_FEEDING_LOCATION:

                game = room.bloodBloomGameManager.getGame(playerId);



                if( game == null ) {
                    log.error("actionChange(" + newState + ") but no game. We should have already registered.");
                    log.error("_room._bloodBloomGameManager=" + room.bloodBloomGameManager);
                    break;
                }

                if( game.isFinished ) {
                    log.error("actionChange(" + newState + ") but game finished");
                    break;
                }

//                if (!ArrayUtil.contains(game.gameServer.predatorIds, playerId)) {
//                    game.gameServer.addPredator(playerId);
//                }

//
//                if( !game.isPredator( playerId )) {
//                    log.error("actionChange(" + newState + ") but not predator in game. We should have already registered.");
//                    log.error("_room._bloodBloomGameManager=" + room.bloodBloomGameManager);
//                    break;
//                }

                player.setState( newState );
//                plaupdateAvatarState();
                if( game.isLobbyStarted ) {
                    log.debug("    Joining lobby...");
                    game.joinLobby( player.playerId );
                }
                else {
                    log.debug("    Starting lobby...");
                    game.startLobby();
                }
//                if( game.multiplePredators ) {
//                    if( !game.isCountDownTimerStarted ) {
//                        game.startCountDownTimer();
//                    }
//                }
//                else {
//                }



                //Make sure the player is facing the same direction as the prey when they arrive


                break;

//                case VConstants.PLAYER_STATE_FEEDING_PREDATOR:
//                player.setState( VConstants.PLAYER_STATE_FEEDING_PREDATOR );
//                break;

            default:
                player.setState( newState );


        }

        updateAvatarState( player );

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

//    public static function updateAvatarState(player :PlayerData) :void
//    {
//        var newState :String = "Default";
//
//        if( player.state == VConstants.AVATAR_STATE_BARED) {
//            newState = player.state;
//        }
//
//        if( player.state == VConstants.AVATAR_STATE_FEEDING ||
//            player.state == VConstants.GAME_MODE_FEED_FROM_NON_PLAYER ) {
//            newState = VConstants.AVATAR_STATE_FEEDING;
//        }
//
//        if( newState != player.avatarState ) {
//            log.debug(player.playerId + " updateAvatarState(" + newState + "), when action=" + player.state);
//            player.setAvatarState(newState);
//        }
//    }

    /**
    * If the avatar moves, break off the feeding/baring.
    */
    public static function handleAvatarMoved( player :PlayerData, userIdMoved :int ) :void
    {
        //Moving nullifies any action we are currently doing, except if we are heading to
        //feed.

        switch( player.state ) {

            case VConstants.PLAYER_STATE_MOVING_TO_FEED:

//            case VConstants.GAME_MODE_MOVING_TO_FEED_ON_NON_PLAYER:
                break;//Don't change our state if we are moving into position

            case VConstants.PLAYER_STATE_FEEDING_PREDATOR:
            case VConstants.PLAYER_STATE_FEEDING_PREY:
            case VConstants.PLAYER_STATE_BARED:
//                var victim :PlayerData = ServerContext.server.getPlayer( player.targetId );
//                if( victim != null ) {
//                    victim.setState( VConstants.AVATAR_STATE_DEFAULT );
//                }
//                else {
//                    log.error("avatarMoved(), we shoud be breaking off a victim, but there is no victim.");
//                }
                stateChange( player, VConstants.PLAYER_STATE_DEFAULT );
//                player.setState( VConstants.AVATAR_STATE_DEFAULT );
                break;

//            case VConstants.AVATAR_STATE_BARED:
////                var predator :PlayerData = ServerContext.server.getPlayer( player.targetId );
////                if( predator != null ) {
////                    predator.setState( VConstants.AVATAR_STATE_DEFAULT );
////                }
////                else {
////                    log.error("avatarMoved(), we shoud be breaking off a victim, but there is no victim.");
////                }
////                player.setState( VConstants.AVATAR_STATE_DEFAULT );
//                stateChange( player, VConstants.PLAYER_STATE_DEFAULT );
//                break;


//            case VConstants.GAME_MODE_FEED_FROM_NON_PLAYER:
            default :
                player.setState( VConstants.AVATAR_STATE_DEFAULT );
        }
    }

   public static function bloodBloomRoundOver( gameRecord :FeedingRecord ) :void
    {
        log.debug("bloodBloomRoundOver()", "gameRecord", gameRecord);
        var srv :GameServer = ServerContext.server;

        if (gameRecord == null) {
            log.error("bloodBloomRoundOver gameRecord==null");
            return;
        }
        if (gameRecord.gameServer == null) {
            log.error("bloodBloomRoundOver gameRecord.gameServer==null");
            return;
        }

        if (gameRecord.gameServer.lastRoundScore == 0) {
            log.debug("score==0 so no blood lost or gained.");

            if (gameRecord.playerIds != null) {
                for each (var playerId :int in gameRecord.playerIds) {
                    if (srv.isPlayer(playerId)) {
                        var player :PlayerData = srv.getPlayer(playerId);
                        player.addFeedback("You scored 0, no blood!");
                    }
                }
            }
            else {
                log.error("bloodBloomRoundOver gameRecord.playerIds == null");
            }
            return;
        }

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
        var preyPlayer :PlayerData = preyIsPlayer ? srv.getPlayer( gameRecord.preyId ) : null;
//        var bloodGained :Number = 0;
        var preyId :int = gameRecord.preyId;
//        var damage :Number = VConstants.BLOOD_LOSS_FROM_THRALL_OR_NONPLAYER_FROM_FEED;
//        //Each predator damages the prey
//        damage = damage * gameRecord.predators.size();
//
//        //Handle the prey loss of blood
//        if( preyIsPlayer ) {
//            log.debug("Prey is player");
//            preyPlayer = srv.getPlayer( gameRecord.preyId );
//            bloodGained = Math.abs( ServerLogic.damage( preyPlayer, damage ));
//            awardBloodBondedBloodEarned( preyPlayer, bloodGained);
//            preyPlayer.addFeedback( "You lost " + Util.formatNumberForFeedback(bloodGained) + " from feeding");
//        }
//        else {
//            log.debug("Prey is nonplayer");
//            bloodGained = Math.abs(ServerContext.npBlood.damageNonPlayer( gameRecord.preyId, damage, room.roomId ));
//        }
//        log.debug("Prey lost " + bloodGained + " blood");
//
//        //You get half the blood lost
//        bloodGained = 0.5 * bloodGained;
//
//        //Predators gain blood from the prey, divvied up
//        var bloodGainedPerPredator :Number = bloodGained / gameRecord.predators.size();
//        var bloodGainedPerPredatorFormatted :String = Util.formatNumberForFeedback(bloodGainedPerPredator);


        for each( var predatorId :int in gameRecord.predators.toArray()) {
            var pred :PlayerData = srv.getPlayer( predatorId );
            if( pred == null ) {
                log.error("adding blood, but no pred", "predatorId", predatorId);
                continue;
            }
//            pred.addMostRecentVictimIds( gameRecord.preyId );

//            pred.addBlood( bloodGainedPerPredator );
//            //The bloodbonded also gains a fraction
//            awardBloodBondedBloodEarned( pred, bloodGainedPerPredator);
//            log.debug(predatorId + " gained " + bloodGainedPerPredatorFormatted);
//            pred.addFeedback( "You gained " + bloodGainedPerPredatorFormatted + " blood!");


            if (preyIsPlayer && preyPlayer != null) {
                //Check if we don't have a sire.  The prey vampire becomes it.
                if (pred.sire == 0) {
                    if (ServerContext.lineage.isMemberOfLineage( preyId )) {
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
                        pred.addFeedback( preyPlayer.name + " is not part of the Lineage (Minions of Lilith).  Feed from a Lineage member to join.");
                        preyPlayer.addFeedback( "You are not part of the Lineage (Minions of Lilith), so " + preyPlayer.name + " cannot become your minion. "
                            + " Feed on a member of the Lineage to join.");
                    }
                }
                else {
                    log.debug(pred.name + "already has a sire=" + pred.sire);
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
            if (xp == 0) {
                return;
            }

            var p :PlayerData = ServerContext.server.getPlayer( playerId );
            if (p != null) {
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

    /**
    * Maps the player state to the visible avatar state, and update if necessary.
    */
    public static function updateAvatarState( player :PlayerData ) :void
    {
        var newAvatarState :String = VConstants.AVATAR_STATE_DEFAULT;
        var playerState :String = player.state;

        switch( playerState ) {
            case VConstants.PLAYER_STATE_BARED:
            newAvatarState = VConstants.AVATAR_STATE_BARED;
            break;

            case VConstants.PLAYER_STATE_FEEDING_PREDATOR:
            newAvatarState = VConstants.AVATAR_STATE_FEEDING;
            break;

            case VConstants.PLAYER_STATE_FEEDING_PREY:
            newAvatarState = VConstants.AVATAR_STATE_BARED;
            break;

            case VConstants.PLAYER_STATE_MOVING_TO_FEED:
            newAvatarState = VConstants.AVATAR_STATE_DEFAULT;
            break;

            case VConstants.PLAYER_STATE_ARRIVED_AT_FEEDING_LOCATION:
            newAvatarState = VConstants.AVATAR_STATE_FEEDING;
            break;

        }

        var currentAvatarState :String = player.avatarState;

        if( newAvatarState != currentAvatarState ) {
            log.debug(player.name + " updateAvatarState(" + newAvatarState + "), when action=" + playerState);
            player.setAvatarState(newAvatarState);
        }
        else {
            log.debug(player.name + " updateAvatarState(" + newAvatarState + "), but not changing since we are=" + currentAvatarState);
        }
    }




    protected static const log :Log = Log.getLog( ServerLogic );

}
}