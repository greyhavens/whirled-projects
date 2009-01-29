package vampire.client
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.Controller;
import com.threerings.util.Log;

import flash.display.Sprite;

import vampire.client.actions.BaseVampireMode;
import vampire.client.actions.hierarchy.HierarchyView;
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
    public static const SHOW_INTRO :String = "ShowIntro";
    
    public static const FEED :String = "Feed";
    
    public static const HIERARCHY_CENTER_SELECTED :String = "HierarchyCenterSelected";
    
    public function VampireController(panel :Sprite)
    {
        setControlledPanel( panel );
    }
        
    public function handleSwitchMode( mode :String ) :void
    {
        
        ClientContext.gameCtrl.agent.sendMessage( RequestActionChangeMessage.NAME, new RequestActionChangeMessage( ClientContext.ourPlayerId, mode).toBytes() );
        //Some actions we don't need the agents permission
//        trace("handleSwitchMode, ClientContext.model.action=" + ClientContext.model.action + ", mode=" + mode);
//        trace("handleSwitchMode, ClientContext.model.action=" + (ClientContext.model.action == null)); 
        switch(ClientContext.model.action) {
            case Constants.GAME_MODE_HIERARCHY:
            case Constants.GAME_MODE_BLOODBOND:
            case Constants.GAME_MODE_NOTHING:
            case null:
                ClientContext.model.dispatchEvent( new ChangeActionEvent( mode ) );
                break;
            default:
            
        }
        
        if( Constants.LOCAL_DEBUG_MODE ) {
            ClientContext.model.dispatchEvent( new ChangeActionEvent( mode ) );
        }
    }
    

    
    public function handleCloseMode( actionmode :BaseVampireMode) :void
    {
        switch(ClientContext.model.action) {
            case Constants.GAME_MODE_HIERARCHY:
            case Constants.GAME_MODE_BLOODBOND:
            case Constants.GAME_MODE_NOTHING:
            case null:
                ClientContext.model.dispatchEvent( new ChangeActionEvent( Constants.GAME_MODE_NOTHING ) );
                break;
            default:
                ClientContext.gameCtrl.agent.sendMessage( RequestActionChangeMessage.NAME, new RequestActionChangeMessage( ClientContext.ourPlayerId, Constants.GAME_MODE_NOTHING).toBytes() );
            
        }
        
        if( Constants.LOCAL_DEBUG_MODE ) {
            ClientContext.model.dispatchEvent( new ChangeActionEvent( Constants.GAME_MODE_NOTHING ) );
        }
        
        
    }
    
    
    public function handleQuit() :void
    {
        ClientContext.gameCtrl.agent.sendMessage( Constants.NAMED_EVENT_QUIT );
                
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
        ClientContext.game.ctx.mainLoop.popMode();
    }
    
    public function handleShowIntro() :void
    {
        if( ClientContext.game.ctx.mainLoop.topMode !== new IntroHelpMode() ) {
            ClientContext.game.ctx.mainLoop.pushMode( new IntroHelpMode());
        }
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
    
    public function handleHierarchyCenterSelected(playerId :int, hierarchyView :HierarchyView) :void
    {
        if( hierarchyView._hierarchy == null || hierarchyView._hierarchy.getMinionCount( playerId ) == 0) {
            return;
        }
        hierarchyView.updateHierarchy( playerId );
    }
    
    
    protected static const log :Log = Log.getLog( VampireController );

}
}