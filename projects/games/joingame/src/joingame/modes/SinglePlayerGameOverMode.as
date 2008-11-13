package joingame.modes
{
    import com.threerings.flash.SimpleTextButton;
    import com.threerings.util.Log;
    import com.whirled.contrib.simplegame.objects.SceneObject;
    import com.whirled.contrib.simplegame.objects.SimpleSceneObject;
    import com.whirled.contrib.simplegame.resource.ImageResource;
    import com.whirled.contrib.simplegame.resource.ResourceManager;
    import com.whirled.contrib.simplegame.resource.SwfResource;
    import com.whirled.contrib.simplegame.tasks.LocationTask;
    import com.whirled.net.MessageReceivedEvent;
    
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    import flash.filters.ColorMatrixFilter;
    
    import joingame.AppContext;
    import joingame.GameContext;
    import joingame.model.JoinGameModel;
    import joingame.net.InternalJoinGameEvent;
    import joingame.net.JoinGameMessage;
    import joingame.net.ReplayConfirmMessage;
    import joingame.net.ReplayRequestMessage;

    public class SinglePlayerGameOverMode extends JoinGameMode
    {
        protected static var log :Log = Log.getLog(SinglePlayerGameOverMode);
        protected var _bg :DisplayObject;
        
        
        /*This variable represents the entire game state */
        protected var _gameModel: JoinGameModel;
        
        protected var _out_placer :MovieClip;
        protected var _marquee_placer :MovieClip;
        protected var _marqueeClass :Class;
        
        protected var _myColorMatrix_filter :ColorMatrixFilter;
        protected var _startButton :SimpleSceneObject;
        
        protected var _winnerClip :SceneObject;
        
        override protected function setup() :void
        {
            super.setup();
            fadeIn();
        }
        
        
        override protected function enter() :void
        {
            log.debug("Player " + AppContext.playerId + ", SinglePlayerGameOverMode...");
            
            AppContext.messageManager.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            
            _bg = ImageResource.instantiateBitmap("BG_watcher");
            if(_bg != null) {
                _modeLayer.addChild(_bg);
                AppContext.gameWidth = _bg.width;
                AppContext.gameHeight = _bg.height;
            }
            else {
                trace("!!!!!Background is null!!!");
            }
            
            var swfRoot :MovieClip = MovieClip(SwfResource.getSwfDisplayRoot("UI"));
            _modeLayer.addChild(swfRoot);
            
            _out_placer = MovieClip(swfRoot["out_placer"]);
            _marquee_placer = MovieClip(swfRoot["marquee_placer"]);
            
            var swf :SwfResource = (ResourceManager.instance.getResource("UI") as SwfResource);
            _marqueeClass = swf.getClass("marquee");
            var tempMarquee :MovieClip = new _marqueeClass();
            
            var winnerClass :Class = swf.getClass("winner");
            var _winnerClipMovieClip :MovieClip = new winnerClass();
            
            _winnerClip = new SimpleSceneObject( _winnerClipMovieClip );
            addObject( _winnerClip, _modeLayer);
            _winnerClip.x = AppContext.gameWidth/2;
            _winnerClip.y = -100;
            
            
            var replayButtonClass :Class = swf.getClass("replay_button");
            
            var startButtonMovieClip :MovieClip = new replayButtonClass();
            startButtonMovieClip.mouseEnabled = true;
            startButtonMovieClip.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
            startButtonMovieClip.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
            startButtonMovieClip.addEventListener(MouseEvent.CLICK, mouseClicked);
            startButtonMovieClip.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
            
            _startButton = new SimpleSceneObject( startButtonMovieClip );
            _startButton.x = AppContext.gameWidth/2;
            _startButton.y = -100;
            
            
            var mainMenuButton :SimpleTextButton = new SimpleTextButton("Main Menu");
            mainMenuButton.x = 50;
            mainMenuButton.y = 50;
            mainMenuButton.addEventListener(MouseEvent.CLICK, doMainMenuButtonClick);
            _modeLayer.addChild( mainMenuButton );
         
            
            
            addObject( _startButton, _modeLayer);
            
            var myElements_array:Array = [2,0,0,0,-13.5,0,2,0,0,-13.5,0,0,2,0,-13.5,0,0,0,1,0];
            _myColorMatrix_filter = new ColorMatrixFilter(myElements_array);
            
            gameOver();
            
        }
        
        
        
        protected function doMainMenuButtonClick (event :MouseEvent) :void
        {
            fadeOutToMode( new SinglePlayerIntroMode() );
//            GameContext.mainLoop.unwindToMode( new SinglePlayerIntroMode());
        }
        
        protected function messageReceived (event :MessageReceivedEvent) :void
        {
            log.debug(event.name + " " + JoinGameMessage(event.value).name);
            if (event.value is ReplayConfirmMessage) {
                handleReplayConfirm( ReplayConfirmMessage(event.value) );
            }
        }
        
        protected function gameOver( e :InternalJoinGameEvent = null) :void
        {
//            _winnerClip.addTask( LocationTask.CreateEaseOut( _winnerClip.x, 200, 1.0));
//            _modeLayer.setChildIndex( _winnerClip.displayObject, _modeLayer.numChildren - 1);
//            AudioManager.instance.playSoundNamed("final_applause");
            
            _startButton.addTask( LocationTask.CreateEaseOut( _winnerClip.x, 242, 1.0));
            _modeLayer.setChildIndex( _startButton.displayObject, _modeLayer.numChildren - 1);
                
        }
        
        override protected  function exit() :void
        {
            AppContext.messageManager.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
        }
        
        private function mouseClicked( event:MouseEvent ) :void
        {
            _startButton.y -= 4;
            log.debug("sending " + ReplayRequestMessage.NAME );
            AppContext.messageManager.sendMessage(new ReplayRequestMessage(AppContext.playerId, GameContext.playerCookieData, GameContext.requestedSinglePlayerLevel));
        }
        
        private function mouseOver( event:MouseEvent ) :void
        {
            _startButton.displayObject.filters = [_myColorMatrix_filter];
        }
        
        private function mouseOut( event:MouseEvent ) :void 
        {
            _startButton.displayObject.filters = [];
        }
        
        private function mouseDown( event:MouseEvent ) :void 
        {
            _startButton.y += 4;
        }
        
        
        /** Respond to messages from the JoingameServer. */
        protected function handleReplayConfirm (event :ReplayConfirmMessage) :void
        {
            log.debug("handleReplayConfirm()");
            GameContext.gameModel.setModelMemento( event.modelMemento );
            log.debug("  players=" + GameContext.gameModel.currentSeatingOrder);
            fadeOutToMode( new PlayPuzzleMode() );
//            GameContext.mainLoop.unwindToMode(new PlayPuzzleMode());
        }
    }
}