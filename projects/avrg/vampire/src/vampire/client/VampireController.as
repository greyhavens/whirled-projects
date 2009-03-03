package vampire.client
{
import com.threerings.util.Controller;
import com.threerings.util.Log;
import com.whirled.contrib.avrg.AvatarHUD;
import com.whirled.contrib.simplegame.SimObject;

import flash.display.MovieClip;
import flash.display.Sprite;

import vampire.avatar.AvatarGameBridge;
import vampire.avatar.VampireAvatarHUDOverlay;
import vampire.client.actions.BaseVampireMode;
import vampire.client.actions.hierarchy.HierarchyView;
import vampire.client.events.ChangeActionEvent;
import vampire.data.Codes;
import vampire.data.SharedPlayerStateClient;
import vampire.data.VConstants;
import vampire.net.messages.BloodBondRequestMessage;
import vampire.net.messages.FeedRequestMessage2;
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

    public static const SHOW_INTRO :String = "ShowIntro";

    public static const SHOW_DEBUG :String = "ShowDebug";

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
        log.debug("handleSwitchMode("+mode+")");

        //If we want to go to bared mode, disable any previus targeting overlays
        if( mode == VConstants.GAME_MODE_BARED  ) {
//            ClientContext.hud.avatarOverlay.setDisplayMode( VampireAvatarHUDOverlay.DISPLAY_MODE_SHOW_INFO_ALL_AVATARS );
        }

        //If we are already baring, toggle us out.
        if( mode == VConstants.GAME_MODE_BARED &&
            ClientContext.model.action == VConstants.GAME_MODE_BARED) {

            return;
//            log.debug("  sending to server "+VConstants.GAME_MODE_NOTHING);
//            ClientContext.gameCtrl.agent.sendMessage( RequestActionChangeMessage.NAME,
//                new RequestActionChangeMessage( ClientContext.ourPlayerId,
//                    VConstants.GAME_MODE_NOTHING).toBytes() );
        }
        else if(mode == VConstants.GAME_MODE_FEED_FROM_NON_PLAYER ||
            mode == VConstants.GAME_MODE_FEED_FROM_PLAYER) {

            //If we want to feed on someone, but we are already in bared mode,
            //first stop bared mode.
            if( ClientContext.model.action == VConstants.GAME_MODE_BARED ) {

                var playerKey :String = Codes.playerRoomPropKey( ClientContext.ourPlayerId );
                ClientContext.ctrl.player.props.setIn( playerKey,
                    Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_ACTION, VConstants.GAME_MODE_NOTHING);

                log.debug("  sending to server "+VConstants.GAME_MODE_NOTHING);
                trace(ClientContext.ourPlayerId + " setting avatar state mode switch");
                ClientContext.model.setAvatarState( VConstants.GAME_MODE_NOTHING );
            }

            trace(ClientContext.ourPlayerId + " setting avatar state mode switch");
            ClientContext.model.setAvatarState( VConstants.GAME_MODE_FEED_FROM_PLAYER );

        }
        else {

            log.debug("  sending to server "+mode);
            ClientContext.ctrl.agent.sendMessage( RequestActionChangeMessage.NAME,
                new RequestActionChangeMessage( ClientContext.ourPlayerId, mode).toBytes() );
        }
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

        if( VConstants.LOCAL_DEBUG_MODE ) {
            ClientContext.model.dispatchEvent( new ChangeActionEvent( mode ) );
        }
    }



    public function handleCloseMode( actionmode :BaseVampireMode) :void
    {
        switch(ClientContext.model.action) {
            case VConstants.GAME_MODE_HIERARCHY_AND_BLOODBONDS:
//            case Constants.GAME_MODE_BLOODBOND:
            case VConstants.GAME_MODE_NOTHING:
            case null:
                ClientContext.model.dispatchEvent( new ChangeActionEvent( VConstants.GAME_MODE_NOTHING ) );
                break;
            default:
                ClientContext.ctrl.agent.sendMessage( RequestActionChangeMessage.NAME, new RequestActionChangeMessage( ClientContext.ourPlayerId, VConstants.GAME_MODE_NOTHING).toBytes() );

        }

        if( VConstants.LOCAL_DEBUG_MODE ) {
            ClientContext.model.dispatchEvent( new ChangeActionEvent( VConstants.GAME_MODE_NOTHING ) );
        }


    }


    public function handleQuit() :void
    {
        trace(ClientContext.ourPlayerId + " setting avatar state from quit");
        ClientContext.model.setAvatarState( VConstants.GAME_MODE_NOTHING );

        ClientContext.ctrl.agent.sendMessage( VConstants.NAMED_EVENT_QUIT );

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

        ClientContext.ctrl.agent.sendMessage(
            BloodBondRequestMessage.NAME,
            new BloodBondRequestMessage(
                ClientContext.ourPlayerId,
                ClientContext.model.targetPlayerId,
                ClientContext.getPlayerName(ClientContext.model.targetPlayerId),
                true).toBytes() );
    }

    public function handleShowDebug() :void
    {
        try {
            var hierarchySceneObject :SimObject =
                ClientContext.game.ctx.mainLoop.topMode.getObjectNamed( IntroHelpMode.NAME );

            if( hierarchySceneObject == null) {
                ClientContext.game.ctx.mainLoop.topMode.addObject( new IntroHelpMode(),
                    ClientContext.game.ctx.mainLoop.topMode.modeSprite);
            }

            else {
                hierarchySceneObject.destroySelf();
            }
        }
        catch( err :Error ) {
            trace( err.getStackTrace() );
        }
    }


    public function handleShowIntro( startFrame :String = null) :void
    {
        try {
            var hierarchySceneObject :SimObject =
                ClientContext.game.ctx.mainLoop.topMode.getObjectNamed( HelpPopup.NAME );

            if( hierarchySceneObject == null) {
                ClientContext.game.ctx.mainLoop.topMode.addObject( new HelpPopup(startFrame),
                    ClientContext.game.ctx.mainLoop.topMode.modeSprite);
            }
            else {
                if( startFrame == null ) {
                    hierarchySceneObject.destroySelf();
                }
                else {
                    HelpPopup(hierarchySceneObject).gotoFrame( startFrame );
                }
            }
        }
        catch( err :Error ) {
            trace( err.getStackTrace() );
        }
    }

//    public function handleFeedRequest( targetPlayerId :int, targetIsVictim :Boolean) :void
    public function handleFeedRequest( targetingOverlay :VampireAvatarHUDOverlay, parentSprite :Sprite, hud :HUD) :void
    {
        //If we are alrady in bared mode, first dump us out before any feeding shinannigens
        if( ClientContext.model.action == VConstants.GAME_MODE_BARED ) {
            var playerKey :String = Codes.playerRoomPropKey( ClientContext.ourPlayerId );
            ClientContext.ctrl.player.props.setIn( playerKey,
                Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_ACTION, VConstants.GAME_MODE_NOTHING);

            trace(ClientContext.ourPlayerId + " setting avatar state from handleFeedRequest");
            ClientContext.model.setAvatarState( VConstants.GAME_MODE_NOTHING );

            ClientContext.ctrl.agent.sendMessage( RequestActionChangeMessage.NAME,
                new RequestActionChangeMessage( ClientContext.ourPlayerId,
                    VConstants.GAME_MODE_NOTHING).toBytes() );

//            targetingOverlay.setDisplayMode( VampireAvatarHUDOverlay.DISPLAY_MODE_SHOW_INFO_ALL_AVATARS );
            return;
        }

        trace("handle handleFeedRequest");

        //If we are a vampire we can feed, otherwise not.
        if( ClientContext.model.level >= VConstants.MINIMUM_VAMPIRE_LEVEL ||
            VConstants.LOCAL_DEBUG_MODE ) {

                targetingOverlay.setDisplayMode( VampireAvatarHUDOverlay.DISPLAY_MODE_SHOW_VALID_TARGETS );
//            if( targetingOverlay.displayMode == VampireAvatarHUDOverlay.DISPLAY_MODE_SHOW_VALID_TARGETS ) {
//                targetingOverlay.setDisplayMode( VampireAvatarHUDOverlay.DISPLAY_MODE_SHOW_INFO_ALL_AVATARS );
//            }
//            else {
//                targetingOverlay.setDisplayMode( VampireAvatarHUDOverlay.DISPLAY_MODE_SHOW_VALID_TARGETS );
//            }

        }
        else {
            ClientContext.hud.showFeedBack( "Only vampires can feed.  You must be at least level " +
                VConstants.MINIMUM_VAMPIRE_LEVEL +".  You are level " + ClientContext.model.level, true);
        }


//
//        if( parentSprite.contains( targetingOverlay.displayObject )) {
//
//            targetingOverlay.setDisplayMode( VampireAvatarHUDOverlay.DISPLAY_MODE_OFF );
//
//            parentSprite.removeChild( targetingOverlay.displayObject );
//        }
//        else {
//            parentSprite.addChildAt( targetingOverlay.displayObject, 0 );
//        }



//        targetingOverlay.visible = !targetingOverlay.visible;
//        if( targetingOverlay.visible ) {
////            Sprite(targetingOverlay.displayObject).mouseEnabled = true;
//            parentSprite.addChild( targetingOverlay.displayObject );
//        }
//        else {
//            if( parentSprite.contains( targetingOverlay.displayObject )) {
//                parentSprite.removeChild( targetingOverlay.displayObject );
//            }
////            Sprite(targetingOverlay.displayObject).mouseEnabled = false;
//        }








//        ClientContext.gameCtrl.agent.sendMessage( FeedRequestMessage.NAME, new FeedRequestMessage( ClientContext.ourPlayerId, 0, false).toBytes() );
    }

    public function handleSendFeedRequest( targetId :int, multiPredators :Boolean  ) :void
    {
        var targetLocation :Array;
        var targetAvatar :AvatarHUD = ClientContext.hud.avatarOverlay.getAvatar( targetId );
        if( targetAvatar != null ) {
            targetLocation = targetAvatar.location;
        }
        else {
            log.error("handleSendFeedRequest(target=" + targetId + "), avatar is null so no loc");
        }

        var msg :FeedRequestMessage2 = new FeedRequestMessage2( ClientContext.ourPlayerId, targetId,
            multiPredators, targetLocation[0], targetLocation[1], targetLocation[2]);
        log.debug(ClientContext.ctrl + " handleSendFeedRequest() sending " + msg)
        ClientContext.ctrl.agent.sendMessage( FeedRequestMessage2.NAME, msg.toBytes() );
        if( multiPredators ) {
            ClientContext.hud.avatarOverlay.setDisplayMode( VampireAvatarHUDOverlay.DISPLAY_MODE_SHOW_FEED_TARGET, targetId, true );
        }
        else {
            ClientContext.hud.avatarOverlay.setDisplayMode( VampireAvatarHUDOverlay.DISPLAY_MODE_SHOW_INFO_ALL_AVATARS );
        }

        //Set the avatar target.  That way, when the avatar arrived at it's destination, it
        //will set it's orientation the same as the target's orientation.
        var setTargetFunction :Function = ClientContext.ctrl.room.getEntityProperty(
            AvatarGameBridge.ENTITY_PROPERTY_SETTARGET_FUNCTION, ClientContext.ourEntityId ) as Function;
        if( setTargetFunction != null ) {
            setTargetFunction( targetId );
        }

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
            if( SharedPlayerStateClient.getCurrentAction( model.targetPlayerId ) == VConstants.GAME_MODE_BARED ) {

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

            ClientContext.ctrl.agent.sendMessage( VConstants.NAMED_EVENT_MAKE_SIRE, ClientContext.model.targetPlayerId );
        }
    }

    public function makeMinion( ... ignored ) :void
    {
        log.info("makeMinion(" + ClientContext.model.targetPlayerId + ")" );
        if( ClientContext.model.targetPlayerId > 0) {
            ClientContext.ctrl.agent.sendMessage( VConstants.NAMED_EVENT_MAKE_MINION, ClientContext.model.targetPlayerId );
        }
    }

    public function handleShowHierarchy(_hudMC :MovieClip) :void
    {
        try {
            var hierarchySceneObject :SimObject =
                ClientContext.game.ctx.mainLoop.topMode.getObjectNamed( HierarchyView.NAME );
            if( hierarchySceneObject == null) {
                ClientContext.game.ctx.mainLoop.topMode.addObject( new HierarchyView(_hudMC),
                    ClientContext.game.ctx.mainLoop.topMode.modeSprite);
            }
            else {
                hierarchySceneObject.destroySelf();
            }
        }
        catch( err :Error ) {
            trace( err.getStackTrace() );
        }
    }


    protected static const log :Log = Log.getLog( VampireController );

}
}