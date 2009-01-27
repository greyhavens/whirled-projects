package vampire.client
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.AgentSubControl;
import com.whirled.contrib.EventHandlers;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertyGetSubControl;

import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.utils.Timer;

import vampire.client.events.ChangeActionEvent;
import vampire.client.events.ClosestPlayerChangedEvent;
import vampire.data.Constants;
import vampire.data.SharedPlayerStateClient;
import vampire.data.SharedPlayerStateServer;


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

        _propsCtrl.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propChanged);
        _propsCtrl.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, elementChanged);
        
        //Update the HUD when the room props come in.
//        EventHandlers.registerListener(ClientContext.gameCtrl.player, AVRGamePlayerEvent.ENTERED_ROOM, firePropertyChangedUpdate);
        
        //If the room props are already present, update the HUD now.
        if( SharedPlayerStateClient.isProps( ClientContext.ourPlayerId ) ) {
            firePropertyChangedUpdate();
        }
        
        //Every second, update who is our closest player.  Used for targeting e.g. feeding.
        _proximityTimer = new Timer(Constants.TIME_INTERVAL_PROXIMITY_CHECK, 0);
        EventHandlers.registerListener( _proximityTimer, TimerEvent.TIMER, checkProximity);    
        _proximityTimer.start();
        
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
        
        if( closestOtherPlayerId > 0) {
            ClientContext.currentClosestPlayerId = closestOtherPlayerId;
            dispatchEvent( new ClosestPlayerChangedEvent( closestOtherPlayerId ) );
        }
    }
    public function firePropertyChangedUpdate( ...ignored ) :void
    {
        log.debug("firePropertyChangedUpdate()");
//        dispatchEvent( new PlayerStateChangedEvent( ClientContext.ourPlayerId ) );
    }
    public function destroy () :void
    {
        _propsCtrl.removeEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propChanged);
        _propsCtrl.removeEventListener(ElementChangedEvent.ELEMENT_CHANGED, elementChanged);
        ClientContext.gameCtrl.player.removeEventListener(AVRGamePlayerEvent.ENTERED_ROOM, firePropertyChangedUpdate);
        _proximityTimer.removeEventListener(TimerEvent.TIMER, checkProximity);
        _proximityTimer.stop();
    }
    
    protected function propChanged (e :PropertyChangedEvent) :void
    {
        //Check if it is non-player properties changed??
//        log.debug("propChanged", "e", e);
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
            if( e.index == SharedPlayerStateServer.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_ACTION) {
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
    
    
    public function get bloodbonded() :Array
    {
        return SharedPlayerStateClient.getBloodBonded( ClientContext.ourPlayerId );
    }
    
    public function get minions() :Array
    {
        return SharedPlayerStateClient.getMinions( ClientContext.ourPlayerId );
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
    
    protected var _agentCtrl :AgentSubControl;
    protected var _propsCtrl :PropertyGetSubControl;
    
    protected var _proximityTimer :Timer;
    
//    protected var _currentPlayerState :SharedPlayerState;
    
//    protected var _playerStates :HashMap;

    protected static var log :Log = Log.getLog(GameModel);
}
}