package vampire.client.modes
{
    
import com.threerings.flash.SimpleTextButton;

import flash.events.MouseEvent;

import vampire.client.ClientContext;
import vampire.data.Constants;
[RemoteClass(alias="vampire.client.modes.FeedMode")]

public class FeedMode extends BaseVampireMode
{
    override protected function setupUI():void
    {
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
    }
    
    protected function gainBlood( ... ignored ) :void
    {
        trace("gainBlood");
        ClientContext.gameCtrl.agent.sendMessage( Constants.NAMED_EVENT_BLOOD_UP );
    }
    
    protected function loseBlood( ... ignored ) :void
    {
        trace("loseBlood");
        ClientContext.gameCtrl.agent.sendMessage( Constants.NAMED_EVENT_BLOOD_DOWN );
    }
            
}
}