package vampire.server
{

import com.threerings.flash.MathUtil;
import com.threerings.flash.Vector2;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.OfflinePlayerPropertyControl;
import com.whirled.avrg.PlayerSubControlServer;
import com.whirled.contrib.simplegame.ObjectMessage;
import com.whirled.contrib.simplegame.SimObject;
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
import vampire.net.messages.FeedRequestCancelMsg;
import vampire.net.messages.FeedRequestMsg;
import vampire.net.messages.FeedingDataMsg;
import vampire.net.messages.GameStartedMsg;
import vampire.net.messages.MovePredIntoPositionMsg;
import vampire.net.messages.RoomNameMsg;
import vampire.net.messages.SendGlobalMsg;
import vampire.net.messages.ShareTokenMsg;
import vampire.server.feeding.FeedingRecord;
import vampire.server.feeding.LogicFeeding;



public class LogicServer extends SimObject
{

//    override protected function addedToDB () :void
//    {
//        registerListener(ServerContext.ctrl.game, MessageReceivedEvent.MESSAGE_RECEIVED,
//            handleMessageReceived);
//    }

    override public function getObjectGroup (groupNum :int) :String
    {
        switch (groupNum) {
            case 0: return GameServer.GROUP_MESSAGE_LISTENERS;
            // 1 is the number of groups this class defines
            default: return super.getObjectGroup(groupNum - 1);
        }
    }

    override protected function receiveMessage (msg:ObjectMessage) :void
    {
        if (msg is ServerObjectMessage) {
            handleMessage(ServerObjectMessage(msg).player, ServerObjectMessage(msg).msg);
        }
    }


    public static function increaseLevel (player :PlayerData) :void
    {
        var xpNeededForNextLevel :Number = Logic.xpNeededForLevel(player.level + 1);
        var missingXp :Number = xpNeededForNextLevel - player.xp;
        addXP(player.playerId, missingXp);
    }

    public static function decreaseLevel (player :PlayerData) :void
    {
        if (player.level > 1) {
            var xpNeededForCurrentLevel :int = Logic.xpNeededForLevel(player.level);
            var missingXp :Number = -(player.xp - xpNeededForCurrentLevel) - 1;
            addXP(player.playerId, missingXp)
        }
    }

    public static function addXP (playerId :int, bonus :Number) :void
    {
         if (ServerContext.server.isPlayer(playerId)) {
             var player :PlayerData = ServerContext.server.getPlayer(playerId);
             player.xp = player.xp + bonus;
        }
        else {
            //Add to offline database
            ServerContext.ctrl.loadOfflinePlayer(playerId,
                function (props :OfflinePlayerPropertyControl) :void {
                    var currentXP :Number = Number(props.get(Codes.PLAYER_PROP_XP_SLEEP));
                    if (!isNaN(currentXP)) {
                        props.set(Codes.PLAYER_PROP_XP_SLEEP, currentXP + bonus);
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
//    public static function handleMessage (player :PlayerData, name :String, value :Object) :void
    public static function handleMessage (player :PlayerData, msg :Message) :void
    {
        var room :Room = player.room;
        var playerId :int = player.playerId;

        try{

            // handle messages that make (at least some) sense even if we're between rooms
            //Attempt to handle Message type message first
//            var msg :Message = ServerContext.msg.deserializeMessage(name, value);
//            log.debug(playerId + " handleMessage() GameMessage: ", "name", name, "value", msg);
            if (msg != null) {
                if (msg is AvatarChosenMsg) {
                    handleAvatarChosenMessage(player, AvatarChosenMsg(msg));
                }
                else if (msg is BloodBondRequestMsg) {
                    handleBloodBondRequest(player, BloodBondRequestMsg(msg));
                }
//                else if (msg is FeedRequestMsg) {
//                    LogicFeeding.handleFeedRequestMessage(player, FeedRequestMsg(msg));
//                }
                else if (msg is ShareTokenMsg) {
                    handleShareTokenMessage(player, ShareTokenMsg(msg));
                }
//                else if (msg is FeedConfirmMsg) {
//                    var feedConfirm :FeedConfirmMsg = FeedConfirmMsg(msg);
//                    LogicFeeding.handleFeedConfirmMessage(player, feedConfirm);
//                }
//                else if (msg is FeedRequestCancelMsg) {
//                    var feedCancel :FeedRequestCancelMsg = FeedRequestCancelMsg(msg);
//                    LogicFeeding.handleFeedRequestCancel(player, feedCancel);
//                }
//                else if (msg is FeedingDataMsg) {
//                    var bytes :ByteArray = FeedingDataMsg(msg).feedingData;
//                    if (bytes != null) {
//                        player.feedingData = bytes;
//                    }
//                }
                else if (msg is GameStartedMsg) {
                    var gameStarted :GameStartedMsg = GameStartedMsg(msg);
                    var playerStarted :PlayerData = getPlayer(gameStarted.playerId);
                    handleGameStartedMessage(playerStarted, gameStarted);
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
                    handleDebug(player, debugMsg);
                }
            }
        }
        catch(err :Error) {
            log.error(err.getStackTrace());
        }

    }

    protected static function handleDebug (player :PlayerData, debugMsg :DebugMsg) :void
    {
        log.debug("handleDebug", "player", player, "debugMsg", debugMsg);
        switch (debugMsg.type) {
            case DebugMsg.DEBUG_GAIN_XP:
            log.debug("handleDebug", "addXP", 500);
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
            log.debug("No registered debug type: " + debugMsg);
            break;
        }
    }

    protected static function handleAvatarChosenMessage (player :PlayerData,
        msg :AvatarChosenMsg) :void
    {
        log.debug(msg);
        if (msg.isFemale) {
            PlayerSubControlServer(player.ctrl).awardPrize(Trophies.BASIC_AVATAR_FEMALE);
        }
        else {
            PlayerSubControlServer(player.ctrl).awardPrize(Trophies.BASIC_AVATAR_MALE);
        }
        player.ctrl.props.set(Codes.PLAYER_PROP_TIME, 1);
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
        player.sire = targetPlayerId;
        log.info(player.playerId + " then setting sire(" + ServerContext.server.lineage.getSireId(player.playerId) + ")");
    }

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


//    protected static function handleRequestActionChange (player :PlayerData, e :RequestStateChangeMsg) :void
//    {
//        log.debug("handleRequestActionChange(..), e.action=" + e.state);
//        stateChange(player, e.state);
//    }

//    /**
//    * Here we check if we are allowed to change action.
//    * ATM we just allow it.
//    */
//    public static function stateChange2 (player :PlayerData, newState :String) :void
//    {
//        log.debug(player.name + " stateChange(" + newState + ")");
//        if (player == null || player.room == null) {
//            log.error("room null");
//            return;
//        }
//        var angleRadians :Number;
//        var degs :Number;
//        var game :FeedingRecord;
//        var predLocIndex :int;
//        var newLocation :Array;
//        var targetX :Number;
//        var targetY :Number;
//        var targetZ :Number;
//        var playerId :int = player.playerId;
//        var room :Room = player.room;
//
//
//
//        switch (newState) {
//            case VConstants.PLAYER_STATE_BARED:
//
//                //If I'm feeding, just break off the feed.
////                if (room.bloodBloomGameManager.isPredatorInGame(playerId)) {
////                    room.bloodBloomGameManager.playerQuitsGameOrRoom(playerId);
////                    player.state = VConstants.PLAYER_STATE_DEFAULT;
////                    break;
////                }
//
////                //If we are alrady in bare mode, toggle it, unless we are in a game.
////                //Then we should quit the game to get out of bared mode
////                if (player.state == VConstants.PLAYER_STATE_BARED) {
////                    if (!room.bloodBloomGameManager.isPreyInGame(playerId)) {
////                        player.setState(VConstants.PLAYER_STATE_DEFAULT);
////                        break;
////                    }
////                }
//
//                //Otherwise, go into bared mode.  Why not?
////                player.state = newState;
//                break;
//
//
////            case VConstants.AVATAR_STATE_MOVING_TO_FEED:
//            case VConstants.PLAYER_STATE_MOVING_TO_FEED:
//            /**
//            * Move the avatar into position.  The lobby is started immediately.
//            */
//
//
//                //Make sure we don't overwrite existing feeding.
////                if (player.state != VConstants.PLAYER_STATE_MOVING_TO_FEED) {
////                    player.state = newState;
////                }
//
//                //Check if there are any games existing.
//                game = room.bloodBloomGameManager.getGame(player.targetId);
////                if (game == null) {
////                    //No game, ok start one.  This does NOT start a BB game, just inits a record
////                    //so that other players will not stand on the wrong place.
////                    room.bloodBloomGameManager.f
////                }
//
//                if (game == null) {
//                    log.warning("stateChange(" + newState + ") but no game. We should have already registered.");
////                    log.error("no game hmmm.  here is the bbmanager:" + room.bloodBloomGameManager);
//                    break;
//                }
//                var targetLocation :Array = player.targetLocation;
//                var avatar :AVRGameAvatar = player.avatar;
//
//                angleRadians = new Vector2(targetLocation[0] - avatar.x, targetLocation[2] - avatar.z).angle;
//                degs = convertStandardRads2GameDegrees(angleRadians);
//                var predIndex :int = game == null ? 0 : game.getPredIndex(player.playerId);
//                predLocIndex = MathUtil.clamp(predIndex, 0,
//                    VConstants.PREDATOR_LOCATIONS_RELATIVE_TO_PREY.length - 1);
//
//                var msg :MovePredIntoPositionMsg = new MovePredIntoPositionMsg(
//                    player.playerId, player.targetId, predLocIndex == 0, predLocIndex, targetLocation);
//
//               PlayerSubControlServer(player.ctrl).sendMessage(msg.name, msg.toBytes());
////               stateChange(player, VConstants.PLAYER_STATE_ARRIVED_AT_FEEDING_LOCATION);
//               break;
//
//            case VConstants.PLAYER_STATE_ARRIVED_AT_FEEDING_LOCATION:
//
////                game = room.bloodBloomGameManager.getGame(playerId);
////
////                if (game == null) {
////                    log.error("actionChange(" + newState + ") but no game. We should have already registered.");
////                    log.error("_room._bloodBloomGameManager=" + room.bloodBloomGameManager);
////                    break;
////                }
////
////                if (game.isFinished) {
////                    log.error("actionChange(" + newState + ") but game finished");
////                    break;
////                }
//
////                if (!ArrayUtil.contains(game.gameServer.predatorIds, playerId)) {
////                    game.gameServer.addPredator(playerId);
////                }
//
////
////                if (!game.isPredator(playerId)) {
////                    log.error("actionChange(" + newState + ") but not predator in game. We should have already registered.");
////                    log.error("_room._bloodBloomGameManager=" + room.bloodBloomGameManager);
////                    break;
////                }
//
////                player.state = newState;
////                plaupdateAvatarState();
////                if (game.isLobbyStarted) {
////                    log.debug("    Joining lobby...");
////                    game.joinLobby(player.playerId);
////                }
////                else {
////                    log.debug("    Starting lobby...");
////                    game.startLobby();
////                }
////                if (game.multiplePredators) {
////                    if (!game.isCountDownTimerStarted) {
////                        game.startCountDownTimer();
////                    }
////                }
////                else {
////                }
//
//
//
//                //Make sure the player is facing the same direction as the prey when they arrive
//
//
//                break;
//
////                case VConstants.PLAYER_STATE_FEEDING_PREDATOR:
////                player.setState(VConstants.PLAYER_STATE_FEEDING_PREDATOR);
////                break;
//
//            default:
////                player.state = newState;
//
//
//        }
//
//        updateAvatarState(player);
//
//        function convertStandardRads2GameDegrees(rad :Number) :Number
//        {
//            return MathUtil.toDegrees(MathUtil.normalizeRadians(rad + Math.PI / 2));
//        }
//
//    }



    /**
    * Maps the player state to the visible avatar state, and update if necessary.
    * Don't call this in an update loop.
    */
    public static function updateAvatarState (player :PlayerData) :void
    {
        if (player == null || player.avatar == null || player.room == null) {
            return;
        }
        var newAvatarState :String = player.avatar.state;
//
//        switch (player.state) {
//
//            case VConstants.PLAYER_STATE_DEFAULT:
//            newAvatarState = VConstants.AVATAR_STATE_DEFAULT;
//            break;
//
//            case VConstants.PLAYER_STATE_BARED:
//            newAvatarState = VConstants.AVATAR_STATE_BARED;
//            break;
//
//            case VConstants.PLAYER_STATE_FEEDING_PREDATOR:
//            newAvatarState = VConstants.AVATAR_STATE_FEEDING;
//            break;
//
//            case VConstants.PLAYER_STATE_FEEDING_PREY:
//            newAvatarState = VConstants.AVATAR_STATE_BARED;
//            break;
//
//            case VConstants.PLAYER_STATE_MOVING_TO_FEED:
//            newAvatarState = VConstants.AVATAR_STATE_DEFAULT;
//            break;
//
//            case VConstants.PLAYER_STATE_ARRIVED_AT_FEEDING_LOCATION:
//            newAvatarState = VConstants.AVATAR_STATE_FEEDING;
//            break;
//
//        }

        if (newAvatarState != player.avatar.state) {
            player.ctrl.setAvatarState(newAvatarState);
        }
    }





    protected static const log :Log = Log.getLog(LogicServer);

}
}