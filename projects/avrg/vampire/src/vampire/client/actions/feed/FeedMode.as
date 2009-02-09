package vampire.client.actions.feed
{
    
import com.threerings.flash.SimpleTextButton;
import com.threerings.util.Command;

import flash.events.MouseEvent;

import vampire.client.ClientContext;
import vampire.client.VampireController;
import vampire.client.actions.BaseVampireMode;
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
        
        
        var feedButton :SimpleTextButton = new SimpleTextButton( "FEED!!!!" );
        feedButton.x = 50;
        feedButton.y = 120;
        Command.bind( feedButton, MouseEvent.CLICK, VampireController.FEED);
        modeSprite.addChild( feedButton );
    }
    
    protected function gainBlood( ... ignored ) :void
    {
        ClientContext.gameCtrl.agent.sendMessage( Constants.NAMED_EVENT_BLOOD_UP );
    }
    
    protected function loseBlood( ... ignored ) :void
    {
        ClientContext.gameCtrl.agent.sendMessage( Constants.NAMED_EVENT_BLOOD_DOWN );
    }
            
}
}