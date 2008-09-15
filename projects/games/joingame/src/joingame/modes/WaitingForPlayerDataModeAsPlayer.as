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
    public class WaitingForPlayerDataModeAsPlayer extends AppMode
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
            _text.text = "Waiting for other players to check in...";
    
            this.modeSprite.addChild(_text);
            AppContext.gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            
            /* Double check that we are a player, and not a player theat became an observer */
            AppContext.gameCtrl.net.sendMessage(Server.PLAYER_READY, {}, NetSubControl.TO_SERVER_AGENT);
            
        }
        
        
        /** Respond to messages from other clients. */
        public function messageReceived (event :MessageReceivedEvent) :void
        {
            
            if (event.name == Server.ALL_PLAYERS_READY)
            {
                trace("WaitingForReadyPlayersMode Server.ALL_PLAYERS_READY for player " + AppContext.gameCtrl.game.getMyId());
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
            AppContext.gameCtrl.net.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            super.destroy();
        }
        
    }
}