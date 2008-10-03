package
{
    import com.threerings.util.*;
    import com.whirled.contrib.simplegame.*;
    import com.whirled.contrib.simplegame.resource.*;
    import com.whirled.game.*;
    import com.whirled.net.MessageReceivedEvent;
    
    import flash.display.Sprite;
    import flash.events.Event;
    
    import joingame.*;
    import joingame.model.JoinGameModel;
    import joingame.modes.*;
    
    
    [SWF(width="700", height="500", frameRate="30")]
    public class JoinGame extends Sprite
    {
        
        public function JoinGame()
        {
            AppContext.mainSprite = this;

            // setup GameControl
            AppContext.gameCtrl = new GameControl(this, true);
            var isConnected :Boolean = AppContext.gameCtrl.isConnected();
            
            graphics.clear();
            this.graphics.beginFill(0);
            this.graphics.drawRect(0, 0, 700, 500);
            this.graphics.endFill();
    
    
    
            this.addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);
            
            if(!isConnected) {
                return;
            }
            
            /*Disable the "Request Rematch" button*/
            AppContext.gameCtrl.local.setShowReplay(false)
            
            // setup main loop
            AppContext.mainLoop = new MainLoop(this, (isConnected ? AppContext.gameCtrl.local : this.stage));
            AppContext.mainLoop.setup();
    
            Constants.isMultiplayer = AppContext.gameCtrl.game.seating.getPlayerIds().length > 1;
            AppContext.isObserver = !ArrayUtil.contains(AppContext.gameCtrl.game.seating.getPlayerIds(), AppContext.gameCtrl.game.getMyId());
            
            if(AppContext.isObserver) {
                AppContext.mainLoop.pushMode(new WaitingForPlayerDataModeAsObserver());
            }
            else if(Constants.isMultiplayer) {
                AppContext.mainLoop.pushMode(new RegisterPlayerMode());
            }
            else {
                AppContext.mainLoop.pushMode(new SinglePlayerIntroMode());
            }
        
            AppContext.mainLoop.pushMode(new LoadingMode());
            AppContext.mainLoop.run();
            
        }


        
        /** Respond to messages from other clients. */
        public function messageReceived (event :MessageReceivedEvent) :void
        {
            AppContext.gameCtrl.local.feedback("\nPlayer " + AppContext.myid + ", JoinGame, messageReceived " + event.name);
            if (event.name == Server.MODEL_CONFIRM)
            {
                AppContext.gameCtrl.net.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
                
                GameContext.gameModel = new JoinGameModel( AppContext.gameCtrl);
                GameContext.gameModel.setModelMemento( event.value[0] as Array );
                
                AppContext.mainLoop.unwindToMode(new ObserverMode());
            }
            
            
        }

        

        /**
         * This is called when your game is unloaded.
         */
        protected function handleUnload (event :Event) :void
        {
            // stop any sounds, clean up any resources that need it
            AppContext.mainLoop.shutdown();
        }
        
        
        
    }
    

}