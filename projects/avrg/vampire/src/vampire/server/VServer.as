//
// $Id$

package vampire.server {

import com.threerings.util.HashMap;
import com.threerings.util.HashSet;
import com.threerings.util.Log;
import com.threerings.util.Random;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.avrg.OfflinePlayerPropertyControl;
import com.whirled.avrg.PlayerSubControlServer;
import com.whirled.contrib.avrg.probe.ServerStub;
import com.whirled.contrib.simplegame.server.ObjectDBThane;
import com.whirled.net.MessageReceivedEvent;

import flash.utils.getTimer;
import flash.utils.setInterval;

import vampire.Util;
import vampire.data.Codes;
import vampire.data.Logic;
import vampire.data.MinionHierarchyServer;
import vampire.data.VConstants;
import vampire.feeding.FeedingGameServer;
import vampire.net.VMessageManager;

public class VServer extends ObjectDBThane
{
//    public static const FRAMES_PER_SECOND :int = 30;

    public static var log :Log = Log.getLog(VServer);


    public var random :Random = new Random();

    public function get control () :AVRServerGameControl
    {
        return _ctrl;
    }

    public function isAdmin (playerId :int) :Boolean
    {
        // we might want to make this dynamic later
        return playerId < 20
            || playerId == 14088    // cirrus
            || playerId == 14128    // nimbus
            || playerId == 16444    // equinox
            || playerId == 14001    // sirrocco
            || playerId == 14137    // coriolis
            || playerId == 14134    // sunshine
            || playerId == 23340    //me (ragbeard)
            ;
    }

    public function VServer ()
    {
        log.info("Vampire Server initializing...");
        if( ServerContext.ctrl == null ) {
            log.error("AVRServerGameControl should of been initialized already");
            return;
        }
        ServerContext.vserver = this;
        _ctrl = ServerContext.ctrl;

//        _ctrl.game.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, handleMessage);
        registerListener(_ctrl.game, AVRGameControlEvent.PLAYER_JOINED_GAME, playerJoinedGame);
        registerListener(_ctrl.game, AVRGameControlEvent.PLAYER_QUIT_GAME, playerQuitGame);

        ServerContext.msg = new VMessageManager( _ctrl );
        registerListener(ServerContext.msg, MessageReceivedEvent.MESSAGE_RECEIVED, handleMessage );

        _startTime = getTimer();
        _lastTickTime = _startTime;
        setInterval(tick, SERVER_TICK_UPDATE_MILLISECONDS);

        ServerContext.minionHierarchy = new MinionHierarchyServer( this );
        addObject( ServerContext.minionHierarchy );

//        ServerContext.trophies = new Trophies(this, ServerContext.minionHierarchy);

        ServerContext.nonPlayersBloodMonitor = new NonPlayerAvatarsBloodMonitor();
        addObject( ServerContext.nonPlayersBloodMonitor );

        //Tim's bloodbond game server
        FeedingGameServer.init( _ctrl );

//        _stub = new ServerStub(_ctrl);
    }




    public function getRoom (roomId :int) :Room
    {
        if (roomId == 0) {
            throw new Error("Bad argument to getRoom [roomId=0]");
        }
        var room :Room = _rooms.get(roomId);
        if (room == null) {


            try {
                room = new Room(roomId);
                _rooms.put(roomId, room );
                addObject( room );
            }
            catch(err :Error ) {
                log.error("Attempted to get a room with no players.  Throws error.  Use isRoom()");
            }
        }
        return room;
    }

    public function isRoom( roomId :int) :Boolean
    {
        return _rooms.containsKey( roomId );
    }

    public function getPlayer (playerId :int) :Player
    {
        return Player(_players.get(playerId));
    }

//    override public function update(dt:Number):void
//    {
//
//    }


    protected function removeStaleRooms() :void
    {
        for each( var roomId :int in _rooms.keys()) {
            var room :Room = _rooms.get( roomId ) as Room;
            if( room == null || room.isStale ) {
                log.debug("Removed room from VServer " + roomId);
                _rooms.remove( roomId );
            }
        }
    }
    protected function tick () :void
    {
        var time :int = getTimer();
        var dT :int = time - _lastTickTime;
        _lastTickTime = time;
        var dT_seconds :Number = dT / 1000.0;

//        var frame :int = dT * (FRAMES_PER_SECOND / 1000);
//        var second :int = dT / 1000;

        //Update the non-players blood levels.
//        ServerContext.nonPlayers.tick( dT_seconds );

//        ServerContext.minionHierarchy.tick();
//        _avatarManager.update( dT_seconds );

        removeStaleRooms();

        _ctrl.doBatch(function () :void {

            _rooms.forEach( function( roomId :int, room :Room) :void {

                for each( var globalMessage :String in _globalFeedback) {
                    room.addFeedback( globalMessage, 0);
                }
            });


            update( dT_seconds );

        });

        _globalFeedback.splice(0);



//        //Remove stale non-players.
//        for each(var np :NonPlayerAvatar in getObjectsInGroup(NonPlayerAvatar.GROUP)) {
//            if( np.isStale ) {
//                np.destroySelf();
//                _nonplayers.remove( np.playerId );
//            }
//        }


    }

    // a message comes in from a player, figure out which Player instance will handle it
    protected function handleMessage (evt :MessageReceivedEvent) :void
    {
        trace(evt);
        try {
//            log.debug("handleMessage", "evt", evt);
            var player :Player = getPlayer(evt.senderId);
            if (player == null) {
                log.warning("Received message for non-existent player [evt=" + evt + "]");
                log.warning("playerids=" + _players.keys());
                return;
            }
            _ctrl.doBatch(function () :void {
                player.handleMessage(evt.name, evt.value);
            });
        }
        catch( err :Error ) {
            log.error(err + "\n" + err.getStackTrace());
        }
    }

    // when players enter the game, we create a local record for them
    protected function playerJoinedGame (evt :AVRGameControlEvent) :void
    {
        try {
            log.info("playerJoinedGame() " + evt);
            var playerId :int = int(evt.value);

            //Add to the permanent record of players.
//            if( playerId > 0 ) {
//                _playerIds.add( playerId );
//            }

            if (_players.containsKey(playerId)) {
                log.warning("Joining player already known", "playerId", playerId);
                return;
            }


    //        log.info("!!!!!Before player created", "player time", _ctrl.getPlayer(playerId).props.get( Codes.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE));
            log.info("!!!!!Before player created", "player time", new Date(_ctrl.getPlayer(playerId).props.get( Codes.PLAYER_PROP_LAST_TIME_AWAKE)).toTimeString());

            var pctrl :PlayerSubControlServer = _ctrl.getPlayer(playerId);
            if (pctrl == null) {
                throw new Error("Could not get PlayerSubControlServer for player!");
            }
    //
    //        log.info("!!!!!After player created", "player time", _ctrl.getPlayer(playerId).props.get( Codes.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE));
            log.info("!!!!!AFter player control created", "player time", new Date(_ctrl.getPlayer(playerId).props.get( Codes.PLAYER_PROP_LAST_TIME_AWAKE)).toTimeString());


            var hierarchyChanged :Boolean = false;

            _ctrl.doBatch(function () :void {
                var player :Player = new Player(pctrl);
                _players.put(playerId, player);
                ServerContext.nonPlayersBloodMonitor.addNewPlayer( playerId );
            });

            //Keep a record of player ids to distinguish players and non-players
            //even when the players are not actively playing.

            log.debug("Sucessfully created Player object.");
        }
        catch( err :Error ) {
            log.error(err + "\n" + err.getStackTrace());
        }
    }



    // when they leave, clean up
    protected function playerQuitGame (evt :AVRGameControlEvent) :void
    {
        try {
            log.info("playerQuitGame(" + playerId + ")");
            var playerId :int = int(evt.value);

            var player :Player = _players.remove(playerId);
            if (player == null) {
                log.warning("Quitting player not known", "playerId", playerId);
                return;
            }

            _ctrl.doBatch(function () :void {

                player.shutdown();
            });

            log.info("Player quit the game", "player", player);

    //        log.info("!!!!!After player quit the game", "player time", _ctrl.getPlayer(playerId).props.get( Codes.PLAYER_PROP_PREFIX_LAST_TIME_AWAKE));
            log.info("!!!!!After player quit the game", "player time", new Date(_ctrl.getPlayer(playerId).props.get( Codes.PLAYER_PROP_LAST_TIME_AWAKE)).toTimeString());
        }
        catch( err :Error ) {
            log.error(err + "\n" + err.getStackTrace());
        }
    }

    public function get rooms() :HashMap
    {
        return _rooms;
    }

    /**
    * When a player gains blood, his sires all share a portion of the gain
    *
    */
    public function playerGainedBlood( player :Player, blood :Number, sourcePlayerId :int = 0 ) :void
    {
        var bloodShared :Number = VConstants.BLOOD_GAIN_FRACTION_SHARED_WITH_SIRES * blood;
        var allsires :HashSet = ServerContext.minionHierarchy.getAllSiresAndGrandSires( player.playerId );

        if( allsires.size() == 0 ) {
            log.debug("no sires");
            return;
        }

        var bloodForEachSire :Number = bloodShared / allsires.size();
        allsires.forEach( function ( sireId :int) :void {
            if( isPlayer( sireId )) {
                var sire :Player = getPlayer( sireId );
                sire.addBlood( bloodForEachSire );
            }
        });
    }

    /**
    * When a player gains blood, his sires all share a portion of the gain
    *
    */
    public function awardSiresXpEarned( player :Player, xp :Number ) :void
    {
        log.debug("awardSiresXpEarned(" + player.name + ", xp=" + xp);

        var allsires :HashSet = ServerContext.minionHierarchy.getAllSiresAndGrandSires( player.playerId );
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

        var immediateSire :int = ServerContext.minionHierarchy.getSireId( player.playerId );

        function awardXP( sireId :int, awardXP :Number ) :void {
            if( isPlayer( sireId )) {
                var sire :Player = getPlayer( sireId );
                if( sire.isVampire() ) {
                    sire.addXP( awardXP );
                    log.debug("awarding sire " + sire.name + ", xp=" + awardXP);
                    sire.addFeedback( "You gained " + Util.formatNumberForFeedback(awardXP) + " experience from minion " + player.name );
                }
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
    public function awardBloodBondedXpEarned( player :Player, xp :Number ) :void
    {
        log.debug("awardBloodBondedXpEarned(" + player.name + ", xp=" + xp);
        if( player.bloodbonded <= 0 ) {
            return;
        }
        var bloodBondedPlayer :Player = getPlayer( player.bloodbonded );
        var xpBonus :Number = xp * VConstants.BLOOD_BOND_FEEDING_XP_BONUS;
        var xBonusFormatted :String = Util.formatNumberForFeedback(xpBonus);

        if( bloodBondedPlayer != null ) {
            bloodBondedPlayer.addXP( xpBonus );
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
    public function awardBloodBondedBloodEarned( player :Player, blood :Number ) :void
    {
        log.debug("awardBloodBondedBloodEarned(" + player.name + ", blood=" + blood);
        if( player.bloodbonded <= 0 ) {
            return;
        }
        var bloodBondedPlayer :Player = getPlayer( player.bloodbonded );
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

    public function addXPToPlayer( playerId :int, xp :Number ) :void
    {
        if( isPlayer( playerId ) ) {
            var player :Player = getPlayer( playerId );
            player.addXP( xp );
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

    public function addBloodToPlayer( playerId :int, blood :Number ) :void
    {
        if( isPlayer( playerId ) ) {
            var player :Player = getPlayer( playerId );
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

    /**
    * Keep track of invites for trophies.
    * NB this does *not* check if the invited player already has a sire, it is assumed that
    * this check has already been made, and this function is called only after the first
    * time the sire is newly set.
    *
    */
    public function playerInvitedByPlayer( newPlayerId :int, inviterId :int ) :void
    {
        var newbie :Player = getPlayer( newPlayerId );
        if( newbie == null ) {
            log.error("playerInvitedByPlayer", "newPlayerId", newPlayerId, "inviterId", inviterId);
            return;
        }

        if( isPlayer( inviterId )) {
            var inviter :Player = getPlayer( inviterId );
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

    public function checkBloodBondFormation( preyId :int, predatorIds :Array) :void
    {
        if( !isPlayer( preyId )) {
            return;
        }

        var prey :Player = getPlayer( preyId );
        //At the moment, it's 2 alternate feedings each
        //I.e. Player 1 eats Player 2, 2 eats 1, 1 eats 2, 2 eats 1.
        var minfeedings :int = 2;
        var preyVictims :Array = prey.mostRecentVictimIds;

        if( preyVictims.length < minfeedings) {
            return;
        }
        for each(var predId :int in predatorIds) {

            if( !isPlayer( predId)) {
                log.error("checkBloodBondFormation, no pred for id=" + predId );
                continue;
            }
            var predator :Player = getPlayer( predId );
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
                _globalFeedback.push(prey.name + " is now bloodbonded with " + predator.name);
                break;
            }
        }
    }


    public function isPlayer( playerId :int ) :Boolean
    {
        return _players.containsKey( playerId );
    }


    protected var _startTime :int;
    protected var _lastTickTime :int;

    protected var _ctrl :AVRServerGameControl;
    protected var _rooms :HashMap = new HashMap();
    protected var _players :HashMap = new HashMap();

    protected var _globalFeedback :Array = new Array();

//    protected var _playerIds :HashSet = new HashSet();

    protected var _stub :ServerStub;

    public static const SERVER_TICK_UPDATE_MILLISECONDS :int = 400;

}
}

