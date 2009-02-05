package vampire.client.actions.hierarchy
{
    
    
import com.threerings.flash.SimpleTextButton;

import flash.events.MouseEvent;

import vampire.client.ClientContext;
import vampire.client.actions.BaseVampireMode;
import vampire.data.Constants;

[RemoteClass(alias="vampire.client.modes.HierarchyMode")]

public class HierarchyMode extends BaseVampireMode
{
    override protected function setupUI():void
    {
        super.setupUI();
        trace("!!!! in HierarchyMode.setupUI()");
        modeSprite.graphics.clear();
        modeSprite.graphics.beginFill(0xd0d0e3);
        modeSprite.graphics.drawRect(0, 0, 300, 300);
        modeSprite.graphics.endFill();
        
        
        var makeSireButton :SimpleTextButton = new SimpleTextButton( "Make Sire" );
        makeSireButton.x = 10;
        makeSireButton.y = 50;
        makeSireButton.addEventListener( MouseEvent.CLICK, makeSire);
        modeSprite.addChild( makeSireButton );
        
        var makeMinionButton :SimpleTextButton = new SimpleTextButton( "Make Minion" );
        makeMinionButton.x = 10;
        makeMinionButton.y = 80;
        makeMinionButton.addEventListener( MouseEvent.CLICK, makeMinion);
        modeSprite.addChild( makeMinionButton );
        
        
        var h :HierarchyView = new HierarchyView();
        addObject( h, modeSprite);
    }
    
    protected function makeSire( ... ignored ) :void
    {
        if( ClientContext.currentClosestPlayerId > 0) {
            ClientContext.gameCtrl.agent.sendMessage( Constants.NAMED_EVENT_MAKE_SIRE, ClientContext.currentClosestPlayerId );
        }
    }
    
    protected function makeMinion( ... ignored ) :void
    {
        if( ClientContext.currentClosestPlayerId > 0) {
            ClientContext.gameCtrl.agent.sendMessage( Constants.NAMED_EVENT_MAKE_MINION, ClientContext.currentClosestPlayerId );
        }
    }
    
}
}