package vampire.client
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.avrg.AgentSubControl;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertyGetSubControl;

import flash.events.EventDispatcher;
import flash.geom.Point;
import flash.utils.Dictionary;

import vampire.client.events.ChangeActionEvent;
import vampire.client.events.ClosestPlayerChangedEvent;
import vampire.client.events.HierarchyUpdatedEvent;
import vampire.data.Codes;
import vampire.data.Constants;
import vampire.data.MinionHierarchy;
import vampire.data.SharedPlayerStateClient;


/**
 * The game and subgames interact with the agent code and properties via this class.
 * 
 */
public class GameModel extends EventDispatcher
{
    public function setup () :void
    {
//        _playerStates = new HashMap();
        
        _agentCtrl = ClientContext.gameCtrl.agent;
        _propsCtrl = ClientContext.gameCtrl.room.props;

        _events.registerListener( _propsCtrl, PropertyChangedEvent.PROPERTY_CHANGED, propChanged);
        _events.registerListener( _propsCtrl, ElementChangedEvent.ELEMENT_CHANGED, elementChanged);
        
        
        //Update the HUD when the room props come in.
        _events.registerListener(ClientContext.gameCtrl.player, AVRGamePlayerEvent.ENTERED_ROOM, playerEnteredRoom);
        
        //Update the closest userId (might not be a player)
        _events.registerListener(ClientContext.gameCtrl.room, AVRGameRoomEvent.SIGNAL_RECEIVED, handleSignalReceived);
        
        //If the room props are already present, update the HUD now.
        if( SharedPlayerStateClient.isProps( ClientContext.ourPlayerId ) ) {
            playerEnteredRoom();
        }
        
        //Every second, update who is our closest player.  Used for targeting e.g. feeding.
//        _proximityTimer = new Timer(Constants.TIME_INTERVAL_PROXIMITY_CHECK, 0);
//        _events.registerListener( _proximityTimer, TimerEvent.TIMER, checkProximity );
//        _proximityTimer.start();
        
    }
    
    /**
    * The player avatar tells the model who is closest.
    */
    protected function handleSignalReceived( e :AVRGameRoomEvent) :void
    {
        trace("model.handleSignalReceived(), e=" + e);
        if( e.name == Constants.SIGNAL_CLOSEST_ENTITY) {
            var args :Array = e.value as Array;
            if( args != null && args.length >= 2 && args[0] == ClientContext.ourPlayerId) {
                closestUserId = int(args[1]);
                trace("model.handleSignalReceived(), Closest id=" + closestUserId);
            }
        }
    }


    protected function checkProximity( ...ignored) :void
    {
        var av :AVRGameAvatar = ClientContext.gameCtrl.room.getAvatarInfo( ClientContext.ourPlayerId);
        if( av == null) {
            return;
        }
        var mylocation :Point = new Point( av.x, av.y );
        var closestOtherPlayerId :int = -1;
        var closestOtherPlayerDistance :Number = Number.MAX_VALUE;
        
        for each( var playerid :int in ClientContext.gameCtrl.room.getPlayerIds()) {
            if( playerid == ClientContext.ourPlayerId) {
                continue;
            }
            av = ClientContext.gameCtrl.room.getAvatarInfo( playerid );
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
        trace(Constants.DEBUG_MINION + " Player entered room");
        
        if( hierarchy == null) {
            
            _hierarchy = loadHierarchyFromProps();
            trace(Constants.DEBUG_MINION + " loadHierarchyFromProps()=" + _hierarchy);
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
        _events.freeAllHandlers();
//        _proximityTimer.stop();
    }
    
    protected function loadHierarchyFromProps() :MinionHierarchy
    {
        log.debug(Constants.DEBUG_MINION + " loadHierarchyFromProps()");
        var hierarchy :MinionHierarchy = new MinionHierarchy();
        var playerIds :Array = ClientContext.gameCtrl.room.props.get( Codes.ROOM_PROP_MINION_HIERARCHY_ALL_PLAYER_IDS ) as Array;
        
//        log.debug(Constants.DEBUG_MINION + " loadHierarchyFromProps()", "playerIds", playerIds);
            
        if( playerIds == null) {
            log.error(Constants.DEBUG_MINION +  " playerIds=" + playerIds);
            return hierarchy;
        }
        
        var dict :Dictionary = ClientContext.gameCtrl.room.props.get(Codes.ROOM_PROP_MINION_HIERARCHY) as Dictionary;
        
        if( dict != null) {
            
            for each( var playerId :int in playerIds) {
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
            log.debug(Constants.DEBUG_MINION + " loadHierarchyFromProps()", "dict==null");
        }
        hierarchy.recomputeMinions();
        log.debug(Constants.DEBUG_MINION + " loadHierarchyFromProps()", "hierarchy", hierarchy);
        return hierarchy;
    }
    
    protected function propChanged (e :PropertyChangedEvent) :void
    {
        //Check if it is non-player properties changed??
        log.debug(Constants.DEBUG_MINION + " propChanged", "e", e);
        
        if( e.name == Codes.ROOM_PROP_MINION_HIERARCHY || e.name == Codes.ROOM_PROP_MINION_HIERARCHY_ALL_PLAYER_IDS) {
            
//            var playerIds :Array = ClientContext.gameCtrl.room.props.get( Codes.ROOM_PROP_MINION_HIERARCHY_ALL_PLAYER_IDS ) as Array;
            
//            if( playerIds == null) {
//                log.error("propChanged", "e", e, "playerIds", playerIds);
//                return;
//            }
            
            _hierarchy = loadHierarchyFromProps();
            log.debug(Constants.DEBUG_MINION + " HUD updating hierarchy=" + _hierarchy);
            
            dispatchEvent( new HierarchyUpdatedEvent( _hierarchy ) );
        }
            
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
    
    public function elementChanged (e :ElementChangedEvent) :void
    {
        log.debug(Constants.DEBUG_MINION + " elementChanged()", "e", e); 
        if( e.name == Codes.ROOM_PROP_MINION_HIERARCHY) {
                
            _hierarchy = loadHierarchyFromProps();
            log.debug(Constants.DEBUG_MINION + " elementChanged", "e", e, "_hierarchy", _hierarchy);
        
            dispatchEvent( new HierarchyUpdatedEvent( _hierarchy ) );
            return;
        }
        
        //Check if it is non-player properties changed??
//        log.debug("elementChanged", "e", e);
        //Otherwise check for player updates
        var playerIdUpdated :int = SharedPlayerStateClient.parsePlayerIdFromPropertyName( e.name );
        
        if( !isNaN( playerIdUpdated ) && playerIdUpdated == ClientContext.ourPlayerId) {
//            _playerStates.put( playerIdUpdated, SharedPlayerStateServer.fromBytes(ByteArray(e.newValue)) );
//            log.debug("Updated state=" + _playerStates.get( playerIdUpdated));

//            log.debug("Value in room props=" + ClientContext.gameCtrl.room.props.get(e.name) as Dictionary;)
//            dispatchEvent( new Event( VampireController.PLAYER_STATE_CHANGED ) );
//            dispatchEvent( new PlayerStateChangedEvent( playerIdUpdated ) );
            
            
            //If the action changes on the server, that means the change is forced, so change to that action.
            if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_ACTION) {
                log.debug("  Dispatching event=" + ChangeActionEvent.CHANGE_ACTION + " new action=" + e.newValue);
                dispatchEvent( new ChangeActionEvent( e.newValue.toString() ) );
            }
            
        }
        else {
            log.warning("  Failed to update ElementChangedEvent" + e);
        }
        
    }
    
    public function playerIdsInRoom() :Array
    {
        return ClientContext.gameCtrl.room.getPlayerIds();
    }
    
    public function isPlayerInRoom( playerId :int ) :Boolean
    {
        return ArrayUtil.contains( playerIdsInRoom(), playerId );
    }
    
    public function isPlayer( userId :int ) :Boolean
    {
        return ArrayUtil.contains( playerIdsInRoom(), userId );
    }
    
    public function get bloodbonded() :Array
    {
        return SharedPlayerStateClient.getBloodBonded( ClientContext.ourPlayerId );
    }
    
    public function get minions() :Array
    {
        return SharedPlayerStateClient.getMinions( ClientContext.ourPlayerId );
    }
    
    public function get blood() :Number
    {
        return SharedPlayerStateClient.getBlood( ClientContext.ourPlayerId );
    }
    
    public function get level() :int
    {
        return SharedPlayerStateClient.getLevel( ClientContext.ourPlayerId );
    }
    
    public function get xp() :int
    {
        return SharedPlayerStateClient.getXP( ClientContext.ourPlayerId );
    }
    
    public function get time() :int
    {
        return SharedPlayerStateClient.getTime( ClientContext.ourPlayerId );
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
    
    public function get hierarchy() :MinionHierarchy
    {
        return _hierarchy;
//        var bytes :ByteArray = _propsCtrl.get( Codes.ROOM_PROP_MINION_HIERARCHY) as ByteArray;
//        if( bytes != null) {
//            var m :MinionHierarchy = new MinionHierarchy();
//            m.fromBytes( bytes );
//            return m; 
//        }
//        return null;
    }
    

    
//    public function get state () :SharedPlayerStateServer
//    {
//        return _playerStates.get( ClientContext.ourPlayerId ) as SharedPlayerStateServer;
//    }
//    
//    public function get isState () :Boolean
//    {
//        return _playerStates.containsKey( ClientContext.ourPlayerId );
//    }
//    
//    public function get playerIdsWithStates() :Array
//    {
//        return _playerStates.keys();
//    }
//    
//    public function getState( playerId :int ) :SharedPlayerStateServer
//    {
//        return _playerStates.get( playerId );
//    }
    
//    
//    public function get playerIdsInRoom() :Array
//    {
//        
//    }
    
    
    protected var _hierarchy :MinionHierarchy;
    protected var _agentCtrl :AgentSubControl;
    protected var _propsCtrl :PropertyGetSubControl;
    
//    protected var _proximityTimer :Timer;
    
    protected var closestUserId :int;
    
//    protected var _currentPlayerState :SharedPlayerState;
    
//    protected var _playerStates :HashMap;

    protected static var log :Log = Log.getLog(GameModel);
    
    protected var _events :EventHandlerManager = new EventHandlerManager();
}
}