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
import vampire.client.events.PlayerArrivedAtLocationEvent;
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

        var testPopup :PopupMessage = new PopupMessage(ClientContext.ctrl, "sdsdf", ClientContext.hud);
        addObject( testPopup, modeSprite );
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

        //If this player hasn't played before, automatically show the help.
        if( ClientContext.model.isNewPlayer() ) {
//            addObject(  new HelpPopup(), modeSprite );
        }

        _feedingGameDraggableSprite = new DraggableSceneObject(ClientContext.ctrl);
        modeSprite.addChild( _feedingGameDraggableSprite.displayObject );

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
                trace("avatar changed, playerId="+playerMovedId);

                //We are only allowed to change our own avatar.
                if( playerMovedId != ClientContext.ourPlayerId ) {
                    return;
                }

                //Do as if we have pushed the 'Bared" button.
                var avatar :AVRGameAvatar = ClientContext.ctrl.room.getAvatarInfo( playerMovedId );
                trace("avatar state="+avatar.state);
                trace("ClientContext.model.action="+ClientContext.model.action);
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

//        _subgameSprite = new Sprite();
//        modeSprite.addChild( _subgameSprite );
//        var subgameconfig :Config = new Config();
//        subgameconfig.hostSprite = _subgameSprite;
//        subgame = new SimpleGame( subgameconfig );
////        subgame.run();
//        subgame.ctx.mainLoop.pushMode( new NothingMode() );

        trace(ClientContext.ourPlayerId + " setting avatar state from game beginning");
        ClientContext.model.setAvatarState( VConstants.GAME_MODE_NOTHING );

//        registerListener( ClientContext.model, ChangeActionEvent.CHANGE_ACTION, changeAction );

//        registerListener( ClientContext.gameCtrl.room.props, PropertyChangedEvent.PROPERTY_CHANGED, handlePropChanged);

//        _thaneObjectDBForNonPlayers = new ObjectDBThane();

//        updateNonPlayersIds( ClientContext.gameCtrl.room.props.get( Codes.ROOM_PROP_NON_PLAYERS ) as Array );

        //Every X seconds, check the non-player ids, updating the server if changed.
        var nonPlayerIdTimer :SimpleTimer = new SimpleTimer(3, updateNonPlayerIds, true, "npTimer");
        addObject( nonPlayerIdTimer );


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

                Sprite(_feedingGameDraggableSprite.displayObject).addChild( _feedingGameClient );
                _feedingGameClient.mouseEnabled = true;
                _feedingGameClient.mouseChildren = true;
                _feedingGameDraggableSprite.init(new Rectangle(0,0,0,0), 0,0,0,0);
//                modeSprite.addChild(_feedingGameClient);
            }
        }
    }




    protected function onGameComplete () :void
    {
        log.info(ClientContext.ourPlayerId + " onGameComplete(), Feeding complete, setting avatar state to default");//, "completedSuccessfully", completedSuccessfully);

        if( Sprite(_feedingGameDraggableSprite.displayObject).contains( _feedingGameClient ) ){
            Sprite(_feedingGameDraggableSprite.displayObject).removeChild( _feedingGameClient )
        }

//        modeSprite.removeChild(_feedingGameClient);
        trace(ClientContext.ourPlayerId + " setting avatar state from game complete");
        ClientContext.model.setAvatarState( VConstants.GAME_MODE_NOTHING );
        if( _feedingGameClient.playerData != null ) {
            ClientContext.ctrl.agent.sendMessage( VConstants.NAMED_EVENT_UPDATE_FEEDING_DATA,
                _feedingGameClient.playerData.toBytes() );
        }
        else {
            log.error("onGameComplete(), _feedingGameClient.playerData==null");
        }
        _feedingGameClient = null;

        //Reset the overlay
//        ClientContext.avatarOverlay.setDisplayMode( VampireAvatarHUDOverlay.DISPLAY_MODE_OFF );

    }

//    override public function update( dt :Number ) :void
//    {
//        super.update( dt );
//        _thaneObjectDBForNonPlayers.update( dt );
//    }







    override protected function exit() :void
    {
        modeSprite.visible = false;
        log.warning("!!! " + ClassUtil.tinyClassName(this) + "exiting.  Is this what we want??");
    }

    override protected function destroy() :void
    {
//        subgame.shutdown();
//        _thaneObjectDBForNonPlayers.shutdown();
    }

//    protected function changeAction( e :ChangeActionEvent ) :void
//    {
//        return;
//        var action :String = e.action;
//
//        var m :AppMode;
//
//        switch( action ) {
////                case Constants.GAME_MODE_BLOODBOND:
////                     m = new BloodBondMode();
////                     break;
//
//             case VConstants.GAME_MODE_FEED_FROM_PLAYER:
//             case VConstants.GAME_MODE_FEED_FROM_NON_PLAYER:
//                 m = new FeedMode();
//                 break;
//
//             case VConstants.GAME_MODE_BARED:
//                 m = new EatMeMode();
//                 break;
//
//             case VConstants.GAME_MODE_FIGHT:
//                 m = new FightMode();
//                 break;
//
////                 case Constants.GAME_MODE_HIERARCHY_AND_BLOODBONDS:
////                     m = new HierarchyMode();
////                     break;
//
//             default:
//                 m = new NothingMode();
//        }
//
//        log.debug("current mode=" + ClassUtil.getClassName( subgame.ctx.mainLoop.topMode ) );
//        log.debug("new mode=" + ClassUtil.getClassName( m ) );
//        if( m !== subgame.ctx.mainLoop.topMode) {
//            subgame.ctx.mainLoop.unwindToMode( m );
//        }
//        else{
//            log.debug("Not changing mode because the mode is already on top, m=" + m);
//        }
//
//    }

//    protected var subgame :SimpleGame;
//    protected var _subgameSprite :Sprite;
    protected var _hud :HUD;

    protected var _feedingGameClient :FeedingGameClient;
    protected var _feedingGameDraggableSprite :DraggableSceneObject;

    protected var _currentNonPlayerIds :Array;
//    /**Holds feeding data until game is over and it's sent to the server*/
//    protected var _playerFeedingDataTemp :PlayerFeedingData;

//    protected var _thaneObjectDBForNonPlayers :ObjectDBThane;

    protected static const log :Log = Log.getLog( MainGameMode );
}
}