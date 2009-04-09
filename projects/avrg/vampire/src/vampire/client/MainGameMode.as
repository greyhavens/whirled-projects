package vampire.client
{
import com.threerings.flash.SimpleTextButton;
import com.threerings.util.ClassUtil;
import com.threerings.util.Command;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.net.MessageReceivedEvent;

import flash.events.MouseEvent;

import vampire.avatar.VampireAvatarHUDOverlay;
import vampire.client.events.LineageUpdatedEvent;
import vampire.data.Lineage;
import vampire.data.VConstants;
import vampire.debug.LineageDebug;
import vampire.feeding.FeedingClient;
import vampire.net.messages.FeedRequestMsg;
import vampire.net.messages.FeedingDataMsg;
import vampire.net.messages.GameStartedMsg;
import vampire.net.messages.RoomNameMsg;
import vampire.net.messages.ShareTokenMsg;

public class MainGameMode extends AppMode
{
    override protected function enter () :void
    {
        if (!ClientContext.ctrl.isConnected()) {
            return;
        }

        modeSprite.visible = true;
        log.debug("Starting " + ClassUtil.tinyClassName(this));

        ClientContext.model.setup();
//        //Add intro panel if we're a new player
//        if(ClientContext.isNewPlayer) {
//            ClientContext.controller.handleShowIntro("intro");
//            ClientContext.isNewPlayer = false;
//        }
//        else {
//            log.debug("We're NOT a new player");
//        }

        ClientContext.controller.handleShowIntro("intro");

        //Notify the agent that we are now wearing the right avatar, and can receive popup messages
        ClientContext.ctrl.agent.sendMessage(GameStartedMsg.NAME,
            new GameStartedMsg(ClientContext.ourPlayerId).toBytes());

        //Init the avatar logic controller and avatar event listener
        _avatarController = new ClientAvatar(ClientContext.ctrl);
        addObject(_avatarController);

    }

    override protected function setup () :void
    {
        super.setup();

        if (!ClientContext.ctrl.isConnected()) {
            return;
        }

        //Set the game mode where all game objects are added.
        ClientContext.gameMode = this;

        modeSprite.visible = false;

        ClientContext.model = new GameModel();
        addObject(ClientContext.model);

        //If there is a share token, send the invitee to the server
        var inviterId :int = ClientContext.ctrl.local.getInviterMemberId();
        var shareToken :String = ClientContext.ctrl.local.getInviteToken();
        //If we don't have a sire, and we are invited, send our invite token
        if(inviterId != 0 && SharedPlayerStateClient.getSire(ClientContext.ourPlayerId) == 0) {
            log.info(ClientContext.ctrl.player.getPlayerId() + " sending  inviterId=" + inviterId + ", token=" + shareToken);
            ClientContext.ctrl.agent.sendMessage(ShareTokenMsg.NAME,
                new ShareTokenMsg(ClientContext.ourPlayerId, inviterId, shareToken).toBytes());
        }


        if (VConstants.LOCAL_DEBUG_MODE) {

            var lineage :Lineage = new Lineage();
            LineageDebug.addRandomPlayersToLineage(lineage, 10);
//                lineage.setPlayerSire(1, 2);
//                lineage.setPlayerSire(3, 1);
//                lineage.setPlayerSire(4, 1);
//                lineage.setPlayerSire(5, 1);
//                lineage.setPlayerSire(6, 5);
//                lineage.setPlayerSire(7, 6);
//                lineage.setPlayerSire(8, 6);
//                lineage.setPlayerSire(9, 1);
//                lineage.setPlayerSire(10, 1);
//                lineage.setPlayerSire(11, 1);
//                lineage.setPlayerSire(12, 1);
//                lineage.setPlayerSire(13, 1);
//                lineage.setPlayerSire(14, 1);
            var msg :LineageUpdatedEvent = new LineageUpdatedEvent(lineage, ClientContext.ourPlayerId);
            ClientContext.model.lineage = lineage;
            ClientContext.model.dispatchEvent(msg);

            var lineagedebug :LineageDebug = new LineageDebug();
//            addObject(lineagedebug);
        }

        //Init the feeding game, if we're not testing.
        if (!VConstants.LOCAL_DEBUG_MODE) {
            FeedingClient.init(modeSprite, ClientContext.ctrl);
        }

        _events.registerListener(ClientContext.ctrl.player, MessageReceivedEvent.MESSAGE_RECEIVED,
            handleMessageReceived);

        //Listen for the player leaving the room, shut down the client then
        _events.registerListener(ClientContext.ctrl.player, AVRGamePlayerEvent.LEFT_ROOM,
            handlePlayerLeft);

        //Create the overlay for individual avatars
        ClientContext.avatarOverlay = new VampireAvatarHUDOverlay(ClientContext.ctrl);
        addSceneObject(ClientContext.avatarOverlay, modeSprite);

        //Add the main HUD
        _hud = new HUD();
        addSceneObject(_hud, modeSprite);
        ClientContext.hud = _hud;

        //Make sure we start the game standing, not dancing or feeding etc.
        ClientContext.model.setAvatarState(VConstants.AVATAR_STATE_DEFAULT);


        //Add the tutorial.  It starts deactivated.
        ClientContext.tutorial = new Tutorial();


        //Add the client load balancer
        addObject(new LoadBalancerClient(ClientContext.ctrl, modeSprite));

        //Add a debug panel for admins
        if(ClientContext.isAdmin(ClientContext.ourPlayerId) || VConstants.LOCAL_DEBUG_MODE) {
            var debug :SimpleTextButton = new SimpleTextButton("Admin");
            Command.bind(debug, MouseEvent.CLICK, VampireController.SHOW_DEBUG);
            modeSprite.addChild(debug);
        }


    }


    protected function handleStartFeedingClient (gameId :int) :void
    {
//        log.info("Received StartClient message", "gameId", gameId);

        if (_feedingGameClient != null) {
            log.warning("Received StartFeeding message while already in game");
        } else {

            /*if (VConstants.LOCAL_DEBUG_MODE) {
                _feedingGameClient = new BloodBloomStandalone(modeSprite);
            }
            else {
                _feedingGameClient = FeedingClient.create(gameId,
                    ClientContext.model.playerFeedingData, onGameComplete);
            }*/
            _feedingGameClient = FeedingClient.create(gameId,
                    ClientContext.model.playerFeedingData, onGameComplete);

            modeSprite.addChildAt(_feedingGameClient, 0)

            //Notify the tutorial
            ClientContext.tutorial.feedGameStarted();
        }
    }

    protected function handleMessageReceived (e :MessageReceivedEvent) :void
    {
        var ctrl :AVRGameControl = ClientContext.ctrl;

        if (e.name == "StartClient") {
            handleStartFeedingClient(e.value as int);
        }
        else if (e.name == FeedRequestMsg.NAME) {
            var msg :FeedRequestMsg =
                ClientContext.msg.deserializeMessage(e.name, e.value) as FeedRequestMsg;

//            trace("got " + FeedRequestMsg.NAME);
            var fromPlayerName :String = ClientContext.getPlayerName(msg.playerId);
            var popup :PopupQuery = new PopupQuery(
                    VampireController.POPUP_PREFIX_FEED_REQUEST + msg.playerId,
                    fromPlayerName + " would like to feed on you.",
                    ["Accept", "Deny"],
                    [
                        function () :void {
                            ClientContext.controller.handleAcceptFeedRequest(msg.playerId);
                        },
                        function () :void {
                            ClientContext.controller.handleDenyFeedRequest(msg.playerId);
                        },
                    ]);

            if(getObjectNamed(popup.objectName) == null) {
                addSceneObject(popup, modeSprite);
                ClientContext.centerOnViewableRoom(popup.displayObject);
                ClientContext.animateEnlargeFromMouseClick(popup);
            }
        }
        else if (e.name == RoomNameMsg.NAME) {
            var roomMsg :RoomNameMsg = new RoomNameMsg(ClientContext.ourPlayerId,
                                                       ClientContext.ctrl.room.getRoomId(),
                                                       ClientContext.ctrl.room.getRoomName());
            log.debug("Sending to agent=" + roomMsg);
            ClientContext.ctrl.agent.sendMessage(RoomNameMsg.NAME, roomMsg.toBytes());
        }
    }

    protected function handlePlayerLeft (e :AVRGamePlayerEvent) :void
    {
        shutDownFeedingClient();
    }




    protected function onGameComplete () :void
    {
        log.info(ClientContext.ourPlayerId + " onGameComplete(), Feeding complete, setting avatar state to default");//, "completedSuccessfully", completedSuccessfully);

        ClientContext.model.setAvatarState(VConstants.AVATAR_STATE_DEFAULT);
//        var feedingClient :FeedingClient = FeedingClient(_feedingGameClient);
        if(_feedingGameClient.playerData != null) {
            log.info(_feedingGameClient.playerData);

            ClientContext.ctrl.agent.sendMessage(FeedingDataMsg.NAME,
                new FeedingDataMsg(ClientContext.ourPlayerId,
                _feedingGameClient.playerData.toBytes()).toBytes());

//            ClientContext.ctrl.agent.sendMessage(VConstants.NAMED_EVENT_UPDATE_FEEDING_DATA,
//                feedingClient.playerData.toBytes());
        }
        else {
            log.error("onGameComplete(), _feedingGameClient.playerData==null");
        }
        shutDownFeedingClient();

        //Notify the tutorial
        ClientContext.tutorial.feedGameOver();

    }

    protected function shutDownFeedingClient () :void
    {
        if (_feedingGameClient != null) {
            _feedingGameClient.shutdown();

            if (_feedingGameClient.parent != null) {
                _feedingGameClient.parent.removeChild(_feedingGameClient);
            }
            _feedingGameClient = null;
        }
    }



    protected var _hud :HUD;
    protected var _avatarController :ClientAvatar;
    protected var _feedingGameClient :FeedingClient;
    protected static const log :Log = Log.getLog(MainGameMode);
}
}
