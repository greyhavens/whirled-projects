package vampire.avatar
{
import com.threerings.flash.MathUtil;
import com.whirled.AvatarControl;
import com.whirled.ControlEvent;
import com.whirled.EntityControl;

import vampire.data.Constants;
    
    
/**
 * Monitors other room entities and reports to the AVRG game client (via sendSignal())
 * the closest avatar (not necessarily playing the game).
 * 
 */
public class VampireAvatarController
{
    public function VampireAvatarController( ctrl :AvatarControl)
    {
        _ctrl = ctrl;
        
//        _ctrl.addEventListener(ControlEvent.STATE_CHANGED, handleStateChange);
//        _ctrl.addEventListener(ControlEvent.CHAT_RECEIVED, handleChatReceived);
//        _ctrl.addEventListener(ControlEvent.SIGNAL_RECEIVED, handleSignalReceived);
        
        _ctrl.addEventListener(ControlEvent.ENTITY_ENTERED, computeClosestAvatar);
        _ctrl.addEventListener(ControlEvent.ENTITY_LEFT, computeClosestAvatar);
        
        _ctrl.addEventListener(ControlEvent.ENTITY_MOVED, handleEntityMoved);
//        trace("\nVampireAvatarController loaded!\n");
        
    }
    protected function handleEntityMoved (e :ControlEvent) :void
    {
//        trace("\nVampireAvatarController handleEntityMoved!");
//        trace( playerId + " e=" + e);
        if( e.value != null) {//Only compute closest avatars when this avatar has arrived at location
            
            computeClosestAvatar(e);
        }
    }
    
    
    /**
     * This is called when the user selects a different state.
     */
    protected function handleStateChange (event :ControlEvent) :void
    {
//        trace("\nVampireAvatarController changing state=" + event.name+ "!\n");
        _state = event.name;
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
    
    protected function get playerId() :int
    {
        return int(_ctrl.getEntityProperty(EntityControl.PROP_MEMBER_ID));
    }
    
    protected function computeClosestAvatar( e :ControlEvent = null ) :void
    {
        var userIdMoved :int = int(_ctrl.getEntityProperty( EntityControl.PROP_MEMBER_ID, e.name));
        
        var myLocation :Array = _ctrl.getLogicalLocation();
        if( userIdMoved == playerId && e != null) {
            myLocation = e.value as Array;
        }
        var closestUserId :int;
        var closestUserDistance :Number = Number.MAX_VALUE;
        var myX :Number = myLocation[0] as Number;
        var myZ :Number = myLocation[2] as Number;
        trace("me(" + myX + ", " + myZ + ")");

        for each( var entityId :String in _ctrl.getEntityIds(EntityControl.TYPE_AVATAR)) {
            
            var entityUserId :int = int(_ctrl.getEntityProperty( EntityControl.PROP_MEMBER_ID, entityId));
            
            if( entityUserId == playerId ) {
                continue;
            }
            
            var entityLocation :Array = _ctrl.getEntityProperty( EntityControl.PROP_LOCATION_LOGICAL, entityId) as Array;
            
            if( entityUserId == userIdMoved && e != null) {
                entityLocation = e.value as Array;
            }
            
            if( entityLocation != null) {
                var distance :Number = MathUtil.distance( myX, myZ, entityLocation[0], entityLocation[2]);
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
        if( closestUserId > 0 && closestUserId != playerId && closestUserId != _closestUserId) {
//            trace("VampireAvatarController handleEntityMoved, sending closestUserId=" + closestUserId);
            _closestUserId = closestUserId;  
            _ctrl.sendSignal( Constants.SIGNAL_CLOSEST_ENTITY, [playerId, closestUserId, _ctrl.getViewerName(closestUserId)]);
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