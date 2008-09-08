package joingame.modes
{
    import com.threerings.flash.SimpleTextButton;
    import com.whirled.contrib.simplegame.AppMode;
    import com.whirled.game.NetSubControl;
    import com.whirled.net.MessageReceivedEvent;
    
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    import joingame.*;
    import joingame.model.*;
    
    /**
     * The game does not start until all players click 'ready' or similar.  This screen 
     * can contain some simple instructions.  In addition, the game downloads the player states 
     * here, and does not go to the next mode until are is downloaded.
     */
    public class WaitingForReadyPlayersMode extends AppMode
    {
        override protected function setup ():void
        {
//            _playersReady = new Array();
            _button = new SimpleTextButton("Waiting for player data!");
            _modeSprite.addChild(_button);
            _button.addEventListener(MouseEvent.CLICK, playerReady);
            _button.x = 100;
            _button.y = 100;
            
            AppContext.gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
//            _timer.addEventListener(TimerEvent.TIMER, timerListener);
//            _timer.start();
            
            playerReady(null);
            
        }
        
        private function playerReady(event:MouseEvent):void
        {
            AppContext.gameCtrl.net.sendMessage(Server.PLAYER_READY, {}, NetSubControl.TO_SERVER_AGENT);
        }
        
        /** Respond to messages from other clients. */
        public function messageReceived (event :MessageReceivedEvent) :void
        {
            
            if (event.name == Server.ALL_PLAYERS_READY)
            {
//                trace("WaitingForReadyPlayersMode Server.ALL_PLAYERS_READY for player " + AppContext.gameCtrl.game.getMyId());
                GameContext.gameState = new JoinGameModel( AppContext.gameCtrl);
                GameContext.gameState.setModelMemento( event.value[0] as Array );
                
                AppContext.gameCtrl.net.sendMessage(Server.PLAYER_RECEIVED_START_GAME_STATE, {}, NetSubControl.TO_SERVER_AGENT);
            }
            else if (event.name == Server.START_PLAY)
            {
//                trace("WaitingForReadyPlayersMode Server.START_PLAY for player " + AppContext.gameCtrl.game.getMyId());
                AppContext.mainLoop.unwindToMode(new PlayPuzzleMode());
            }
        }
        
        override protected function destroy () :void
        {
//            _timer.removeEventListener(TimerEvent.TIMER, timerListener);
//            _timer.stop();
            _button.removeEventListener(MouseEvent.CLICK, playerReady);
            AppContext.gameCtrl.net.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            super.destroy();
            
        }
        
        private function timerListener(e:TimerEvent):void
        {
            playerReady(null);
        }
        
//        private var _playersReady:Array;
        private var _button: SimpleTextButton;
        
//        private var _timer: Timer = new Timer(3000);//Ping the server every few seconds
    }
}