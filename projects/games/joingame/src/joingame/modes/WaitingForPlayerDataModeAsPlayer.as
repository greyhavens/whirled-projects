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
    import joingame.view.*;
    
    /**
     * The game does not start until all players click 'ready' or similar.  This screen 
     * can contain some simple instructions.  In addition, the game downloads the player states 
     * here, and does not go to the next mode until are is downloaded.
     */
    public class WaitingForPlayerDataModeAsPlayer extends AppMode
    {
        override protected function setup ():void
        {
            if( !AppContext.gameCtrl.isConnected() ) {
                return;
            }
            
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
            AppContext.gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            
            
            
            /* Double check that we are a player, and not a player theat became an observer */
            AppContext.gameCtrl.net.sendMessage(Server.PLAYER_READY, {}, NetSubControl.TO_SERVER_AGENT);
            
            _readyToStart = false;
            _startTimer = new Timer(1000, 0);
            _startTimer.addEventListener(TimerEvent.TIMER, timerEvent);
            _startTimer.start();
        }
        
        public function timerEvent (event :TimerEvent) :void
        {
            if(_readyToStart && (getTimer() - AppContext.beginToShowInstructionsTime) >= Constants.TIME_TO_SHOW_INSTRUCTIONS) {
                _startTimer.removeEventListener(TimerEvent.TIMER, timerEvent);
                _startTimer.stop();
                AppContext.mainLoop.unwindToMode(new PlayPuzzleMode());    
            }
            
        }
        
        
        
        /** Respond to messages from other clients. */
        public function messageReceived (event :MessageReceivedEvent) :void
        {
            
            if (event.name == Server.ALL_PLAYERS_READY)
            {
                trace("WaitingForReadyPlayersMode Server.ALL_PLAYERS_READY for player " + AppContext.gameCtrl.game.getMyId());
                GameContext.gameModel = new JoinGameModel( AppContext.gameCtrl);
                GameContext.gameModel.setModelMemento( event.value[0] as Array );
                
                AppContext.gameCtrl.net.sendMessage(Server.PLAYER_RECEIVED_START_GAME_STATE, {}, NetSubControl.TO_SERVER_AGENT);
                
            }
            else if (event.name == Server.START_PLAY)
            {
                _readyToStart = true;
                timerEvent(null);
            }
        }
        
        
        override protected function destroy () :void
        {
            AppContext.gameCtrl.net.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            super.destroy();
        }
        
        protected var _bg :DisplayObject;
        protected var _readyToStart :Boolean;
        protected var _startTimer :Timer;
        
    }
}