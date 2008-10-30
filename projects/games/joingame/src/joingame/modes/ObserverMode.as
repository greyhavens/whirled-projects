package joingame.modes
{
    import com.threerings.util.*;
    import com.whirled.contrib.simplegame.*;
    import com.whirled.contrib.simplegame.audio.*;
    import com.whirled.contrib.simplegame.net.*;
    import com.whirled.contrib.simplegame.objects.*;
    import com.whirled.contrib.simplegame.resource.*;
    import com.whirled.contrib.simplegame.tasks.*;
    import com.whirled.contrib.simplegame.util.*;
    import com.whirled.game.*;
    import com.whirled.net.MessageReceivedEvent;
    
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.filters.ColorMatrixFilter;
    import flash.text.TextField;
    import flash.utils.Timer;
    import flash.utils.getTimer;
    
    import joingame.*;
    import joingame.model.*;
    import joingame.net.InternalJoinGameEvent;
    import joingame.net.ReplayConfirmMessage;
    import joingame.net.ReplayRequestMessage;
    import joingame.view.*;
    
    public class ObserverMode extends AppMode
    {
        protected static var log :Log = AppContext.log;
        
        override protected function setup () :void
        {
            log.debug("Player " + AppContext.myid + ",PlayPuzzleMode...");
            if(!AppContext.gameCtrl.isConnected()) {
                return;
            }
//            AppContext.gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            
            AppContext.messageManager.addEventListener(ReplayRequestMessage.NAME, handleReplayRequest);
            AppContext.messageManager.addEventListener(ReplayConfirmMessage.NAME, handleReplayConfirm);
            
            _modeSprite.mouseEnabled = false;
            
            
            
            
            _bg = ImageResource.instantiateBitmap("BG_watcher");
            if(_bg != null) {
                _modeSprite.addChild(_bg);
                AppContext.gameWidth = _bg.width;
                AppContext.gameHeight = _bg.height;
            }
            else {
                trace("!!!!!Background is null!!!");
            }
            
            var swfRoot :MovieClip = MovieClip(SwfResource.getSwfDisplayRoot("UI"));
            modeSprite.addChild(swfRoot);
            
            _out_placer = MovieClip(swfRoot["out_placer"]);
            _marquee_placer = MovieClip(swfRoot["marquee_placer"]);
            
            
            
            
            
            var swf :SwfResource = (ResourceManager.instance.getResource("UI") as SwfResource);
            _marqueeClass = swf.getClass("marquee");
            var tempMarquee :MovieClip = new _marqueeClass();
            
            
            Constants.GUI_OBSERVER_VIEW_GAP_BETWEEN_FLOOR_AND_BOARDS = (AppContext.gameHeight - _marquee_placer.y) + tempMarquee.height/2;
            
            var winnerClass :Class = swf.getClass("winner");
            var _winnerClipMovieClip :MovieClip = new winnerClass();
            
            _winnerClip = new SimpleSceneObject( _winnerClipMovieClip );
            addObject( _winnerClip, modeSprite);
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
            
            
            
            addObject( _startButton, modeSprite);
            
            var myElements_array:Array = [2,0,0,0,-13.5,0,2,0,0,-13.5,0,0,2,0,-13.5,0,0,0,1,0];
            _myColorMatrix_filter = new ColorMatrixFilter(myElements_array);
            
            _restartTimeTextField = new TextField();
            _restartTimeTextField.selectable = false;
            _restartTimeTextField.textColor = 0xFFFFFF;
            _restartTimeTextField.width = 10;
            _restartTimeTextField.x = 50;
            _restartTimeTextField.x = AppContext.gameWidth/2 - _restartTimeTextField.width/2;
            _restartTimeTextField.y = 258;
            _restartTimeTextField.text = "";
            _restartTimeTextField.visible = false;
            this.modeSprite.addChild( _restartTimeTextField );
            
            _gameRestartTimer = new Timer(1000, 0);
            _gameRestartTimer.addEventListener(TimerEvent.TIMER, gameTimer);
            _totalTimeElapsedSinceNewGameTimerStarted = 0;
        
        
            initGameData();
        }
        
        protected function gameTimer(  e :TimerEvent) :void
        {
            _totalTimeElapsedSinceNewGameTimerStarted++;
            _restartTimeTextField.text = "" + ( Constants.GAME_RESTART_TIME - _totalTimeElapsedSinceNewGameTimerStarted) ;
            _restartTimeTextField.visible = true;
            modeSprite.setChildIndex( _restartTimeTextField, modeSprite.numChildren - 1);
            if( _totalTimeElapsedSinceNewGameTimerStarted >  Constants.GAME_RESTART_TIME) {
                _restartTimeTextField.visible = false;
                _gameRestartTimer.stop();
                _totalTimeElapsedSinceNewGameTimerStarted = 0;
            }
        }
        
        protected function reset() :void
        {
            _winnerClip.y = -100;
            _startButton.y = -100;
            for each (var s :SceneObject in _id2HeadshotSceneObject.values()) {
                s.destroySelf();
            }
            
            for each ( s in _id2MarqueeSceneObject.values()) {
                s.destroySelf();
            }
            
            _id2HeadshotSceneObject.clear();
            _id2MarqueeSceneObject.clear();
            
            
            _gameRestartTimer.stop();
            _gameRestartTimer.reset();
            _restartTimeTextField.visible = false;
            _totalTimeElapsedSinceNewGameTimerStarted = 0;
            
            initGameData();
        }
        
        override protected function exit () :void
        {
//            AppContext.gameCtrl.net.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            AppContext.messageManager.removeEventListener(ReplayRequestMessage.NAME, handleReplayRequest);
            AppContext.messageManager.removeEventListener(ReplayConfirmMessage.NAME, handleReplayConfirm);
//            _gameRestartTimer.removeEventListener(TimerEvent.TIMER, gameTimer);
//            _gameRestartTimer.stop();
            if(_startButton != null) {
                
                var movieClip :MovieClip = _startButton.displayObject as MovieClip;
                movieClip.removeEventListener(MouseEvent.MOUSE_OVER, mouseOver);
                movieClip.removeEventListener(MouseEvent.MOUSE_OUT, mouseOut);
                movieClip.removeEventListener(MouseEvent.CLICK, mouseClicked);
                movieClip.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
            }
            if( _gameModel != null )
            {
                _gameModel.removeEventListener(InternalJoinGameEvent.PLAYER_REMOVED, animateHeadshotsToLocation);
                _gameModel.removeEventListener(InternalJoinGameEvent.GAME_OVER, gameOver);
            }
            
            super.exit();
        }
        
        
        protected function initGameData() :void 
        {
            
            
            if(_boardsView != null) {
                _boardsView.destroySelf();
            }
            
            if( _gameModel != null )
            {
                _gameModel.removeEventListener(InternalJoinGameEvent.PLAYER_REMOVED, animateHeadshotsToLocation);
                _gameModel.removeEventListener(InternalJoinGameEvent.GAME_OVER, gameOver);
            }
            
            _gameModel = GameContext.gameModel;
            
            
            _id2HeadshotSceneObject = new HashMap();
            _id2MarqueeSceneObject = new HashMap();
            
            for each (var id :int in _gameModel._initialSeatedPlayerIds) {
                var marquee :MovieClip = new _marqueeClass();
                var so2 :SimpleSceneObject = new SimpleSceneObject(marquee);
                _id2MarqueeSceneObject.put( id, so2);
                addObject( so2, modeSprite);
            }
            
            for each ( id in _gameModel._initialSeatedPlayerIds) {
                var headshot :DisplayObject = GameContext.getHeadshot(id);
                var so :SimpleSceneObject = new SimpleSceneObject(headshot);
                _id2HeadshotSceneObject.put(id, so);
                so.x = 10;
                so.y = 10;
                addObject( so, modeSprite);
            }
            
            
            _boardsView = new JoinGameBoardsView(GameContext.gameModel, AppContext.gameCtrl, true);
            addObject( _boardsView, _modeSprite);
            _boardsView.updateBoardDisplays();
            _gameModel.addEventListener(InternalJoinGameEvent.PLAYER_REMOVED, animateHeadshotsToLocation);
            _gameModel.addEventListener(InternalJoinGameEvent.GAME_OVER, gameOver);
            
            animateHeadshotsToLocation(null, 0);
            
            trace("Player " + AppContext.myid + ", ObserverMode, initGameData(), _gameModel.currentSeatingOrder=" + _gameModel.currentSeatingOrder);
            if(_gameModel.currentSeatingOrder.length == 1) {
                
                gameOver();
            }
        }
        
        
        
        /** Respond to messages from the JoingameServer. */
        protected function handleReplayRequest (event :ReplayRequestMessage) :void
        {
            /* This is simply mark the headshots of those that have 
            requested to play again */
            var id :int = event.playerId;
            var headshot :SceneObject = _id2HeadshotSceneObject.get(id) as SceneObject;
            if( headshot != null ) {
                headshot.displayObject.filters = [ _myColorMatrix_filter ];
            }
            _totalTimeElapsedSinceNewGameTimerStarted = 0;
            
        }
        
        /** Respond to messages from the JoingameServer. */
        protected function handleReplayConfirm (event :ReplayConfirmMessage) :void
        {
            var playerIdsAcceptedForNextGame :Array = event.currentActivePlayers;
                
            var keys :Array = _id2HeadshotSceneObject.keys();
            for each (var key :int in keys) {
                var headshot :SceneObject = _id2HeadshotSceneObject.get(key) as SceneObject;
                if( headshot != null ) {
                    headshot.displayObject.filters = [];
                }
            }

            if( ArrayUtil.contains( playerIdsAcceptedForNextGame, AppContext.gameCtrl.game.getMyId())) {  
                AppContext.beginToShowInstructionsTime = getTimer();
                GameContext.mainLoop.unwindToMode(new WaitingForPlayerDataModeAsPlayer());
            }
            else {
                AppContext.isObserver = true;//Now a permenent observer
                GameContext.gameModel.setModelMemento( event.modelMemento);
                reset();
            }
            
        }
        
//        
//        /** Respond to messages from the JoingameServer. */
//        public function messageReceived (event :MessageReceivedEvent) :void
//        {
//            var id :int;  
//            var headshot :SceneObject;          
//            /* This is simply mark the headshots of those that have 
//                requested to play again */
//            if (event.name == JoingameServer.REPLAY_REQUEST)
//            {
//                id = event.senderId;
//                headshot = _id2HeadshotSceneObject.get(id) as SceneObject;
//                if( headshot != null ) {
//                    headshot.displayObject.filters = [ _myColorMatrix_filter ];
//                }
//                _totalTimeElapsedSinceNewGameTimerStarted = 0;
//            }
//            else if (event.name == JoingameServer.REPLAY_CONFIRM)
//            {
//                var playerIdsAcceptedForNextGame :Array = event.value[0] as Array;
//                
//                var keys :Array = _id2HeadshotSceneObject.keys();
//                for each (var key :int in keys) {
//                    headshot = _id2HeadshotSceneObject.get(key) as SceneObject;
//                    if( headshot != null ) {
//                        headshot.displayObject.filters = [];
//                    }
//                }
//
//                if( ArrayUtil.contains( playerIdsAcceptedForNextGame, AppContext.gameCtrl.game.getMyId())) {  
//                    AppContext.beginToShowInstructionsTime = getTimer();
//                    GameContext.mainLoop.unwindToMode(new WaitingForPlayerDataModeAsPlayer());
//                }
//                else {
//                    AppContext.isObserver = true;//Now a permenent observer
//                    GameContext.gameModel.setModelMemento( event.value[1] as Array);
//                    reset();
//                }
//            }
//            
//        }
        
        private function mouseClicked( event:MouseEvent ) :void
        {
            _startButton.y -= 4;
            AppContext.messageManager.sendMessage(new ReplayRequestMessage(AppContext.playerId), NetSubControl.TO_ALL);
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
        
        
        protected function gameOver( e :InternalJoinGameEvent = null) :void
        {
            _winnerClip.addTask( LocationTask.CreateEaseOut( _winnerClip.x, 200, 1.0));
            modeSprite.setChildIndex( _winnerClip.displayObject, modeSprite.numChildren - 1);
            AudioManager.instance.playSoundNamed("final_applause");
            
            if(!AppContext.isObserver && AppContext.gameCtrl.isConnected() && GameContext.gameModel.potentialPlayerIds.length > 1) {
                _startButton.addTask( LocationTask.CreateEaseOut( _winnerClip.x, 242, 1.0));
                modeSprite.setChildIndex( _startButton.displayObject, modeSprite.numChildren - 1);
                
//                _gameRestartTimer.reset();
//                _gameRestartTimer.start(); 
            }
        }
        
        protected function animateHeadshotsToLocation( e :InternalJoinGameEvent, animationDuration :Number = Constants.HEADSHOT_MOVEMENT_TIME) :void
        {
            
            var scaleTask: ScaleTask;
            var moveTask :LocationTask;
            var parallelTask :ParallelTask;
            var id :int;
            var toX :int;
            var toY :int;
            
            var boardWidth :int = Constants.PUZZLE_TILE_SIZE * Constants.PUZZLE_STARTING_COLS;
            var availableHorizontalSpaceForBoards :Number = AppContext.gameWidth - 2*Constants.GUI_OBSERVER_VIEW_GAP_BETWEEN_BORDER_AND_BOARDS;
            var playerCount :int = _gameModel.currentSeatingOrder.length;
            var boardScale :Number = ((availableHorizontalSpaceForBoards - (Constants.GUI_OBSERVER_VIEW_GAP_BETWEEN_BOARDS * playerCount  + 1))/ playerCount) / boardWidth;
            boardScale = Math.min(0.7, boardScale);
            var actualBoardWidth :int = boardWidth * boardScale;
            var totalWidthOfAllBoards :int = actualBoardWidth * playerCount + Constants.GUI_OBSERVER_VIEW_GAP_BETWEEN_BOARDS * (playerCount - 1);
            var adjustedXOffset :int = (availableHorizontalSpaceForBoards - totalWidthOfAllBoards)/2;
            var currentXPosition :int = Constants.GUI_OBSERVER_VIEW_GAP_BETWEEN_BORDER_AND_BOARDS + adjustedXOffset;
            
            var headshot :SceneObject;
            var marquee :SceneObject;
            for each ( id in _gameModel.currentSeatingOrder) {
                
                marquee = _id2MarqueeSceneObject.get(id) as SceneObject;
                
                marquee.scaleX = 1.0;
                marquee.scaleY = 1.0;
                var marqueeScale :Number = actualBoardWidth / marquee.width as Number;
                marqueeScale = Math.min(  marqueeScale, 1.0);
                
                marquee.scaleX = marqueeScale;
                marquee.scaleY = marqueeScale;
                
                headshot = _id2HeadshotSceneObject.get(id) as SceneObject;
                headshot.scaleX = marqueeScale;
                headshot.scaleY = marqueeScale;
                
                
                
                
                toX = currentXPosition + actualBoardWidth/2 - headshot.width/2;
                toY = _marquee_placer.y - headshot.height/2;
                
                moveTask = LocationTask.CreateEaseOut(toX, toY, animationDuration);
                headshot.addTask( moveTask );
                modeSprite.setChildIndex( headshot.displayObject, modeSprite.numChildren - 1); 
                
                toX = toX + headshot.width/2;
                toY = toY + headshot.height/2;
                
                moveTask = LocationTask.CreateEaseOut(toX, toY, animationDuration);
                marquee.addTask( moveTask ); 
                
                currentXPosition +=  actualBoardWidth + Constants.GUI_OBSERVER_VIEW_GAP_BETWEEN_BOARDS;
            }
            
            var oustedPlayerCount :int = _gameModel._playerIdsInOrderOfLoss.length;
            var headshotScale :Number = ((availableHorizontalSpaceForBoards - (Constants.GUI_OBSERVER_VIEW_GAP_BETWEEN_HEADSHOTS * oustedPlayerCount  + 1))/ oustedPlayerCount) / boardWidth;
            headshotScale = Math.min(Constants.GUI_OBSERVER_VIEW_MAX_OUSTED_PLAYER_HEADSHOT_SCALE, headshotScale);
            var actualHeadshotWidth :int = 80 * headshotScale;
            var actualHeadshotHeight :int = 60 * headshotScale;
            
            totalWidthOfAllBoards = actualHeadshotWidth * oustedPlayerCount + Constants.GUI_OBSERVER_VIEW_GAP_BETWEEN_HEADSHOTS * (oustedPlayerCount - 1);
            adjustedXOffset = (availableHorizontalSpaceForBoards - totalWidthOfAllBoards)/2;
            currentXPosition = Constants.GUI_OBSERVER_VIEW_GAP_BETWEEN_BORDER_AND_BOARDS + adjustedXOffset;
            
            for each ( id in _gameModel._playerIdsInOrderOfLoss) {
                
                
                /* Remove the marquee if it exists */
                if(_id2MarqueeSceneObject.get(id) != null) {
                    marquee = _id2MarqueeSceneObject.get(id) as SceneObject;
                    marquee.destroySelf();
                    _id2MarqueeSceneObject.remove(id);
                }
                
                headshot = _id2HeadshotSceneObject.get(id) as SceneObject;
                
                
                
                toX = currentXPosition + actualHeadshotWidth/2 - actualHeadshotWidth/2;
                toY = _out_placer.y - actualHeadshotHeight/2;
                
                
                scaleTask = new ScaleTask(headshotScale, headshotScale, animationDuration);
                moveTask = LocationTask.CreateEaseOut(toX, toY, animationDuration);
                parallelTask = new ParallelTask( scaleTask, moveTask);
                headshot.addTask( parallelTask );
                
                currentXPosition +=  actualHeadshotWidth + Constants.GUI_OBSERVER_VIEW_GAP_BETWEEN_HEADSHOTS;
            }
            
            
        }
        

        
        protected var _id2HeadshotSceneObject :HashMap;
        protected var _id2MarqueeSceneObject :HashMap;
        
        protected var _boardsView :JoinGameBoardsView;
        protected var _bg :DisplayObject;
        /*This variable represents the entire game state */
        protected var _gameModel: JoinGameModel;
        
        protected var _out_placer :MovieClip;
        protected var _marquee_placer :MovieClip;
        protected var _marqueeClass :Class;
        
        protected var _myColorMatrix_filter :ColorMatrixFilter;
        protected var _startButton :SimpleSceneObject;
        
        protected var _winnerClip :SceneObject;
        
        protected var _restartTimeTextField :TextField;
        protected var _gameRestartTimer :Timer;
        protected var _totalTimeElapsedSinceNewGameTimerStarted :int;
        
    }
}