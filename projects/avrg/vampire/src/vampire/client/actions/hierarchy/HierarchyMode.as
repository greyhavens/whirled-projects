package vampire.client.actions.hierarchy
{
    
    
import com.threerings.flash.SimpleTextButton;
import com.threerings.flash.TextFieldUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.Command;
import com.threerings.util.Log;
import com.whirled.contrib.EventHandlers;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.net.ElementChangedEvent;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;

import vampire.client.ClientContext;
import vampire.client.VampireController;
import vampire.data.Codes;
import vampire.data.SharedPlayerStateClient;

[RemoteClass(alias="vampire.client.modes.HierarchyMode")]

public class HierarchyMode extends SceneObject
{
    public function HierarchyMode()
    {
        setupUI();
    } 
    override public function get displayObject () :DisplayObject
    {
        return modeSprite;
    }
    
    protected function setupUI():void
    {
        modeSprite.graphics.beginFill(0xd0d0e3);
        modeSprite.graphics.drawRect(0, 0, 200, 200);
        modeSprite.graphics.endFill();
        modeSprite.addChild( TextFieldUtil.createField( ClassUtil.shortClassName( this ), {selectable :false}));
        
        var closeButton :SimpleTextButton = new SimpleTextButton( "Close" );
        closeButton.x = modeSprite.width - 50;
        closeButton.y = 0;
        _events.registerListener( closeButton, MouseEvent.CLICK, function(...ignored) :void {
            destroySelf();    
        });
        modeSprite.addChild( closeButton );
        
        
//        super.setupUI();
        trace("!!!! in HierarchyMode.setupUI()");
        modeSprite.graphics.clear();
        modeSprite.graphics.beginFill(0xd0d0e3);
        modeSprite.graphics.drawRect(0, 0, 500, 500);
        modeSprite.graphics.endFill();
        
        
        var makeSireButton :SimpleTextButton = new SimpleTextButton( "Make Sire" );
        makeSireButton.x = 10;
        makeSireButton.y = 50;
        
        makeSireButton.addEventListener( MouseEvent.CLICK, ClientContext.controller.makeSire);
        modeSprite.addChild( makeSireButton );
        
        var makeMinionButton :SimpleTextButton = new SimpleTextButton( "Make Minion" );
        makeMinionButton.x = 10;
        makeMinionButton.y = 80;
        makeMinionButton.addEventListener( MouseEvent.CLICK, ClientContext.controller.makeMinion);
        modeSprite.addChild( makeMinionButton );
        
        
        var h :HierarchyView = new HierarchyView();
        addObject( h, modeSprite);
        
        
        
        //Now shows bloodbonds as well
         _bloodBondedView = new Sprite();
         _bloodBondedView.x = 300;
        
        var addTargetButton :SimpleTextButton = new SimpleTextButton("BloodBond Target");
        Command.bind( addTargetButton, MouseEvent.CLICK, VampireController.ADD_BLOODBOND);
        _bloodBondedView.addChild( addTargetButton );
        addTargetButton.x = 20;
        addTargetButton.y = 30;
        
        modeSprite.addChild( _bloodBondedView );
        
        _events
        _events.registerListener( ClientContext.gameCtrl.room.props, ElementChangedEvent.ELEMENT_CHANGED, elementChanged);
        
        showBloodBonded();
    }
    
    protected function elementChanged (e :ElementChangedEvent) :void
    {
        var playerIdUpdated :int = SharedPlayerStateClient.parsePlayerIdFromPropertyName( e.name );
        
        if( !isNaN( playerIdUpdated ) && playerIdUpdated == ClientContext.ourPlayerId) {
            
            if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED 
                || e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED_NAME) {
                showBloodBonded();
            }
        }
    }
    
    protected function destroy() :void
    {
        EventHandlers.unregisterListener( ClientContext.gameCtrl.room.props, ElementChangedEvent.ELEMENT_CHANGED, elementChanged);
    }
    
    protected function showBloodBonded() :void
    {
        if( ClientContext.model.bloodbonded <= 0 ) {
//            log.warning("showBloodBonded(0)");
            return;
        }
        
        
        var button :SimpleTextButton = new SimpleTextButton( ClientContext.model.bloodbondedName );
        Command.bind( button, MouseEvent.CLICK, VampireController.REMOVE_BLOODBOND, ClientContext.model.bloodbonded);
        button.x = 20;
        button.y = 140;
        _bloodBondedView.addChild( button );
            
            
//        while( _bloodBondedView.numChildren > 0) { _bloodBondedView.removeChildAt(0);}
//        
//        var currentY :int = 100;
//        for (var i :int = 0; i < currentBloodBonded.length; i += 2) {
//            var playerId :int = int( currentBloodBonded[i] );
//            if( playerId <= 0) {
//                log.error("showBloodBonded(), currentBloodBonded[" + i + "]=" + currentBloodBonded[i] );
//                continue;
//            }
//            var playerAvater :AVRGameAvatar = ClientContext.gameCtrl.room.getAvatarInfo( playerId );
//            var buttonLabel :String = "" + playerId;
//            if( playerAvater != null && playerAvater.name != null) {
//                buttonLabel = playerAvater.name
//            }
//            else {
//                buttonLabel = currentBloodBonded[i+1] as String;
//            }
//            
//        }
        
        
    }
    
    protected var _bloodBondedView :Sprite;
    
    protected var modeSprite :Sprite = new Sprite();
    
    
    protected static const log :Log = Log.getLog( HierarchyMode );
    
}
}