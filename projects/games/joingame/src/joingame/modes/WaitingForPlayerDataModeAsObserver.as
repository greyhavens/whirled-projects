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
    
    import flash.events.TimerEvent;
    import flash.text.TextField;
    import flash.utils.Timer;
    
    import joingame.*;
    import joingame.model.*;
    import joingame.view.*;
    
    /**
     * As an observer we need the current game state.
     */
    public class WaitingForPlayerDataModeAsObserver extends AppMode
    {
        override protected function setup ():void
        {
            if( !AppContext.gameCtrl.isConnected() ) {
                return;
            }
            
            _requestGameStateTimer = new Timer(5000, 0);
            _requestGameStateTimer.addEventListener(TimerEvent.TIMER, timer);
            _requestGameStateTimer.start();
            
            
            var _text :TextField = new TextField();
            _text.selectable = false;
//            _text.autoSize = TextFieldAutoSize.CENTER;
            _text.textColor = 0xFFFFFF;
            _text.scaleX = 2;
            _text.scaleY = 2;
            _text.width = 300;
            _text.x = 50;
            _text.y = 50;
            _text.text = "Waiting for player data...";
    
            this.modeSprite.addChild(_text);
            AppContext.gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            
            AppContext.gameCtrl.net.sendMessage(Server.MODEL_REQUEST, {}, NetSubControl.TO_SERVER_AGENT);
        }
        
        
        protected function timer( e :TimerEvent) :void
        {
            trace("Player " + AppContext.myid + ", Resending game model request");
            if( AppContext.gameCtrl.isConnected() ) {
                AppContext.gameCtrl.net.sendMessage(Server.MODEL_REQUEST, {}, NetSubControl.TO_SERVER_AGENT);
            }
        }
        
        /** Respond to messages from other clients. */
        public function messageReceived (event :MessageReceivedEvent) :void
        {
            trace("\nPlayer " + AppContext.myid + ", WaitingForPlayerDataModeAsObserver, messageReceived " + event.name);
            if (event.name == Server.MODEL_CONFIRM)
            {
//                AppContext.gameCtrl.local.feedback("observer starting game (Observer Mode)");
                GameContext.gameState = new JoinGameModel( AppContext.gameCtrl);
                GameContext.gameState.setModelMemento( event.value[0] as Array );
                
                AppContext.mainLoop.unwindToMode(new ObserverMode());
            }
        }
        
        
        override protected function destroy () :void
        {
            AppContext.gameCtrl.net.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            _requestGameStateTimer.removeEventListener(TimerEvent.TIMER, timer);
            _requestGameStateTimer.stop();
            super.destroy();
        }
        
        
        protected var _requestGameStateTimer :Timer;
    }
}