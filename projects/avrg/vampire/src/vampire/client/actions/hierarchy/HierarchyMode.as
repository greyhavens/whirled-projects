package vampire.client.actions.hierarchy
{
    
    
import com.threerings.flash.SimpleTextButton;
import com.threerings.util.Log;

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
        
        makeSireButton.addEventListener( MouseEvent.CLICK, ClientContext.controller.makeSire);
        modeSprite.addChild( makeSireButton );
        
        var makeMinionButton :SimpleTextButton = new SimpleTextButton( "Make Minion" );
        makeMinionButton.x = 10;
        makeMinionButton.y = 80;
        makeMinionButton.addEventListener( MouseEvent.CLICK, ClientContext.controller.makeMinion);
        modeSprite.addChild( makeMinionButton );
        
        
        var h :HierarchyView = new HierarchyView();
        addObject( h, modeSprite);
    }
    
    
    protected static const log :Log = Log.getLog( HierarchyMode );
    
}
}