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
    import flash.filters.ColorMatrixFilter;
    
    import joingame.*;
    import joingame.model.*;
    import joingame.net.JoinGameEvent;
    import joingame.view.*;
    
    public class ObserverMode extends AppMode
    {
        
        override protected function setup () :void
        {
            trace("\nPlayer " + AppContext.myid + ", ObserverMode()");
            if(!AppContext.gameCtrl.isConnected()) {
                return;
            }
            AppContext.gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            
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
//            trace("Constants.GUI_OBSERVER_VIEW_GAP_BETWEEN_FLOOR_AND_BOARDS=" + Constants.GUI_OBSERVER_VIEW_GAP_BETWEEN_FLOOR_AND_BOARDS);
            
            
            
            var winnerClass :Class = swf.getClass("winner");
            var _winnerClipMovieClip :MovieClip = new winnerClass();
            
            _winnerClip = new SimpleSceneObject( _winnerClipMovieClip );
            addObject( _winnerClip, modeSprite);
            _winnerClip.x = AppContext.gameWidth/2;
            _winnerClip.y = -100;
            
            
            var replayButtonClass :Class = swf.getClass("replay_button");
            
            var startButtonMovieClip :MovieClip = new replayButtonClass();//MovieClip(_winnerClipMovieClip["replay_button"]);
            startButtonMovieClip.mouseEnabled = true;
            startButtonMovieClip.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
            startButtonMovieClip.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
            startButtonMovieClip.addEventListener(MouseEvent.CLICK, mouseClicked);
            startButtonMovieClip.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
            
            _startButton = new SimpleSceneObject( startButtonMovieClip );
            _startButton.x = AppContext.gameWidth/2;
            _startButton.y = -100;
            
            
            
            addObject( _startButton, modeSprite);
            
            var myElements_array:Array = [2,0,0,0,-13.5,0,2,0,0,-13.5,0,0,2,0,-13.5,0,0,0,1,0]
            _myColorMatrix_filter = new ColorMatrixFilter(myElements_array);
            
            
            initGameData();
        }
        
        override protected function destroy () :void
        {
            AppContext.gameCtrl.net.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            if(_startButton != null) {
                
                var movieClip :MovieClip = _startButton.displayObject as MovieClip;
                movieClip.removeEventListener(MouseEvent.MOUSE_OVER, mouseOver);
                movieClip.removeEventListener(MouseEvent.MOUSE_OUT, mouseOut);
                movieClip.removeEventListener(MouseEvent.CLICK, mouseClicked);
                movieClip.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
            }
            if( _gameModel != null )
            {
                _gameModel.removeEventListener(JoinGameEvent.PLAYER_KNOCKED_OUT, animateHeadshotsToLocation);
                _gameModel.removeEventListener(JoinGameEvent.GAME_OVER, gameOver);
            }
            
            super.destroy();
        }
        
        
        protected function initGameData() :void 
        {
            if(_boardsView != null) {
                _boardsView.destroySelf();
            }
            
            if( _gameModel != null )
            {
                _gameModel.removeEventListener(JoinGameEvent.PLAYER_KNOCKED_OUT, animateHeadshotsToLocation);
                _gameModel.removeEventListener(JoinGameEvent.GAME_OVER, gameOver);
            }
            
            _gameModel = GameContext.gameState;
            
            
            _id2HeadshotSceneObject = new HashMap();
            _id2MarqueeSceneObject = new HashMap();
            
            for each (var id :int in _gameModel._initialSeatedPlayerIds) {
                var marquee :MovieClip = new _marqueeClass();
                var so2 :SimpleSceneObject = new SimpleSceneObject(marquee);
                _id2MarqueeSceneObject.put( id, so2);
                addObject( so2, modeSprite);
                /* Make sure they are just abobe the background */
//                modeSprite.setChildIndex( so2.displayObject, 1);
            }
            
            for each ( id in _gameModel._initialSeatedPlayerIds) {
                var headshot :DisplayObject = GameContext.getHeadshot(id);
                var so :SimpleSceneObject = new SimpleSceneObject(headshot);
                _id2HeadshotSceneObject.put(id, so);
                so.x = 10;
                so.y = 10;
                addObject( so, modeSprite);
            }
            
            
            _boardsView = new JoinGameBoardsView(GameContext.gameState, AppContext.gameCtrl, true);
            addObject( _boardsView, _modeSprite);
            _boardsView.updateBoardDisplays();
            _gameModel.addEventListener(JoinGameEvent.PLAYER_KNOCKED_OUT, animateHeadshotsToLocation);
            _gameModel.addEventListener(JoinGameEvent.GAME_OVER, gameOver);
            
            animateHeadshotsToLocation(null);
            
            trace("Player " + AppContext.myid + ", ObserverMode, initGameData(), _gameModel.currentSeatingOrder=" + _gameModel.currentSeatingOrder);
            if(_gameModel.currentSeatingOrder.length <= 1) {
                gameOver();
            }
        }
        
        /** Respond to messages from the server. */
        public function messageReceived (event :MessageReceivedEvent) :void
        {
            var id :int;  
            var headshot :SceneObject;          
            /* This is simply mark the headshots of those that have 
                requested to play again */
            if (event.name == Server.REPLAY_REQUEST)
            {
                id = event.senderId;
                headshot = _id2HeadshotSceneObject.get(id) as SceneObject;
                if( headshot != null ) {
                    headshot.displayObject.filters = [ _myColorMatrix_filter ];
                }

            }
//            else if (event.name == Server.ALL_PLAYERS_READY)
//            {
//                GameContext.gameState = new JoinGameModel( AppContext.gameCtrl);
//                GameContext.gameState.setModelMemento( event.value[0] as Array );
//                trace("setting new model, sending " + Server.PLAYER_RECEIVED_START_GAME_STATE);
//                AppContext.gameCtrl.net.sendMessage(Server.PLAYER_RECEIVED_START_GAME_STATE, {}, NetSubControl.TO_SERVER_AGENT);
//                
//            }
            else if (event.name == Server.REPLAY_CONFIRM)
            {
                trace("\nPlayer " + AppContext.myid + ", " + Server.REPLAY_CONFIRM + " for " + AppContext.myid);
                
                var playerIdsAcceptedForNextGame :Array = event.value[0] as Array;
                
                trace("playerIdsAcceptedForNextGame=" + playerIdsAcceptedForNextGame);
                
                
                
                
                var keys :Array = _id2HeadshotSceneObject.keys();
                for each (var key :int in keys) {
                    headshot = _id2HeadshotSceneObject.get(key) as SceneObject;
                    if( headshot != null ) {
                        headshot.displayObject.filters = [];
                    }
                }

                if( ArrayUtil.contains( playerIdsAcceptedForNextGame, AppContext.gameCtrl.game.getMyId())) {  
                    trace("starting WaitingForPlayerDataModeAsPlayer");
                    AppContext.mainLoop.unwindToMode(new WaitingForPlayerDataModeAsPlayer());
                }
                else {
                    trace("starting a new WaitingForPlayerDataModeAsObserver");
                    AppContext.isObserver = true;//Now a permenent observer
                    AppContext.mainLoop.unwindToMode(new WaitingForPlayerDataModeAsObserver());
                }
            }
            
        }
        
        private function mouseClicked( event:MouseEvent ) :void
        {
            _startButton.y -= 4;
            trace("Player " + AppContext.myid + ", sending " + Server.REPLAY_REQUEST );
            AppContext.gameCtrl.net.sendMessage(Server.REPLAY_REQUEST, {});//, NetSubControl.TO_SERVER_AGENT
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
        
        
        protected function gameOver( e :JoinGameEvent = null) :void
        {
            trace("Player " + AppContext.myid + ", ObserverMode gameOver()");
            _winnerClip.addTask( LocationTask.CreateEaseOut( _winnerClip.x, 200, 1.0));
            modeSprite.setChildIndex( _winnerClip.displayObject, modeSprite.numChildren - 1);
            
            if(!AppContext.isObserver) {
                _startButton.addTask( LocationTask.CreateEaseOut( _winnerClip.x, 242, 1.0));
                modeSprite.setChildIndex( _startButton.displayObject, modeSprite.numChildren - 1);
            }
        }
        
        protected function animateHeadshotsToLocation( e :JoinGameEvent) :void
        {
            
//            trace("\n!!!!!!!!!!animatePiecesToLocation() for player " + AppContext.gameCtrl.game.getMyId());
            
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
                
                headshot = _id2HeadshotSceneObject.get(id) as SceneObject;
                headshot.scaleX = 1.0;
                headshot.scaleY = 1.0;
                marquee = _id2MarqueeSceneObject.get(id) as SceneObject;
                
                toX = currentXPosition + actualBoardWidth/2 - headshot.width/2;
                toY = _marquee_placer.y - headshot.height/2;
                
                moveTask = LocationTask.CreateEaseOut(toX, toY, Constants.HEADSHOT_MOVEMENT_TIME);
                headshot.addTask( moveTask ); 
                
                toX = toX + headshot.width/2;
                toY = toY + headshot.height/2;
                
                moveTask = LocationTask.CreateEaseOut(toX, toY, Constants.HEADSHOT_MOVEMENT_TIME);
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
                
                
                scaleTask = new ScaleTask(headshotScale, headshotScale, Constants.HEADSHOT_MOVEMENT_TIME);
                moveTask = LocationTask.CreateEaseOut(toX, toY, Constants.HEADSHOT_MOVEMENT_TIME);
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
        
//        protected var _winnerClip :MovieClip;
        protected var _myColorMatrix_filter :ColorMatrixFilter;
        protected var _startButton :SimpleSceneObject;
        
        protected var _winnerClip :SceneObject;
        
        
    }
}