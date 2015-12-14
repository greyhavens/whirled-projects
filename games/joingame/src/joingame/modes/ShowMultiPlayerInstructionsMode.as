package joingame.modes
{
    import com.threerings.util.*;
    import com.whirled.contrib.simplegame.*;
    import com.whirled.contrib.simplegame.audio.*;
    import com.whirled.contrib.simplegame.net.*;
    import com.whirled.contrib.simplegame.resource.*;
    import com.whirled.contrib.simplegame.util.*;
    import com.whirled.game.*;
    import com.whirled.net.MessageReceivedEvent;
    
    import flash.display.DisplayObject;
    import flash.events.TimerEvent;
    import flash.text.TextField;
    import flash.utils.Timer;
    import flash.utils.getTimer;
    
    import joingame.*;
    import joingame.model.*;
    import joingame.net.AllPlayersReadyMessage;
    import joingame.net.JoinGameMessage;
    import joingame.net.PlayerReceivedGameStateMessage;
    import joingame.net.StartPlayMessage;
    import joingame.view.*;
    
    /**
     * The game does not start until all players click 'ready' or similar.  This screen 
     * can contain some simple instructions.  In addition, the game downloads the player states 
     * here, and does not go to the next mode until are is downloaded.
     */
    public class ShowMultiPlayerInstructionsMode extends JoinGameMode
    {
        private static const log :Log = Log.getLog(ShowMultiPlayerInstructionsMode);
        
        override protected function enter ():void
        {
            log.debug(ClassUtil.shortClassName(ShowMultiPlayerInstructionsMode) + " enter()");
            
            _bg = ImageResource.instantiateBitmap("INSTRUCTIONS");
            
            if(_bg != null) {
                _modeSprite.addChild(_bg);
            }
            else {
                trace("!!!!!Background is null!!!");
            }
            
            var _text :TextField = new TextField();
            _text.selectable = false;
            _text.textColor = 0xFFFFFF;
            _text.x = 550;
            _text.y = 400;
            _text.text = "Waiting for other\nplayers to check in...";
    
            this.modeSprite.addChild(_text);
            AppContext.messageManager.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            
            /* Double check that we are a player, and not a player theat became an observer */
//            AppContext.messageManager.sendMessageToServer(JoingameServer.PLAYER_READY, {});
            
            _readyToStart = true;
            _startTimer = new Timer(1000, 0);
            _startTimer.addEventListener(TimerEvent.TIMER, timerEvent);
            _startTimer.start();
        }
        
        protected function timerEvent (event :TimerEvent) :void
        {
            if(true || _readyToStart && (getTimer() - AppContext.beginToShowInstructionsTime) >= Constants.TIME_TO_SHOW_INSTRUCTIONS) {
                _startTimer.removeEventListener(TimerEvent.TIMER, timerEvent);
                _startTimer.stop();
                fadeOutToMode( new PlayPuzzleMode() );
//                GameContext.mainLoop.unwindToMode(new PlayPuzzleMode());    
            }
            
        }
        
        
        /** Respond to messages from other clients. */
        protected function handleAllPlayersReady (event :AllPlayersReadyMessage) :void
        {
        
            trace("WaitingForReadyPlayersMode JoingameServer.ALL_PLAYERS_READY for player " + AppContext.gameCtrl.game.getMyId());
            GameContext.gameModel = new JoinGameModel( AppContext.gameCtrl);
            GameContext.gameModel.setModelMemento( event.model );
            
            AppContext.messageManager.sendMessage(new PlayerReceivedGameStateMessage(AppContext.playerId));
                
        }
        
        /** Respond to messages from other clients. */
        protected function handleStartPlay (event :StartPlayMessage) :void
        {
            _readyToStart = true;
            timerEvent(null);
        }
        
        
        
        
        /** Respond to messages from other clients. */
        protected function messageReceived (event :MessageReceivedEvent) :void
        {
            log.debug(event.name + " " + JoinGameMessage(event.value).name);
            if (event.value is AllPlayersReadyMessage) {
                handleAllPlayersReady( AllPlayersReadyMessage(event.value) );
            }
            else if (event.value is StartPlayMessage) {
                handleStartPlay( StartPlayMessage(event.value) );
            }
        }
        
        
        override protected function exit () :void
        {
            AppContext.messageManager.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            super.exit();
        }
        
        
        protected var _bg :DisplayObject;
        protected var _readyToStart :Boolean;
        protected var _startTimer :Timer;
        
    }
}