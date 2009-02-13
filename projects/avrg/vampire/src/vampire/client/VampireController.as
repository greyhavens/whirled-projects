package vampire.client
{
import com.threerings.util.Controller;
import com.threerings.util.Log;

import flash.display.MovieClip;
import flash.display.Sprite;

import vampire.client.actions.BaseVampireMode;
import vampire.client.actions.hierarchy.HierarchyView;
import vampire.client.events.ChangeActionEvent;
import vampire.data.Constants;
import vampire.data.SharedPlayerStateClient;
import vampire.net.messages.BloodBondRequestMessage;
import vampire.net.messages.FeedRequestMessage;
import vampire.net.messages.RequestActionChangeMessage;
import vampire.net.messages.SuccessfulFeedMessage;


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
    
    public static const SHOW_HIERARCHY :String = "ShowHierarchy";
    
    public static const FEED :String = "Feed";
    public static const FEED_REQUEST :String = "FeedRequest";
    
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
//        switch(ClientContext.model.action) {
//            case Constants.GAME_MODE_HIERARCHY_AND_BLOODBONDS:
////            case Constants.GAME_MODE_BLOODBOND:
//            case Constants.GAME_MODE_NOTHING:
//            case null:
//                ClientContext.model.dispatchEvent( new ChangeActionEvent( mode ) );
//                break;
//            default:
//            
//        }
        
        if( Constants.LOCAL_DEBUG_MODE ) {
            ClientContext.model.dispatchEvent( new ChangeActionEvent( mode ) );
        }
    }
    

    
    public function handleCloseMode( actionmode :BaseVampireMode) :void
    {
        switch(ClientContext.model.action) {
            case Constants.GAME_MODE_HIERARCHY_AND_BLOODBONDS:
//            case Constants.GAME_MODE_BLOODBOND:
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
    
//    public function handleRemoveBloodBond( bloodBondedPlayerId :int) :void
//    {
//        if( !ClientContext.model.isPlayerInRoom( bloodBondedPlayerId ) ) {
//            return;
//        }
//        
//        ClientContext.gameCtrl.agent.sendMessage( 
//            BloodBondRequestMessage.NAME, 
//            new BloodBondRequestMessage( 
//                ClientContext.ourPlayerId, 
//                bloodBondedPlayerId, 
//                ClientContext.getPlayerName(bloodBondedPlayerId),
//                false).toBytes() );
//    }
    
    public function handleAddBloodBond() :void
    {
        if( ClientContext.model.bloodbonded == ClientContext.model.targetPlayerId
            || ClientContext.model.targetPlayerId <= 0) {
            log.debug("handleAddBloodBond() " + ClientContext.currentClosestPlayerId + " already bloodbonded");
            return;
        }
        
        log.debug("handleAddBloodBond() request to add " + ClientContext.model.targetPlayerId );
        
        ClientContext.gameCtrl.agent.sendMessage( 
            BloodBondRequestMessage.NAME, 
            new BloodBondRequestMessage( 
                ClientContext.ourPlayerId, 
                ClientContext.model.targetPlayerId, 
                ClientContext.getPlayerName(ClientContext.model.targetPlayerId),
                true).toBytes() );
    }
    
    public function handleHideIntro() :void
    {
        ClientContext.game.ctx.mainLoop.popMode();
    }
    
    public function handleShowIntro() :void
    {
        trace("handleShowIntro()");
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
        if( !SharedPlayerStateClient.isVampire( ClientContext.ourPlayerId )) {
            trace("Only vampires are allowed to feed.");
            return;
        }
        
        var model :GameModel = ClientContext.model;
        if( model.isPlayer( model.targetPlayerId)) {
            //Player victims must be the state "EatMe" 
            if( SharedPlayerStateClient.getCurrentAction( model.targetPlayerId ) == Constants.GAME_MODE_BARED ) {
                
                if( SharedPlayerStateClient.isVampire( model.targetPlayerId ) && 
                    SharedPlayerStateClient.getBlood(model.targetPlayerId) <= 1 ) {
                        //If the victim vampire does not have enough blood, cancel the feed.
                        trace("Not enough blood", "targetPlayerId", model.targetPlayerId, "blood", SharedPlayerStateClient.getBlood(model.targetPlayerId));
                            return;
                        }
                trace("Sending SuccessfulFeedMessage", "targetPlayerId", model.targetPlayerId);
                ClientContext.msg.sendMessage( new SuccessfulFeedMessage( ClientContext.ourPlayerId, model.targetPlayerId));
            }
            
        } 
        else {//Just assume you sucessfully fed of a non-playing user
            if( model.targetPlayerId > 0) {//Do you have a target?  If not, don't send a SuccessfulFeedMessage
                trace("Sending SuccessfulFeedMessage", "targetPlayerId", model.targetPlayerId);
                ClientContext.msg.sendMessage( new SuccessfulFeedMessage( ClientContext.ourPlayerId, model.targetPlayerId));
            }
        }
        
    }
    
    public function handleHierarchyCenterSelected(playerId :int, hierarchyView :HierarchyView) :void
    {
        if( hierarchyView._hierarchy == null || hierarchyView._hierarchy.getMinionCount( playerId ) == 0) {
            return;
        }
        hierarchyView.updateHierarchy( playerId );
    }
    
    public function makeSire( ... ignored ) :void
    {
        log.info("makeSire(" + ClientContext.model.targetPlayerId + ")" );
        if( ClientContext.model.targetPlayerId > 0) {
            
            ClientContext.gameCtrl.agent.sendMessage( Constants.NAMED_EVENT_MAKE_SIRE, ClientContext.model.targetPlayerId );
        }
    }
    
    public function makeMinion( ... ignored ) :void
    {
        log.info("makeMinion(" + ClientContext.model.targetPlayerId + ")" );
        if( ClientContext.model.targetPlayerId > 0) {
            ClientContext.gameCtrl.agent.sendMessage( Constants.NAMED_EVENT_MAKE_MINION, ClientContext.model.targetPlayerId );
        }
    }
    
    public function handleShowHierarchy(_hudMC :MovieClip) :void
    {
//                    throw new Error("f");
        try {
            if( ClientContext.game.ctx.mainLoop.topMode.getObjectNamed( HierarchyView.NAME ) == null) {
                ClientContext.game.ctx.mainLoop.topMode.addObject( new HierarchyView(_hudMC), ClientContext.game.ctx.mainLoop.topMode.modeSprite);
            }
        }
        catch( err :Error ) {
            trace( err.getStackTrace() );
        }
    }
    
    
    protected static const log :Log = Log.getLog( VampireController );

}
}