package vampire.client
{
import com.threerings.util.ClassUtil;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.Config;
import com.whirled.contrib.simplegame.SimpleGame;
import com.whirled.net.MessageReceivedEvent;

import flash.display.Sprite;

import vampire.client.actions.NothingMode;
import vampire.client.actions.feed.EatMeMode;
import vampire.client.actions.feed.FeedMode;
import vampire.client.actions.fight.FightMode;
import vampire.client.events.ChangeActionEvent;
import vampire.data.VConstants;
import vampire.feeding.FeedingGameClient;
import vampire.feeding.FeedingPlayerData;

public class MainGameMode extends AppMode
{
    public function MainGameMode()
    {
        super();
    }
    
    override protected function enter() :void
    {
        log.debug("Starting " + ClassUtil.tinyClassName( this ));

    }
    
    override protected function setup() :void
    {
        super.setup();
        
        ClientContext.model = new GameModel();
        addObject( ClientContext.model );
        ClientContext.model.setup();
        
        //If this player hasn't played before, automatically show the help.
        if( ClientContext.model.isNewPlayer() ) {
            
            addObject(  new IntroHelpMode(), modeSprite ); 
//            ClientContext.game.ctx.mainLoop.pushMode( new IntroHelpMode() );
        }
    
    
        //If we start moving, and we are in bared mode, change to default mode.
        registerListener(ClientContext.ctrl.room, AVRGameRoomEvent.PLAYER_MOVED, function( 
            e :AVRGameRoomEvent) :void {
                var playerMovedId :int = int( e.value );
                if( playerMovedId == ClientContext.ourPlayerId) {
                    if( ClientContext.model.action == VConstants.GAME_MODE_BARED ) {
                        ClientContext.controller.handleSwitchMode( VConstants.GAME_MODE_NOTHING );
                        ClientContext.ctrl.player.setAvatarState( VConstants.GAME_MODE_NOTHING );
                    }
                }    
            });
        
        
            
        FeedingGameClient.init( modeSprite, ClientContext.ctrl );
        
        _events.registerListener(ClientContext.ctrl.player, MessageReceivedEvent.MESSAGE_RECEIVED,
            handleMessageReceived);
        
        _hud = new HUD();
        addObject( _hud, modeSprite );
        ClientContext.hud = _hud;
        
        _subgameSprite = new Sprite();
        modeSprite.addChild( _subgameSprite );
        var subgameconfig :Config = new Config();
        subgameconfig.hostSprite = _subgameSprite;
        subgame = new SimpleGame( subgameconfig );
        subgame.run();
        subgame.ctx.mainLoop.pushMode( new NothingMode() );
        
        ClientContext.ctrl.player.setAvatarState( VConstants.GAME_MODE_NOTHING );
        
        registerListener( ClientContext.model, ChangeActionEvent.CHANGE_ACTION, changeAction ); 
        
//        registerListener( ClientContext.gameCtrl.room.props, PropertyChangedEvent.PROPERTY_CHANGED, handlePropChanged);
        
//        _thaneObjectDBForNonPlayers = new ObjectDBThane();
        
//        updateNonPlayersIds( ClientContext.gameCtrl.room.props.get( Codes.ROOM_PROP_NON_PLAYERS ) as Array );
    }
    
    protected function handleMessageReceived (e :MessageReceivedEvent) :void
    {
        if (e.name == "StartClient") {
            var gameId :int = e.value as int;
            log.info("Received StartClient message", "gameId", gameId);

            if (_feedingGameClient != null) {
                log.warning("Received StartFeeding message while already in game");
            } else {
                _feedingGameClient = FeedingGameClient.create( gameId, new FeedingPlayerData(), onGameComplete);

                modeSprite.addChild(_feedingGameClient);
            }
        }
    }
    
    protected function onGameComplete () :void
    {
        log.info("Feeding complete");//, "completedSuccessfully", completedSuccessfully);
        modeSprite.removeChild(_feedingGameClient);
        ClientContext.ctrl.player.setAvatarState( VConstants.GAME_MODE_NOTHING );
        _feedingGameClient = null;
    }
    
//    override public function update( dt :Number ) :void
//    {
//        super.update( dt );
//        _thaneObjectDBForNonPlayers.update( dt );
//    }
        

    

        
        
    
    override protected function exit() :void
    {
        log.warning("!!! " + ClassUtil.tinyClassName(this) + "exiting.  Is this what we want??");
    }
    
    override protected function destroy() :void
    {
        subgame.shutdown();
//        _thaneObjectDBForNonPlayers.shutdown();
    }
    
    protected function changeAction( e :ChangeActionEvent ) :void
    {
        var action :String = e.action;
        
        var m :AppMode;
        
        switch( action ) {
//                case Constants.GAME_MODE_BLOODBOND:
//                     m = new BloodBondMode();
//                     break;
                 
             case VConstants.GAME_MODE_FEED_FROM_PLAYER:
                 m = new FeedMode();
                 break;
                   
             case VConstants.GAME_MODE_BARED:
                 m = new EatMeMode();
                 break;
                 
             case VConstants.GAME_MODE_FIGHT:
                 m = new FightMode();
                 break;
                     
//                 case Constants.GAME_MODE_HIERARCHY_AND_BLOODBONDS:
//                     m = new HierarchyMode();
//                     break;
                     
             default:
                 m = new NothingMode();
        }
        
        log.debug("current mode=" + ClassUtil.getClassName( subgame.ctx.mainLoop.topMode ) );
        log.debug("new mode=" + ClassUtil.getClassName( m ) );
        if( m !== subgame.ctx.mainLoop.topMode) {
            subgame.ctx.mainLoop.unwindToMode( m );
        }
        else{
            log.debug("Not changing mode because the mode is already on top, m=" + m);
        }
    }
    
    protected var subgame :SimpleGame;
    protected var _subgameSprite :Sprite;
    protected var _hud :HUD;
    
    protected var _feedingGameClient :FeedingGameClient;
    
//    protected var _thaneObjectDBForNonPlayers :ObjectDBThane;
    
    protected static const log :Log = Log.getLog( MainGameMode );
}
}