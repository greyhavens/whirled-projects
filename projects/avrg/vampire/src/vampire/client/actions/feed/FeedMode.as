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
import vampire.data.Constants;
import vampire.data.Logic;
[RemoteClass(alias="vampire.client.modes.FeedMode")]

public class FeedMode extends BaseVampireMode
{
    override protected function setupUI():void
    {
        return;
        
        super.setupUI();
        
        
        var getBloodButton :SimpleTextButton = new SimpleTextButton( "+Blood" );
        getBloodButton.x = 50;
        getBloodButton.y = 50;
        getBloodButton.addEventListener( MouseEvent.CLICK, gainBlood);
        modeSprite.addChild( getBloodButton );
        
        var loseBloodButton :SimpleTextButton = new SimpleTextButton( "-Blood" );
        loseBloodButton.x = 50;
        loseBloodButton.y = 80;
        loseBloodButton.addEventListener( MouseEvent.CLICK, loseBlood);
        modeSprite.addChild( loseBloodButton );
        
        var addLevelButton :SimpleTextButton = new SimpleTextButton( "+Level" );
        addLevelButton.x = getBloodButton.x + 100;
        addLevelButton.y = getBloodButton.y
        addLevelButton.addEventListener( MouseEvent.CLICK, gainLevel);
        modeSprite.addChild( addLevelButton );
        
        var loseLevelButton :SimpleTextButton = new SimpleTextButton( "-Level" );
        loseLevelButton.x = loseBloodButton.x + 100;
        loseLevelButton.y = loseBloodButton.y;
        loseLevelButton.addEventListener( MouseEvent.CLICK, loseLevel);
        modeSprite.addChild( loseLevelButton );
        
        var addXPButton :SimpleTextButton = new SimpleTextButton( "+XP" );
        addXPButton.x = loseLevelButton.x;
        addXPButton.y = loseLevelButton.y + 50;
        addXPButton.addEventListener( MouseEvent.CLICK, gainXP);
        modeSprite.addChild( addXPButton );
        
        var loseXPButton :SimpleTextButton = new SimpleTextButton( "-XP" );
        loseXPButton.x = addXPButton.x;
        loseXPButton.y = addXPButton.y + 30;
        loseXPButton.addEventListener( MouseEvent.CLICK, loseXP);
        modeSprite.addChild( loseXPButton );
        
        var toVampireButton :SimpleTextButton = new SimpleTextButton( "Vampire Colors" );
        toVampireButton.x = loseXPButton.x;
        toVampireButton.y = loseXPButton.y + 50;
        toVampireButton.addEventListener( MouseEvent.CLICK, function(...ignored):void { 
            ClientContext.gameCtrl.agent.sendMessage( 
                Constants.SIGNAL_CHANGE_COLOR_SCHEME_REQUEST, 
                AvatarGameBridge.COLOR_SCHEME_VAMPIRE ); 
        });
        
        modeSprite.addChild( toVampireButton );
        
        var toHumanButton :SimpleTextButton = new SimpleTextButton( "Human colors" );
        toHumanButton.x = loseXPButton.x;
        toHumanButton.y = toVampireButton.y + 30;
        toHumanButton.addEventListener( MouseEvent.CLICK, function(...ignored):void{ 
            ClientContext.gameCtrl.agent.sendMessage( 
                Constants.SIGNAL_CHANGE_COLOR_SCHEME_REQUEST, 
                AvatarGameBridge.COLOR_SCHEME_HUMAN ); 
        });
        modeSprite.addChild( toHumanButton );
        
        
        
        var feedButton :SimpleTextButton = new SimpleTextButton( "FEED!!!!" );
        feedButton.x = 50;
        feedButton.y = 120;
        Command.bind( feedButton, MouseEvent.CLICK, VampireController.FEED);
        modeSprite.addChild( feedButton );
    }
    
    protected function gainBlood( ... ignored ) :void
    {
        ClientContext.gameCtrl.agent.sendMessage( Constants.NAMED_EVENT_BLOOD_UP );
        if( Constants.LOCAL_DEBUG_MODE) {
            
            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.gameCtrl.room.props);
            
            var currentBlood :Number = ClientContext.model.blood;
            if( isNaN( currentBlood )) {
                currentBlood = 0;
            }
            props.setIn( Codes.playerRoomPropKey( ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD, currentBlood + 20);
        }
    }
    
    protected function loseBlood( ... ignored ) :void
    {
        ClientContext.gameCtrl.agent.sendMessage( Constants.NAMED_EVENT_BLOOD_DOWN );
        
        if( Constants.LOCAL_DEBUG_MODE) {
            
            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.gameCtrl.room.props);
            
            var currentBlood :Number = ClientContext.model.blood;
            if( isNaN( currentBlood )) {
                currentBlood = 0;
            }
            props.setIn( Codes.playerRoomPropKey( ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD, Math.max(0,currentBlood - 20));
        }
    }
    
    protected function gainLevel( ... ignored ) :void
    {
        ClientContext.gameCtrl.agent.sendMessage( Constants.NAMED_EVENT_LEVEL_UP );
        
        if( Constants.LOCAL_DEBUG_MODE) {
            
            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.gameCtrl.room.props);
            
            var currentLevel :Number = ClientContext.model.level;
            
            var xpNeededForNextLevel :int = Logic.xpNeededForLevel( currentLevel + 1) - ClientContext.model.xp;
            
            props.setIn( Codes.playerRoomPropKey( ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP, ClientContext.model.xp + xpNeededForNextLevel);
        }
    }
    
    protected function loseLevel( ... ignored ) :void
    {
        ClientContext.gameCtrl.agent.sendMessage( Constants.NAMED_EVENT_LEVEL_DOWN );
        
        if( Constants.LOCAL_DEBUG_MODE) {
            
            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.gameCtrl.room.props);
            
            var currentLevel :Number = ClientContext.model.level;
            if( currentLevel > 1) {
                var newXp :int = Logic.xpNeededForLevel( currentLevel - 1 );
                props.setIn( Codes.playerRoomPropKey( ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP, newXp);
            }
            
        }
    }
    
    protected function gainXP( ... ignored ) :void
    {
        
        if( Constants.LOCAL_DEBUG_MODE) {
            
            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.gameCtrl.room.props);
            
            var currentXP:int = ClientContext.model.xp;
            
            props.setIn( Codes.playerRoomPropKey( ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP, Math.max(0,currentXP + 20));
            trace("Current xp=" + ClientContext.model.xp);
        }
    }
    
    protected function loseXP( ... ignored ) :void
    {
        if( Constants.LOCAL_DEBUG_MODE) {
            
            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.gameCtrl.room.props);
            
            var currentXP:int = ClientContext.model.xp;
            
            props.setIn( Codes.playerRoomPropKey( ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP, Math.max(0,currentXP - 20));
        }
    }
            
}
}