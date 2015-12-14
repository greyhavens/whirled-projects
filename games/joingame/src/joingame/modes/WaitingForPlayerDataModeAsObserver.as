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
    
    import joingame.*;
    import joingame.model.*;
    import joingame.net.ModelRequestMessage;
    import joingame.view.*;
    
    /**
     * As an observer we need the current game state.
     */
    public class WaitingForPlayerDataModeAsObserver extends JoinGameMode
    {
        protected static var log :Log = Log.getLog(WaitingForPlayerDataModeAsObserver);
        
        override protected function setup ():void
        {
            log.debug("WaitingForPlayerDataModeAsObserver...");
            
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
            _text.text = "Waiting for\nplayer data...";
    
            this.modeSprite.addChild(_text);
            
            AppContext.isObserver = true;
            
            
            if(GameContext.gameModel != null) {
                GameContext.gameModel.removeAllPlayers();
            }
            else {
                GameContext.gameModel = new JoinGameModel(AppContext.gameCtrl);
            }
            GameContext.gameModel.getModelFromPropertySpaces();
            GameContext.mainLoop.unwindToMode(new ObserverMode());
            
        }
        
        
//        protected function timer( e :TimerEvent) :void
//        {
////            trace("Player " + AppContext.myid + ", Resending game model request");
//            if( AppContext.gameCtrl.isConnected() ) {
//                AppContext.messageManager.sendMessage(new ModelRequestMessage(AppContext.playerId));
//            }
//        }
//        
//        /** Respond to messages from other clients. */
//        public function messageReceived (event :MessageReceivedEvent) :void
//        {
//            if (event.name == JoingameServer.MODEL_CONFIRM)
//            {
//                GameContext.gameModel = new JoinGameModel( AppContext.gameCtrl);
//                GameContext.gameModel.setModelMemento( event.value[0] as Array );
//                GameContext.mainLoop.unwindToMode(new ObserverMode());
//            }
//            
//            
//        }
        
        
        override protected function destroy () :void
        {
//            AppContext.gameCtrl.net.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            super.destroy();
        }
        
        override protected function exit () :void
        {
//            AppContext.gameCtrl.net.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            super.exit();
        }
        
        
        protected var _requestGameStateTimer :Timer;
        protected var _bg :DisplayObject;
    }
}