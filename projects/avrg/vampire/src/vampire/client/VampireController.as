package vampire.client
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.Controller;
import com.threerings.util.Log;

import flash.display.Sprite;

import vampire.client.actions.BaseVampireMode;
import vampire.client.events.ChangeActionEvent;
import vampire.data.Constants;
import vampire.data.SharedPlayerStateClient;
import vampire.net.messages.BloodBondRequestMessage;
import vampire.net.messages.FeedRequestMessage;
import vampire.net.messages.RequestActionChangeMessage;


/**
 * GUI logic.  
 * 
 */
public class VampireController extends Controller
{
    public static const SWITCH_MODE :String = "SwitchMode";
    public static const CLOSE_MODE :String = "CloseMode";
//    public static const PLAYER_STATE_CHANGED :String = "PlayerStateChanged";
    public static const QUIT :String = "Quit";
    
    public static const REMOVE_BLOODBOND :String = "RemoveBloodBond";
    public static const ADD_BLOODBOND :String = "AddBloodBond";
    
    public static const HIDE_INTRO :String = "HideIntro";
    
    public static const FEED :String = "Feed";
    
    public function VampireController(panel :Sprite)
    {
        setControlledPanel( panel );
    }
        
    public function handleSwitchMode( mode :String ) :void
    {
        
        ClientContext.gameCtrl.agent.sendMessage( RequestActionChangeMessage.NAME, new RequestActionChangeMessage( ClientContext.ourPlayerId, mode).toBytes() );
        if( Constants.LOCAL_DEBUG_MODE ) {
            ClientContext.model.dispatchEvent( new ChangeActionEvent( mode ) );
        }
    }
    

    
    public function handleCloseMode( actionmode :BaseVampireMode) :void
    {
        ClientContext.gameCtrl.agent.sendMessage( RequestActionChangeMessage.NAME, new RequestActionChangeMessage( ClientContext.ourPlayerId, Constants.GAME_MODE_NOTHING).toBytes() );
//        actionmode.ctx.mainLoop.popMode();
//        actionmode.ctx.mainLoop.unwindToMode( new NothingMode() );
    }
    
//    public function handlePlayerStateChanged( playerModel :Model, hud :HUD) :void
//    {
//        hud.updatePlayerState( playerModel );
//    }
    
    public function handleQuit() :void
    {
        ClientContext.quit();
    }
    
    public function handleRemoveBloodBond( bloodBondedPlayerId :int) :void
    {
        if( !ClientContext.model.isPlayerInRoom( bloodBondedPlayerId ) ) {
            return;
        }
        
        ClientContext.gameCtrl.agent.sendMessage( 
            BloodBondRequestMessage.NAME, 
            new BloodBondRequestMessage( 
                ClientContext.ourPlayerId, 
                bloodBondedPlayerId, 
                ClientContext.getPlayerName(bloodBondedPlayerId),
                false).toBytes() );
    }
    
    public function handleAddBloodBond() :void
    {
        if( ArrayUtil.contains(ClientContext.model.bloodbonded, ClientContext.ourPlayerId) ||  !ClientContext.model.isPlayerInRoom( ClientContext.currentClosestPlayerId ) ) {
            return;
        }
        
        if( !ArrayUtil.contains( SharedPlayerStateClient.getBloodBonded( ClientContext.ourPlayerId), ClientContext.currentClosestPlayerId) ) {
            log.debug("handleAddBloodBond() request to add " + ClientContext.currentClosestPlayerId );
            
            ClientContext.gameCtrl.agent.sendMessage( 
                BloodBondRequestMessage.NAME, 
                new BloodBondRequestMessage( 
                    ClientContext.ourPlayerId, 
                    ClientContext.currentClosestPlayerId, 
                    ClientContext.getPlayerName(ClientContext.currentClosestPlayerId),
                    true).toBytes() );
        }
        else {
            log.debug("handleAddBloodBond() " + ClientContext.currentClosestPlayerId + " already bloodbonded");
        }
    }
    
    public function handleHideIntro() :void
    {
        ClientContext.game.ctx.mainLoop.unwindToMode( new MainGameMode() );
    }
    
    public function handleFeedRequest( targetPlayerId :int, targetIsVictim :Boolean) :void
    {
        ClientContext.gameCtrl.agent.sendMessage( FeedRequestMessage.NAME, new FeedRequestMessage( ClientContext.ourPlayerId, targetPlayerId, targetIsVictim).toBytes() );
    }
    
    public function handleFeed() :void
    {
        if( SharedPlayerStateClient.getCurrentAction( ClientContext.currentClosestPlayerId) == Constants.GAME_MODE_EAT_ME) {
            
            
            ClientContext.gameCtrl.agent.sendMessage( Constants.NAMED_EVENT_FEED, ClientContext.currentClosestPlayerId );
        }
    }
    
    
    protected static const log :Log = Log.getLog( VampireController );

}
}