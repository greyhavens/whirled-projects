package vampire.client
{
import com.threerings.flash.MathUtil;
import com.threerings.flash.SimpleTextButton;
import com.threerings.util.ArrayUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.Command;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.contrib.avrg.DraggableSceneObject;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.objects.SimpleTimer;
import com.whirled.net.MessageReceivedEvent;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

import vampire.avatar.VampireAvatarHUDOverlay;
import vampire.client.events.LineageUpdatedEvent;
import vampire.client.events.PlayerArrivedAtLocationEvent;
import vampire.data.Lineage;
import vampire.data.VConstants;
import vampire.feeding.FeedingGameClient;
import vampire.net.messages.NonPlayerIdsInRoomMessage;

public class MainGameMode extends AppMode
{
    public function MainGameMode()
    {
        super();
    }

    override protected function enter() :void
    {
        modeSprite.visible = true;
        log.debug("Starting " + ClassUtil.tinyClassName( this ));

        //Add intro panel if we're a new player
        if( ClientContext.isNewPlayer) {
            ClientContext.controller.handleShowIntro("intro");
            ClientContext.isNewPlayer = false;
        }
        else {
            log.debug("We're NOT a new player");
        }

    }

    protected function updateNonPlayerIds(...ignored ) :void
    {
        if( _currentNonPlayerIds == null ) {
            _currentNonPlayerIds = new Array();
        }

        var npIds :Array = ClientContext.getNonPlayerIds();
        npIds.sort();

        var roomId :int = ClientContext.ctrl.room.getRoomId();

        if( !ArrayUtil.equals( _currentNonPlayerIds, npIds ) ) {
            var msg :NonPlayerIdsInRoomMessage = new NonPlayerIdsInRoomMessage(
                ClientContext.ourPlayerId, npIds, roomId );
    //        log.debug("Sending " + msg);
            ClientContext.ctrl.agent.sendMessage( msg.name, msg.toBytes() );
            _currentNonPlayerIds = npIds;
        }



//        trace( ClientContext.ourPlayerId + " our inviter=" + ClientContext.ctrl.local.getInviterMemberId());
    }

    override protected function setup() :void
    {
        modeSprite.visible = false;
        super.setup();

        ClientContext.model = new GameModel();
        addObject( ClientContext.model );
        ClientContext.model.setup();

        if( VConstants.LOCAL_DEBUG_MODE) {

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
            ClientContext.model.dispatchEvent( msg );
        }

        //If this player hasn't played before, automatically show the help.
        if( ClientContext.model.isNewPlayer() ) {
//            addObject(  new HelpPopup(), modeSprite );
        }

//        _feedingGameDraggableSprite = new DraggableSceneObject(ClientContext.ctrl);
//        modeSprite.addChild( _feedingGameDraggableSprite.displayObject );

        //If we start moving, and we are in bared mode, change to default mode.
        registerListener(ClientContext.ctrl.room, AVRGameRoomEvent.PLAYER_MOVED, function(
            e :AVRGameRoomEvent) :void {
                var playerMovedId :int = int( e.value );
                if( playerMovedId == ClientContext.ourPlayerId) {
                    if( ClientContext.model.action == VConstants.GAME_MODE_BARED ) {
                        ClientContext.controller.handleSwitchMode( VConstants.GAME_MODE_NOTHING );
//                        trace(ClientContext.ourPlayerId + " setting avatar state from player moved");
                        ClientContext.model.setAvatarState( VConstants.GAME_MODE_NOTHING );
                    }
                }
            });

        //If we go into bared mode via the avatar menu, update the game too.
        registerListener(ClientContext.ctrl.room, AVRGameRoomEvent.AVATAR_CHANGED, function(
            e :AVRGameRoomEvent) :void {
                var playerMovedId :int = int( e.value );
//                trace("avatar changed, playerId="+playerMovedId);

                //We are only allowed to change our own avatar.
                if( playerMovedId != ClientContext.ourPlayerId ) {
                    return;
                }

                //Do as if we have pushed the 'Bared" button.
                var avatar :AVRGameAvatar = ClientContext.ctrl.room.getAvatarInfo( playerMovedId );
//                trace("avatar state="+avatar.state);
//                trace("ClientContext.model.action="+ClientContext.model.action);
                if( avatar != null) {
                    //If we change our avatar to bared, but we are not in the bared state.
                    if( avatar.state == VConstants.GAME_MODE_BARED &&
                        ClientContext.model.action != VConstants.GAME_MODE_BARED) {
                        ClientContext.controller.handleSwitchMode( VConstants.GAME_MODE_BARED );
                    }
                }

            });

        //Move our avatar a while after feeding
        registerListener(ClientContext.ctrl.player, MessageReceivedEvent.MESSAGE_RECEIVED, function(
            e :MessageReceivedEvent) :void {
                if( e.name == VConstants.NAMED_EVENT_MOVE_PREDATOR_AFTER_FEEDING ) {

                    //Humans practising don't need to move.
                    if( !ClientContext.model.isVampire() ) {
                        return;
                    }

                    var moveTimer :SimpleTimer = new SimpleTimer( 2.5, function() :void {

                        var location :Array = ClientContext.model.location;
                        if( location != null ) {
                            ClientContext.ctrl.player.setAvatarLocation(
                                MathUtil.clamp( location[0] + 0.1,0,1),
                                location[1],
                                MathUtil.clamp( location[2] - 0.1,0,1), location[3]);
                        }
                    }, false);
                    addObject( moveTimer );

                }

            });

        //If the game server says no more feeding, leave predator action



        FeedingGameClient.init( modeSprite, ClientContext.ctrl );

        _events.registerListener(ClientContext.ctrl.player, MessageReceivedEvent.MESSAGE_RECEIVED,
            handleMessageReceived);

        //Create the overlay for individual avatars
        ClientContext.avatarOverlay = new VampireAvatarHUDOverlay( ClientContext.ctrl );
        addObject( ClientContext.avatarOverlay, modeSprite );
        //And pass to the server player arrival events, if we are moving to feed.
        //This lets the server know that we have moved into position, and the game can
        //start.
        registerListener( ClientContext.avatarOverlay, PlayerArrivedAtLocationEvent.PLAYER_ARRIVED,
            function(...ignored) :void {
                if( ClientContext.model.action == VConstants.GAME_MODE_MOVING_TO_FEED_ON_NON_PLAYER ||
                    ClientContext.model.action == VConstants.GAME_MODE_MOVING_TO_FEED_ON_PLAYER ) {

                        ClientContext.ctrl.agent.sendMessage(
                            PlayerArrivedAtLocationEvent.PLAYER_ARRIVED );
                    }
            });

        _hud = new HUD();
        addObject( _hud, modeSprite );
        ClientContext.hud = _hud;


        trace(ClientContext.ourPlayerId + " setting avatar state from game beginning");
        ClientContext.model.setAvatarState( VConstants.GAME_MODE_NOTHING );


        //Every X seconds, check the non-player ids, updating the server if changed.
        var nonPlayerIdTimer :SimpleTimer = new SimpleTimer(2, updateNonPlayerIds, true, "npTimer");
        addObject( nonPlayerIdTimer );





        //Add a debug panel for admins
        if( ClientContext.isAdmin(ClientContext.ourPlayerId) || VConstants.LOCAL_DEBUG_MODE ) {
            var debug :SimpleTextButton = new SimpleTextButton("debug");
            Command.bind( debug, MouseEvent.CLICK, VampireController.SHOW_DEBUG );
            modeSprite.addChild( debug );
        }


    }

    protected function handleMessageReceived (e :MessageReceivedEvent) :void
    {
        if (e.name == "StartClient") {
            var gameId :int = e.value as int;
            log.info("Received StartClient message", "gameId", gameId);

            if (_feedingGameClient != null) {
                log.warning("Received StartFeeding message while already in game");
            } else {
                _feedingGameClient = FeedingGameClient.create( gameId, ClientContext.model.playerFeedingData, onGameComplete);

                modeSprite.addChild(_feedingGameClient);
            }
        }
    }




    protected function onGameComplete () :void
    {
        log.info(ClientContext.ourPlayerId + " onGameComplete(), Feeding complete, setting avatar state to default");//, "completedSuccessfully", completedSuccessfully);

        trace(ClientContext.ourPlayerId + " setting avatar state from game complete");
        ClientContext.model.setAvatarState( VConstants.GAME_MODE_NOTHING );
        if( _feedingGameClient.playerData != null ) {
            log.info(_feedingGameClient.playerData);
            ClientContext.ctrl.agent.sendMessage( VConstants.NAMED_EVENT_UPDATE_FEEDING_DATA,
                _feedingGameClient.playerData.toBytes() );
        }
        else {
            log.error("onGameComplete(), _feedingGameClient.playerData==null");
        }
        _feedingGameClient.shutdown();

        //Remove game after getting the feeding data, feeding data is nulled after stage removal.
        if( _feedingGameClient.parent != null ){
            _feedingGameClient.parent.removeChild( _feedingGameClient )
        }
        _feedingGameClient = null;
        //Reset the overlay
//        ClientContext.avatarOverlay.setDisplayMode( VampireAvatarHUDOverlay.DISPLAY_MODE_OFF );

    }








    override protected function exit() :void
    {
        modeSprite.visible = false;
        log.warning("!!! " + ClassUtil.tinyClassName(this) + "exiting.  Is this what we want??");
    }

    override protected function destroy() :void
    {
        super.destroy();
    }

    protected var _hud :HUD;

    protected var _feedingGameClient :FeedingGameClient;

    protected var _currentNonPlayerIds :Array;


    protected static const log :Log = Log.getLog( MainGameMode );
}
}