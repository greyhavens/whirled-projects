package vampire.server.feeding
{
    import com.threerings.flash.MathUtil;
    import com.threerings.flash.Vector2;
    import com.threerings.util.Log;
    import com.whirled.avrg.AVRGameAvatar;
    import com.whirled.avrg.OfflinePlayerPropertyControl;
    import com.whirled.avrg.PlayerSubControlServer;
    import com.whirled.contrib.simplegame.net.Message;
    import com.whirled.contrib.simplegame.objects.BasicGameObject;

    import flash.utils.ByteArray;

    import vampire.Util;
    import vampire.data.Codes;
    import vampire.data.VConstants;
    import vampire.feeding.FeedingRoundResults;
    import vampire.net.messages.DebugMsg;
    import vampire.net.messages.FeedConfirmMsg;
    import vampire.net.messages.FeedRequestCancelMsg;
    import vampire.net.messages.FeedRequestMsg;
    import vampire.net.messages.FeedingDataMsg;
    import vampire.net.messages.MovePredIntoPositionMsg;
    import vampire.server.GameServer;
    import vampire.server.LogicServer;
    import vampire.server.PlayerData;
    import vampire.server.Room;
    import vampire.server.ServerContext;

public class LogicFeeding extends BasicGameObject
{

    public static function handleMessage (player :PlayerData, msg :Message) :void
    {
        var room :Room = player.room;
        var playerId :int = player.playerId;

        try{
            if (msg != null) {
                if (msg is FeedRequestMsg) {
                    LogicFeeding.handleFeedRequestMessage(player, FeedRequestMsg(msg));
                }
                else if (msg is FeedConfirmMsg) {
                    var feedConfirm :FeedConfirmMsg = FeedConfirmMsg(msg);
                    LogicFeeding.handleFeedConfirmMessage(player, feedConfirm);
                }
                else if (msg is FeedRequestCancelMsg) {
                    var feedCancel :FeedRequestCancelMsg = FeedRequestCancelMsg(msg);
                    LogicFeeding.handleFeedRequestCancel(player, feedCancel);
                }
                else if (msg is FeedingDataMsg) {
                    var bytes :ByteArray = FeedingDataMsg(msg).feedingData;
                    if (bytes != null) {
                        player.feedingData = bytes;
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
            case DebugMsg.DEBUG_RESET_HIGH_SCORES:
            if (FeedingContext.leaderBoardServer != null) {
                FeedingContext.leaderBoardServer.resetScores();
            }
            break;

            default:
            break;
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

    public static function bloodBloomRoundOver (gameRecord :FeedingRecord,
        results :FeedingRoundResults) :void
    {
        log.debug("bloodBloomRoundOver()", "gameRecord", gameRecord);
        var srv :GameServer = ServerContext.server;

        if (gameRecord == null) {
            log.error("bloodBloomRoundOver gameRecord==null");
            return;
        }
        if (results == null) {
            log.error("bloodBloomRoundOver", "results", results);
            return;
        }

        //Reference these once since they require computing
        var averageScore :Number = results.averageScore;
        var totalScore :Number = results.totalScore;

        var room :Room = gameRecord.room;
        if (room == null) {
            log.error("bloodBloomRoundOver", "gameRecord.room", room);
            return;
        }

        var preyIsPlayer :Boolean = srv.isPlayer(gameRecord.gameServer.preyId);
        var preyPlayer :PlayerData = preyIsPlayer ? srv.getPlayer(gameRecord.gameServer.preyId) : null;
        var preyId :int = gameRecord.gameServer.preyId;

        //Send the LeaderBoard the scores
        log.debug("Sending message to LeaderBoardServer");
        ServerContext.server.dispatchEvent(new FeedingHighScoreEvent(averageScore, results.scores));
//        ServerContext.server.sendMessageToNamedObject(
//            new ObjectMessage(LeaderBoardServer.MESSAGE_LEADER_BOARD_MESSAGE_SCORES,
//                [averageScore, results.scores]),
//            LeaderBoardServer.NAME);

        var predIds :Array = [];
        results.scores.forEach(function (playerId :int, score :Number) :void {
            if (score > 0 && playerId != gameRecord.preyId) {
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
                log.debug("server.lineage.isMemberOfLineage("+pred.playerId+")=" +
                    ServerContext.lineage.isMemberOfLineage(pred.playerId));

                log.debug("server.lineage.isMemberOfLineage("+preyId+")=" +
                    ServerContext.lineage.isMemberOfLineage(preyId));

                if (!ServerContext.lineage.isMemberOfLineage(pred.playerId)) {
                    if (ServerContext.lineage.isMemberOfLineage(preyId)) {
                        LogicServer.makeSire(pred,  preyPlayer.playerId);
                        log.info("Showing sire feedback popup.");
                        pred.addFeedback(Codes.POPUP_PREFIX + preyPlayer.name +
                            " is now your sire!", 3);

                        preyPlayer.addFeedback(Codes.POPUP_PREFIX + pred.name +
                            " is now one of your progeny!", 3);

                        //Award coins to the sire
                        preyPlayer.ctrl.completeTask(Codes.TASK_ACQUIRE_PROGENY_ID,
                            Codes.TASK_ACQUIRE_PROGENY_SCORE);
                        pred.ctrl.completeTask(Codes.TASK_ACQUIRE_PROGENY_ID,
                            Codes.TASK_ACQUIRE_PROGENY_SCORE);

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
        log.debug("End of feeding round, numPlayers=" + results.initialPlayerCount);

        //Check for wildly huge scores.  Probably a bug
        if (averageScore > VConstants.MAX_THEORETICAL_FEEDING_SCORE) {
            log.error("Score error?", "MAX_THEORETICAL_FEEDING_SCORE",
                VConstants.MAX_THEORETICAL_FEEDING_SCORE, "averageScore",
                averageScore);
            return;
        }
        //Update the highest possible score.  We use this to scale the coin payout
        FeedingContext.topBloodBloomScore = Math.max(FeedingContext.topBloodBloomScore, averageScore);
        var xpGained :Number = averageScore * VConstants.XP_GAINED_FROM_FEEDING_PER_BLOOD_UNIT;
        var xpFormatted :String = Util.formatNumberForFeedback(xpGained);
        //The score between [0,1]
        var feedingScoreScaled :Number = averageScore / FeedingContext.topBloodBloomScore;

        function awardXP(playerId :int, xp :Number, xpFormatted :String) :void {
            if (xp == 0) {
                return;
            }

            var p :PlayerData = ServerContext.server.getPlayer(playerId);
            if (p != null) {
                LogicServer.addXP(p.playerId, xp);
                p.addFeedback("You gained " + xpFormatted + " experience from feeding!");

                //Notify the analyser
//                ServerContext.server.sendMessageToNamedObject(
//                    new ObjectMessage(AnalyserServer.MSG_RECEIVED_FEEDING_PAYOUT,
//                        [playerId, xp, results.scores.get(playerId)]),
//                    AnalyserServer.NAME);

                //Add some bonus xp to your blood bond, if they are online
                awardBloodBondedXpEarned(p, xp);
                //Add some bonus xp to your sires
                awardSiresXpEarned(p, xp);
                p.ctrl.completeTask(Codes.TASK_FEEDING, feedingScoreScaled);
            }
        }

        if (preyIsPlayer && preyPlayer != null) {
            awardXP(gameRecord.gameServer.preyId, xpGained, xpFormatted);
        }

        gameRecord.gameServer.predatorIds.forEach(function(predId :int, ...ignored) :void {
            //Only award xp if the pred score was > 0
            //This also excludes players that loin the lobby after the feed is started.
            if (results.scores.get(predId) > 0) {
                awardXP(predId, xpGained, xpFormatted);
            }
        });
    }

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
        if (!ServerContext.lineage.isMemberOfLineage(player.playerId)) {
            return;
        }

        function awardXP(sireId :int, awardXP :Number) :void {

//            ServerContext.server.sendMessageToNamedObject(
//                new ObjectMessage(AnalyserServer.MSG_RECEIVED_PROGENY_PAYOUT, [sireId, awardXP]),
//                AnalyserServer.NAME);

            if (ServerContext.server.isPlayer(sireId)) {
                var sire :PlayerData = ServerContext.server.getPlayer(sireId);
                log.debug("awarding sire " + sire.name + ", xp=" + awardXP);
                LogicServer.addXP(sire.playerId, awardXP);
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

        var currentSireId :int = ServerContext.lineage.getSireId(player.playerId);
        var generations :int = 1;
        var immediateSire :int = ServerContext.lineage.getSireId(player.playerId);

        while (currentSireId != 0 && generations <= 2) {

            if (currentSireId == immediateSire) {
                awardXP(currentSireId, xp * VConstants.XP_GAIN_FRACTION_SHARED_WITH_IMMEDIATE_SIRE);
            }
            else {
                awardXP(currentSireId, xp * VConstants.XP_GAIN_FRACTION_SHARED_WITH_GRANDSIRES);
            }
            currentSireId = ServerContext.lineage.getSireId(currentSireId);
            generations++;
        }
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
            LogicServer.addXP(bloodBondedPlayer.playerId,  xpBonus);
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

    /**
    * Move the avatar into position.  The lobby is started immediately.
    */
    public static function movePredatorIntoPosition (player :PlayerData, game :FeedingRecord) :void
    {
        if (player == null || player.room == null || game == null) {
            log.error("movePredatorIntoPosition", "player", player, "game", game);
            return;
        }

        if (player.avatar == null) {
            log.error("movePredatorIntoPosition", "player.avatar", player.avatar);
            return;
        }

        if (game.preyLocation == null) {
            log.error("movePredatorIntoPosition", "game.preyLocation", game.preyLocation);
            return;
        }

        var angleRadians :Number;
        var degs :Number;
        var predLocIndex :int;
        var newLocation :Array;
        var targetX :Number;
        var targetY :Number;
        var targetZ :Number;
        var playerId :int = player.playerId;
        var room :Room = player.room;


        var targetLocation :Array = game.preyLocation;
        var avatar :AVRGameAvatar = player.avatar;

        angleRadians = new Vector2(targetLocation[0] - avatar.x, targetLocation[2] - avatar.z).angle;
        degs = convertStandardRads2GameDegrees(angleRadians);
        var predIndex :int = game.getPredIndex(player.playerId);
        predLocIndex = MathUtil.clamp(predIndex, 0,
            VConstants.PREDATOR_LOCATIONS_RELATIVE_TO_PREY.length - 1);

        var msg :MovePredIntoPositionMsg = new MovePredIntoPositionMsg(
            player.playerId, player.targetId, predIndex == 0, predLocIndex, targetLocation);

       player.sctrl.sendMessage(MovePredIntoPositionMsg.NAME, msg.toBytes());

       function convertStandardRads2GameDegrees(rad :Number) :Number
       {
           return MathUtil.toDegrees(MathUtil.normalizeRadians(rad + Math.PI / 2));
       }

    }

    public static function handleFeedRequestMessage (player :PlayerData, e :FeedRequestMsg) :void
    {
        if (player == null || player.room == null || e == null) {
            log.error("handleFeedRequestMessage", "player", player, "e", e);
            return;
        }
        var roomFeedingManager :RoomFeedingManager =
            ServerContext.feedingManager.getRoomFeedingManager(player.room.roomId);
        //Set info useful for later
        player.targetId = e.targetPlayer;
//        player.targetLocation = [e.targetX, e.targetY, e.targetZ];

        //If a game lobby already exists, add ourselves to that game, and move into position.
        //Otherwise, first ask the prey.
        //Prey is already in a game, or the prey is a non-player, add ourselves.
        if (roomFeedingManager.isPreyInGame(e.targetPlayer)
            || !isPlayer(e.targetPlayer)) {

            log.info("Prey is already in a game (or it's a non-player)");
            log.debug("handleFeedRequestMessage, requestFeed", "preylocation", [e.targetX, e.targetY, e.targetZ, e.targetAngle]);
            var game :FeedingRecord = roomFeedingManager.requestFeed(
                e.predId,
                e.targetPlayer,
                e.targetName,
                [e.targetX, e.targetY, e.targetZ]);//Prey location
            //Send a request confirm back. This will destroy and unneeded popups.
            player.sctrl.sendMessage(FeedConfirmMsg.NAME, new FeedConfirmMsg(e.playerId,
                e.targetPlayer, "", e.predId, true).toBytes());;

        }
        else {
            //If the prey is a player, ask permission.  Otherwise start up the lobby
            if (isPlayer(e.targetPlayer)) {
                //Ask the prey first.
                var preyPlayer :PlayerData = getPlayer(e.targetPlayer);
                if (preyPlayer != null) {
                    log.debug(player.name + " is asking " + preyPlayer.name + " to feed");
                    preyPlayer.sctrl.sendMessage(e.name, e.toBytes());
                }
            }
            else {//Not a player?  Walk to the target, on arrival we'll start up the lobby
                log.error("No player? WTF?");
            }
        }

    }

    public static function handleFeedRequestCancel (prey :PlayerData, e :FeedRequestCancelMsg) :void
    {
        //Just send it to the client, so the popup can be destroyed.
        if (isPlayer(e.targetPlayer)) {
            getPlayer(e.targetPlayer).sctrl.sendMessage(e.name, e.toBytes());
        }
    }

    public static function handleFeedConfirmMessage (prey :PlayerData, e :FeedConfirmMsg) :void
    {
        log.debug("handleFeedConfirmMessage", "e", e);

        if (prey == null) {
            log.error("handleFeedConfirmMessage", "player", prey);
            return;
        }

        if (prey.room == null || prey.room.ctrl == null || !prey.room.ctrl.isConnected()) {
            log.error("handleFeedConfirmMessage", "player.room", prey.room);
            return;
        }

        if (prey == null) {
            log.error("handleFeedConfirmMessage", "prey", prey);
            return;
        }
        var requestingPlayer :PlayerData = getPlayer(e.predatorId);

        if (e.isAllowedToFeed) {
            var roomFeedingManager :RoomFeedingManager =
                ServerContext.feedingManager.getRoomFeedingManager(prey.room.roomId);
            //Join the game
            var game :FeedingRecord = roomFeedingManager.requestFeed(
                    e.predatorId,
                    prey.playerId,
                    e.preyName,
                    prey.location);//Prey location
        }

        if (requestingPlayer != null) {
            var feedConfirm :FeedConfirmMsg = new FeedConfirmMsg(prey.playerId,
                                                                 prey.playerId,
                                                                 prey.name,
                                                                 requestingPlayer.playerId,
                                                                 e.isAllowedToFeed);

            PlayerSubControlServer(requestingPlayer.ctrl).sendMessage(FeedConfirmMsg.NAME, feedConfirm.toBytes());
        }
        else {
            log.error("handleFeedConfirmMessage", "requestingPlayer", requestingPlayer);
        }

    }

    protected static const log :Log = Log.getLog(LogicFeeding);

}
}
