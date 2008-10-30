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
    import joingame.net.RegisterPlayerMessage;
    import joingame.net.ReplayConfirmMessage;
    import joingame.view.*;
    
    /**
     * The game does not start until all players click 'ready' or similar.  This screen 
     * can contain some simple instructions.  In addition, the game downloads the player states 
     * here, and does not go to the next mode until are is downloaded.
     */
    public class RegisterPlayerMode extends AppMode
    {
        protected static var log :Log = AppContext.log;
        
        override protected function setup ():void
        {
            log.debug("RegisterPlayerMode...");
            
            if( !AppContext.isConnected ) {
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
            _text.text = "Saying hello\nto the JoingameServer...";
    
            this.modeSprite.addChild(_text);
            AppContext.messageManager.addEventListener(ReplayConfirmMessage.NAME, handleReplayConfirm);
            
            AppContext.beginToShowInstructionsTime = getTimer();
            
            AppContext.messageManager.sendMessage(new RegisterPlayerMessage(AppContext.playerId));
            
            timer = new Timer(3000, 0);
            timer.addEventListener(TimerEvent.TIMER, tryAgain);
            timer.start();
        }
        
        
        protected function tryAgain( e :TimerEvent ) :void
        {
            if( AppContext.gameCtrl.isConnected()) {
                AppContext.messageManager.sendMessage(new RegisterPlayerMessage(AppContext.playerId));
            }
            else {
                //quit game
            }
        }
        
        /** Respond to messages from other clients. */
        public function handleReplayConfirm (event :ReplayConfirmMessage) :void
        {
            AppContext.messageManager.removeEventListener(ReplayConfirmMessage.NAME, handleReplayConfirm);
            GameContext.mainLoop.unwindToMode(new WaitingForPlayerDataModeAsPlayer());
        }
        
        
        override protected function destroy () :void
        {
            AppContext.messageManager.removeEventListener(ReplayConfirmMessage.NAME, handleReplayConfirm);
            timer.removeEventListener(TimerEvent.TIMER, tryAgain);
            if( timer.running ) { timer.stop(); }
            
            super.destroy();
        }
        
        override protected function exit () :void
        {
            AppContext.messageManager.removeEventListener(ReplayConfirmMessage.NAME, handleReplayConfirm);
            timer.removeEventListener(TimerEvent.TIMER, tryAgain);
            if( timer.running ) { timer.stop(); }
            
            super.exit();
        }
        
        protected var timer :Timer;
        protected var _bg :DisplayObject;
    }
}