package vampire.client
{
import com.threerings.flash.SimpleTextButton;
import com.threerings.util.Command;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.MainLoop;

import flash.display.Sprite;
import flash.events.MouseEvent;

import vampire.data.Constants;
import vampire.data.SharedPlayerStateClient;

/**
 * The main game HUD, showing e.g. blood, game notifications, and buttons to select the subgame to
 * play.
 */
public class HUD extends Sprite
{
    public function HUD()
    {
        setupUI();
        
        ClientContext.model.addEventListener( PlayerStateChangedEvent.NAME, playerUpdated );
        log.debug("Starting HUD");
        
        updatePlayerState( ClientContext.ourPlayerId );
//        if( ClientContext.model.isState ) {
//            log.debug("    there is our state in the room props.");
//            updatePlayerState( ClientContext.model.state );
//        }
//        else {
//            log.debug("    our state is not in the room props.");
//        }
    }
    
    
    protected function setupUI() :void
    {
        graphics.beginFill(0xffffff);
        graphics.drawRect(0,0, 400, 50);
        graphics.endFill();
        
        var startX :int = 30;
        var startY :int = 0;
            
        for each ( var mode :String in Constants.GAME_MODES) {
            var button :SimpleTextButton = new SimpleTextButton( mode );
            button.x = startX;
            button.y = startY;
            startX += 90;
            Command.bind( button, MouseEvent.CLICK, VampireController.SWITCH_MODE, [MainLoop.instance, mode]);
            addChild( button );
        }
        
        _blood = new Sprite();
        addChild( _blood );
        _blood.x = 50;
        _blood.y = 40; 
        
        var quitButton :SimpleTextButton = new SimpleTextButton( "Quit" );
        quitButton.x = startX;
        button.y = startY;
        startX += 90;
        Command.bind( quitButton, MouseEvent.CLICK, VampireController.QUIT);
        addChild( quitButton );
    }
    
    
    protected function playerUpdated( e :PlayerStateChangedEvent ) :void
    {
        updatePlayerState( e.playerId );
    }
    
    public function updatePlayerState( playerId :int ) :void
    {
        showBlood( playerId );
    } 
    
    protected function showBlood( playerId :int ) :void
    {
        log.debug("Showing player blood=" + SharedPlayerStateClient.getBlood( playerId ) + "/" + SharedPlayerStateClient.getMaxBlood( playerId ));
//        if( state != null ) {
            
//            var state :SharedPlayerState = playerModel.state;
            
            _blood.graphics.clear();
            _blood.graphics.lineStyle(1, 0xcc0000);
            _blood.graphics.drawRect(0, 0, SharedPlayerStateClient.getMaxBlood( playerId ), 10);
            _blood.graphics.beginFill( 0xcc0000 );
            _blood.graphics.drawRect(0, 0, SharedPlayerStateClient.getBlood( playerId ), 10);
            _blood.graphics.endFill();
//        }
//        else {
//            log.error("showBlood(), but null state");
//        }
    }
    
    protected var _blood :Sprite;
    protected static const log :Log = Log.getLog( HUD );
}

}