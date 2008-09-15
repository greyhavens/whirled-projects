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
    
    import flash.text.TextField;
    
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
            
            
            var _text :TextField = new TextField();
            _text.selectable = false;
//            _text.autoSize = TextFieldAutoSize.CENTER;
            _text.textColor = 0xFFFFFF;
            _text.scaleX = 2;
            _text.scaleY = 2;
            _text.width = 300;
            _text.x = 50;
            _text.y = 50;
            _text.text = "Saying hello to the server...";
    
            this.modeSprite.addChild(_text);
            AppContext.gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            
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
            super.destroy();
        }
        
    }
}