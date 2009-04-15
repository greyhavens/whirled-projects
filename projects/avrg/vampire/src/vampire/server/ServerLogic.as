package vampire.server
{

import com.threerings.flash.MathUtil;
import com.threerings.flash.Vector2;
import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.OfflinePlayerPropertyControl;
import com.whirled.contrib.simplegame.ObjectMessage;
import com.whirled.contrib.simplegame.net.Message;

import flash.utils.ByteArray;

import vampire.Util;
import vampire.data.Codes;
import vampire.data.Logic;
import vampire.data.VConstants;
import vampire.net.messages.AvatarChosenMsg;
import vampire.net.messages.BloodBondRequestMsg;
import vampire.net.messages.DebugMsg;
import vampire.net.messages.FeedConfirmMsg;
import vampire.net.messages.FeedRequestMsg;
import vampire.net.messages.FeedingDataMsg;
import vampire.net.messages.GameStartedMsg;
import vampire.net.messages.MovePredIntoPositionMsg;
import vampire.net.messages.PlayerArrivedAtLocationMsg;
import vampire.net.messages.RequestStateChangeMsg;
import vampire.net.messages.RoomNameMsg;
import vampire.net.messages.SendGlobalMsg;
import vampire.net.messages.ShareTokenMsg;



public class ServerLogic
{

//    /**
//    * When a player gains blood, his sires all share a portion of the gain
//    *
//    */
//    public static function playerGainedBlood(player :PlayerData, blood :Number, sourcePlayerId :int = 0) :void
//    {
//        var bloodShared :Number = VConstants.BLOOD_GAIN_FRACTION_SHARED_WITH_SIRES * blood;
//        var allsires :HashSet = ServerContext.server.lineage.getAllSiresAndGrandSires(player.playerId);
//
//        if (allsires.size() == 0) {
//            log.debug("no sires");
//            return;
//        }
//
//        var bloodForEachSire :Number = bloodShared / allsires.size();
//        allsires.forEach(function (sireId :int) :void {
//            if (ServerContext.server.isPlayer(sireId)) {
//                var sire :PlayerData = ServerContext.server.getPlayer(sireId);
//                sire.addBlood(bloodForEachSire);
//            }
//        });
//    }

    /**
    * When a player gains blood, his sires all share a portion of the gain
    *
    */
    public static function awardSiresXpEarned (player :PlayerData, xp :Number) :void
    {
        if (player == null) {
            log.error("awardSiresXpEarned", "player", player);
            return;
        }
        log.debug("awardSiresXpEarned(" + player.name + ", xp=" + xp);



        //Check if we are part of the Lineage (with Ubervamp as the grandsire).  Only then
        //are we allowed to collect minion xp.
        if (!ServerContext.server.lineage.isMemberOfLineage(player.playerId)) {
            return;
        }

        function awardXP(sireId :int, awardXP :Number) :void {
            if (ServerContext.server.isPlayer(sireId)) {
                var sire :PlayerData = ServerContext.server.getPlayer(sireId);
                log.debug("awarding sire " + sire.name + ", xp=" + awardXP);
                addXP(sire.playerId, awardXP);
                sire.addXPBonusNotification(awardXP);
            }
            else {//Add to offline database
                ServerContext.ctrl.loadOfflinePlayer(sireId,
                    function (props :OfflinePlayerPropertyControl) :void {
                        var currentXP :Number = Number(props.get(Codes.PLAYER_PROP_XP_SLEEP));
                        if (isNaN(currentXP)) {
                            currentXP = 0;
                        }
                        props.set(Codes.PLAYER_PROP_XP_SLEEP, currentXP + awardXP);
                    },
                    function (failureCause :Object) :void {
                        log.warning("Eek! Sending message to offline player failed!", "cause",
                            failureCause);
                    });
            }
        }

        //Award to sires two levels up
        var numberOfGrandGenerationsToAward :int = 2;

        var currentSireId :int = ServerContext.server.lineage.getSireId(player.playerId);
        var generations :int = 1;
        var immediateSire :int = ServerContext.server.lineage.getSireId(player.playerId);

        while (currentSireId != 0 && generations <= 2) {

            if (currentSireId == immediateSire) {
                awardXP(currentSireId, xp * VConstants.XP_GAIN_FRACTION_SHARED_WITH_IMMEDIATE_SIRE);
            }
            else {
                awardXP(currentSireId, xp * VConstants.XP_GAIN_FRACTION_SHARED_WITH_GRANDSIRES);
            }
            currentSireId = ServerContext.server.lineage.getSireId(currentSireId);
            generations++;
        }









//        var allsires :HashSet = ServerContext.server.lineage.getAllSiresAndGrandSires(player.playerId);
//        if (allsires.size() == 0) {
//            log.debug("no sires");
//            return;
//        }


//        if (!allsires.contains(VConstants.UBER_VAMP_ID)) {
////            player.addFeedback("You must be part of the Lineage to earn XP from your minions");
//            return;
//        }



//        allsires.forEach(function (sireId :int) :void {
//            if (sireId == immediateSire) {
//                awardXP(sireId, xp * VConstants.XP_GAIN_FRACTION_SHARED_WITH_IMMEDIATE_SIRE);
//            }
//            else {
//                awardXP(sireId, xp * VConstants.XP_GAIN_FRACTION_SHARED_WITH_GRANDSIRES);
//            }
//        });
    }

    /**
    * When a player gains blood, his sires all share a portion of the gain
    *
    */
    protected static function awardBloodBondedXpEarned (player :PlayerData, xp :Number) :void
    {
        log.debug("awardBloodBondedXpEarned(" + player.name + ", xp=" + xp);
        if (player.bloodbond <= 0) {
            return;
        }
        var bloodBondedPlayer :PlayerData =ServerContext.server.getPlayer(player.bloodbond);
        var xpBonus :Number = xp * VConstants.BLOOD_BOND_FEEDING_XP_BONUS;
        var xBonusFormatted :String = Util.formatNumberForFeedback(xpBonus);

        if (bloodBondedPlayer != null) {
            addXP(bloodBondedPlayer.playerId,  xpBonus);
            bloodBondedPlayer.addFeedback("You gained " + xBonusFormatted + " experience from your bloodbond " + player.name);
            log.debug("awarding bloodbond " + bloodBondedPlayer.name + ", xp=" + xpBonus);
        }
        else {
            //Add to offline database
            ServerContext.ctrl.loadOfflinePlayer(player.bloodbond,
                function (props :OfflinePlayerPropertyControl) :void {
                    var currentXP :Number = Number(props.get(Codes.PLAYER_PROP_XP_SLEEP));
                    if (isNaN(currentXP)) {
                        currentXP = 0;
                    }
                    props.set(Codes.PLAYER_PROP_XP_SLEEP, currentXP + xpBonus);
                },
                function (failureCause :Object) :void {
                    log.warning("Eek! Sending message to offline player failed!", "cause", failureCause);
                });
        }
    }


//     /**
//    * When a player gains blood, his sires all share a portion of the gain
//    *
//    */
//    protected static function awardBloodBondedBloodEarned(player :PlayerData, blood :Number) :void
//    {
//        log.debug("awardBloodBondedBloodEarned(" + player.name + ", blood=" + blood);
//        if (player.bloodbonded <= 0) {
//            return;
//        }
//        var bloodBondedPlayer :PlayerData =ServerContext.server.getPlayer(player.bloodbonded);
//        var bloodBonus :Number = blood * VConstants.BLOOD_BOND_FEEDING_XP_BONUS;
//        var bloodBonusFormatted :String = Util.formatNumberForFeedback(Math.abs(bloodBonus));
//
//        if (bloodBondedPlayer != null) {
//            bloodBondedPlayer.addBlood(bloodBonus);
//            bloodBondedPlayer.addFeedback("You " + (blood > 0 ? "gained ":"lost ") + bloodBonusFormatted + " blood from your bloodbond.");
//            log.debug("awarding bloodbond " + bloodBondedPlayer.name + ", blood=" + bloodBonus);
//        }
//        else {
//            //Add to offline database
//            ServerContext.ctrl.loadOfflinePlayer(player.bloodbonded,
//                function (props :OfflinePlayerPropertyControl) :void {
//                    var currentBlood :Number = Number(props.get(Codes.PLAYER_PROP_BLOOD));
//                    if (!isNaN(currentBlood)) {
//                        props.set(Codes.PLAYER_PROP_BLOOD, Math.max(1, currentBlood + bloodBonus));
//                    }
//                },
//                function (failureCause :Object) :void {
//                    log.warning("Eek! Sending message to offline player failed!", "cause", failureCause);
//                });
//        }
//    }


//    protected static function addBloodToPlayer(playerId :int, blood :Number) :void
//    {
//        if (ServerContext.server.isPlayer(playerId)) {
//            var player :PlayerData = ServerContext.server.getPlayer(playerId);
//            player.addBlood(blood);
//        }
//        else {
//
//            //Add to offline database
//            ServerContext.ctrl.loadOfflinePlayer(playerId,
//                function (props :OfflinePlayerPropertyControl) :void {
//                    var currentBlood :Number = Number(props.get(Codes.PLAYER_PROP_BLOOD));
//                    if (!isNaN(currentBlood)) {
//                        props.set(Codes.PLAYER_PROP_BLOOD, currentBlood + blood);
//                    }
//                },
//                function (failureCause :Object) :void {
//                    log.warning("Eek! Sending message to offline player failed!", "cause", failureCause);
//                });
//        }
//    }



//    public static function checkBloodBondFormation (gameRecord :FeedingRecord) :void
//    {
//        if (gameRecord == null || gameRecord.feedingIds == null) {
//            log.debug("checkBloodBondFormation", "gameRecord", gameRecord);
//            return;
//        }
//
//        var preyId :int = gameRecord.preyId;
////        var predatorIds :Array = gameRecord.predators.toArray();
//
//        if (!isPlayer(preyId)) {
//            log.debug("checkBloodBondFormation", "preyId", preyId);
//            return;
//        }
//
//        var validRounds :int = 0;
//        var lastPredId :int = 0;
//
//        log.debug("checkBloodBondFormation", "feedingIds", gameRecord.feedingIds);
//        //Count backwards through the rounds.  If any are invalid, break.
//        for (var ii :int = gameRecord.feedingIds.length - 1; ii >= 0; ii--) {
//            var roundIds :Array = gameRecord.feedingIds[ii] as Array;
//            log.debug("checkBloodBondFormation", "looking at round", ii);
//            if (roundIds == null || roundIds.length != 2) {
//                log.debug("checkBloodBondFormation", "roundIds == null || roundIds.length != 2");
//                break;
//            }
//
//            var predId :int = roundIds[1];
//            if (lastPredId == 0) {
//                log.debug("checkBloodBondFormation", "setting lastPredId", predId);
//                lastPredId = predId;
//            }
//
//            if (predId != lastPredId) {
//                log.debug("checkBloodBondFormation", "predId", predId, "lastPredId", lastPredId);
//                break;
//            }
//            validRounds++;
//        }
//
//        log.debug("checkBloodBondFormation", "validRounds", validRounds);
//
//        if (lastPredId == 0) {
//            log.debug("checkBloodBondFormation", "lastPredId", lastPredId);
//            return;
//        }
//
//        if (!isPlayer(lastPredId)) {
//            log.debug("checkBloodBondFormation", "isPlayer(lastPredId)", isPlayer(lastPredId));
//            return;
//        }
//
//        var prey :PlayerData = getPlayer(preyId);
//        var pred :PlayerData = getPlayer(lastPredId);
//        if (prey.bloodbonded == lastPredId) {
//            log.debug("checkBloodBondFormation", "prey.bloodbonded", prey.bloodbonded);
//            return;
//        }
//
//
//        //If we are one away, notify the players.
//        if (validRounds == VConstants.FEEDING_ROUNDS_TO_FORM_BLOODBOND - 1) {
//            var feedback1 :String = "You have almost created a bloodbond!  To cement the bond, "
//                + " play one more round.";
//
//            prey.addFeedback(Codes.POPUP_PREFIX + feedback1);
//            pred.addFeedback(Codes.POPUP_PREFIX + feedback1);
//        }
//        //If we have enough, create the bloodbond
//        else if (validRounds == VConstants.FEEDING_ROUNDS_TO_FORM_BLOODBOND) {
//            prey.setBloodBonded(pred.playerId);//This also sets the name
//            pred.setBloodBonded(prey.playerId);
//            log.debug("Creating new bloodbond=" + pred.name + " + " + prey.name);
//            prey.addFeedback(Codes.POPUP_PREFIX + "You are now bloodbonded with " + pred.name);
//            pred.addFeedback(Codes.POPUP_PREFIX + "You are now bloodbonded with " + prey.name);
//            ServerContext.server.addGlobalFeedback(prey.name + " is now bloodbonded with " + pred.name);
//            gameRecord.feedingIds.splice(0);
//        }
//    }

//    /**
//    * Returns actual damage.  If feeding, always have 1 left over.
//    */
//    public static function damage (player :PlayerData, damage :Number, isFeeding :Boolean = true) :Number
//    {
//        var actualDamage :Number = (player.blood - 1) >= damage ? damage : player.blood - 1;
//
//        player.setBlood(player.blood - damage); // note: setBlood clamps this to [0, maxBlood]
//
//        return actualDamage;
//
//    }

    protected static function increaseLevel (player :PlayerData) :void
    {
        var xpNeededForNextLevel :Number = Logic.xpNeededForLevel(player.level + 1);
        log.debug("xpNeededForNextLevel" + xpNeededForNextLevel);
        var missingXp :Number = xpNeededForNextLevel - player.xp;
        log.debug("missingXp" + missingXp);
        addXP(player.playerId, missingXp);
//        awardSiresXpEarned(player, missingXp);
    }

    protected static function decreaseLevel (player :PlayerData) :void
    {
        if (player.level > 1) {
            var xpNeededForCurrentLevel :int = Logic.xpNeededForLevel(player.level);
            var missingXp :Number = -(player.xp - xpNeededForCurrentLevel) - 1;
            addXP(player.playerId, missingXp)
        }
    }

//    protected static function removeBlood(player :PlayerData, amount :Number) :void
//    {
//        if (!player.isDead()) {
//            player.setBlood(player.blood - amount); // note: setBlood clamps this to [0, maxBlood]
//        }
//    }


    public static function addXP (playerId :int, bonus :Number) :void
    {
         if (ServerContext.server.isPlayer(playerId)) {
            var player :PlayerData = ServerContext.server.getPlayer(playerId);

            var currentLevel :int = Logic.levelGivenCurrentXpAndInvites(player.xp, player.invites);

            var xp :Number = player.xp;
            xp += bonus;
            xp = Math.max(xp, 0);
            var newLevel :int = Logic.levelGivenCurrentXpAndInvites(xp, player.invites);

            player.xp = Math.min(xp, Logic.maxXPGivenXPAndInvites(xp, player.invites));

//            if (newLevel > currentLevel) {
//                player.setBlood(Math.min(player.blood, 0.1 * player.maxBlood));
//            }

//            var levelWithMaxInvites :int = Logic.levelGivenCurrentXpAndInvites(xp, 100000);
//            if (levelWithMaxInvites > newLevel) {
//                var invitesNeededForNextLevel :int = Logic.invitesNeededForLevel(newLevel + 1);
//                invitesNeededForNextLevel = Math.max(0, invitesNeededForNextLevel - player.invites);
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
                    if (!isNaN(currentXP)) {
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
            log.debug(playerId + " handleMessage() GameMessage: ", "name", name, "value", msg);
            if (msg != null) {

                if (msg is RequestStateChangeMsg) {
                    handleRequestActionChange(player, RequestStateChangeMsg(msg));
                }
                else if (msg is AvatarChosenMsg) {
                    handleAvatarChosenMessage(player, AvatarChosenMsg(msg));
                }
                else if (msg is BloodBondRequestMsg) {
                    handleBloodBondRequest(player, BloodBondRequestMsg(msg));
                }
                else if (msg is FeedRequestMsg) {
                    handleFeedRequestMessage(player, FeedRequestMsg(msg));
                }
                else if (msg is ShareTokenMsg) {
                    handleShareTokenMessage(player, ShareTokenMsg(msg));
                }
                else if (msg is FeedConfirmMsg) {
                    var feedConfirm :FeedConfirmMsg = FeedConfirmMsg(msg);
                    var requestingPlayer :PlayerData = getPlayer(feedConfirm.predatorId);
                    handleFeedConfirmMessage(requestingPlayer, feedConfirm);
                }
                else if (msg is FeedingDataMsg) {
                    var bytes :ByteArray = FeedingDataMsg(msg).feedingData;
                    if (bytes != null) {
                        player.feedingData = bytes;
                    }
                }
                else if (msg is GameStartedMsg) {
                    var gameStarted :GameStartedMsg = GameStartedMsg(msg);
                    var playerStarted :PlayerData = getPlayer(gameStarted.playerId);
                    handleGameStartedMessage(playerStarted, gameStarted);
                }
                else if (msg is PlayerArrivedAtLocationMsg) {
                    handlePlayerArrivedAtLocation(player);
                }
                else if (msg is SendGlobalMsg) {
                    var globalMessage :String = SendGlobalMsg(msg).message;
                    ServerContext.server.addGlobalFeedback(globalMessage);
                }
                else if (msg is RoomNameMsg) {
                    var roomMsg :RoomNameMsg = RoomNameMsg(msg);
                    if (roomMsg.roomId != 0 &&
                        ServerContext.server.getRoom(roomMsg.roomId) != null) {

                        var roomNoName :Room = ServerContext.server.getRoom(roomMsg.roomId);
                        roomNoName.handleRoomNameMsg(roomMsg);
                    }
                }
                else if (msg is DebugMsg) {
                    var debugMsg :DebugMsg = DebugMsg(msg);
                    switch (debugMsg.type) {
                        case DebugMsg.DEBUG_GAIN_XP:
                        addXP(player.playerId, 500);
                        break;

                        case DebugMsg.DEBUG_LOSE_XP:
                        addXP(player.playerId, -500);
                        break;

                        case DebugMsg.DEBUG_LEVEL_UP:
                        increaseLevel(player);
                        break;

                        case DebugMsg.DEBUG_LEVEL_DOWN:
                        decreaseLevel(player);
                        break;

                        case DebugMsg.DEBUG_ADD_INVITE:
                        player.addToInviteTally();
                        break;

                        case DebugMsg.DEBUG_LOSE_INVITE:
                        player.invites = Math.max(0, player.invites - 1);
                        break;

                        default:
                        log.debug("No registered debug type: " + msg);
                        break;
                    }
                }
            }
        }
        catch(err :Error) {
            log.error(err.getStackTrace());
        }

    }

    protected static function handleAvatarChosenMessage (player :PlayerData,
        msg :AvatarChosenMsg) :void
    {
        log.debug(msg);
        if (msg.isFemale) {
            player.ctrl.awardPrize(Trophies.BASIC_AVATAR_FEMALE);
        }
        else {
            player.ctrl.awardPrize(Trophies.BASIC_AVATAR_MALE);
        }
        player.ctrl.props.set(Codes.PLAYER_PROP_LAST_TIME_AWAKE, 1);
    }
    protected static function handlePlayerArrivedAtLocation (player :PlayerData) :void
    {
        log.debug(player.playerId + " message " + PlayerArrivedAtLocationMsg.NAME,
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
    protected static function playerInvitedByPlayer (newPlayerId :int, inviterId :int) :void
    {
        var newbie :PlayerData = ServerContext.server.getPlayer(newPlayerId);
        if (newbie == null) {
            log.error("playerInvitedByPlayer", "newPlayerId", newPlayerId, "inviterId", inviterId);
            return;
        }

        if (ServerContext.server.isPlayer(inviterId)) {
            var inviter :PlayerData = ServerContext.server.getPlayer(inviterId);
            inviter.addToInviteTally();
//            Trophies.checkInviteTrophies(inviter);
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

    protected static function handleGameStartedMessage (player :PlayerData, e :GameStartedMsg) :void
    {
        var xpGainedWhileAsleep :Number = Number(player.ctrl.props.get(Codes.PLAYER_PROP_XP_SLEEP));
        log.debug("Getting xpGainedWhileAsleep=" + xpGainedWhileAsleep);
        if (!isNaN(xpGainedWhileAsleep) && xpGainedWhileAsleep > 0) {
            addXP(player.playerId, xpGainedWhileAsleep);
            var descendentsCount :int = ServerContext.server.lineage.getProgenyCount(player.playerId);
            player.addFeedback(Codes.POPUP_PREFIX + "You gained " +
                Util.formatNumberForFeedback(xpGainedWhileAsleep) +
                " experience from your " +
                (player.bloodbond != 0 ? "bloodbond " : "") +
                (player.bloodbond != 0 && descendentsCount > 0 ? "and " : "") +
                (descendentsCount > 0 ? "progeny " : "") +
                "while you were asleep!");

        }
        player.ctrl.props.set(Codes.PLAYER_PROP_XP_SLEEP, 0);
    }

    protected static function handleShareTokenMessage (player :PlayerData, e :ShareTokenMsg) :void
    {
        var inviterId :int = e.inviterId;
        log.debug(player.playerId + " received inviter id=" + inviterId);
        if (player.sire == 0) {
            log.info(player.playerId + " setting sire=" + inviterId);

            makeSire(player, inviterId);
            player.addFeedback(Codes.POPUP_PREFIX + e.shareToken + " has invited you to " +
                "Vampire Whirled and is now your sire!");

            if (isPlayer(inviterId)) {
                getPlayer(inviterId).addFeedback(Codes.POPUP_PREFIX +
                    player.name + " has become your progeny!");
            }

            //Tally the successful invites for trophies
            playerInvitedByPlayer(player.playerId, inviterId);
        }
        else {
            log.warning("handleShareTokenMessage, but our sire != 0", "e", e);
        }
    }
    protected static function handleFeedRequestMessage (player :PlayerData, e :FeedRequestMsg) :void
    {
        log.debug("handleFeedRequestMessage");

        if (player == null || player.room == null || e == null) {
            log.error("handleFeedRequestMessage", "player", player, "e", e);
            return;
        }

        var game :FeedingRecord;

        //If we're bared, return us the the default state.
//        if (player.state == VConstants.PLAYER_STATE_BARED) {
//            stateChange(player, VConstants.PLAYER_STATE_DEFAULT);
//            return;
//        }


        //Set info useful for later
        player.targetId = e.targetPlayer;
        player.targetLocation = [e.targetX, e.targetY, e.targetZ];

        //If a game lobby already exists, add ourselves to that game, and move into position.
        //Otherwise, first ask the prey.


        //Prey is already in a game, or the prey is a non-player, add ourselves.
        if (player.room.bloodBloomGameManager.isPreyInGame(e.targetPlayer)
            || !isPlayer(e.targetPlayer)) {

            //Make sure the prey immediately goes into bared mode
            if (isPlayer(e.targetPlayer)) {
                stateChange(getPlayer(e.targetPlayer), VConstants.PLAYER_STATE_BARED);
            }

            game = player.room.bloodBloomGameManager.requestFeed(
                e.playerId,
                e.targetPlayer,
                e.targetName,
                [e.targetX, e.targetY, e.targetZ]);//Prey location

            stateChange(player, VConstants.PLAYER_STATE_MOVING_TO_FEED);

//            log.debug("adding to game");
//            //Add ourselves to a game.  We'll check this later, when we arrive at our location
//            game = player.room.bloodBloomGameManager.requestFeed(
//                e.playerId,
//                (e.targetPlayer != 0 ? e.targetPlayer : -1),//BB used -1 as the AI player
//                [e.targetX, e.targetY, e.targetZ]);//Prey location
//
//            if (!game.isStarted) {
//
//                stateChange(player, VConstants.PLAYER_STATE_MOVING_TO_FEED);
////                if (player.room.isPlayer(e.targetPlayer)) {
////                }
////                else {
////                    stateChange(player, VConstants.GAME_MODE_MOVING_TO_FEED_ON_NON_PLAYER);
////                }
//            }
        }
        else {
            //If the prey is a player, ask permission.  Otherwise start up the lobby
            if (isPlayer(e.targetPlayer)) {
                log.debug("asking prey permission");
                //Ask the prey first.
                var preyPlayer :PlayerData = getPlayer(e.targetPlayer);
                if (preyPlayer != null) {
                    log.debug(player.name + " is asking " + preyPlayer.name + " to feed");
                    preyPlayer.ctrl.sendMessage(e.name, e.toBytes());
                }
            }
            else {//Not a player?  Walk to the target, on arrival we'll start up the lobby
                log.error("No player? WTF?");
//                actionChange(player, VConstants.GAME_MODE_MOVING_TO_FEED_ON_NON_PLAYER);
            }
        }

    }

    protected static function handleFeedConfirmMessage (player :PlayerData, e :FeedConfirmMsg) :void
    {
        log.debug("handleFeedConfirmMessage", "e", e);

        if (player == null) {
            log.error("handleFeedConfirmMessage", "player", player);
            return;
        }

        if (player.room == null || player.room.ctrl == null || !player.room.ctrl.isConnected()) {
            log.error("handleFeedConfirmMessage", "player.room", player.room);
            return;
        }

        var prey :PlayerData = getPlayer(e.playerId);
        if (prey == null) {
            log.error("handleFeedConfirmMessage", "prey", player);
            return;
        }

        if (e.isAllowedToFeed) {

            //Make sure the prey immediately goes into bared mode
            stateChange(prey, VConstants.PLAYER_STATE_BARED);

            //Join the game
            var game :FeedingRecord = player.room.bloodBloomGameManager.requestFeed(
                    player.playerId,
                    prey.playerId,
                    e.preyName,
                    player.targetLocation);//Prey location

            stateChange(player, VConstants.PLAYER_STATE_MOVING_TO_FEED);
//            if (!game.isStarted) {
//            }
        }
        else {
            player.addFeedback(prey.name + " denied your request to feed.");
        }
    }

    protected static function getPlayer (playerId :int) :PlayerData
    {
        return ServerContext.server.getPlayer(playerId);
    }

    protected static function isPlayer (playerId :int) :Boolean
    {
        return ServerContext.server.isPlayer(playerId);
    }


    public static function makeSire (player :PlayerData, targetPlayerId :int) :void
    {
        if (player == null) {
            return;
        }
        if (targetPlayerId == player.sire) {
            return;
        }
        var oldSire :int = player.sire;
        log.info(player.playerId + " makeSire(" + targetPlayerId + ")");


        ServerContext.server.lineage.setPlayerSire(player.playerId, targetPlayerId);
        log.info(player.playerId + " then setting sire(" + ServerContext.server.lineage.getSireId(player.playerId) + ")");
        player.sire = ServerContext.server.lineage.getSireId(player.playerId);

//        ServerContext.minionHierarchy.updatePlayer(targetPlayerId);
//        ServerContext.server.lineage.updatePlayer(player.playerId);
//        ServerContext.minionHierarchy.updateIntoRoomProps();

//        if (oldSire != 0) {
//            ServerContext.server.lineage.updatePlayer(oldSire);
//        }
    }

//    public static function makeMinion(player :PlayerData, targetPlayerId :int) :void
//    {
//        log.info("makeMinion(" + targetPlayerId + ")");
//        ServerContext.server.lineage.setPlayerSire(targetPlayerId, playerId);
//
//        player.setSire(ServerContext.server.lineage.getSireId(playerId));
//
//        ServerContext.server.lineage.updatePlayer(playerId);
////        ServerContext.minionHierarchy.updateIntoRoomProps();
//    }




    /**
    * Here we check if we are allowed to change action.
    * ATM we just allow it.
    */
    protected static function handleBloodBondRequest (player :PlayerData, e :BloodBondRequestMsg) :void
    {
        var targetPlayer :PlayerData = ServerContext.server.getPlayer(e.targetPlayer);

        if (targetPlayer == null) {
            log.debug("Cannot perform blood bond request unless both players are in the same room");
            return;
        }

        if (e.add) {

            player.bloodBond = e.targetPlayer;
        }
    }


    protected static function handleRequestActionChange (player :PlayerData, e :RequestStateChangeMsg) :void
    {
        log.debug("handleRequestActionChange(..), e.action=" + e.state);
        stateChange(player, e.state);
    }

    /**
    * Here we check if we are allowed to change action.
    * ATM we just allow it.
    */
    public static function stateChange (player :PlayerData, newState :String) :void
    {
        log.debug(player.name + " stateChange(" + newState + ")");
        if (player == null || player.room == null) {
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



        switch (newState) {
            case VConstants.PLAYER_STATE_BARED:

                //If I'm feeding, just break off the feed.
                if (room.bloodBloomGameManager.isPredatorInGame(playerId)) {
                    room.bloodBloomGameManager.playerQuitsGame(playerId);
                    player.state = VConstants.PLAYER_STATE_DEFAULT;
                    break;
                }

//                //If we are alrady in bare mode, toggle it, unless we are in a game.
//                //Then we should quit the game to get out of bared mode
//                if (player.state == VConstants.PLAYER_STATE_BARED) {
//                    if (!room.bloodBloomGameManager.isPreyInGame(playerId)) {
//                        player.setState(VConstants.PLAYER_STATE_DEFAULT);
//                        break;
//                    }
//                }

                //Otherwise, go into bared mode.  Whay not?
                player.state = newState;
                break;


//            case VConstants.AVATAR_STATE_MOVING_TO_FEED:
            case VConstants.PLAYER_STATE_MOVING_TO_FEED:
            /**
            * Move the avatar into position.  Once it's in position, we can join the lobby.
            */


                //Make sure we don't overwrite existing feeding.
                if (player.state != VConstants.PLAYER_STATE_MOVING_TO_FEED) {
                    player.state = newState;
                }

                //Check if there are any games existing.
                game = room.bloodBloomGameManager.getGame(player.targetId);
//                if (game == null) {
//                    //No game, ok start one.  This does NOT start a BB game, just inits a record
//                    //so that other players will not stand on the wrong place.
//                    room.bloodBloomGameManager.f
//                }

                if (game == null) {
                    log.error("stateChange(" + newState + ") but no game. We should have already registered.");
//                    log.error("no game hmmm.  here is the bbmanager:" + room.bloodBloomGameManager);
                    break;
                }
                var targetLocation :Array = player.targetLocation;
                var avatar :AVRGameAvatar = player.avatar;

                angleRadians = new Vector2(targetLocation[0] - avatar.x, targetLocation[2] - avatar.z).angle;
                degs = convertStandardRads2GameDegrees(angleRadians);
                var predIndex :int = game == null ? 0 : game.getPredIndex(player.playerId);
                predLocIndex = MathUtil.clamp(predIndex, 0,
                    VConstants.PREDATOR_LOCATIONS_RELATIVE_TO_PREY.length - 1);

                var msg :MovePredIntoPositionMsg = new MovePredIntoPositionMsg(
                    player.playerId, player.targetId, predLocIndex == 0, predLocIndex, targetLocation);

               player.ctrl.sendMessage(msg.name, msg.toBytes());
               break;

            case VConstants.PLAYER_STATE_ARRIVED_AT_FEEDING_LOCATION:

                game = room.bloodBloomGameManager.getGame(playerId);



                if (game == null) {
                    log.error("actionChange(" + newState + ") but no game. We should have already registered.");
                    log.error("_room._bloodBloomGameManager=" + room.bloodBloomGameManager);
                    break;
                }

                if (game.isFinished) {
                    log.error("actionChange(" + newState + ") but game finished");
                    break;
                }

//                if (!ArrayUtil.contains(game.gameServer.predatorIds, playerId)) {
//                    game.gameServer.addPredator(playerId);
//                }

//
//                if (!game.isPredator(playerId)) {
//                    log.error("actionChange(" + newState + ") but not predator in game. We should have already registered.");
//                    log.error("_room._bloodBloomGameManager=" + room.bloodBloomGameManager);
//                    break;
//                }

                player.state = newState;
//                plaupdateAvatarState();
                if (game.isLobbyStarted) {
                    log.debug("    Joining lobby...");
                    game.joinLobby(player.playerId);
                }
                else {
                    log.debug("    Starting lobby...");
                    game.startLobby();
                }
//                if (game.multiplePredators) {
//                    if (!game.isCountDownTimerStarted) {
//                        game.startCountDownTimer();
//                    }
//                }
//                else {
//                }



                //Make sure the player is facing the same direction as the prey when they arrive


                break;

//                case VConstants.PLAYER_STATE_FEEDING_PREDATOR:
//                player.setState(VConstants.PLAYER_STATE_FEEDING_PREDATOR);
//                break;

            default:
                player.state = newState;


        }

        updateAvatarState(player);

        function convertStandardRads2GameDegrees(rad :Number) :Number
        {
            return MathUtil.toDegrees(MathUtil.normalizeRadians(rad + Math.PI / 2));
        }

    }



//    public static function enteredRoom (player :PlayerData, evt :AVRGamePlayerEvent) :void
//    {
//
//        log.info(VConstants.DEBUG_MINION + " Player entered room {{{", "player", toString());
//        log.debug(VConstants.DEBUG_MINION + " hierarchy=" + ServerContext.server.lineage);
//
////        log.debug(Constants.DEBUG_MINION + " Player enteredRoom, already on the database=" + toString());
////        log.debug(Constants.DEBUG_MINION + " Player enteredRoom, hierarch=" + ServerContext.minionHierarchy);
//
////            var thisPlayer :PlayerData = this;
//            var room :Room = ServerContext.vserver.getRoom(int(evt.value));
//            ServerContext.vserver.control.doBatch(function () :void {
//                try {
//                    if (room != null) {
////                        var minionsBytes :ByteArray = ServerContext.minionHierarchy.toBytes();
////                        ServerContext.serverLogBroadcast.log("enteredRoom, sending hierarchy=" + ServerContext.minionHierarchy);
////                        _room.ctrl.props.set(Codes.ROOM_PROP_MINION_HIERARCHY, minionsBytes);
//
//                        room.playerEntered(player);
//                        ServerContext.server.lineage.playerEnteredRoom(player, room);
//                        player.updateAvatarState();
//                    }
//                    else {
//                        log.error("WTF, enteredRoom called, but room == null???");
//                    }
//                }
//                catch(err:Error)
//                {
//                    log.error(err.getStackTrace());
//                }
//            });
//
//        //Make sure we are the right color when we enter a room.
////        handleChangeColorScheme((isVampire() ? VConstants.COLOR_SCHEME_VAMPIRE : VConstants.COLOR_SCHEME_HUMAN));
////        setIntoRoomProps();
//
//        log.debug(VConstants.DEBUG_MINION + "after _room.playerEntered");
//        log.debug(VConstants.DEBUG_MINION + "hierarchy=" + ServerContext.server.lineage);
//
//    }

//    public static function updateAvatarState(player :PlayerData) :void
//    {
//        var newState :String = "Default";
//
//        if (player.state == VConstants.AVATAR_STATE_BARED) {
//            newState = player.state;
//        }
//
//        if (player.state == VConstants.AVATAR_STATE_FEEDING ||
//            player.state == VConstants.GAME_MODE_FEED_FROM_NON_PLAYER) {
//            newState = VConstants.AVATAR_STATE_FEEDING;
//        }
//
//        if (newState != player.avatarState) {
//            log.debug(player.playerId + " updateAvatarState(" + newState + "), when action=" + player.state);
//            player.setAvatarState(newState);
//        }
//    }

    /**
    * If the avatar moves, break off the feeding/baring.
    */
    protected static function handleAvatarMoved (player :PlayerData, userIdMoved :int) :void
    {
        //Moving nullifies any action we are currently doing, except if we are heading to
        //feed.

        switch (player.state) {

            case VConstants.PLAYER_STATE_MOVING_TO_FEED:

//            case VConstants.GAME_MODE_MOVING_TO_FEED_ON_NON_PLAYER:
                break;//Don't change our state if we are moving into position

            case VConstants.PLAYER_STATE_FEEDING_PREDATOR:
            case VConstants.PLAYER_STATE_FEEDING_PREY:
            case VConstants.PLAYER_STATE_BARED:
//                var victim :PlayerData = ServerContext.server.getPlayer(player.targetId);
//                if (victim != null) {
//                    victim.setState(VConstants.AVATAR_STATE_DEFAULT);
//                }
//                else {
//                    log.error("avatarMoved(), we shoud be breaking off a victim, but there is no victim.");
//                }
                stateChange(player, VConstants.PLAYER_STATE_DEFAULT);
//                player.setState(VConstants.AVATAR_STATE_DEFAULT);
                break;

//            case VConstants.AVATAR_STATE_BARED:
////                var predator :PlayerData = ServerContext.server.getPlayer(player.targetId);
////                if (predator != null) {
////                    predator.setState(VConstants.AVATAR_STATE_DEFAULT);
////                }
////                else {
////                    log.error("avatarMoved(), we shoud be breaking off a victim, but there is no victim.");
////                }
////                player.setState(VConstants.AVATAR_STATE_DEFAULT);
//                stateChange(player, VConstants.PLAYER_STATE_DEFAULT);
//                break;


//            case VConstants.GAME_MODE_FEED_FROM_NON_PLAYER:
            default :
                player.state = VConstants.AVATAR_STATE_DEFAULT;
        }
    }

   public static function bloodBloomRoundOver (gameRecord :FeedingRecord, finalScores :HashMap) :void
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

        var preyIsPlayer :Boolean = srv.isPlayer(gameRecord.gameServer.preyId);
        var preyPlayer :PlayerData = preyIsPlayer ? srv.getPlayer(gameRecord.gameServer.preyId) : null;
        var preyId :int = gameRecord.gameServer.preyId;

        //Send the LeaderBoard the scores
        log.debug("Sending message to LeaderBoardServer");
        ServerContext.server.sendMessageToNamedObject(
            new ObjectMessage(LeaderBoardServer.MESSAGE_LEADER_BOARD_MESSAGE_SCORES, finalScores),
            LeaderBoardServer.NAME);

        var predIds :Array = [];
        finalScores.forEach(function (playerId :int, score :int) :void {
            if (score > 0 && playerId != gameRecord.gameServer.preyId) {
                predIds.push(playerId);
            }
        });

        for each(var predatorId :int in predIds) {
            var pred :PlayerData = srv.getPlayer(predatorId);
            if (pred == null) {
                log.error("adding blood, but no pred", "predatorId", predatorId);
                continue;
            }

            if (preyIsPlayer && preyPlayer != null) {
                //Check if we don't have a sire.  The prey vampire becomes it.
                if (!ServerContext.server.lineage.isMemberOfLineage(pred.playerId)) {
                    if (ServerContext.server.lineage.isMemberOfLineage(preyId)) {
                        makeSire(pred,  preyPlayer.playerId);
                        pred.addFeedback(Codes.POPUP_PREFIX + preyPlayer.name +
                            " has become your sire!");

                        //Award coins to the sire
                        preyPlayer.ctrl.completeTask(Codes.TASK_ACQUIRE_PROGENY_ID,
                            Codes.TASK_ACQUIRE_PROGENY_SCORE);

                        //Award to sires two levels up
                        var numberOfGrandGenerationsToAward :int = 2;

                        var currentSireId :int = ServerContext.server.lineage.getSireId(
                            preyPlayer.playerId);
                        var generations :int = 1;

                        while (currentSireId != 0 && generations <= 2) {
                            if (srv.isPlayer(currentSireId)
                                && srv.getPlayer(currentSireId).room != null) {
                                var grandSirePlayer :PlayerData = srv.getPlayer(currentSireId);

                                //Tell the sire she's got children
                                grandSirePlayer.room.addFeedback(Codes.POPUP_PREFIX +
                                    pred.name + " has joined your Lineage! ", currentSireId);

                                //Award coins to the sire(s)
                                grandSirePlayer.ctrl.completeTask(Codes.TASK_ACQUIRE_PROGENY_ID,
                                    Codes.TASK_ACQUIRE_PROGENY_SCORE/10);

                            }
                            currentSireId = ServerContext.server.lineage.getSireId(currentSireId);
                            generations++;
                        }

//                        var preySireId :int = ServerContext.server.lineage.getSireId(preyPlayer.playerId);
//
//
//
//                        if (preyPlayer.sire
//
//                        for each(var sireId :int in
//                            ServerContext.server.lineage.getAllSiresAndGrandSires(pred.playerId).toArray()) {
//
//                            if (srv.isPlayer(sireId)
//                                && srv.getPlayer(sireId).room != null) {
//
//                                //Tell the sire she's got children
//                                srv.getPlayer(sireId).room.addFeedback(Codes.POPUP_PREFIX +
//                                    pred.name + " has joined your Lineage! ", sireId);
//
//                                //Award coins to the sire(s)
//                                preyPlayer.ctrl.completeTask(Codes.TASK_ACQUIRE_PROGENY_ID,
//                                    Codes.TASK_ACQUIRE_PROGENY_SCORE/10);
//
//                            }
//                        }
                    }
                    else {
                        pred.addFeedback(preyPlayer.name + " is not part of the Lineage (Progeny of Lilith).  Feed from a Lineage member to join.");
                        preyPlayer.addFeedback("You are not part of the Lineage (Progeny of Lilith), so " + pred.name + " cannot become your progeny. "
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


        //Then handle experience.  ATM everyone gets xp=score
        var numPlayers :Number = predIds.length + (gameRecord.gameServer.preyId != 0 ? 1 : 0);
        var playerScore :Number = gameRecord.gameServer.lastRoundScore / numPlayers;
        //Update the highest possible score.  We use this to scale the coin payout
        ServerContext.topBloodBloomScore = Math.max(ServerContext.topBloodBloomScore, playerScore);
        var xpGained :Number = playerScore * VConstants.XP_GAINED_FROM_FEEDING_PER_BLOOD_UNIT;
        var xpFormatted :String = Util.formatNumberForFeedback(xpGained);
        //The score between [0,1]
        var feedingScoreScaled :Number = playerScore / ServerContext.topBloodBloomScore;

        function awardXP(playerId :int, xp :Number, xpFormatted :String) :void {
            if (xp == 0) {
                return;
            }

            var p :PlayerData = ServerContext.server.getPlayer(playerId);
            if (p != null) {
                addXP(p.playerId, xp);
                p.addFeedback("You gained " + xpFormatted + " experience from feeding!");
                //Add some bonus xp to your blood bond, if they are online
                awardBloodBondedXpEarned(p, xp);
                //Add some bonus xp to your sires
                awardSiresXpEarned(p, xp);
                p.ctrl.completeTask(Codes.TASK_FEEDING_ID, feedingScoreScaled);
            }
        }

        if (preyIsPlayer && preyPlayer != null) {
            awardXP(gameRecord.preyId, xpGained, xpFormatted);
        }

        gameRecord.predators.forEach(function(predId :int) :void {
            //Only award xp if the pred score was > 0
            //This also excludes players that loin the lobby after the feed is started.
            if (finalScores.get(predId) > 0) {
                awardXP(predId, xpGained, xpFormatted);
            }
        });
    }

    /**
    * Maps the player state to the visible avatar state, and update if necessary.
    */
    public static function updateAvatarState (player :PlayerData) :void
    {
        if (player == null || player.avatar == null || player.room == null) {
            return;
        }
        var newAvatarState :String = VConstants.AVATAR_STATE_DEFAULT;
        var playerState :String = player.state;

        switch (playerState) {
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

//        var currentAvatarState :String = player.avatarState;
        var currentAvatarState :String = player.avatar != null ? player.avatar.state : "Default";

        if (newAvatarState != currentAvatarState) {
            log.debug(player.name + " updateAvatarState(" + newAvatarState + "), when action=" + playerState);
            player.ctrl.setAvatarState(newAvatarState);
//            player.setAvatarState(newAvatarState);
        }
        else {
            log.debug(player.name + " updateAvatarState(" + newAvatarState + "), but not changing since we are=" + currentAvatarState);
        }
    }





    protected static const log :Log = Log.getLog(ServerLogic);

}
}