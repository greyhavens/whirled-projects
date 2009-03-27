package vampire.client
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.EntityControl;
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.avrg.AgentSubControl;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.objects.SimpleTimer;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertyGetSubControl;

import flash.utils.ByteArray;
import flash.utils.Dictionary;

import vampire.avatar.AvatarGameBridge;
import vampire.client.events.ChangeActionEvent;
import vampire.client.events.LineageUpdatedEvent;
import vampire.client.events.PlayerArrivedAtLocationEvent;
import vampire.client.events.PlayersFeedingEvent;
import vampire.data.Codes;
import vampire.data.Lineage;
import vampire.data.VConstants;
import vampire.feeding.PlayerFeedingData;


/**
 * The game and subgames interact with the agent code and properties via this class.
 *
 */

[Event(name="Hierarchy Updated", type="vampire.client.events.LineageUpdatedEvent")]
public class GameModel extends SimObject//EventDispatcher
    //implements Updatable
{
    public function setup () :void
    {
//        _playerStates = new HashMap();

        _agentCtrl = ClientContext.ctrl.agent;
        _propsCtrl = ClientContext.ctrl.room.props;


        _currentEntityId = ClientContext.ourEntityId;

        registerListener( _propsCtrl, PropertyChangedEvent.PROPERTY_CHANGED, handlePropChanged);
        registerListener( _propsCtrl, ElementChangedEvent.ELEMENT_CHANGED, handleElementChanged);

        //Monitor and adjust for avatar changes
        registerListener(ClientContext.ctrl.room, AVRGameRoomEvent.AVATAR_CHANGED, handleAvatarChanged);


        //Update the HUD when the room props come in.
        registerListener(ClientContext.ctrl.player, AVRGamePlayerEvent.ENTERED_ROOM, playerEnteredRoom);


        //Let's hear when the avatar arrived at a destination
         var setCallback :Function = ClientContext.ctrl.room.getEntityProperty(
            AvatarGameBridge.ENTITY_PROPERTY_SET_AVATAR_ARRIVED_CALLBACK, ClientContext.ourEntityId) as Function;
        if( setCallback != null) {
            setCallback( avatarArrivedAtDestination );
        }
        else {
            log.error("!!!!!! This avatar is CRUSTY and old, missing AvatarGameBridge.ENTITY_PROPERTY_SET_AVATAR_ARRIVED_CALLBACK");
        }


        //Reset the entityId if something about the avatar changes
        registerListener(ClientContext.ctrl.room, AVRGameRoomEvent.AVATAR_CHANGED, handleAvatarChanged);

        resetAvatarCallbackFunctions();



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

    protected function resetAvatarCallbackFunctions() :void
    {
//        trace("resetAvatarArrivedFunction, ClientContext.ourEntityId=" + ClientContext.ourEntityId);
        //Let's hear when the avatar arrived at a destination
        var setAvatarArrivedCallback :Function = ClientContext.ctrl.room.getEntityProperty(
            AvatarGameBridge.ENTITY_PROPERTY_SET_AVATAR_ARRIVED_CALLBACK, ClientContext.ourEntityId) as Function;
        if( setAvatarArrivedCallback != null) {
            setAvatarArrivedCallback( avatarArrivedAtDestination );
        }
        else {
            log.error("!!!!!! This avatar is CRUSTY and old, missing AvatarGameBridge.ENTITY_PROPERTY_SET_AVATAR_ARRIVED_CALLBACK");

            //Ok, our avatar has changed.
            //I can't seem to update the avatar location function, so quit the game with a warning
            if (!VConstants.LOCAL_DEBUG_MODE) {
                var quitPopupName :String = "QuitAvatarBorked";
                if( ClientContext.gameMode.getObjectNamed(quitPopupName) == null) {
                    var popup :PopupQuery = new PopupQuery(
                        quitPopupName,
                        "Sorry.  Vampire Whirled cannot (yet) handle a mid-game avatar change.  " +
                        "Click the vampire icon to restart..");
                    ClientContext.centerOnViewableRoom(popup.displayObject);
                    ClientContext.gameMode.addSceneObject( popup, ClientContext.gameMode.modeSprite );
                    ClientContext.animateEnlargeFromMouseClick(popup);

                    var quitTimer :SimpleTimer = new SimpleTimer(5, function() :void {
                        ClientContext.controller.handleQuit();
                    });
                    ClientContext.gameMode.addObject( quitTimer );

                }
            }
        }
    }

    protected function avatarArrivedAtDestination(...ignored) :void
    {
        if( !ClientContext.ctrl.isConnected()) {
            trace("avatarArrivedAtDestination, ctrl null, setting callback null");
            var setCallback :Function = ClientContext.ctrl.room.getEntityProperty(
            AvatarGameBridge.ENTITY_PROPERTY_SET_AVATAR_ARRIVED_CALLBACK, ClientContext.ourEntityId) as Function;
            if( setCallback != null) {
                setCallback( null );
            }
            return;
        }


//        trace("dispatchEvent PlayerArrivedAtLocationEvent");
        dispatchEvent( new PlayerArrivedAtLocationEvent() );

    }


    /**
    * If we change avatars, make sure to update the movement notification function
    */
    protected function handleAvatarChanged( e :AVRGameRoomEvent ) :void
    {
//        trace("handleAvatarChanged");
        var playerAvatarChangedId :int = int( e.value );

        //We are care about our own avatar
        if( playerAvatarChangedId != ClientContext.ourPlayerId ) {
            return;
        }

        //Get our entityId
        var currentEntityId :String;

        for each( var entityId :String in ClientContext.ctrl.room.getEntityIds(EntityControl.TYPE_AVATAR)) {

            var entityUserId :int = int(ClientContext.ctrl.room.getEntityProperty( EntityControl.PROP_MEMBER_ID, entityId));

            if( entityUserId == ClientContext.ctrl.player.getPlayerId() ) {
                currentEntityId = entityId;
                break;
            }

        }

        if( currentEntityId != _currentEntityId) {

            //Update the clientcontext cached version
            ClientContext.clearOurEntityId();

            //Change our id for future reference.
            _currentEntityId = currentEntityId;

            resetAvatarCallbackFunctions();
        }



//        trace("  currentEntityId=" + currentEntityId);
//
//        trace("  _currentEntityId=" + _currentEntityId);

//        if( currentEntityId != _currentEntityId) {
//
//            _updateAvatar = true;
//            //Update the clientcontext cached version
//            ClientContext.clearOurEntityId();
//
//            //Change our id for future reference.
//            _currentEntityId = currentEntityId;
//        }
//
//
//        //Update the avatar functions on the second event.
//        if( _updateAvatar ) {
//            _updateAvatar = false;
//            //Update avatar dependent stuff
//            resetAvatarArrivedFunction();
//
//        }

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


//    protected function checkProximity( ...ignored) :void
//    {
//        var av :AVRGameAvatar = ClientContext.ctrl.room.getAvatarInfo( ClientContext.ourPlayerId);
//        if( av == null) {
//            return;
//        }
//        var mylocation :Point = new Point( av.x, av.y );
//        var closestOtherPlayerId :int = -1;
//        var closestOtherPlayerDistance :Number = Number.MAX_VALUE;
//
//        for each( var playerid :int in ClientContext.ctrl.room.getPlayerIds()) {
//            if( playerid == ClientContext.ourPlayerId) {
//                continue;
//            }
//            av = ClientContext.ctrl.room.getAvatarInfo( playerid );
//            var otherPlayerPoint :Point = new Point( av.x, av.y );
//            var distance :Number = Point.distance( mylocation, otherPlayerPoint);
//            if( distance < closestOtherPlayerDistance) {
//                closestOtherPlayerId = playerid;
//                closestOtherPlayerDistance = distance;
//            }
//        }
//
////        if( closestOtherPlayerId > 0) {
//            ClientContext.currentClosestPlayerId = closestOtherPlayerId;
//            dispatchEvent( new ClosestPlayerChangedEvent( closestOtherPlayerId ) );
////        }
//    }
    public function playerEnteredRoom( ...ignored ) :void
    {
        //Reset avatar locations
//        ClientContext.ctrl.room.getEntityProperty(
//            AvatarGameBridge.ENTITY_PROPERTY_RESET_LOCATIONS, ClientContext.ourEntityId );

        trace(VConstants.DEBUG_MINION + " Player entered room");

        if( lineage == null) {

            _lineage = loadHierarchyFromProps();
            trace(VConstants.DEBUG_MINION + " loadHierarchyFromProps()=" + _lineage);
            dispatchEvent( new LineageUpdatedEvent( _lineage ) );

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

    protected function loadHierarchyFromProps() :Lineage
    {
        log.debug(VConstants.DEBUG_MINION + " loadHierarchyFromProps()");
        var hierarchy :Lineage = new Lineage();
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


        switch (e.name) {
            case Codes.ROOM_PROP_MINION_HIERARCHY:// ) {//|| e.name == Codes.ROOM_PROP_MINION_HIERARCHY_ALL_PLAYER_IDS) {
            _lineage = loadHierarchyFromProps();
            dispatchEvent( new LineageUpdatedEvent( _lineage ) );
            break;

            case Codes.ROOM_PROP_PLAYERS_FEEDING_UNAVAILABLE:
            var p :Array = playersFeeding;
            dispatchEvent( new PlayersFeedingEvent( p ) );
            break;

            default:
            break;
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
        //Why do I have to do this?  Is there a race condidtion, where the game is shutdown
        //but it's still receiving updates?
        if (!ClientContext.ctrl.isConnected()) {
            return;
        }

//        log.debug(Constants.DEBUG_MINION + " elementChanged()", "e", e);
        if( e.name == Codes.ROOM_PROP_MINION_HIERARCHY) {

            _lineage = loadHierarchyFromProps();
//            log.debug(Constants.DEBUG_MINION + " elementChanged", "e", e, "_hierarchy", _hierarchy);

            dispatchEvent( new LineageUpdatedEvent( _lineage ) );

            trace(Codes.ROOM_PROP_MINION_HIERARCHY + " updated, lineage now=" + _lineage);
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
                    log.debug("From room props " + playerIdUpdated + ", action=" + ClientContext.model.state +
                        ", setStateFunction() " + e.newValue.toString());
                    setStateFunction( e.newValue.toString() );
                }
                else {
                    log.error("handleElementChanged, setStateFunction==null, crusty avatar??", "e",
                        e, "entityAvatarId", entityAvatarId, "playerIdUpdated", playerIdUpdated );
                }

            }


            if( playerIdUpdated == ClientContext.ourPlayerId ) {

                switch (e.index) {
                    case Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_STATE:
                    dispatchEvent( new ChangeActionEvent( e.newValue.toString() ) );
                    break;

//                    case Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_ID:
//                    setAvatarTarget(int(e.newValue));
//                    break;
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

    public function get sire() :int
    {
        if (_lineage != null) {
            return _lineage.getSireId(ClientContext.ourPlayerId);
        }
        return 0;
    }

    public function get invites() :int
    {
        return SharedPlayerStateClient.getInvites( ClientContext.ourPlayerId );
    }

    public function get location() :Array
    {
        var avatar :AVRGameAvatar = ClientContext.ctrl.room.getAvatarInfo( ClientContext.ourPlayerId );
        if( avatar != null ) {
            return [avatar.x, avatar.y, avatar.z, avatar.orientation];
        }
        return null;
    }

    public function getLocation (playerId :int) :Array
    {
        var avatar :AVRGameAvatar = ClientContext.ctrl.room.getAvatarInfo(playerId);
        if( avatar != null ) {
            return [avatar.x, avatar.y, avatar.z, avatar.orientation];
        }
        return null;
    }

    public function get avatar() :AVRGameAvatar
    {
        if (ClientContext.ctrl.room == null) {
            return null;
        }
        return ClientContext.ctrl.room.getAvatarInfo(ClientContext.ourPlayerId);
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


    public function setStandBehindTarget (targetId :int) :void
    {
        //Set the avatar target.  That way, when the avatar arrived at it's destination, it
        //will set it's orientation the same as the target's orientation.
        var setTargetFunction :Function = ClientContext.ctrl.room.getEntityProperty(
            AvatarGameBridge.ENTITY_PROPERTY_SET_STAND_BEHIND_ID_FUNCTION, ClientContext.ourEntityId ) as Function;
        if( setTargetFunction != null ) {
            setTargetFunction( targetId );
        }
        else {
            log.error("Cannot set avatar stand behind target as the function is null, targetId=" + targetId);
        }
    }
//
//    public function get targetPlayerId() :int
//    {
//        return SharedPlayerStateClient.getTargetPlayer(  ClientContext.ourPlayerId );
//    }

    public function get state() :String
    {
        return SharedPlayerStateClient.getCurrentState( ClientContext.ourPlayerId );
    }

    public function isNewPlayer() :Boolean
    {
        return time <= 1;
    }

    public function isVampire() :Boolean
    {
        return VConstants.LOCAL_DEBUG_MODE || level >= VConstants.MINIMUM_VAMPIRE_LEVEL;
    }

    public function get lineage() :Lineage
    {
        return _lineage;
    }

    //For debugging
    public function set lineage(h :Lineage) :void
    {
        _lineage = h;
    }

    public function get hotspot () :Array
    {
        var hotspot :Array = ClientContext.ctrl.room.getEntityProperty(
            EntityControl.PROP_HOTSPOT, ClientContext.ourEntityId ) as Array;
        return hotspot;
    }

    public function getAvatarName (playerId :int) :String
    {
        var entityId :String = ClientContext.getPlayerEntityId(playerId);
        if (entityId != null) {
            var name :String = ClientContext.ctrl.room.getEntityProperty(
                EntityControl.PROP_NAME, entityId) as String;
            return name;
        }
        return null;
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
            try {
                pfd.fromBytes(bytes);
            }
            catch( err :Error ) {
                log.error(err.getStackTrace());
                return new PlayerFeedingData();
            }
        }

        return pfd;
    }

//    public function get validNonPlayerTargetsFromChatting() :Array
//    {
//        var targets :Array = ClientContext.ctrl.room.getEntityProperty(
//            AvatarGameBridge.ENTITY_PROPERTY_CHAT_TARGETS, ClientContext.ourEntityId) as Array;
//
//        trace("validNonPlayerTargetsFromChatting targets != null: " + (targets != null));
//        return targets;
//    }


    public function get playersFeeding() :Array
    {
        var feedingPlayers :Array =
            ClientContext.ctrl.room.props.get( Codes.ROOM_PROP_PLAYERS_FEEDING_UNAVAILABLE ) as Array;

        return feedingPlayers == null ? [] : feedingPlayers;
    }



    public function setAvatarState( state :String ) :void
    {
        log.debug(ClientContext.ourPlayerId + " setAvatarState", "state", state);
        ClientContext.ctrl.player.setAvatarState( state );
    }


    protected var _currentEntityId :String;

//    /**
//    * When you change avatars, the AVRGameRoomEvent.AVATAR_CHANGED is dispatched twice.  Once,
//    * when the old avatar is removed, and once when the new avatar is loaded.  However, there is
//    * no way to listen specifically for the second, since your entityID is changed on the first
//    * event.
//    *
//    * So use the boolean, on the first event, set it to true, then on the second, reload the
//    * avatar functions.
//    */
//    protected var _updateAvatar :Boolean = false;

    public var currentSelectedTarget :int = 0;

    protected var _lineage :Lineage;
    protected var _agentCtrl :AgentSubControl;
    protected var _propsCtrl :PropertyGetSubControl;


    protected static var log :Log = Log.getLog(GameModel);

}
}