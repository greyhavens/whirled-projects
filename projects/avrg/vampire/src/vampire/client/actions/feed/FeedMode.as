package vampire.client.actions.feed
{
    
import com.threerings.flash.SimpleTextButton;
import com.threerings.util.Command;

import fakeavrg.PropertyGetSubControlFake;

import flash.events.MouseEvent;

import vampire.avatar.AvatarGameBridge;
import vampire.client.ClientContext;
import vampire.client.VampireController;
import vampire.client.actions.BaseVampireMode;
import vampire.data.Codes;
import vampire.data.VConstants;
import vampire.data.Logic;
[RemoteClass(alias="vampire.client.modes.FeedMode")]

public class FeedMode extends BaseVampireMode
{
    override protected function setupUI():void
    {
        return;
        
        super.setupUI();
        
        
    }
    
    protected function gainBlood( ... ignored ) :void
    {
        ClientContext.ctrl.agent.sendMessage( VConstants.NAMED_EVENT_BLOOD_UP );
        if( VConstants.LOCAL_DEBUG_MODE) {
            
            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.ctrl.room.props);
            
            var currentBlood :Number = ClientContext.model.blood;
            if( isNaN( currentBlood )) {
                currentBlood = 0;
            }
            props.setIn( Codes.playerRoomPropKey( ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD, currentBlood + 20);
        }
    }
    
    protected function loseBlood( ... ignored ) :void
    {
        ClientContext.ctrl.agent.sendMessage( VConstants.NAMED_EVENT_BLOOD_DOWN );
        
        if( VConstants.LOCAL_DEBUG_MODE) {
            
            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.ctrl.room.props);
            
            var currentBlood :Number = ClientContext.model.blood;
            if( isNaN( currentBlood )) {
                currentBlood = 0;
            }
            props.setIn( Codes.playerRoomPropKey( ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD, Math.max(0,currentBlood - 20));
        }
    }
    
    protected function gainLevel( ... ignored ) :void
    {
        ClientContext.ctrl.agent.sendMessage( VConstants.NAMED_EVENT_LEVEL_UP );
        
        if( VConstants.LOCAL_DEBUG_MODE) {
            
            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.ctrl.room.props);
            
            var currentLevel :Number = ClientContext.model.level;
            
            var xpNeededForNextLevel :int = Logic.xpNeededForLevel( currentLevel + 1) - ClientContext.model.xp;
            
            props.setIn( Codes.playerRoomPropKey( ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP, ClientContext.model.xp + xpNeededForNextLevel);
        }
    }
    
    protected function loseLevel( ... ignored ) :void
    {
        ClientContext.ctrl.agent.sendMessage( VConstants.NAMED_EVENT_LEVEL_DOWN );
        
        if( VConstants.LOCAL_DEBUG_MODE) {
            
            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.ctrl.room.props);
            
            var currentLevel :Number = ClientContext.model.level;
            if( currentLevel > 1) {
                var newXp :int = Logic.xpNeededForLevel( currentLevel - 1 );
                props.setIn( Codes.playerRoomPropKey( ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP, newXp);
            }
            
        }
    }
    
    protected function gainXP( ... ignored ) :void
    {
        
        if( VConstants.LOCAL_DEBUG_MODE) {
            
            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.ctrl.room.props);
            
            var currentXP:int = ClientContext.model.xp;
            
            props.setIn( Codes.playerRoomPropKey( ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP, Math.max(0,currentXP + 20));
            trace("Current xp=" + ClientContext.model.xp);
        }
    }
    
    protected function loseXP( ... ignored ) :void
    {
        if( VConstants.LOCAL_DEBUG_MODE) {
            
            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.ctrl.room.props);
            
            var currentXP:int = ClientContext.model.xp;
            
            props.setIn( Codes.playerRoomPropKey( ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP, Math.max(0,currentXP - 20));
        }
    }
            
}
}