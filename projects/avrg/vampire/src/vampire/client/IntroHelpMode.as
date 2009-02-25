package vampire.client
{
import com.threerings.flash.SimpleTextButton;
import com.threerings.flash.TextFieldUtil;
import com.threerings.util.Command;
import com.threerings.util.HashMap;
import com.whirled.contrib.simplegame.objects.SceneObject;

import fakeavrg.PropertyGetSubControlFake;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

import vampire.avatar.AvatarGameBridge;
import vampire.data.Codes;
import vampire.data.Logic;
import vampire.data.VConstants;

public class IntroHelpMode extends SceneObject
{
    public function IntroHelpMode()
    {
        setup()
    }
    
    override public function get objectName () :String
    {
        return NAME;
    }
    
    override public function get displayObject():DisplayObject
    {
        return modeSprite;
    }
    
//    override 
    protected function setup() :void
    {
//        modeSprite.graphics.beginFill(0xcc0000);
//        modeSprite.graphics.drawRect(100, 100, 400, 200);
//        modeSprite.graphics.endFill();
//        
//        modeSprite.graphics.lineStyle(0x000000, 1);
        
        
        var background :Sprite = new Sprite();
        background.graphics.beginFill(0xcc0000);
        background.graphics.drawRect(100, 100, 400, 200);
        background.graphics.endFill();
        modeSprite.addChild( background );
        
        var welcometext :TextField = TextFieldUtil.createField("Welcome to Vampire, click to remove", {selectable:false, x:120, y:120, width:200}); 
        modeSprite.addChild( welcometext );
        
//        Command.bind( welcometext, MouseEvent.CLICK, VampireController.HIDE_INTRO );
        Command.bind( background, MouseEvent.CLICK, destroySelf );
            
            
               
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
        
        

        
        
        
        var feedButton :SimpleTextButton = new SimpleTextButton( "FEED!!!!" );
        feedButton.x = 50;
        feedButton.y = 120;
        Command.bind( feedButton, MouseEvent.CLICK, VampireController.FEED);
        modeSprite.addChild( feedButton );
        
        
        var locationsButton :SimpleTextButton = new SimpleTextButton( "Locations from avatar" );
        locationsButton.x = loseXPButton.x;
        locationsButton.y = loseXPButton.y + 30;
        locationsButton.addEventListener( MouseEvent.CLICK, function(...ignored):void{ 
            var locations :HashMap  = ClientContext.ctrl.room.getEntityProperty( AvatarGameBridge.ENTITY_PROPERTY_AVATAR_LOCATIONS, ClientContext.ourEntityId) as HashMap;
            trace("locations:");
            if( locations != null) {
                locations.forEach( function( id :int, data :Array) :void {
                    trace( id + "   data=" + data);    
                });
            }
        });
        modeSprite.addChild( locationsButton );
        
        var locationsChangedButton :SimpleTextButton = new SimpleTextButton( "Locations changed" );
        locationsChangedButton.x = locationsButton.x;
        locationsChangedButton.y = locationsButton.y + 30;
        locationsChangedButton.addEventListener( MouseEvent.CLICK, function(...ignored):void{ 
            trace("locations changed=" + ClientContext.ctrl.room.getEntityProperty( AvatarGameBridge.ENTITY_PROPERTY_IS_LOCATIONS_CHANGED, ClientContext.ourEntityId) );
            
        });
        modeSprite.addChild( locationsChangedButton );
        
        var showInviteButton :SimpleTextButton = new SimpleTextButton( "Show Invites" );
        showInviteButton.x = locationsChangedButton.x;
        showInviteButton.y = locationsChangedButton.y + 30;
        showInviteButton.addEventListener( MouseEvent.CLICK, function(...ignored):void{ 
            ClientContext.ctrl.local.showInvitePage("Join my game!!", "sire=" + ClientContext.ourPlayerId);
            
        });
        modeSprite.addChild( showInviteButton );
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
        
   protected var modeSprite :Sprite = new Sprite(); 
   public static const NAME :String = "IntroHelp";
}
}