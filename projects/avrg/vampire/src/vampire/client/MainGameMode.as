package vampire.client
{
import com.threerings.flash.SimpleTextButton;
import com.threerings.util.ClassUtil;
import com.threerings.util.Command;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.net.MessageReceivedEvent;

import flash.display.Sprite;
import flash.events.MouseEvent;

import vampire.avatar.VampireAvatarHUDOverlay;
import vampire.client.events.LineageUpdatedEvent;
import vampire.data.Lineage;
import vampire.data.VConstants;
import vampire.debug.LineageDebug;
import vampire.feeding.FeedingClient;
import vampire.net.messages.FeedRequestMsg;
import vampire.net.messages.GameStartedMsg;

public class MainGameMode extends AppMode
{
    override protected function enter () :void
    {
        modeSprite.visible = true;
        log.debug("Starting " + ClassUtil.tinyClassName(this));

        ClientContext.model.setup();
        //Add intro panel if we're a new player
        if(ClientContext.isNewPlayer) {
            ClientContext.controller.handleShowIntro("intro");
            ClientContext.isNewPlayer = false;
        }
        else {
            log.debug("We're NOT a new player");
        }

        ClientContext.controller.handleShowIntro("intro");

        //Notify the agent that we are now wearing the right avatar, and can receive popup messages
        ClientContext.ctrl.agent.sendMessage(GameStartedMsg.NAME,
            new GameStartedMsg(ClientContext.ourPlayerId).toBytes());

        //Init the avatar logic controller and avatar event listener
        _avatarController = new AvatarClientController(ClientContext.ctrl);
        addObject(_avatarController);

    }

    override protected function setup () :void
    {
        //Set the game mode where all game objects are added.
        ClientContext.gameMode = this;

        modeSprite.visible = false;
        super.setup();

        ClientContext.model = new GameModel();
        addObject(ClientContext.model);


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
            addObject(lineagedebug);
        }


        if (!VConstants.LOCAL_DEBUG_MODE) {
            FeedingClient.init(modeSprite, ClientContext.ctrl);
        }

        _events.registerListener(ClientContext.ctrl.player, MessageReceivedEvent.MESSAGE_RECEIVED,
            handleMessageReceived);

        //Create the overlay for individual avatars
        ClientContext.avatarOverlay = new VampireAvatarHUDOverlay(ClientContext.ctrl);
        addSceneObject(ClientContext.avatarOverlay, modeSprite);
        //And pass to the server player arrival events, if we are moving to feed.

        _hud = new HUD();
        addSceneObject(_hud, modeSprite);
        ClientContext.hud = _hud;


        ClientContext.model.setAvatarState(VConstants.AVATAR_STATE_DEFAULT);

        //Add a debug panel for admins
        if(ClientContext.isAdmin(ClientContext.ourPlayerId) || VConstants.LOCAL_DEBUG_MODE) {
            var debug :SimpleTextButton = new SimpleTextButton("Admin");
            Command.bind(debug, MouseEvent.CLICK, VampireController.SHOW_DEBUG);
            modeSprite.addChild(debug);
        }

        //Add the tutorial
        ClientContext.tutorial = new Tutorial();
//        ClientContext.tutorial.activateTutorial();


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
    }




    protected function onGameComplete () :void
    {
        log.info(ClientContext.ourPlayerId + " onGameComplete(), Feeding complete, setting avatar state to default");//, "completedSuccessfully", completedSuccessfully);

        ClientContext.model.setAvatarState(VConstants.AVATAR_STATE_DEFAULT);
        var feedingClient :FeedingClient = FeedingClient(_feedingGameClient);
        if(feedingClient.playerData != null) {
            log.info(feedingClient.playerData);
            ClientContext.ctrl.agent.sendMessage(VConstants.NAMED_EVENT_UPDATE_FEEDING_DATA,
                feedingClient.playerData.toBytes());
        }
        else {
            log.error("onGameComplete(), _feedingGameClient.playerData==null");
        }
        feedingClient.shutdown();
        _feedingGameClient = null;

        //Notify the tutorial
        ClientContext.tutorial.feedGameOver();

    }



    protected var _hud :HUD;
    protected var _avatarController :AvatarClientController;
    protected var _feedingGameClient :Sprite;
    protected static const log :Log = Log.getLog(MainGameMode);
}
}
