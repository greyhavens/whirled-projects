package vampire.client
{
import com.threerings.util.Log;
import com.threerings.util.StringUtil;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.AgentSubControl;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertyGetSubControl;

import flash.events.EventDispatcher;

import vampire.data.SharedPlayerStateClient;

public class Model extends EventDispatcher
{
    public function setup () :void
    {
//        _playerStates = new HashMap();
        
        _agentCtrl = ClientContext.gameCtrl.agent;
        _propsCtrl = ClientContext.gameCtrl.room.props;

        _propsCtrl.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propChanged);
        
        _propsCtrl.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, elementChanged);
        
        //Update the HUD when the room props come in.
        ClientContext.gameCtrl.player.addEventListener(AVRGamePlayerEvent.ENTERED_ROOM, firePropertyChangedUpdate);
        
        //If the room props are already present, update the HUD now.
        if( _propsCtrl.get( SharedPlayerStateClient.ROOM_PROP_PREFIX_PLAYER_DICT + ClientContext.ourPlayerId) != null) {
            firePropertyChangedUpdate();
        }
        
        
        
//        for each( var playerId :int in players ) {
//            if( _propsCtrl.get( SharedPlayerStateClient.ROOM_PROP_PREFIX_PLAYER_DICT + playerId) != null) {
//                dispatchEvent( new PlayerStateChangedEvent( playerId ) );
////                var bytes :ByteArray = _propsCtrl.get( "" + playerId) as ByteArray;
////                if( bytes == null) {
////                    log.warning("Model.setup(), _propsCtrl contains something for " + playerId + " but not a ByteArray, which it should be");
////                }
////                else {
//////                    var playerstate :SharedPlayerStateServer = SharedPlayerStateServer.fromBytes( bytes );
////                    log.debug("setup(), state already in room props=" + playerstate);
//////                    _playerStates.put( playerId, playerstate );
////                    dispatchEvent( new PlayerStateChangedEvent( playerId ) );
////                    
////                }
//                
//            }
//            else {
//                log.debug("Model.setup(), no room props for " + playerId)
//            }
//        }
        
        
//        var stateBytes :ByteArray = (_propsCtrl.get(Constants.PROP_STATE) as ByteArray);
//        _curState = (stateBytes != null ? SharedState.fromBytes(stateBytes) : new SharedState());
//
//        // read current scores
//        var scoreBytes :ByteArray = (_propsCtrl.get(Constants.PROP_SCORES) as ByteArray);
//        _curScores = (scoreBytes != null ?
//            ScoreTable.fromBytes(scoreBytes, Constants.SCORETABLE_MAX_ENTRIES) :
//            new ScoreTable(Constants.SCORETABLE_MAX_ENTRIES));
    }


    public function firePropertyChangedUpdate( ...ignored ) :void
    {
        log.debug("firePropertyChangedUpdate()");
        dispatchEvent( new PlayerStateChangedEvent( ClientContext.ourPlayerId ) );
    }
    public function destroy () :void
    {
        _propsCtrl.removeEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propChanged);
        _propsCtrl.removeEventListener(ElementChangedEvent.ELEMENT_CHANGED, elementChanged);
        ClientContext.gameCtrl.player.removeEventListener(AVRGamePlayerEvent.ENTERED_ROOM, firePropertyChangedUpdate);
    }
    
    protected function propChanged (e :PropertyChangedEvent) :void
    {
        //Check if it is non-player properties changed??
        log.debug("propChanged", "e", e);
        //Otherwise check for player updates
        
        var playerIdUpdated :int = parsePlayerIdFromPropertyName( e.name );
        if( !isNaN( playerIdUpdated )) {
//            _playerStates.put( playerIdUpdated, SharedPlayerStateServer.fromBytes(ByteArray(e.newValue)) );
//            log.debug("Updated state=" + _playerStates.get( playerIdUpdated));
            log.debug("  Dispatching event=" + PlayerStateChangedEvent.NAME);
//            dispatchEvent( new Event( VampireController.PLAYER_STATE_CHANGED ) );
            dispatchEvent( new PlayerStateChangedEvent( playerIdUpdated ) );
        }
        else {
            log.warning("  Failed to update PropertyChangedEvent" + e);
        }
        
        
        
        
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
    
    protected function elementChanged (e :ElementChangedEvent) :void
    {
        //Check if it is non-player properties changed??
        log.debug("propChanged", "e", e);
        //Otherwise check for player updates
        
        
        
        var playerIdUpdated :int = parsePlayerIdFromPropertyName( e.name );
        
        
        if( !isNaN( playerIdUpdated )) {
//            _playerStates.put( playerIdUpdated, SharedPlayerStateServer.fromBytes(ByteArray(e.newValue)) );
//            log.debug("Updated state=" + _playerStates.get( playerIdUpdated));

//            log.debug("Value in room props=" + ClientContext.gameCtrl.room.props.get(e.name) as Dictionary;)
            log.debug("  Dispatching event=" + PlayerStateChangedEvent.NAME);
//            dispatchEvent( new Event( VampireController.PLAYER_STATE_CHANGED ) );
            dispatchEvent( new PlayerStateChangedEvent( playerIdUpdated ) );
        }
        else {
            log.warning("  Failed to update ElementChangedEvent" + e);
        }
        
    }
    
    public static function parsePlayerIdFromPropertyName (prop :String) :int
    {
        if (StringUtil.startsWith(prop, SharedPlayerStateClient.ROOM_PROP_PREFIX_PLAYER_DICT)) {
            var num :Number = parseInt(prop.slice(SharedPlayerStateClient.ROOM_PROP_PREFIX_PLAYER_DICT.length));
            if (!isNaN(num)) {
                return num;
            }
        }
        return -1;
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
    
//    protected var _currentPlayerState :SharedPlayerState;
    
//    protected var _playerStates :HashMap;

    protected static var log :Log = Log.getLog(Model);
}
}