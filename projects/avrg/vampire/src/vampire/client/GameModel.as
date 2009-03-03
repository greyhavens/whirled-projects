package vampire.client
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.AgentSubControl;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertyGetSubControl;

import flash.geom.Point;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

import vampire.avatar.AvatarGameBridge;
import vampire.client.events.ChangeActionEvent;
import vampire.client.events.ClosestPlayerChangedEvent;
import vampire.client.events.HierarchyUpdatedEvent;
import vampire.data.Codes;
import vampire.data.MinionHierarchy;
import vampire.data.SharedPlayerStateClient;
import vampire.data.VConstants;
import vampire.feeding.PlayerFeedingData;


/**
 * The game and subgames interact with the agent code and properties via this class.
 *
 */

[Event(name="Hierarchy Updated", type="vampire.client.events.HierarchyUpdatedEvent")]
public class GameModel extends SimObject//EventDispatcher
    //implements Updatable
{
    public function setup () :void
    {
//        _playerStates = new HashMap();

        _agentCtrl = ClientContext.ctrl.agent;
        _propsCtrl = ClientContext.ctrl.room.props;

        registerListener( _propsCtrl, PropertyChangedEvent.PROPERTY_CHANGED, handlePropChanged);
        registerListener( _propsCtrl, ElementChangedEvent.ELEMENT_CHANGED, handleElementChanged);


        //Update the HUD when the room props come in.
        registerListener(ClientContext.ctrl.player, AVRGamePlayerEvent.ENTERED_ROOM, playerEnteredRoom);

//        //Update the HUD when the room props come in.
//        registerListener(ClientContext.ctrl.room, AVRGameRoomEvent.AVATAR_CHANGED,
//            function ( e :AVRGameRoomEvent) :void {
//                trace("GameModel heard " + AVRGameRoomEvent.AVATAR_CHANGED + " " + e);
//            });
//
//        registerListener(ClientContext.ctrl.room, AVRGameRoomEvent.PLAYER_MOVED,
//            function ( e :AVRGameRoomEvent) :void {
//                trace("GameModel heard " + AVRGameRoomEvent.PLAYER_MOVED + " " + e);
//            });
//
//        registerListener(ClientContext.ctrl.room, AVRGameRoomEvent.SIGNAL_RECEIVED,
//            function ( e :AVRGameRoomEvent) :void {
//                trace("GameModel heard " + AVRGameRoomEvent.SIGNAL_RECEIVED + " " + e);
//            });



        //Update the closest userId (might not be a player)
//        _events.registerListener(ClientContext.gameCtrl.room, AVRGameRoomEvent.SIGNAL_RECEIVED, handleSignalReceived);


//        _nonPlayerLocations = new NonPlayerMonitor( ClientContext.gameCtrl.room );


//        _avatarManager = new VampireAvatarHUDManager(ClientContext.ctrl);
//        //Let the server know when we arrive at a location, if we are walking to a feed.
//        registerListener( _avatarManager, PlayerArrivedAtLocationEvent.PLAYER_ARRIVED,
//            function(...ignored) :void {
//                if( action == VConstants.GAME_MODE_MOVING_TO_FEED_ON_NON_PLAYER ||
//                    action == VConstants.GAME_MODE_MOVING_TO_FEED_ON_PLAYER ) {
//
//                        ClientContext.ctrl.agent.sendMessage(
//                            PlayerArrivedAtLocationEvent.PLAYER_ARRIVED );
//                    }
//            });
//
//
//
//        this.db.addObject( _avatarManager );


        //If the room props are already present, update the HUD now.
        if( SharedPlayerStateClient.isProps( ClientContext.ourPlayerId ) ) {
            playerEnteredRoom();
        }


        _events.registerListener( ClientContext.ctrl.room, MessageReceivedEvent.MESSAGE_RECEIVED,
            function(e:MessageReceivedEvent):void{
                trace(ClientContext.ctrl.player.getPlayerId() + ", got " + e);
            } );



        //Every second, update who is our closest player.  Used for targeting e.g. feeding.
//        _proximityTimer = new Timer(Constants.TIME_INTERVAL_PROXIMITY_CHECK, 0);
//        _events.registerListener( _proximityTimer, TimerEvent.TIMER, checkProximity );
//        _proximityTimer.start();

    }

    override protected function update( dt :Number ) :void
    {
//        _avatarManager.update( dt );
    }

//    /**
//    * The player avatar tells the model who is closest.
//    */
//    protected function handleSignalReceived( e :AVRGameRoomEvent) :void
//    {
//        trace("model.handleSignalReceived(), e=" + e);
//        if( e.name == VConstants.SIGNAL_CLOSEST_ENTITY) {
//            var args :Array = e.value as Array;
//            if( args != null && args.length >= 2 && args[0] == ClientContext.ourPlayerId) {
//                closestUserId = int(args[1]);
//                trace("model.handleSignalReceived(), Closest id=" + closestUserId);
//            }
//        }
//    }


    protected function checkProximity( ...ignored) :void
    {
        var av :AVRGameAvatar = ClientContext.ctrl.room.getAvatarInfo( ClientContext.ourPlayerId);
        if( av == null) {
            return;
        }
        var mylocation :Point = new Point( av.x, av.y );
        var closestOtherPlayerId :int = -1;
        var closestOtherPlayerDistance :Number = Number.MAX_VALUE;

        for each( var playerid :int in ClientContext.ctrl.room.getPlayerIds()) {
            if( playerid == ClientContext.ourPlayerId) {
                continue;
            }
            av = ClientContext.ctrl.room.getAvatarInfo( playerid );
            var otherPlayerPoint :Point = new Point( av.x, av.y );
            var distance :Number = Point.distance( mylocation, otherPlayerPoint);
            if( distance < closestOtherPlayerDistance) {
                closestOtherPlayerId = playerid;
                closestOtherPlayerDistance = distance;
            }
        }

//        if( closestOtherPlayerId > 0) {
            ClientContext.currentClosestPlayerId = closestOtherPlayerId;
            dispatchEvent( new ClosestPlayerChangedEvent( closestOtherPlayerId ) );
//        }
    }
    public function playerEnteredRoom( ...ignored ) :void
    {
        //Reset avatar locations
        ClientContext.ctrl.room.getEntityProperty(
            AvatarGameBridge.ENTITY_PROPERTY_RESET_LOCATIONS, ClientContext.ourEntityId );

        trace(VConstants.DEBUG_MINION + " Player entered room");

        if( hierarchy == null) {

            _hierarchy = loadHierarchyFromProps();
            trace(VConstants.DEBUG_MINION + " loadHierarchyFromProps()=" + _hierarchy);
            dispatchEvent( new HierarchyUpdatedEvent( _hierarchy ) );

//            var bytes :ByteArray = ClientContext.gameCtrl.room.props.get( Codes.ROOM_PROP_MINION_HIERARCHY ) as ByteArray;
//            if( bytes != null) {
//                _hierarchy = new MinionHierarchy();
//                _hierarchy.fromBytes( bytes );
//                dispatchEvent( new HierarchyUpdatedEvent( hierarchy ) );
//            }
        }
        else {
            log.warning("Player entered room, but no minion hierarchy to load.");
        }
    }
    public function shutdown () :void
    {
//        _events.freeAllHandlers();
//        _avatarManager.shutdown();
//        _proximityTimer.stop();
    }

    protected function loadHierarchyFromProps() :MinionHierarchy
    {
        log.debug(VConstants.DEBUG_MINION + " loadHierarchyFromProps()");
        var hierarchy :MinionHierarchy = new MinionHierarchy();
//        var playerIds :Array = ClientContext.gameCtrl.room.props.get( Codes.ROOM_PROP_MINION_HIERARCHY_ALL_PLAYER_IDS ) as Array;

//        log.debug(Constants.DEBUG_MINION + " loadHierarchyFromProps()", "playerIds", playerIds);

//        if( playerIds == null) {
//            log.error(VConstants.DEBUG_MINION +  " playerIds=" + playerIds);
//            return hierarchy;
//        }

        var dict :Dictionary = ClientContext.ctrl.room.props.get(Codes.ROOM_PROP_MINION_HIERARCHY) as Dictionary;

        if( dict != null) {

            var playerId :int;
            for (var key:Object in dict) {//Where key==playerId

                playerId = int(key);
//            for each( var playerId :int in playerIds) {
                if( dict[playerId] != null) {
                    var data :Array = dict[playerId] as Array;
                    var playerName :String = data[0];
                    var sireId :int = int(data[1]);
                    hierarchy.setPlayerSire( playerId, sireId );
                    hierarchy.setPlayerName( playerId, playerName );
                }

            }
        }
        else {
            log.debug(VConstants.DEBUG_MINION + " loadHierarchyFromProps()", "dict==null");
        }
        hierarchy.recomputeMinions();
        log.debug(VConstants.DEBUG_MINION + " loadHierarchyFromProps()", "hierarchy", hierarchy);
        return hierarchy;
    }

    protected function handlePropChanged (e :PropertyChangedEvent) :void
    {
        //Check if it is non-player properties changed??
//        log.debug(VConstants.DEBUG_MINION + " propChanged", "e", e);

        if( e.name == Codes.ROOM_PROP_MINION_HIERARCHY ) {//|| e.name == Codes.ROOM_PROP_MINION_HIERARCHY_ALL_PLAYER_IDS) {

//            var playerIds :Array = ClientContext.gameCtrl.room.props.get( Codes.ROOM_PROP_MINION_HIERARCHY_ALL_PLAYER_IDS ) as Array;

//            if( playerIds == null) {
//                log.error("propChanged", "e", e, "playerIds", playerIds);
//                return;
//            }

            _hierarchy = loadHierarchyFromProps();
//            log.debug(VConstants.DEBUG_MINION + " HUD updating hierarchy=" + _hierarchy);

            dispatchEvent( new HierarchyUpdatedEvent( _hierarchy ) );
        }
//        else if( e.name == Codes.ROOM_PROP_NON_PLAYERS ) {
//            updateNonPlayersIds();
//
//        }

//            if( e.newValue is ByteArray) {
//                _hierarchy = new MinionHierarchy();
//                _hierarchy.fromBytes( ByteArray(e.newValue) );
//                trace("\n      " + Constants.DEBUG_MINION + " !!!!!!!!!!!Hierarch data arrived in room=" + _hierarchy.toString());
//                dispatchEvent( new HierarchyUpdatedEvent( _hierarchy ) );
//
//            }
//            else {
//                log.error("propChanged " + Codes.ROOM_PROP_MINION_HIERARCHY + " but not a ByteArray");
//            }



//        //Otherwise check for player updates
//
//        var playerIdUpdated :int = SharedPlayerStateClient.parsePlayerIdFromPropertyName( e.name );
//        if( !isNaN( playerIdUpdated )) {
////            _playerStates.put( playerIdUpdated, SharedPlayerStateServer.fromBytes(ByteArray(e.newValue)) );
////            log.debug("Updated state=" + _playerStates.get( playerIdUpdated));
//            log.debug("  Dispatching event=" + PlayerStateChangedEvent.NAME);
////            dispatchEvent( new Event( VampireController.PLAYER_STATE_CHANGED ) );
//            dispatchEvent( new PlayerStateChangedEvent( playerIdUpdated ) );
//        }
//        else {
//            log.warning("  Failed to update PropertyChangedEvent" + e);
//        }




//        var playerKey :String = Codes.ROOM_PROP_PREFIX_PLAYER_DICT + player.playerId;
//
//        switch (e.name) {
//
//            case
//
//            case Codes.PLAYER_SHARED_STATE_KEY:
//                var newState :SharedState = SharedState.fromBytes(ByteArray(e.newValue));
//                this.setState(newState);
//                break;
//
//            case Constants.PROP_SCORES:
//                var newScores :ScoreTable = ScoreTable.fromBytes(ByteArray(e.newValue),
//                    Constants.SCORETABLE_MAX_ENTRIES);
//                this.setScores(newScores);
//                break;
//
//            default:
//                log.warning("unrecognized property changed: " + e.name);
//                break;
//        }
    }



    public function handleElementChanged (e :ElementChangedEvent) :void
    {
//        log.debug(Constants.DEBUG_MINION + " elementChanged()", "e", e);
        if( e.name == Codes.ROOM_PROP_MINION_HIERARCHY) {

            _hierarchy = loadHierarchyFromProps();
//            log.debug(Constants.DEBUG_MINION + " elementChanged", "e", e, "_hierarchy", _hierarchy);

            dispatchEvent( new HierarchyUpdatedEvent( _hierarchy ) );
            return;
        }

        //Otherwise check for player updates
        var playerIdUpdated :int = SharedPlayerStateClient.parsePlayerIdFromPropertyName( e.name );


        if( !isNaN( playerIdUpdated )) {

            //If a state change comes in, inform the avatar
            if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_AVATAR_STATE) {

                var entityAvatarId :String = ClientContext.getPlayerEntityId(playerIdUpdated);

                var setStateFunction :Function = ClientContext.ctrl.room.getEntityProperty(
                    AvatarGameBridge.ENTITY_PROPERTY_SETSTATE_FUNCTION, entityAvatarId) as Function;

                if( setStateFunction != null ) {
                    log.debug(ClientContext.ourPlayerId + " setStateFunction() " + e.newValue.toString());
                    setStateFunction( e.newValue.toString() );
                }
                else {
                    log.error("handleElementChanged, setStateFunction==null, crusty avatar??", "e", e );
                }

            }


            if( playerIdUpdated == ClientContext.ourPlayerId ) {
                //If the action changes on the server, that means the change is forced, so change to that action.
                if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_ACTION) {
    //                log.debug("  Dispatching event=" + ChangeActionEvent.CHANGE_ACTION + " new action=" + e.newValue);
                    dispatchEvent( new ChangeActionEvent( e.newValue.toString() ) );
                }
            }

        }
        else {
//            log.warning("  Failed to update ElementChangedEvent" + e);
        }

    }

    public function playerIdsInRoom() :Array
    {
        return ClientContext.ctrl.room.getPlayerIds();
    }

    public function isPlayerInRoom( playerId :int ) :Boolean
    {
        return ArrayUtil.contains( playerIdsInRoom(), playerId );
    }

    public function isPlayer( userId :int ) :Boolean
    {
        return ArrayUtil.contains( playerIdsInRoom(), userId );
    }

    public function get bloodbonded() :int
    {
        if( VConstants.LOCAL_DEBUG_MODE) {
           return 1;
        }
        else {
            return SharedPlayerStateClient.getBloodBonded( ClientContext.ourPlayerId );
        }
    }

    public function get bloodbondedName() :String
    {
        if( VConstants.LOCAL_DEBUG_MODE) {
            return "Bloodbond name";
        }
        else {
            var name :String = SharedPlayerStateClient.getBloodBondedName( ClientContext.ourPlayerId );
            return name != null && name.length > 0 ? name : "No bloodbond yet.";
        }

    }

//    public function get minions() :Array
//    {
//        return SharedPlayerStateClient.getMinions( ClientContext.ourPlayerId );
//    }

    public function get blood() :Number
    {
        return SharedPlayerStateClient.getBlood( ClientContext.ourPlayerId );
    }

    public function get bloodType() :int
    {
        return SharedPlayerStateClient.getBloodType( ClientContext.ourPlayerId );
    }

    public function get maxblood() :Number
    {
        return SharedPlayerStateClient.getMaxBlood( ClientContext.ourPlayerId );
    }

    public function get level() :int
    {
        return SharedPlayerStateClient.getLevel( ClientContext.ourPlayerId );
    }

    public function get location() :Array
    {
        var avatar :AVRGameAvatar = ClientContext.ctrl.room.getAvatarInfo( ClientContext.ourPlayerId );
        if( avatar != null ) {
            return [avatar.x, avatar.y, avatar.z, avatar.orientation];
        }
        return null;
    }


    public function get xp() :Number
    {
        return SharedPlayerStateClient.getXP( ClientContext.ourPlayerId );
    }

    public function get time() :int
    {
        return SharedPlayerStateClient.getTime( ClientContext.ourPlayerId );
    }

    public function get name() :String
    {
        if( VConstants.LOCAL_DEBUG_MODE) {
            return "Player Name";
        }
        else {
            return ClientContext.ctrl.room.getAvatarInfo( ClientContext.ourPlayerId).name;
        }
    }



    public function get targetPlayerId() :int
    {
        return SharedPlayerStateClient.getTargetPlayer(  ClientContext.ourPlayerId );
    }

    public function get action() :String
    {
        return SharedPlayerStateClient.getCurrentAction( ClientContext.ourPlayerId );
    }

    public function isNewPlayer() :Boolean
    {
        return time == 1;
    }

    public function isVampire() :Boolean
    {
        return level >= VConstants.MINIMUM_VAMPIRE_LEVEL;
    }

    public function get hierarchy() :MinionHierarchy
    {
        return _hierarchy;
    }


    public function get playerFeedingData () :PlayerFeedingData
    {
        if( VConstants.LOCAL_DEBUG_MODE ) {
            var dummy :PlayerFeedingData = new PlayerFeedingData();
            dummy.collectStrainFromPlayer( 1, 1 );
            dummy.collectStrainFromPlayer( 3, 3 );
            dummy.collectStrainFromPlayer( 3, 3 );
            dummy.collectStrainFromPlayer( 3, 4 );
            return dummy
        }

        var pfd :PlayerFeedingData = new PlayerFeedingData();
        var bytes :ByteArray = ClientContext.ctrl.player.props.get(Codes.PLAYER_PROP_FEEDING_DATA) as ByteArray;
        if (bytes != null) {
            bytes.position = 0;
            pfd.fromBytes(bytes);
        }

        return pfd;
    }



    protected var _hierarchy :MinionHierarchy;
    protected var _agentCtrl :AgentSubControl;
    protected var _propsCtrl :PropertyGetSubControl;


    protected var closestUserId :int;

    protected static var log :Log = Log.getLog(GameModel);

}
}