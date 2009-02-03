package vampire.avatar
{
import com.threerings.flash.MathUtil;
import com.threerings.util.ArrayUtil;
import com.whirled.AvatarControl;
import com.whirled.ControlEvent;
import com.whirled.EntityControl;

import vampire.data.Constants;
    
    
/**
 * Monitors other room entities and reports to the AVRG game client (via sendSignal())
 * the closest avatar.
 * 
 */
public class VampireAvatarController
{
    public function VampireAvatarController( ctrl :AvatarControl)
    {
        _ctrl = ctrl;
        
//        _ctrl.addEventListener(ControlEvent.STATE_CHANGED, handleStateChange);
        _ctrl.addEventListener(ControlEvent.CHAT_RECEIVED, handleChatReceived);
//        _ctrl.addEventListener(ControlEvent.SIGNAL_RECEIVED, handleSignalReceived);
        
        _ctrl.addEventListener(ControlEvent.ENTITY_ENTERED, handleEntityMoved);
        _ctrl.addEventListener(ControlEvent.ENTITY_LEFT, handleEntityMoved);
        
        _ctrl.addEventListener(ControlEvent.ENTITY_MOVED, handleEntityMoved);
    }
    
    /**
     * This is called when the user selects a different state.
     */
    protected function handleStateChange (event :ControlEvent) :void
    {
        _state = event.name;
//        trace("\nhandleStateChange(), playerId=" + playerId + ", state=" + _state);
    }
    
    protected function handleChatReceived( e :ControlEvent) :void
    {
        //Not yet implemented
//        var speakerId :int = int(e.name);
//        trace("avatar handleChatReceived()", "e.name", e.name, "chat", e.value, "e.target", e.target);
//        
//        if( e.target is AvatarControl) {
////            trace("from/to??():" + AvatarControl(e.target).);    
//        }
//        
//        if( speakerId != _ctrl.getInstanceId()) {
//            
////            _ctrl.sendChat("You said: " + e.value);
////            _ctrl.sendSignal("You said: " + e.value);
//        }
    }
    
//    protected function isPlayer( entityId :String ) :Boolean
//    {
//        return ArrayUtil.contains(_playerIds, _ctrl.getEntityProperty( EntityControl.PROP_MEMBER_ID, entityId));
//    }
    
    protected function get playerId() :int
    {
        return int(_ctrl.getEntityProperty(EntityControl.PROP_MEMBER_ID));
    }
    
    protected function handleEntityMoved( ...ignored ) :void
    {
        
        var closestUserId :int;
        var closestUserDistance :Number = Number.MAX_VALUE;
        var myX :Number = _ctrl.getLogicalLocation()[0] as Number;
        var myY :Number = _ctrl.getLogicalLocation()[1] as Number;
        
        var myUserId :int = playerId;

        for each( var entityId :String in _ctrl.getEntityIds(EntityControl.TYPE_AVATAR)) {
            
            var entityUserId :int = int(_ctrl.getEntityProperty( EntityControl.PROP_MEMBER_ID, entityId));
            
            if( entityUserId == myUserId ) {
                continue;
            }
            var entityLocation :Array = _ctrl.getEntityProperty( EntityControl.PROP_LOCATION_LOGICAL, entityId) as Array;
            
            if( entityLocation != null) {
                var distance :Number = MathUtil.distance( myX, myY, entityLocation[0], entityLocation[1]);
                if( !isNaN(distance)) {
                    if( distance < closestUserDistance) {
                        closestUserDistance = distance;
                        closestUserId = entityUserId;
                    }
                }
                
            }
        }
       
        
//        trace("Closests userId=" + closestUserId);
//        trace("Closests user name=" + _ctrl.getViewerName(closestUserId));
        if( closestUserId > 0 && closestUserId != myUserId && closestUserId != _closestUserId) {
            _closestUserId = closestUserId;  
            _ctrl.sendSignal( Constants.SIGNAL_CLOSEST_ENTITY, [myUserId, closestUserId, _ctrl.getViewerName(closestUserId)]);
        }  
        
        
    }
    
    public function get state() :String
    {
        return _state;
    }
    
    protected var _ctrl :AvatarControl;
    protected var _state :String = Constants.GAME_MODE_NOTHING;
//    protected var _playerIds :Array;
    protected var _closestUserId :int;
}
}