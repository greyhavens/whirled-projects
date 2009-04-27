package vampire.client
{
import com.threerings.flash.SimpleTextButton;
import com.threerings.util.ClassUtil;
import com.threerings.util.Command;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.net.Message;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.display.Sprite;
import flash.events.MouseEvent;

import vampire.avatar.VampireAvatarHUDOverlay;
import vampire.data.Codes;
import vampire.data.VConstants;
import vampire.feeding.FeedingClient;
import vampire.feeding.FeedingClientSettings;
import vampire.net.messages.FeedConfirmMsg;
import vampire.net.messages.FeedRequestCancelMsg;
import vampire.net.messages.FeedRequestMsg;
import vampire.net.messages.FeedingDataMsg;
import vampire.net.messages.GameStartedMsg;
import vampire.net.messages.RoomNameMsg;
import vampire.net.messages.ShareTokenMsg;
import vampire.net.messages.StartFeedingClientMsg;

public class MainGameMode extends AppMode
{
    override protected function enter () :void
    {
        if (!ClientContext.ctrl.isConnected()) {
            return;
        }

        modeSprite.visible = true;
        log.debug("Starting " + ClassUtil.tinyClassName(this));

        if (ClientContext.model.xp < VConstants.MIN_XP_TO_HIDE_HELP) {
            ClientContext.controller.handleShowIntro("intro");
        }

        //Notify the agent that we are now wearing the right avatar, and can receive popup messages
        ClientContext.ctrl.agent.sendMessage(GameStartedMsg.NAME,
            new GameStartedMsg(ClientContext.ourPlayerId).toBytes());

        //Init the avatar logic controller and avatar event listener
        _clientAvatar = new ClientAvatar(ClientContext.ctrl);
        addObject(_clientAvatar);

        //Welcome the player with a link to the group
        ClientContext.ctrl.local.feedback("Welcome to Vampire Whirled!  " +
        "Join the group and read the latest updates: http://www.whirled.com/#groups-d_11220");

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

        //Layer the sprites
        modeSprite.addChild(_spriteLayerLowPriority);
        modeSprite.addChild(_spriteLayerMedPriority);
        modeSprite.addChild(_spriteLayerFeedingGame);
        modeSprite.addChild(_spriteLayerHighPriority);


        ClientContext.model = new PlayerModel();
        addObject(ClientContext.model);

        _lineages = new LineagesClient();
        addObject(_lineages);

        //If there is a share token, send the invitee to the server
        var inviterId :int = ClientContext.ctrl.local.getInviterMemberId();
        var shareToken :String = ClientContext.ctrl.local.getInviteToken();
        //If we don't have a sire, and we are invited, send our invite token
        if(inviterId != 0 && ClientContext.model.sire == 0) {
            log.info(ClientContext.ctrl.player.getPlayerId() + " sending  inviterId=" + inviterId + ", token=" + shareToken);
            ClientContext.ctrl.agent.sendMessage(ShareTokenMsg.NAME,
                new ShareTokenMsg(ClientContext.ourPlayerId, inviterId, shareToken).toBytes());
        }



        //Init the feeding game, if we're not testing.
        if (!VConstants.LOCAL_DEBUG_MODE) {
            FeedingClient.init(modeSprite, ClientContext.ctrl);
        }

        registerListener(ClientContext.ctrl.player, MessageReceivedEvent.MESSAGE_RECEIVED,
            handleMessageReceived);

        //Listen for popup messages coming in on the room props.
        registerListener(ClientContext.ctrl.room.props, PropertyChangedEvent.PROPERTY_CHANGED,
            handleRoomPropChanged);

        //Listen for the player leaving the room, shut down the client then
        registerListener(ClientContext.ctrl.player, AVRGamePlayerEvent.LEFT_ROOM,
            handleOurPlayerLeftRoom);

        //Listen for the player leaving the room, shut down the client then
        registerListener(ClientContext.ctrl.room, AVRGameRoomEvent.PLAYER_LEFT,
            handlePlayerLeftRoom);

        //Create the overlay for individual avatars
        _avatarOverlay = new VampireAvatarHUDOverlay(ClientContext.ctrl);
        addSceneObject(_avatarOverlay, layerLowPriority);

        //Add the main HUD
        _hud = new HUD();
        addSceneObject(_hud, layerLowPriority);
        //Add the client load balancer, which depends on the HUD
        addObject(new LoadBalancerClient(ClientContext.ctrl, _hud));

        //Make sure we start the game standing, not dancing or feeding etc.
        ClientContext.model.setAvatarState(VConstants.AVATAR_STATE_DEFAULT);


        //Add the tutorial.  It starts deactivated.
        ClientContext.tutorial = new Tutorial();



        //Add a debug panel for admins
        if(ClientContext.isAdmin(ClientContext.ourPlayerId) || VConstants.LOCAL_DEBUG_MODE) {
            var debug :SimpleTextButton = new SimpleTextButton("Admin");
            Command.bind(debug, MouseEvent.CLICK, VampireController.SHOW_DEBUG);
            modeSprite.addChild(debug);

            //And for admins, listen to stats messages.
            addObject(new AnalyserClient());
        }


//        if (VConstants.LOCAL_DEBUG_MODE) {
//
//            var lineage :Lineage = new Lineage();
//            lineage.isConnectedToLilith = true;
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
//            var msg :LineageUpdatedEvent = new LineageUpdatedEvent(lineage, ClientContext.ourPlayerId);
//            ClientContext.model.lineage = lineage;
//            ClientContext.model.dispatchEvent(msg);
//        }


    }

    protected function handlePlayerLeftRoom (e :AVRGameRoomEvent) :void
    {
        //Remove any outstanding feed requests from the leaving player
        var feedRequest :SimObject =
            getObjectNamed(VampireController.POPUP_PREFIX_FEED_REQUEST + e.value);
        if (feedRequest != null && feedRequest.isLiveObject) {
            feedRequest.destroySelf();
        }
    }

    protected function handleRoomPropChanged (e :PropertyChangedEvent) :void
    {
        var mode :AppMode = ClientContext.gameMode;

        switch(e.name) {
            case Codes.ROOM_PROP_FEEDBACK:
                var messages :Array = e.newValue as Array;
                if (messages != null) {
                    for each (var m :Array in messages) {
                        var forPlayer :int = int(m[0]);
                        var msg :String = m[1] as String;
                        var priority :int = 1;
                        if (m.length >= 3) {
                            priority = m[2] as int;
                        }
                        if (forPlayer <= 0 || forPlayer == ClientContext.ourPlayerId) {
                            _feedbackMessageQueue.push([msg, priority]);
                            if (forPlayer == 23340) {
                                trace(msg);
                            }
                        }
                    }
                }
                break;

            default:
                break;
        }

    }

    protected function handleFeedConfirm (e :FeedConfirmMsg) :void
    {

        if (getObjectNamed(VConstants.POPUP_MESSAGE_FEED_CONFIRM + e.preyId) != null) {
            getObjectNamed(VConstants.POPUP_MESSAGE_FEED_CONFIRM + e.preyId).destroySelf();
        }


        if (!e.isAllowedToFeed) {
            ClientContext.controller.handleShowPopupMessage(null, e.preyName + " has denied your request to feed", layerLowPriority);
        }
    }
    protected function handleStartFeedingClientMsg (msg :StartFeedingClientMsg) :void
    {
        log.info("handleStartFeedingClientMsg", "msg", msg);

        if (_feedingGameClient != null) {
            log.warning("Received StartFeeding message while already in game");
        } else {

            var settings :FeedingClientSettings = FeedingClientSettings.mpSettings(
                msg.gameId, ClientContext.model.playerFeedingData, onGameComplete);
            _feedingGameClient = FeedingClient.create(settings);

            _spriteLayerFeedingGame.addChildAt(_feedingGameClient, 0)

            //Notify the tutorial
            ClientContext.tutorial.feedGameStarted();
        }
    }

    protected function handleMessageReceived (e :MessageReceivedEvent) :void
    {
        var ctrl :AVRGameControl = ClientContext.ctrl;

        var message :Message = ClientContext.msg.deserializeMessage(e.name, e.value);

        if (message != null) {
            if (message is StartFeedingClientMsg) {
                handleStartFeedingClientMsg(StartFeedingClientMsg(message));
            }
            else if (message is FeedConfirmMsg) {
                handleFeedConfirm(FeedConfirmMsg(message));
            }
            else if (message is FeedRequestMsg) {
                var feedRequestMessage :FeedRequestMsg = FeedRequestMsg(message);

                var fromPlayerName :String = ClientContext.getPlayerName(feedRequestMessage.playerId);
                var popup :PopupQuery = new PopupQuery(
                        VampireController.POPUP_PREFIX_FEED_REQUEST + feedRequestMessage.playerId,
                        fromPlayerName + " would like to feed on you.",
                        ["Accept", "Deny"],
                        [
                            function () :void {
                                ClientContext.controller.handleAcceptFeedRequest(feedRequestMessage.playerId);
                            },
                            function () :void {
                                ClientContext.controller.handleDenyFeedRequest(feedRequestMessage.playerId);
                            },
                        ]);

                if(getObjectNamed(popup.objectName) == null) {
                    addSceneObject(popup, modeSprite);
                    ClientContext.centerOnViewableRoom(popup.displayObject);
                    ClientContext.animateEnlargeFromMouseClick(popup);
                }
            }
            else if (message is RoomNameMsg) {
                var roomMsg :RoomNameMsg = new RoomNameMsg(ClientContext.ourPlayerId,
                                                           ClientContext.ctrl.room.getRoomId(),
                                                           ClientContext.ctrl.room.getRoomName());
                log.debug("Sending to agent=" + roomMsg);
                ClientContext.ctrl.agent.sendMessage(RoomNameMsg.NAME, roomMsg.toBytes());
            }

            else if (message is FeedRequestCancelMsg) {
                var feedcancel :FeedRequestCancelMsg = FeedRequestCancelMsg(message);
                trace(ClientContext.ctrl.player.getPlayerName() + " recieved FeedRequestCancelMsg");
                var waitinForXPopup :SimObject = getObjectNamed(VampireController.POPUP_PREFIX_FEED_REQUEST +
                    feedcancel.playerId);

                trace("waitinForXPopup=" + waitinForXPopup);
                if (waitinForXPopup != null && waitinForXPopup.isLiveObject) {
                    waitinForXPopup.destroySelf();
                }
            }

        }

    }

    protected function handleOurPlayerLeftRoom (e :AVRGamePlayerEvent) :void
    {
        shutDownFeedingClient();

        //Remove outstanding feed requests.
        for each( var s :SimObject in getObjectsInGroup(PopupQuery.GROUP)) {
            if (s.objectName.indexOf(VConstants.POPUP_MESSAGE_FEED_CONFIRM) > -1) {
                s.destroySelf();
            }
            if (s.objectName.indexOf(VampireController.POPUP_PREFIX_FEED_REQUEST) > -1) {
                s.destroySelf();
            }
        }

        //Make sure we are in the 'default' avatar state.
        ClientContext.ctrl.player.setAvatarState(VConstants.AVATAR_STATE_DEFAULT);
    }




    protected function onGameComplete () :void
    {
        log.info(ClientContext.ourPlayerId + " onGameComplete(), Feeding complete, setting avatar state to default");//, "completedSuccessfully", completedSuccessfully);

        ClientContext.model.setAvatarState(VConstants.AVATAR_STATE_DEFAULT);
        if(_feedingGameClient.playerData != null) {
            log.info(_feedingGameClient.playerData);

            ClientContext.ctrl.agent.sendMessage(FeedingDataMsg.NAME,
                new FeedingDataMsg(ClientContext.ourPlayerId,
                _feedingGameClient.playerData.toBytes()).toBytes());

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

    override public function update (dt:Number) :void
    {
        super.update(dt);
        //Show feedback in the local client only feedback
        if (_feedbackMessageQueue.length > 0){

            for each (var msgData :Array in _feedbackMessageQueue) {

                var msg :String = msgData[0] as String;
                var priority :int = msgData[1] as int;

                var layer :Sprite = layerLowPriority;
                switch(priority) {
                    case 2:
                    layer = layerMediumPriority;
                    break;
                    case 2:
                    layer = layerHighPriority;
                    break;
                    default:
                    layer = layerLowPriority;
                }


                if (msg.substr(0, Codes.POPUP_PREFIX.length) == Codes.POPUP_PREFIX) {
                    ClientContext.controller.handleShowPopupMessage("ServerPopup",
                        msg.substring(Codes.POPUP_PREFIX.length), layer);
                }
                else {
                    ClientContext.ctrl.local.feedback(msg);
                }
            }
            _feedbackMessageQueue.splice(0);
        }
    }

    public function get lineages () :LineagesClient
    {
        return _lineages;
//        return getObjectNamed(LineagesClient.NAME) as LineagesClient;
    }

    public function get hud () :HUD
    {
        return _hud;
    }

    public function get layerLowPriority () :Sprite
    {
        return _spriteLayerLowPriority;
    }

    public function get layerMediumPriority () :Sprite
    {
        return _spriteLayerMedPriority;
    }

    public function get layerHighPriority () :Sprite
    {
        return _spriteLayerHighPriority;
    }

    public function get avatarOverlay () :VampireAvatarHUDOverlay
    {
        return _avatarOverlay;
    }



    protected var _hud :HUD;
    protected var _lineages :LineagesClient;
    protected var _feedbackMessageQueue :Array = new Array();
    protected var _clientAvatar :ClientAvatar;
    protected var _feedingGameClient :FeedingClient;
    protected var _avatarOverlay :VampireAvatarHUDOverlay;

    //Layer the sprites for allowing popup messages over and under the feeding game
    protected var _spriteLayerFeedingGame :Sprite = new Sprite();
    protected var _spriteLayerHighPriority :Sprite = new Sprite();
    protected var _spriteLayerMedPriority :Sprite = new Sprite();
    protected var _spriteLayerLowPriority :Sprite = new Sprite();

    protected static const log :Log = Log.getLog(MainGameMode);
}
}
