package vampire.client
{
import com.threerings.util.Controller;
import com.threerings.util.Log;
import com.whirled.contrib.avrg.AvatarHUD;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.MovieClip;
import flash.display.Sprite;

import vampire.avatar.VampireAvatarHUDOverlay;
import vampire.client.events.ChangeActionEvent;
import vampire.data.Codes;
import vampire.data.VConstants;
import vampire.net.messages.BloodBondRequestMsg;
import vampire.net.messages.FeedConfirmMsg;
import vampire.net.messages.FeedRequestMsg;
import vampire.net.messages.RequestStateChangeMsg;


/**
 * GUI logic.
 *
 */
public class VampireController extends Controller
{
    public static const CHANGE_STATE :String = "ChangeState";
//    public static const CLOSE_MODE :String = "CloseMode";
//    public static const PLAYER_STATE_CHANGED :String = "PlayerStateChanged";
    public static const QUIT :String = "Quit";
    public static const QUIT_POPUP :String = "ShowQuitPopup";

    public static const REMOVE_BLOODBOND :String = "RemoveBloodBond";
    public static const ADD_BLOODBOND :String = "AddBloodBond";

    public static const SHOW_INTRO :String = "ShowIntro";

    public static const SHOW_DEBUG :String = "ShowDebug";

    public static const SHOW_HIERARCHY :String = "ShowHierarchy";

    public static const FEED :String = "Feed";
    public static const FEED_REQUEST :String = "FeedRequest";
    public static const FEED_REQUEST_ACCEPT :String = "AcceptFeedRequest";
    public static const FEED_REQUEST_DENY :String = "DenyFeedRequest";

    public static const HIERARCHY_CENTER_SELECTED :String = "HierarchyCenterSelected";

    public function VampireController(panel :Sprite)
    {
        setControlledPanel( panel );
    }

    public function handleChangeState( state :String ) :void
    {
        log.debug("handleChangeState("+state+")");

        switch( state ) {
            case VConstants.PLAYER_STATE_BARED:
//            case VConstants.PLAYER_STATE_FEEDING_PREY:

            //If we are already bared, toggle us out of bared state to the default state.
            if( ClientContext.model.state == VConstants.PLAYER_STATE_BARED) {
                ClientContext.model.setAvatarState( VConstants.AVATAR_STATE_DEFAULT );
                ClientContext.ctrl.agent.sendMessage( RequestStateChangeMsg.NAME,
                    new RequestStateChangeMsg( ClientContext.ourPlayerId,
                        VConstants.PLAYER_STATE_DEFAULT).toBytes() );
            }
            else {//Otherwise, put us in bared mode
                ClientContext.ctrl.agent.sendMessage( RequestStateChangeMsg.NAME,
                    new RequestStateChangeMsg( ClientContext.ourPlayerId,
                        VConstants.PLAYER_STATE_BARED).toBytes() );
            }
            break;

            //If we want to feed on someone, but we are already in bared mode,
            //first stop bared mode.
//            case :VConstants.PLAYER_STATE_FEEDING_PREDATOR:
//            break;

            default:
            break;
        }
        //If we want to go to bared mode, disable any previus targeting overlays
//        if( state == VConstants.AVATAR_STATE_BARED  ) {
////            ClientContext.hud.avatarOverlay.setDisplayMode( VampireAvatarHUDOverlay.DISPLAY_MODE_SHOW_INFO_ALL_AVATARS );
//        }
//
//        //If we are already baring, toggle us out.
//        if( state == VConstants.AVATAR_STATE_BARED &&
//            ClientContext.model.state == VConstants.AVATAR_STATE_BARED) {
//
////            return;
////            log.debug("  sending to server "+VConstants.GAME_MODE_NOTHING);
//            ClientContext.model.setAvatarState( VConstants.AVATAR_STATE_DEFAULT );
//
//            ClientContext.ctrl.agent.sendMessage( RequestStateChangeMsg.NAME,
//                new RequestStateChangeMsg( ClientContext.ourPlayerId,
//                    VConstants.AVATAR_STATE_DEFAULT).toBytes() );
//        }
//        else if(state == VConstants.GAME_MODE_FEED_FROM_NON_PLAYER ||
//            state == VConstants.AVATAR_STATE_FEEDING) {
//
//
//            if( ClientContext.model.state == VConstants.AVATAR_STATE_BARED ) {
//
//                var playerKey :String = Codes.playerRoomPropKey( ClientContext.ourPlayerId );
//                ClientContext.ctrl.player.props.setIn( playerKey,
//                    Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_ACTION, VConstants.AVATAR_STATE_DEFAULT);
//
//                log.debug("  sending to server "+VConstants.AVATAR_STATE_DEFAULT);
//                trace(ClientContext.ourPlayerId + " setting avatar state mode switch");
//                ClientContext.model.setAvatarState( VConstants.AVATAR_STATE_DEFAULT );
//            }
//
//            trace(ClientContext.ourPlayerId + " setting avatar state mode switch");
//            ClientContext.model.setAvatarState( VConstants.AVATAR_STATE_FEEDING );
//
//        }
//        else {
//
//            log.debug("  sending to server "+state);
//            ClientContext.ctrl.agent.sendMessage( RequestStateChangeMsg.NAME,
//                new RequestStateChangeMsg( ClientContext.ourPlayerId, state).toBytes() );
//        }
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
            ClientContext.model.dispatchEvent( new ChangeActionEvent( state ) );
        }
    }



//    public function handleCloseMode( actionmode :BaseVampireMode) :void
//    {
//        switch(ClientContext.model.action) {
//            case VConstants.GAME_MODE_HIERARCHY_AND_BLOODBONDS:
////            case Constants.GAME_MODE_BLOODBOND:
//            case VConstants.GAME_MODE_NOTHING:
//            case null:
//                ClientContext.model.dispatchEvent( new ChangeActionEvent( VConstants.GAME_MODE_NOTHING ) );
//                break;
//            default:
//                ClientContext.ctrl.agent.sendMessage( RequestActionChangeMsg.NAME, new RequestActionChangeMsg( ClientContext.ourPlayerId, VConstants.GAME_MODE_NOTHING).toBytes() );
//
//        }
//
//        if( VConstants.LOCAL_DEBUG_MODE ) {
//            ClientContext.model.dispatchEvent( new ChangeActionEvent( VConstants.GAME_MODE_NOTHING ) );
//        }
//
//
//    }


    public function handleQuit() :void
    {
        trace(ClientContext.ourPlayerId + " setting avatar state from quit");
        ClientContext.model.setAvatarState( VConstants.AVATAR_STATE_DEFAULT );
        ClientContext.ctrl.player.props.set( Codes.PLAYER_PROP_LAST_TIME_AWAKE, new Date().time );

        ClientContext.ctrl.agent.sendMessage( VConstants.NAMED_EVENT_QUIT );

        ClientContext.quit();
    }


    public function handleShowQuitPopup() :void
    {
        var popup :PopupQuery = new PopupQuery( ClientContext.ctrl,
            "QuitPopup",
            "Is your thirst for blood sated?",
            ["Yes, I am sated with blood", "No, I hunger still"],
            [VampireController.QUIT, null]);

        if( ClientContext.gameMode.getObjectNamed( popup.objectName) == null) {
            ClientContext.gameMode.addSceneObject( popup, ClientContext.gameMode.modeSprite );
        }
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
            BloodBondRequestMsg.NAME,
            new BloodBondRequestMsg(
                ClientContext.ourPlayerId,
                ClientContext.model.targetPlayerId,
                ClientContext.getPlayerName(ClientContext.model.targetPlayerId),
                true).toBytes() );
    }

    public function handleShowDebug() :void
    {
        try {
            var hierarchySceneObject :SimObject =
                ClientContext.game.ctx.mainLoop.topMode.getObjectNamed( DebugMode.NAME );

            if( hierarchySceneObject == null) {
                ClientContext.game.ctx.mainLoop.topMode.addSceneObject( new DebugMode(),
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
            var help :SceneObject =
                ClientContext.gameMode.getObjectNamed(HelpPopup.NAME) as SceneObject;

            if( help == null) {
                help = new HelpPopup(startFrame);
                ClientContext.gameMode.addSceneObject(help,
                    ClientContext.game.ctx.mainLoop.topMode.modeSprite);
                ClientContext.animateEnlargeFromMouseClick(help);
            }
            else {
                if( startFrame == null ) {
                    help.destroySelf();
                }
                else {
                    HelpPopup(help).gotoFrame( startFrame );
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
        if( ClientContext.model.state == VConstants.AVATAR_STATE_BARED ) {
            var playerKey :String = Codes.playerRoomPropKey( ClientContext.ourPlayerId );
            ClientContext.ctrl.player.props.setIn( playerKey,
                Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_STATE, VConstants.AVATAR_STATE_DEFAULT);

            trace(ClientContext.ourPlayerId + " setting avatar state from handleFeedRequest");
            ClientContext.model.setAvatarState( VConstants.AVATAR_STATE_DEFAULT );

            ClientContext.ctrl.agent.sendMessage( RequestStateChangeMsg.NAME,
                new RequestStateChangeMsg( ClientContext.ourPlayerId,
                    VConstants.AVATAR_STATE_DEFAULT).toBytes() );

//            targetingOverlay.setDisplayMode( VampireAvatarHUDOverlay.DISPLAY_MODE_SHOW_INFO_ALL_AVATARS );
            return;
        }

        trace("handle handleFeedRequest");

        //If we are a vampire we can feed, otherwise not.
        if( ClientContext.model.level >= VConstants.MINIMUM_VAMPIRE_LEVEL ||
            VConstants.LOCAL_DEBUG_MODE ) {

//                targetingOverlay.setDisplayMode( VampireAvatarHUDOverlay.DISPLAY_MODE_SHOW_VALID_TARGETS );
//            if( targetingOverlay.displayMode == VampireAvatarHUDOverlay.DISPLAY_MODE_SHOW_VALID_TARGETS ) {
//                targetingOverlay.setDisplayMode( VampireAvatarHUDOverlay.DISPLAY_MODE_SHOW_INFO_ALL_AVATARS );
//            }
//            else {
//                targetingOverlay.setDisplayMode( VampireAvatarHUDOverlay.DISPLAY_MODE_SHOW_VALID_TARGETS );
//            }

        }
        else {
            var msg :FeedRequestMsg = new FeedRequestMsg( ClientContext.ourPlayerId,
                0, 0,0,0);
            log.debug(ClientContext.ctrl + " handleSendFeedRequest() sending " + msg)
            ClientContext.ctrl.agent.sendMessage( FeedRequestMsg.NAME, msg.toBytes() );
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

    public function handleSendFeedRequest (targetId :int) :void
    {
        function sendFeedRequest () :void {
            var targetLocation :Array;
            var targetAvatar :AvatarHUD = ClientContext.avatarOverlay.getAvatar( targetId );
            if( targetAvatar != null ) {
                targetLocation = targetAvatar.location;
            }
            else {
                log.error("handleSendFeedRequest(target=" + targetId + "), avatar is null so no loc");
            }

            var msg :FeedRequestMsg = new FeedRequestMsg( ClientContext.ourPlayerId, targetId,
                targetLocation[0], targetLocation[1], targetLocation[2]);

            log.debug(ClientContext.ctrl + " handleSendFeedRequest() sending " + msg)
            ClientContext.ctrl.agent.sendMessage( FeedRequestMsg.NAME, msg.toBytes() );

            //Show feedback if it's a player.
            if (ClientContext.model.isPlayer(targetId)) {
                ClientContext.ctrl.local.feedback("Request for feed sent");
            }


            //Set the avatar target to stand behind.
            //That way, when the avatar arrived at it's destination, it
            //will set it's orientation the same as the target's orientation.
            ClientContext.model.setStandBehindTarget(targetId);
        }



        //Show a popup if we aren't connected to the Lineage, and we choose a sire that is
        var targetIsVampireAndLineageMember :Boolean =
            ClientContext.model.lineage.isMemberOfLineage(targetId);
        if (ClientContext.model.sire == 0 && targetIsVampireAndLineageMember) {
            trace("No sire and target is Lineage, show popup");

            var popup :PopupQuery = new PopupQuery( ClientContext.ctrl,
                    "MakeSire",
                    "If you feed from this Lineage vampire, they will become your permanent sire"
                    + ", allowing you to draw power from your minions.  Are you sure?",
                    ["Yes, I am ready to join the Lineage", "No, I fear the Lineage"],
                    [sendFeedRequest, null]);

            if (ClientContext.gameMode.getObjectNamed(popup.objectName) == null) {
                ClientContext.gameMode.addSceneObject(popup, ClientContext.gameMode.modeSprite);
            }
        }
        else {
            sendFeedRequest();

        }


    }

    public function handleFeed() :void
    {
        var model :GameModel = ClientContext.model;

        switch( ClientContext.avatarOverlay.displayMode ) {

            //Toggle between showing targets and nothing.
            case VampireAvatarHUDOverlay.DISPLAY_MODE_SHOW_VALID_TARGETS:
            ClientContext.avatarOverlay.setDisplayMode( VampireAvatarHUDOverlay.DISPLAY_MODE_OFF);
            break;

            default:
            ClientContext.avatarOverlay.setDisplayMode(
                VampireAvatarHUDOverlay.DISPLAY_MODE_SHOW_VALID_TARGETS);
            break;
        }


    }

    public function handleHierarchyCenterSelected(playerId :int, hierarchyView :LineageView) :void
    {
        if( hierarchyView._hierarchy == null){// || hierarchyView._hierarchy.getMinionCount( playerId ) == 0) {
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
                ClientContext.controller.handleShowIntro("default");
//            var hierarchySceneObject :SimObject =
//                ClientContext.game.ctx.mainLoop.topMode.getObjectNamed( LineageView.NAME );
//            if( hierarchySceneObject == null) {
//
////                ClientContext.game.ctx.mainLoop.topMode.addObject( new LineageView(_hudMC),
////                    ClientContext.game.ctx.mainLoop.topMode.modeSprite);
//            }
//            else {
//                hierarchySceneObject.destroySelf();
//            }
        }
        catch( err :Error ) {
            trace( err.getStackTrace() );
        }
    }


    public function handleShowPopupMessage (name :String, msg :String) :void
    {
        var popup :PopupQuery = new PopupQuery( ClientContext.ctrl, name, msg);
        var mode :AppMode = ClientContext.gameMode;
        if( mode.getObjectNamed( popup.objectName) == null) {
            mode.addSceneObject( popup, mode.modeSprite );
        }
    }

    public function handleAcceptFeedRequest (playerId :int) :void
    {
        var msg :FeedConfirmMsg = new FeedConfirmMsg(ClientContext.ourPlayerId, playerId, true);
        ClientContext.ctrl.agent.sendMessage( FeedConfirmMsg.NAME, msg.toBytes() );
    }

    public function handleDenyFeedRequest (playerId :int) :void
    {
        var msg :FeedConfirmMsg = new FeedConfirmMsg(ClientContext.ourPlayerId, playerId, false);
        ClientContext.ctrl.agent.sendMessage( FeedConfirmMsg.NAME, msg.toBytes() );
    }


    protected static const log :Log = Log.getLog( VampireController );


}
}