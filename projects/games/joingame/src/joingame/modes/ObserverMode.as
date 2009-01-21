package joingame.modes
{
    import com.threerings.flash.SimpleTextButton;
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
    
    public class ObserverMode extends JoinGameMode
    {
        private static const log :Log = Log.getLog(ObserverMode);
        
        override protected function setup () :void
        {
            log.debug("Player " + AppContext.playerId + ",PlayPuzzleMode...");
            _modeLayer.mouseEnabled = false;
            
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
            
            
            Constants.GUI_OBSERVER_VIEW_GAP_BETWEEN_FLOOR_AND_BOARDS = (AppContext.gameHeight - _marquee_placer.y) + tempMarquee.height/2;
            
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
            addObject( _startButton, _modeLayer);
            
            var replayButton :SimpleTextButton = new SimpleTextButton("Replay");
            replayButton.addEventListener(MouseEvent.CLICK, doReplayButtonClicked);
            replayButton.x = 300;
            replayButton.y = -300;
            _modeLayer.addChild( replayButton);
            _replayButton = new SimpleSceneObject( replayButton );
            
            
            var singlePlayerMainMenuButton :SimpleTextButton = new SimpleTextButton("Main Menu");
            singlePlayerMainMenuButton.addEventListener(MouseEvent.CLICK, doMainMenuButtonClicked);
            singlePlayerMainMenuButton.x = 30;
            singlePlayerMainMenuButton.y = 30;
            _singlePlayerMainMenuButton = new SimpleSceneObject( singlePlayerMainMenuButton );
            
            
            if(AppContext.isSinglePlayer ) {
//                addObject( _replayButton, _modeLayer);
                addObject( _singlePlayerMainMenuButton, _modeLayer);
            }
            
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
            this._modeLayer.addChild( _restartTimeTextField );
            
            _gameRestartTimer = new Timer(1000, 0);
            _gameRestartTimer.addEventListener(TimerEvent.TIMER, gameTimer);
            _totalTimeElapsedSinceNewGameTimerStarted = 0;
        
            fadeIn();
        
//            initGameData();
        }
        
        
        protected function doReplayButtonClicked (event :MouseEvent) :void
        {
            log.debug("sending " + ReplayRequestMessage.NAME );
            AppContext.messageManager.sendMessage(new ReplayRequestMessage(AppContext.playerId, GameContext.playerCookieData));
        }
        
        protected function doMainMenuButtonClicked (event :MouseEvent) :void
        {
            GameContext.mainLoop.unwindToMode( new SinglePlayerIntroMode());
        }
        
        
        /** Respond to messages from other clients. */
        protected function messageReceived (event :MessageReceivedEvent) :void
        {
            if (event.value is ReplayRequestMessage) {
                handleReplayRequest( ReplayRequestMessage(event.value) );
            }
            else if (event.value is ReplayConfirmMessage) {
                handleReplayConfirm( ReplayConfirmMessage(event.value) );
            }
        }
        protected function gameTimer(  e :TimerEvent) :void
        {
            _totalTimeElapsedSinceNewGameTimerStarted++;
            _restartTimeTextField.text = "" + ( Constants.GAME_RESTART_TIME - _totalTimeElapsedSinceNewGameTimerStarted) ;
            _restartTimeTextField.visible = true;
            _modeLayer.setChildIndex( _restartTimeTextField, _modeLayer.numChildren - 1);
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
        
        override protected function enter () :void
        {
//            trace("Observer mode");
            AppContext.messageManager.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            initGameData();
        }
        override protected function exit () :void
        {
            AppContext.messageManager.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
//            AppContext.messageManager.removeEventListener(ReplayRequestMessage.NAME, handleReplayRequest);
//            AppContext.messageManager.removeEventListener(ReplayConfirmMessage.NAME, handleReplayConfirm);
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
//            trace("initGameData(), _gameModel._initialSeatedPlayerIds=" + _gameModel._initialSeatedPlayerIds);
            for each (var id :int in _gameModel._initialSeatedPlayerIds) {
                var marquee :MovieClip = new _marqueeClass();
                var so2 :SimpleSceneObject = new SimpleSceneObject(marquee);
                _id2MarqueeSceneObject.put( id, so2);
                addObject( so2, _modeLayer);
            }
            
            for each ( id in _gameModel._initialSeatedPlayerIds) {
                var headshot :DisplayObject = GameContext.getHeadshot(id);
                var so :SimpleSceneObject = new SimpleSceneObject(headshot);
                _id2HeadshotSceneObject.put(id, so);
                so.x = 10;
                so.y = 10;
                addObject( so, _modeLayer);
            }
            
            
            _boardsView = new JoinGameBoardsView(GameContext.gameModel, AppContext.gameCtrl, true);
            addObject( _boardsView, _modeLayer);
            _boardsView.updateBoardDisplays();
            _gameModel.addEventListener(InternalJoinGameEvent.PLAYER_REMOVED, animateHeadshotsToLocation);
            _gameModel.addEventListener(InternalJoinGameEvent.GAME_OVER, gameOver);
            
            animateHeadshotsToLocation(null, 0);
            
//            trace("Player " + AppContext.playerId + ", ObserverMode, initGameData(), _gameModel.currentSeatingOrder=" + _gameModel.currentSeatingOrder);
            if(_gameModel.currentSeatingOrder.length <= 1) {
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
            
            if( AppContext.isSinglePlayer ) {
                log.debug("handleReplayConfirm()");
                GameContext.gameModel.setModelMemento( event.modelMemento );
                log.debug("  players=" + GameContext.gameModel.currentSeatingOrder);
                GameContext.mainLoop.unwindToMode(new PlayPuzzleMode());
            }
            else {
                if( ArrayUtil.contains( playerIdsAcceptedForNextGame, AppContext.playerId)) {  
                    AppContext.beginToShowInstructionsTime = getTimer();
                    GameContext.mainLoop.unwindToMode(new ShowMultiPlayerInstructionsMode());
                }
                else {
                    AppContext.isObserver = true;//Now a permenent observer
                    GameContext.gameModel.setModelMemento( event.modelMemento);
                    reset();
                }
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
            if( ArrayUtil.contains( GameContext.gameModel.currentSeatingOrder, AppContext.playerId)) {
                _winnerClip.addTask( LocationTask.CreateEaseOut( _winnerClip.x, 200, 1.0));
            }
            _modeLayer.setChildIndex( _winnerClip.displayObject, _modeLayer.numChildren - 1);
            AudioManager.instance.playSoundNamed("final_applause");
            
            if( !AppContext.isObserver ) {//Lower the menu for replay or main menu
                if( AppContext.isSinglePlayer ) {
                    _startButton.addTask( LocationTask.CreateEaseOut( _winnerClip.x, 242, 1.0));
                    
                    _replayButton.addTask( LocationTask.CreateEaseOut( _winnerClip.x, 242 + 50, 1.0));
//                    _singlePlayerMainMenuButton.addTask( LocationTask.CreateEaseOut( _winnerClip.x, 242 + 100, 1.0));
                    _modeLayer.setChildIndex( _replayButton.displayObject, _modeLayer.numChildren - 1);
                    _modeLayer.setChildIndex( _singlePlayerMainMenuButton.displayObject, _modeLayer.numChildren - 1);
                    
//                    _modeLayer.addChild( new GameStatsSinglePlayerSprite(GameContext.playerCookieData.clone(), GameContext.gameModel._tempNewPlayerCookie.clone()));
                    GameContext.playerCookieData.setFrom( GameContext.gameModel._tempNewPlayerCookie );
                    if( AppContext.isConnected ) {
                        log.info("gameOver(), Writing new single player cookie");
                        GameContext.cookieManager.needsUpdate();
                    }
                    
                }
                else {//if( GameContext.gameModel.potentialPlayerIds.length > 1) {
                    _startButton.addTask( LocationTask.CreateEaseOut( _winnerClip.x, 242, 1.0));
                    _modeLayer.setChildIndex( _startButton.displayObject, _modeLayer.numChildren - 1);
                    
    //                _gameRestartTimer.reset();
    //                _gameRestartTimer.start(); 
                }
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
                
                if( marquee == null ) {
                    log.error("No marquee for id=" + id);
                    continue;
                }
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
                _modeLayer.setChildIndex( headshot.displayObject, _modeLayer.numChildren - 1); 
                
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
                if( headshot != null) {
                    headshot.addTask( parallelTask );
                }
                else {
                    log.error("   animateHeadshotsToLocation() headshot null for id=" + id);
                }
                
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
        
        protected var _replayButton :SceneObject;
        protected var _singlePlayerMainMenuButton :SceneObject;
        
    }
}