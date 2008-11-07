package
{
    import com.threerings.util.*;
    import com.whirled.contrib.simplegame.*;
    import com.whirled.contrib.simplegame.resource.*;
    import com.whirled.game.*;
    
    import flash.display.Sprite;
    import flash.events.Event;
    
    import joingame.*;
    import joingame.modes.*;
    import joingame.net.JoinMessageManagerClient;
    
    
    [SWF(width="700", height="500", frameRate="30")]
    public class JoinGame extends Sprite
    {
        
        public function JoinGame()
        {
            Log.setLevel("", Log.INFO);
//            Log.setLevel(ClassUtil.getClassName(JoinGameBoardsView), Log.DEBUG);
//            Log.setLevel(ClassUtil.getClassName(SinglePlayerServerPlugin), Log.DEBUG);
//            Log.setLevel(ClassUtil.getClassName(JoingameServer), Log.DEBUG);

//            Log.setLevel(ClassUtil.getClassName(JoinGameBoardRepresentation), Log.DEBUG);
//            Log.setLevel(ClassUtil.getClassName(JoinGameBoardGameArea), Log.DEBUG);
//            Log.setLevel(ClassUtil.getClassName(JoinGameBoardsView), Log.DEBUG);
            
            GameContext.mainSprite = this;

            // setup GameControl
            AppContext.gameCtrl = new GameControl(this, true);
            
            AppContext.isConnected = AppContext.gameCtrl.isConnected();
            
            graphics.clear();
            graphics.beginFill(0);
            graphics.drawRect(0, 0, 700, 500);
            graphics.endFill();
            
            
            
            if(!AppContext.isConnected && !Constants.LOCAL_MODE) {
                log.error("No connection, and it's not local, so poop, I'm leaving");
                return;
            }
            
            this.addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);
            
            if( Constants.LOCAL_MODE ) { 
                
                AppContext.messageManager = new JoinMessageManagerClient();
                AppContext.useServerAgent = false;
                AppContext.playerId = 100;
                
                AppContext.localServer = new JoingameServer(AppContext.gameCtrl);//AppContext.gameCtrl
                
                // setup main loop
                GameContext.mainLoop = new MainLoop(this,  this.stage);
                GameContext.mainLoop.setup();
                
                AppContext.isMultiplayer = false;
                AppContext.isObserver = false;
                
                GameContext.mainLoop.pushMode(new SinglePlayerIntroMode());
            }
            else {
                
                AppContext.playerId = AppContext.gameCtrl.game.getMyId();
                /*Disable the "Request Rematch" button*/
                AppContext.gameCtrl.local.setShowReplay(false);
                
                // setup main loop
                GameContext.mainLoop = new MainLoop(this, (AppContext.isConnected ? AppContext.gameCtrl.local : this.stage));
                GameContext.mainLoop.setup();
        
                AppContext.isMultiplayer = AppContext.gameCtrl.game.seating.getPlayerIds().length > 1;
                AppContext.useServerAgent = AppContext.isMultiplayer;
                AppContext.messageManager = new JoinMessageManagerClient( (AppContext.useServerAgent ? AppContext.gameCtrl : null) );
                
                if( !AppContext.useServerAgent ) {
                    AppContext.localServer = new JoingameServer(AppContext.gameCtrl);
                }
                
                AppContext.isObserver = !ArrayUtil.contains(AppContext.gameCtrl.game.seating.getPlayerIds(), AppContext.gameCtrl.game.getMyId());
                
                if(AppContext.isObserver) {
                    GameContext.mainLoop.pushMode(new WaitingForPlayerDataModeAsObserver());
                }
                else if(AppContext.isMultiplayer) {
                    GameContext.mainLoop.pushMode(new ShowMultiPlayerInstructionsMode());
                    GameContext.mainLoop.pushMode(new RegisterPlayerMode());
                }
                else {
                    GameContext.mainLoop.pushMode(new SinglePlayerIntroMode());
                }
            }
        
            GameContext.mainLoop.pushMode(new LoadingMode());
            GameContext.mainLoop.run();
            
        }


//        
//        /** Respond to messages from other clients. */
//        public function messageReceived (event :MessageReceivedEvent) :void
//        {
//            AppContext.gameCtrl.local.feedback("\nPlayer " + AppContext.myid + ", JoinGame, messageReceived " + event.name);
//            if (event.name == JoingameServer.MODEL_CONFIRM)
//            {
//                AppContext.gameCtrl.net.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
//                
//                GameContext.gameModel = new JoinGameModel( AppContext.gameCtrl);
//                GameContext.gameModel.setModelMemento( event.value[0] as Array );
//                
//                GameContext.mainLoop.unwindToMode(new ObserverMode());
//            }
//            
//            
//        }

        

        /**
         * This is called when your game is unloaded.
         */
        protected function handleUnload (event :Event) :void
        {
            // stop any sounds, clean up any resources that need it
            GameContext.mainLoop.shutdown();
            this.removeEventListener(Event.REMOVED_FROM_STAGE, handleUnload);
        }
        
        public static const log :Log = Log.getLog(JoinGame);
        
    }
    

}