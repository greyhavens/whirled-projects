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
    public class RegisterPlayerMode extends AppMode
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
            _text.width = 300;
            _text.x = 550;
            _text.y = 400;
            _text.text = "Saying hello\nto the server...";
    
            this.modeSprite.addChild(_text);
            AppContext.gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            
            AppContext.beginToShowInstructionsTime = getTimer();
            
            AppContext.gameCtrl.net.sendMessage(Server.REGISTER_PLAYER, {}, NetSubControl.TO_SERVER_AGENT);
            
            timer = new Timer(3000, 0);
            timer.addEventListener(TimerEvent.TIMER, tryAgain);
            timer.start();
        }
        
        
        protected function tryAgain( e :TimerEvent ) :void
        {
            AppContext.gameCtrl.net.sendMessage(Server.REGISTER_PLAYER, {}, NetSubControl.TO_SERVER_AGENT);
        }
        
        /** Respond to messages from other clients. */
        public function messageReceived (event :MessageReceivedEvent) :void
        {
            
            if (event.name == Server.REPLAY_CONFIRM)
            {
                AppContext.mainLoop.unwindToMode(new WaitingForPlayerDataModeAsPlayer());
            }
        }
        
        
        override protected function destroy () :void
        {
            AppContext.gameCtrl.net.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            timer.removeEventListener(TimerEvent.TIMER, tryAgain);
            timer.stop();
            
            super.destroy();
        }
        
        protected var timer :Timer;
        protected var _bg :DisplayObject;
    }
}