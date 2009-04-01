package vampire.client
{
import com.threerings.flash.MathUtil;
import com.threerings.flash.SimpleTextButton;
import com.threerings.flash.Vector2;
import com.threerings.util.ClassUtil;
import com.threerings.util.Command;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.objects.SimpleTimer;
import com.whirled.net.MessageReceivedEvent;

import flash.display.Sprite;
import flash.events.MouseEvent;

import vampire.avatar.AvatarGameBridge;
import vampire.avatar.VampireAvatarHUDOverlay;
import vampire.client.events.LineageUpdatedEvent;
import vampire.client.events.PlayerArrivedAtLocationEvent;
import vampire.data.Lineage;
import vampire.data.VConstants;
import vampire.feeding.FeedingClient;
import vampire.feeding.debug.BloodBloomStandalone;
import vampire.net.messages.FeedRequestMsg;
import vampire.net.messages.GameStartedMsg;
import vampire.net.messages.MovePredIntoPositionMsg;

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

        //Let's hear when the avatar arrived at a destination
//
        if (VConstants.LOCAL_DEBUG_MODE) {
//            handleStartFeedingClient(1);
        }

        ClientContext.controller.handleShowIntro("intro");
//        ClientContext.tutorial.activateTutorial();

        //Notify the agent that we are now wearing the right avatar, and can receive popup messages
        ClientContext.ctrl.agent.sendMessage(GameStartedMsg.NAME,
            new GameStartedMsg(ClientContext.ourPlayerId).toBytes());

    }
//
//    /**
//    * Currently not used, since non-player blood is currently no longer monitored on the server.
//    *
//    */
//    protected function updateNonPlayerIds(...ignored) :void
//    {
//        if(_currentNonPlayerIds == null) {
//            _currentNonPlayerIds = new Array();
//        }
//
//        var npIds :Array = ClientContext.getNonPlayerIds();
//        npIds.sort();
//
//        var roomId :int = ClientContext.ctrl.room.getRoomId();
//
//        if(!ArrayUtil.equals(_currentNonPlayerIds, npIds)) {
//            var msg :NonPlayerIdsInRoomMsg = new NonPlayerIdsInRoomMsg(
//                ClientContext.ourPlayerId, npIds, roomId);
//    //        log.debug("Sending " + msg);
//            ClientContext.ctrl.agent.sendMessage(msg.name, msg.toBytes());
//            _currentNonPlayerIds = npIds;
//        }
//
//
//
////        trace(ClientContext.ourPlayerId + " our inviter=" + ClientContext.ctrl.local.getInviterMemberId());
//    }

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
                lineage.setPlayerSire(1, 2);
                lineage.setPlayerSire(3, 1);
                lineage.setPlayerSire(4, 1);
                lineage.setPlayerSire(5, 1);
                lineage.setPlayerSire(6, 5);
                lineage.setPlayerSire(7, 6);
                lineage.setPlayerSire(8, 6);
                lineage.setPlayerSire(9, 1);
                lineage.setPlayerSire(10, 1);
                lineage.setPlayerSire(11, 1);
                lineage.setPlayerSire(12, 1);
                lineage.setPlayerSire(13, 1);
                lineage.setPlayerSire(14, 1);
            var msg :LineageUpdatedEvent = new LineageUpdatedEvent(lineage, ClientContext.ourPlayerId);
            ClientContext.model.lineage = lineage;
            ClientContext.model.dispatchEvent(msg);
        }



        //If this player hasn't played before, automatically show the help.
        if(ClientContext.model.isNewPlayer()) {
//            addObject(new HelpPopup(), modeSprite);
        }

//        _feedingGameDraggableSprite = new DraggableSceneObject(ClientContext.ctrl);
//        modeSprite.addChild(_feedingGameDraggableSprite.displayObject);

        //If we start moving, and we are in bared mode, change to default mode.
        registerListener(ClientContext.ctrl.room, AVRGameRoomEvent.PLAYER_MOVED, handlePlayerMoved);

        //If we go into bared mode via the avatar menu, update the game too.
        registerListener(ClientContext.ctrl.room,
            AVRGameRoomEvent.AVATAR_CHANGED, handleAvatarChanged);

        registerListener(ClientContext.model,
            PlayerArrivedAtLocationEvent.PLAYER_ARRIVED, handlePlayerArrivedAtLocation);

        //Move our avatar a while after feeding
//        registerListener(ClientContext.ctrl.player, MessageReceivedEvent.MESSAGE_RECEIVED, function(
//            e :MessageReceivedEvent) :void {
//
//
//            });

        //If the game server says no more feeding, leave predator action


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
//        ClientContext.centerOnViewableRoom(_hud.displayObject);
        ClientContext.hud = _hud;


        trace(ClientContext.ourPlayerId + " setting avatar state from game beginning");
        ClientContext.model.setAvatarState(VConstants.AVATAR_STATE_DEFAULT);


        //Every X seconds, check the non-player ids, updating the server if changed.
        //ATM we don't care about this anymore.
//        var nonPlayerIdTimer :SimpleTimer = new SimpleTimer(2, updateNonPlayerIds, true, "npTimer");
//        addObject(nonPlayerIdTimer);





        //Add a debug panel for admins
        if(ClientContext.isAdmin(ClientContext.ourPlayerId) || VConstants.LOCAL_DEBUG_MODE) {
            var debug :SimpleTextButton = new SimpleTextButton("debug");
            Command.bind(debug, MouseEvent.CLICK, VampireController.SHOW_DEBUG);
            modeSprite.addChild(debug);
        }

        //Add the tutorial
        ClientContext.tutorial = new TutorialAppMode();
//        ClientContext.tutorial.activateTutorial();


    }

    protected function handlePlayerMoved (e :AVRGameRoomEvent) :void
    {
        var playerMovedId :int = int(e.value);
        if(playerMovedId == ClientContext.ourPlayerId) {
            if(ClientContext.model.state == VConstants.AVATAR_STATE_BARED) {
                ClientContext.controller.handleChangeState(VConstants.AVATAR_STATE_DEFAULT);
                ClientContext.model.setAvatarState(VConstants.AVATAR_STATE_DEFAULT);
            }
        }
    }

    protected function handlePlayerArrivedAtLocation (e :PlayerArrivedAtLocationEvent) :void
    {
//        trace("MainGameMode, handlePlayerArrivedAtLocation");
//        if(ClientContext.model.state == VConstants.PLAYER_STATE_MOVING_TO_FEED) {
            trace(ClientContext.ourPlayerId + " Sending player arrived event");
            ClientContext.ctrl.agent.sendMessage(PlayerArrivedAtLocationEvent.PLAYER_ARRIVED);
//        }
    }

    /**
    * We can go into 'bared' mode via the game HUD menu, or via the regular avatar menu.
    * Therefore, we must listen to changes in the avatar and check if we have gone into
    * bared mode.
    */
    protected function handleAvatarChanged (e :AVRGameRoomEvent) :void
    {
        var playerAvatarChangedId :int = int(e.value);

        //We are only allowed to change our own avatar.
        if(playerAvatarChangedId != ClientContext.ourPlayerId) {
            return;
        }

        //Do as if we have pushed the 'Bared" button.
        var avatar :AVRGameAvatar = ClientContext.ctrl.room.getAvatarInfo(playerAvatarChangedId);
        if(avatar != null) {

            var isBared :Boolean = ClientContext.model.state == VConstants.PLAYER_STATE_BARED ||
                ClientContext.model.state == VConstants.PLAYER_STATE_FEEDING_PREY;
            //If we change our avatar to bared, but we are not in the bared player state.
            if(!isBared && avatar.state == VConstants.AVATAR_STATE_BARED) {
                ClientContext.controller.handleChangeState(VConstants.PLAYER_STATE_BARED);
            }
        }
    }

    protected function handleStartFeedingClient (gameId :int) :void
    {
        log.info("Received StartClient message", "gameId", gameId);

        if (_feedingGameClient != null) {
            log.warning("Received StartFeeding message while already in game");
        } else {

            if (VConstants.LOCAL_DEBUG_MODE) {
                _feedingGameClient = new BloodBloomStandalone(modeSprite);
            }
            else {
                _feedingGameClient = FeedingClient.create(gameId,
                    ClientContext.model.playerFeedingData, onGameComplete);
            }

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
        else if (e.name == VConstants.NAMED_EVENT_MOVE_PREDATOR_AFTER_FEEDING) {

            var moveTimer :SimpleTimer = new SimpleTimer(2.5, function() :void {

                var location :Array = ClientContext.model.location;
                var hotspot :Array = ClientContext.model.hotspot;
                if (location != null && hotspot != null) {

                    var xDirection :Number = location[3] > 0 && location[3] <= 180 ? 1 : -1;

                    var widthLogical :Number = hotspot[0]/ctrl.local.getRoomBounds()[0];

                    var xDistance :Number = xDirection * widthLogical / 3;

                    ctrl.player.setAvatarLocation(
                        MathUtil.clamp(location[0] + xDistance, 0, 1),
                        location[1],
                        MathUtil.clamp(location[2] - 0.1, 0, 1), location[3]);
                }
            }, false);
            addObject(moveTimer);
        }
        else if (e.name == FeedRequestMsg.NAME) {
            var msg :FeedRequestMsg =
                ClientContext.msg.deserializeMessage(e.name, e.value) as FeedRequestMsg;

            trace("got " + FeedRequestMsg.NAME);
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
        else if (e.name == MovePredIntoPositionMsg.NAME) {

            function convertStandardRads2GameDegrees(rad :Number) :Number
            {
                return MathUtil.toDegrees(MathUtil.normalizeRadians(rad + Math.PI / 2));
            }


            var movemsg :MovePredIntoPositionMsg = ClientContext.msg.deserializeMessage(
                e.name, e.value) as MovePredIntoPositionMsg;

            //If we are the first predator, we go directly behind the prey
            //Otherwise, take a a place
            var targetLocation :Array = movemsg.preyLocation;//ClientContext.model.getLocation(movemsg.preyId);
            var avatar :AVRGameAvatar = ClientContext.model.avatar;



            trace("MovePredIntoPositionMsg");
            trace("targetLocation=" + targetLocation);
//            trace("movemsg.preyId=" + movemsg.preyId);
//            trace("avatar=" + avatar);

            var targetX :Number;
            var targetY :Number;
            var targetZ :Number;

            //TODO: add the hotspot width /2, then test.
            var hotspot :Array = ClientContext.model.hotspot;
            trace("hotspot=" + hotspot);
            var widthLogical :Number = hotspot[0]/ctrl.local.getRoomBounds()[0];

            var distanceLogicalAwayFromPrey :Number = widthLogical / 3;

//            var p1 :Point = ctrl.local.locationToPaintable(0, targetLocation[1],
//                targetLocation[2]);
//            var p2 :Point = ctrl.local.locationToPaintable(widthLogical, targetLocation[1],
//                targetLocation[2]);
////
//            var absoluteWidth :Number = Math.abs(p2.x - p1.x);
//            var absoluteDistanceFrom

//            _hudSprite.graphics.clear();
//            _hudSprite.graphics.beginFill(0, 0.3);
//
//            _hudSprite.graphics.drawRect(-absoluteWidth/2, 0, absoluteWidth, absoluteHeight);
//            _hudSprite.graphics.endFill();



            var angleRadians :Number = new Vector2(targetLocation[0] - avatar.x,
                targetLocation[2] - avatar.z).angle;
            var degs :Number = convertStandardRads2GameDegrees(angleRadians);

            targetX = targetLocation[0] +
                VConstants.PREDATOR_LOCATIONS_RELATIVE_TO_PREY[movemsg.predIndex][0] *
                distanceLogicalAwayFromPrey;
            targetY = targetLocation[1] +
                VConstants.PREDATOR_LOCATIONS_RELATIVE_TO_PREY[movemsg.predIndex][1] *
                distanceLogicalAwayFromPrey;
            targetZ = targetLocation[2] +
                VConstants.PREDATOR_LOCATIONS_RELATIVE_TO_PREY[movemsg.predIndex][2] *
                distanceLogicalAwayFromPrey;

            //If the avatar is already at the location, the client will dispatch a
            //PlayerArrivedAtLocation event, as the location doesn't change.
//            if(targetX == avatar.x &&
//                targetY == avatar.y &&
//                targetZ == avatar.z) {
//                log.error("Player already at location, changing to feed mode");
//                handlePlayerArrivedAtLocation(player);
//            }
//            else {
                ClientContext.ctrl.player.setAvatarLocation(targetX, targetY, targetZ, degs);
//            }
        }



    }




    protected function onGameComplete () :void
    {
        log.info(ClientContext.ourPlayerId + " onGameComplete(), Feeding complete, setting avatar state to default");//, "completedSuccessfully", completedSuccessfully);

        trace(ClientContext.ourPlayerId + " setting avatar state from game complete");
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


//        _feedingGameClientSceneobjectWrapper.destroySelf();
//        _feedingGameClientSceneobjectWrapper = null;
        //Remove game after getting the feeding data, feeding data is nulled after stage removal.
//        if(_feedingGameClient.parent != null){
//            _feedingGameClient.parent.removeChild(_feedingGameClient)
//        }
        _feedingGameClient = null;
        //Reset the overlay
//        ClientContext.avatarOverlay.setDisplayMode(VampireAvatarHUDOverlay.DISPLAY_MODE_OFF);

        //Notify the tutorial
        ClientContext.tutorial.feedGameOver();

    }








    override protected function exit () :void
    {
        modeSprite.visible = false;
        log.warning("!!! " + ClassUtil.tinyClassName(this) + "exiting.  Is this what we want??");

        //Remove the avatar callback
        var setCallback :Function = ClientContext.ctrl.room.getEntityProperty(
        AvatarGameBridge.ENTITY_PROPERTY_SET_AVATAR_ARRIVED_CALLBACK, ClientContext.ourEntityId) as Function;
        if(setCallback != null) {
            setCallback(null);
        }
    }

    override protected function destroy () :void
    {
        super.destroy();

        //Remove the avatar callback
        var setCallback :Function = ClientContext.ctrl.room.getEntityProperty(
        AvatarGameBridge.ENTITY_PROPERTY_SET_AVATAR_ARRIVED_CALLBACK, ClientContext.ourEntityId) as Function;
        if(setCallback != null) {
            setCallback(null);
        }
    }

    protected var _hud :HUD;

    protected var _feedingGameClient :Sprite;

//    protected var _feedingGameClientSceneobjectWrapper :DraggableSceneObject;

    protected var _currentNonPlayerIds :Array;


    protected static const log :Log = Log.getLog(MainGameMode);
}
}