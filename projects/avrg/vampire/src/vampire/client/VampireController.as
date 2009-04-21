package vampire.client
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.Controller;
import com.threerings.util.Log;
import com.whirled.contrib.avrg.AvatarHUD;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.SimObject;

import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Sprite;

import vampire.avatar.VampireAvatarHUDOverlay;
import vampire.data.Lineage;
import vampire.data.VConstants;
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
    public static const QUIT :String = "Quit";
    public static const QUIT_POPUP :String = "ShowQuitPopup";

    public static const REMOVE_BLOODBOND :String = "RemoveBloodBond";
    public static const ADD_BLOODBOND :String = "AddBloodBond";

    public static const SHOW_INTRO :String = "ShowIntro";

    public static const SHOW_DEBUG :String = "ShowDebug";

    public static const SHOW_LINEAGE :String = "ShowLineage";
    public static const SHOW_PREY_LINEAGE :String = "ShowPreyLineage";

    public static const FEED :String = "Feed";
    public static const FEED_REQUEST_ACCEPT :String = "AcceptFeedRequest";
    public static const FEED_REQUEST_DENY :String = "DenyFeedRequest";

    public static const HIERARCHY_CENTER_SELECTED :String = "LineageCenterSelected";

    public static const RECRUIT :String = "Recruit";
    public static const MOVE :String = "Move";
    public static const ACTIVATE_LOAD_BALANCER :String = "ActivateLoadBalancer";
    public static const DECTIVATE_LOAD_BALANCER :String = "DeactivateLoadBalancer";

    public function VampireController (panel :Sprite)
    {
        setControlledPanel(panel);
    }

    public function handleChangeState (state :String) :void
    {
        log.debug("handleChangeState("+state+")");

        switch(state) {
            case VConstants.PLAYER_STATE_BARED:
//            case VConstants.PLAYER_STATE_FEEDING_PREY:

            //If we are already bared, toggle us out of bared state to the default state.
            if (ClientContext.model.state == VConstants.PLAYER_STATE_BARED) {
                ClientContext.model.setAvatarState(VConstants.AVATAR_STATE_DEFAULT);
                ClientContext.ctrl.agent.sendMessage(RequestStateChangeMsg.NAME,
                    new RequestStateChangeMsg(ClientContext.ourPlayerId,
                        VConstants.PLAYER_STATE_DEFAULT).toBytes());
            }
            else {//Otherwise, put us in bared mode
                ClientContext.ctrl.agent.sendMessage(RequestStateChangeMsg.NAME,
                    new RequestStateChangeMsg(ClientContext.ourPlayerId,
                        VConstants.PLAYER_STATE_BARED).toBytes());
            }
            break;

            //If we want to feed on someone, but we are already in bared mode,
            //first stop bared mode.
//            case :VConstants.PLAYER_STATE_FEEDING_PREDATOR:
//            break;

            default:
            break;
        }

    }

    public function handleQuit () :void
    {
        ClientContext.model.setAvatarState(VConstants.AVATAR_STATE_DEFAULT);
        ClientContext.quit();
    }


    public function handleShowQuitPopup () :void
    {
        var popup :PopupQuery = new PopupQuery(
            "QuitPopup",
            "Is your thirst for blood sated?",
            ["Yes", "No"],
            [VampireController.QUIT, null]);

        if (ClientContext.gameMode.getObjectNamed(popup.objectName) == null) {
            ClientContext.gameMode.addSceneObject(popup, ClientContext.gameMode.layerHighPriority);
            ClientContext.centerOnViewableRoom(popup.displayObject);
            ClientContext.animateEnlargeFromMouseClick(popup);
        }
    }

    public function handleShowDebug () :void
    {
        try {
            var hierarchySceneObject :SimObject =
                ClientContext.game.ctx.mainLoop.topMode.getObjectNamed(AdminPanel.NAME);

            if (hierarchySceneObject == null) {
                ClientContext.gameMode.addSceneObject(new AdminPanel(),
                    ClientContext.gameMode.layerHighPriority);
            }

            else {
                hierarchySceneObject.destroySelf();
            }
        }
        catch(err :Error) {
            trace(err.getStackTrace());
        }
    }


    public function handleShowIntro (startFrame :String = null, lineage :Lineage = null,
        playerCenter :int = 0) :void
    {
        try {
            var help :HelpPopup =
                ClientContext.gameMode.getObjectNamed(HelpPopup.NAME) as HelpPopup;

            if (help == null) {
                help = new HelpPopup(startFrame, lineage, playerCenter);
                ClientContext.gameMode.addSceneObject(help,
                    ClientContext.gameMode.layerMediumPriority);

                help.x = ClientContext.ctrl.local.getPaintableArea().width/2;
                help.y = ClientContext.ctrl.local.getPaintableArea().height/2;

                ClientContext.animateEnlargeFromMouseClick(help);

                ClientContext.tutorial.clickedVWButtonOpenHelp();
            }
            else {
                if (startFrame == null) {
                    help.destroySelf();
                }
                else {
                    help.setTargetLineage(lineage, playerCenter);
                    help.gotoFrame(startFrame);
                }
            }


//            help = ClientContext.gameMode.getObjectNamed(HelpPopup.NAME) as HelpPopup;
//            if (help != null) {
//                if (playerCenter != 0) {
//                    help.centerLineageOnPlayer(playerCenter);
//                }
//            }

        }
        catch(err :Error) {
            trace(err.getStackTrace());
        }
    }

    public function handleSendFeedRequest (targetId :int) :void
    {
        function sendFeedRequest () :void {
            var targetLocation :Array;
            var targetAvatar :AvatarHUD = ClientContext.gameMode.avatarOverlay.getAvatar(targetId);
            if (targetAvatar != null) {
                targetLocation = targetAvatar.location;
            }
            else {
                log.error("handleSendFeedRequest(target=" + targetId + "), avatar is null so no loc");
            }


            var targetName :String = ClientContext.model.getAvatarName(targetId);
            var msg :FeedRequestMsg = new FeedRequestMsg(ClientContext.ourPlayerId,
                ClientContext.ourPlayerId, targetId, targetName,
                targetLocation[0], targetLocation[1], targetLocation[2]);

            log.debug(ClientContext.ctrl + " handleSendFeedRequest() sending " + msg)
            ClientContext.ctrl.agent.sendMessage(FeedRequestMsg.NAME, msg.toBytes());

            //Show feedback if it's a player.
            if (ArrayUtil.contains(ClientContext.model.playerIds, targetId)) {
                var popup :PopupQuery = new PopupQuery(
                    VConstants.POPUP_MESSAGE_FEED_CONFIRM + targetId,
                    "Waiting for " + targetName + "'s permission to feed...");
                ClientContext.gameMode.addSceneObject(popup,
                    ClientContext.gameMode.layerMediumPriority);
                ClientContext.centerOnViewableRoom(popup.displayObject);
                ClientContext.animateEnlargeFromMouseClick(popup);

//                var quitTimer :SimpleTimer = new SimpleTimer(3, function() :void {
//                    if (popup.isLiveObject) {
//                        popup.destroySelf();
//                    }
//                });
//                ClientContext.gameMode.addObject(quitTimer);
            }

            //Set the avatar target to stand behind.
            //That way, when the avatar arrived at it's destination, it
            //will set it's orientation the same as the target's orientation.
//            ClientContext.gameMode.sendMessageToNamedObject(
//                new ObjectMessage(ClientAvatar.GAME_MESSAGE_TARGETID, targetId),
//                ClientAvatar.NAME);
        }



        //Show a popup if we aren't connected to the Lineage, and we choose a sire that is
//        trace(ClientContext.ourPlayerId + " lineage=" + ClientContext.model.lineage);
        var targetIsVampireAndLineageMemberAndOnline :Boolean = ClientContext.gameMode.lineages.isLineage(targetId) &&
            ClientContext.gameMode.lineages.getLineage(targetId).isConnectedToLilith;

//            ClientContext.model.lineage.isMemberOfLineage(targetId)
//            && ClientContext.model.isPlayer(targetId);
        if (!ClientContext.model.lineage.isConnectedToLilith
            && targetIsVampireAndLineageMemberAndOnline) {

            var con :VampireController = ClientContext.controller;

            var popup :PopupQuery = new PopupQuery(
                    "MakeSire",
                    VConstants.TEXT_CONFIM_SIRE,
                    ["Yes", "No", "More Info"],
                    [sendFeedRequest, null, function() :void {con.handleShowIntro("lineage");}]);

            if (ClientContext.gameMode.getObjectNamed(popup.objectName) == null) {
                ClientContext.gameMode.addSceneObject(popup, ClientContext.gameMode.modeSprite);
                ClientContext.centerOnViewableRoom(popup.displayObject);
                ClientContext.animateEnlargeFromMouseClick(popup);
            }
        }
        else {
            sendFeedRequest();

        }


    }

    public function handleFeed () :void
    {
        var model :PlayerModel = ClientContext.model;

        switch(ClientContext.gameMode.avatarOverlay.displayMode) {

            //Toggle between showing targets and nothing.
            case VampireAvatarHUDOverlay.DISPLAY_MODE_SHOW_VALID_TARGETS:
            ClientContext.gameMode.avatarOverlay.setDisplayMode(VampireAvatarHUDOverlay.DISPLAY_MODE_OFF);
            break;

            default:
            ClientContext.gameMode.avatarOverlay.setDisplayMode(
                VampireAvatarHUDOverlay.DISPLAY_MODE_SHOW_VALID_TARGETS);
            //Show the load balancer
            handleActivateLoadBalancer();
            break;
        }

        ClientContext.tutorial.clickedFeedHUDButton();

    }

    public function handleLineageCenterSelected (playerId :int, lineageView :LineageView) :void
    {
        lineageView.updateLineage(playerId);
    }

    public function handleShowLineage (_hudMC :MovieClip, lineage :Lineage = null,
        playerCenter :int = 0) :void
    {
        try {
            ClientContext.controller.handleShowIntro("default", lineage, playerCenter);
        }
        catch(err :Error) {
            trace(err.getStackTrace());
        }
    }


    public function handleShowPopupMessage (name :String, msg :String,
        parent :DisplayObjectContainer, buttonNames :Array = null,
        functionsOrCommands :Array = null) :void
    {
        var popup :PopupQuery = new PopupQuery(name, msg, buttonNames, functionsOrCommands);
        var mode :AppMode = ClientContext.gameMode;

        if (mode.getObjectNamed(popup.objectName) != null) {
            mode.getObjectNamed(popup.objectName).destroySelf();
        }

        mode.addSceneObject(popup, parent);
        ClientContext.centerOnViewableRoom(popup.displayObject);
        ClientContext.animateEnlargeFromMouseClick(popup);
    }

    public function handleAcceptFeedRequest (playerId :int) :void
    {
//        var targetName :String = ClientContext.model.getAvatarName(playerId);
        var msg :FeedConfirmMsg = new FeedConfirmMsg(ClientContext.ourPlayerId,
            ClientContext.ourPlayerId, ClientContext.model.name, playerId, true);
        ClientContext.ctrl.agent.sendMessage(FeedConfirmMsg.NAME, msg.toBytes());

        //If you accept one feed request, you accept all concurrent feed request,
        //ans destroy the feed request popups
        for each (var playerIdWaiting :int in ClientContext.model.playerIds) {
            var popupName :String = POPUP_PREFIX_FEED_REQUEST + playerIdWaiting;
            if (ClientContext.gameMode.getObjectNamed(popupName) != null) {
                ClientContext.gameMode.getObjectNamed(popupName).destroySelf();

                if (playerId != playerIdWaiting) {
                    msg = new FeedConfirmMsg(ClientContext.ourPlayerId, ClientContext.ourPlayerId,
                        ClientContext.model.name, playerIdWaiting, true);
                    ClientContext.ctrl.agent.sendMessage(FeedConfirmMsg.NAME, msg.toBytes());
                }
            }
        }
    }

    public function handleDenyFeedRequest (playerId :int) :void
    {
        var targetName :String = ClientContext.model.getAvatarName(playerId);
        var msg :FeedConfirmMsg = new FeedConfirmMsg(ClientContext.ourPlayerId,
            ClientContext.ourPlayerId, targetName, playerId, false);
        ClientContext.ctrl.agent.sendMessage(FeedConfirmMsg.NAME, msg.toBytes());
    }

    public function handleNewLevel (newLevel :int) :void
    {
        handleShowPopupMessage("NewLevel",
            VConstants.TEXT_NEW_LEVEL + newLevel + "!",
            ClientContext.gameMode.layerMediumPriority,
            ["More info"], [function() :void {ClientContext.controller.handleShowIntro("blood")}]);
    }
    public function handleRecruit () :void
    {
        log.debug("Recruiting...");
        ClientContext.ctrl.local.showInvitePage(VConstants.TEXT_INVITE, ClientContext.model.name);
    }

    public function handleMove (roomId :int) :void
    {
        trace("Moving to room (" + roomId + ")");
        ClientContext.ctrl.player.moveToRoom(roomId);
    }

    public function handleActivateLoadBalancer () :void
    {
//        var popup :PopupQuery = new PopupQuery(
//            null,
//            "The scent of blood in the air.  Click on a link to hunt other players\n" +
//            "     <--------------------");
//        ClientContext.gameMode.addSceneObject(popup, ClientContext.gameMode.modeSprite);
//        ClientContext.centerOnViewableRoom(popup.displayObject);
//        ClientContext.animateEnlargeFromMouseClick(popup);
//
//        var quitTimer :SimpleTimer = new SimpleTimer(3, function() :void {
//            if (popup.isLiveObject) {
//                popup.destroySelf();
//            }
//        });
//        ClientContext.gameMode.addObject(quitTimer);

        if (ClientContext.gameMode.getObjectNamed(LoadBalancerClient.NAME) != null) {
            var lb :LoadBalancerClient = ClientContext.gameMode.getObjectNamed(
                LoadBalancerClient.NAME) as LoadBalancerClient;
            lb.activate();
        }
        else {
            log.error("handleActivateLoadBalancer, where is the load balancer???");
        }
    }

    public function handleDeactivateLoadBalancer () :void
    {
        if (ClientContext.gameMode.getObjectNamed(LoadBalancerClient.NAME) != null) {
            var lb :LoadBalancerClient = ClientContext.gameMode.getObjectNamed(
                LoadBalancerClient.NAME) as LoadBalancerClient;
            lb.deactivate();
        }
        else {
            log.error("handleDeactivateLoadBalancer, where is the load balancer???");
        }
    }

    public function handleShowPreyLineage (playerId :int) :void
    {
        var lineage :Lineage = ClientContext.gameMode.lineages.getLineage(playerId);
        trace("handleShowPreyLineage, playerId=" + playerId + ", lineage=" + lineage);
        handleShowIntro("target", lineage, playerId);
    }


    protected static const log :Log = Log.getLog(VampireController);

    public static const POPUP_PREFIX_FEED_REQUEST :String = "RequestFeed";


}
}