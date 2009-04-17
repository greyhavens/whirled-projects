package vampire.server
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.HashSet;
import com.threerings.util.Log;
import com.whirled.avrg.OfflinePlayerPropertyControl;
import com.whirled.contrib.simplegame.ObjectMessage;
import com.whirled.contrib.simplegame.tasks.FunctionTask;
import com.whirled.contrib.simplegame.tasks.RepeatingTask;
import com.whirled.contrib.simplegame.tasks.SerialTask;
import com.whirled.contrib.simplegame.tasks.TimedTask;

import flash.utils.ByteArray;

import vampire.data.Codes;
import vampire.data.Lineage;
import vampire.data.VConstants;


public class LineageServer extends Lineage
{
    public function LineageServer(vserver :GameServer)
    {
        _vserver = vserver;

        addTask(new RepeatingTask(new SerialTask(
                                            new TimedTask(10),
                                            new FunctionTask(checkPlayersNames))));




//        registerListener(vserver.control.game, AVRGameControlEvent.PLAYER_JOINED_GAME,
//            playerJoinedGame);
    }
    protected function checkPlayersNames () :void
    {
        _vserver.players.forEach(function (playerId :int, player :PlayerData) :void {
            if (player.name != getPlayerName(playerId)) {
                setPlayerName(playerId, player.name);
                _playerIdsResendLineage.add(playerId);

                //Resend the lineage to the sire and grandsire.
                for each (var sire :int in getAllSiresAndGrandSires(playerId, 2)) {
                    _playerIdsResendLineage.add(sire);
                }
                for each (var child :int in getAllDescendents(playerId, null, 2)) {
                    _playerIdsResendLineage.add(child);
                }
            }
        });
    }

//    protected function playerJoinedGame (evt :AVRGameControlEvent) :void
//    {
//        log.info("playerJoinedGame() " + evt);
//        var playerId :int = int(evt.value);
//
//        var pctrl :PlayerSubControlServer = _vserver.control.getPlayer(playerId);
//        if (pctrl == null) {
//            log.error("playerJoinedGame, Could not get PlayerSubControlServer for player!");
//            return;
//        }
//
//        //Get the sire, grandsire, children and grandchildren.
//        //They will come in at an unknown later time, so we'll likely have to send
//        //multiple updates.
//
//
//
//    }

    /**
    * Update the relevant players online, and offline.
    *
    */
    protected function playerJoined (player :PlayerData) :void
    {
        log.error("playerJoined", "player", player);
        if (player == null) {
            log.error("playerJoinedOrChanged", "player", player,
                " but no PlayerData.  Maybe we are ahead of the game server?");
            return;
        }

        log.error("playerJoined, setting name", "player.name", player.name);
        setPlayerName(player.playerId, player.name);
        //Don't load this player again in the current session
        _playersLoadedFromDB.add(player.playerId);
        //First add the player as progeny to sire, whether online or offline
        if (player.sire != 0) {
            log.error("playerJoined, setting sire", "player.name", player.sire);
            setPlayerSire(player.playerId, player.sire);
            if (!_playersLoadedFromDB.contains(player.sire)) {
                loadOfflinePlayer(player.sire);
            }
        }
        //Then add the progeny to the lineage,
        for each (var progeny :int in player.progenyIds) {
            setPlayerSire(progeny, player.playerId);
            if (!_playersLoadedFromDB.contains(progeny)) {
                loadOfflinePlayer(progeny);
            }
        }
        _playerIdsResendLineage.add(player.playerId);

        //Resend the lineage to the sire and grandsire.
        for each (var sire :int in getAllSiresAndGrandSires(player.playerId, 2)) {
            _playerIdsResendLineage.add(sire);
        }
        for each (var child :int in getAllDescendents(player.playerId, null, 2)) {
            _playerIdsResendLineage.add(child);
        }
        recursivelyLoadSires(player.playerId);
    }

    protected function recursivelyLoadSires (playerId :int) :void
    {
        if (playerId == VConstants.UBER_VAMP_ID) {
            return;
        }

        if (playerId == 0) {
            return;
        }

        var sireId :int = getSireId(playerId);

        if (sireId == 0) {
            //There's no sire registered.  Let's load the offline props and check.
            if (_vserver.isPlayer(playerId)) {
                return;//Stop here, since the online player has no sire.
            }
            else {
                loadOfflinePlayer(playerId);
            }
        }
        else {
            recursivelyLoadSires(sireId);
        }

    }

    /**
    * The server tells us when a new PlayerData object is created.
    */
    override protected function receiveMessage (msg :ObjectMessage) :void
    {
        if (msg.name == MESSAGE_PLAYER_JOINED_GAME) {
            playerJoined(msg.data as PlayerData);
        }
    }


    /**
    * Updates on server ticks.  This should only be in the order of a few updates per second.
    * We send new Lineages to players with new data in their linages.
    *
    */
    override protected function update(dt:Number) :void
    {
//        var playerLineageSentToRoom :HashSet = new HashSet();

        _playerIdsResendLineage.forEach(function (playerId :int) :void {
            if (_vserver.isPlayer(playerId)) {
                var lineage :Lineage = getSubLineage(playerId, -1, 2);
                log.debug("Setting into " + _vserver.getPlayer(playerId).name+ "'s lineage", "playerId", playerId,
                    "lineage", lineage);
                var bytes :ByteArray = lineage.toBytes();
                _vserver.getPlayer(playerId).lineage = bytes;
                if (_vserver.getPlayer(playerId).room != null) {
                    _vserver.getPlayer(playerId).room.ctrl.props.setIn(
                        Codes.ROOM_PROP_PLAYER_LINEAGE, playerId, bytes);
                }
            }
        });
        _playerIdsResendLineage.clear();
    }

    override public function toString():String
    {
        return super.toString();
    }

    //We use this opportunity to update offline (and online players) progeny data.
    override public function setPlayerSire(playerId :int, sireId :int) :void
    {
        //Only update the lineage and offline props if we haven't loaded them before
        if (getSireId(playerId) != sireId) {
            super.setPlayerSire(playerId, sireId);
            updateProgenyIds(sireId, playerId);
            offlinePlayerFinishedLoading(playerId);
        }
    }

    protected function loadOfflinePlayer (playerId :int) :void
    {
        if (playerId == 0) {
            return;
        }

        if (_playersLoadedFromDB.contains(playerId)) {
            return;
        }

        if (_vserver.isPlayer(playerId)) {
            return;
        }

        log.debug("loadOfflinePlayer", "playerId", playerId, "begin");

        ServerContext.ctrl.loadOfflinePlayer(playerId,
            function (props :OfflinePlayerPropertyControl) :void {
                var progenyIds :Array = props.get(Codes.PLAYER_PROP_PROGENY_IDS) as Array;
                var sireId :int = props.get(Codes.PLAYER_PROP_SIRE) as int;
                var name :String = props.get(Codes.PLAYER_PROP_NAME) as String;

                _playersLoadedFromDB.add(playerId);
                log.debug("loadOfflinePlayer", "playerId", playerId, "in offline props");
                setPlayerName(playerId, name);
                setPlayerSire(playerId, sireId);
                for each (var progenyId :int in progenyIds) {
                    setPlayerSire(progenyId, playerId);
                }

                recursivelyLoadSires(sireId);

                offlinePlayerFinishedLoading(playerId);

            },
            function (failureCause :Object) :void {
                log.warning("Eek! Sending message to offline player failed!", "cause",
                    failureCause);
            });
    }

    /**
    * When an offline player finishes loading, we might want to
    * load it's sire or childrens if there are players who need
    * that data.
    */
    protected function offlinePlayerFinishedLoading (playerId :int) :void
    {
        log.debug("offlinePlayerFinishedLoading", "playerId", playerId);
        log.debug("offlinePlayerFinishedLoading", "lineage", this);
        _playersLoadedFromDB.add(playerId);
        if (isVisibleToOnlinePlayer(playerId)) {
            loadOfflinePlayer(getSireId(playerId));

            for each (var progenyId :int in getProgenyIds(playerId)) {
                loadOfflinePlayer(progenyId);
            }
        }

        //Resend the lineage to the sire and grandsire.
        for each (var sire :int in getAllSiresAndGrandSires(playerId, 2)) {
            _playerIdsResendLineage.add(sire);
        }
        for each (var child :int in getAllDescendents(playerId, null, 2)) {
            _playerIdsResendLineage.add(child);
        }
    }

    /**
    * When an offline player has loaded it's data into the Lineage, we also load
    * it's sire/children, if we they are visible to any online players.
    *
    */
    protected function isVisibleToOnlinePlayer (playerId :int) :Boolean
    {
        var sireId :int = getSireId(playerId);
        if (sireId != 0) {
            if (_vserver.isPlayer(sireId)) {
                return true;
            }

            var grandSireId :int = getSireId(sireId);
            if (_vserver.isPlayer(grandSireId)) {
                return true;
            }
        }
        return false;
    }


    /**
    * Not all players will have the correct progeny ids, since we started the game
    * only storing sireIds.  So we update progeny ids when a new player logs on.
    */
    protected function updateProgenyIds (sireId :int, newProgenyId :int) :void
    {
        if (sireId == 0) {
            return;
        }

        if (_vserver.isPlayer(sireId)) {
            var sire :PlayerData = _vserver.getPlayer(sireId);
            sire.addProgeny(newProgenyId);
        }
        else {//Add to offline database
            ServerContext.ctrl.loadOfflinePlayer(sireId,
                function (props :OfflinePlayerPropertyControl) :void {
                    var oldProgenyIds :Array = props.get(Codes.PLAYER_PROP_PROGENY_IDS) as Array;

                    if (oldProgenyIds == null) {
                        oldProgenyIds = new Array();
                    }

                    if (ArrayUtil.contains(oldProgenyIds, newProgenyId)) {
                        return;
                    }

                    oldProgenyIds.push(newProgenyId);
                    oldProgenyIds.sort();
                    log.debug("Setting " + Codes.PLAYER_PROP_PROGENY_IDS + "=" + oldProgenyIds);
                    props.set(Codes.PLAYER_PROP_PROGENY_IDS, oldProgenyIds.slice());
                },
                function (failureCause :Object) :void {
                    log.warning("Eek! Sending message to offline player failed!", "cause",
                        failureCause);
                });
        }
    }

    override public function get objectName () :String
    {
        return NAME;
    }

    protected var _vserver :GameServer;

    /**
    * Once a player is loaded from offline, they don't need to be loaded again.
    * Record their id here to remember.
    */
    protected var _playersLoadedFromDB :HashSet = new HashSet();

    protected var _playerIdsResendLineage :HashSet = new HashSet();

    public static const MESSAGE_PLAYER_JOINED_GAME :String = "Message: Player Joined";
    public static const NAME :String = "LineageServer";

    protected static const log :Log = Log.getLog(LineageServer);
}
}