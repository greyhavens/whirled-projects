package joingame.modes
{

    import com.threerings.util.*;
    import com.whirled.contrib.simplegame.*;
    import com.whirled.contrib.simplegame.audio.*;
    import com.whirled.contrib.simplegame.net.*;
    import com.whirled.contrib.simplegame.objects.SceneObject;
    import com.whirled.contrib.simplegame.objects.SimpleSceneObject;
    import com.whirled.contrib.simplegame.resource.*;
    import com.whirled.contrib.simplegame.tasks.FunctionTask;
    import com.whirled.contrib.simplegame.tasks.LocationTask;
    import com.whirled.contrib.simplegame.tasks.ParallelTask;
    import com.whirled.contrib.simplegame.tasks.ScaleTask;
    import com.whirled.contrib.simplegame.tasks.SelfDestructTask;
    import com.whirled.contrib.simplegame.tasks.SerialTask;
    import com.whirled.contrib.simplegame.util.*;
    import com.whirled.game.*;
    import com.whirled.net.MessageReceivedEvent;
    
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    
    import joingame.*;
    import joingame.model.*;
    import joingame.net.AddPlayerMessage;
    import joingame.net.GoToObserverModeMessage;
    import joingame.net.InternalJoinGameEvent;
    import joingame.net.JoinGameMessage;
    import joingame.net.WaveDefeatedMessage;
    import joingame.view.*;
    
    public class PlayPuzzleMode extends JoinGameMode
    {
        override protected function setup () :void
        {
            super.setup();
            _shouldFadeIn = true;
            
        }
        
        
        
        /**
         * When this method is called, it assumes that the game starting data
         * has already been downloaded to all clients/players.
         * 
         */
        override protected function enter () :void
        {
            super.enter();
            log.debug("PlayPuzzleMode...");
            /*Start counting progress for coins again */
            if(AppContext.isConnected) {
                AppContext.gameCtrl.game.playerReady();
            }
            
            
            AppContext.messageManager.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            
            var rm :ResourceManager = ResourceManager.instance;

            //            log.debug("init");
//            /*Disable the "Request Rematch" button*/
//            AppContext.gameCtrl.local.setShowReplay(false);
            
            
            _modeLayer.graphics.beginFill(0xffffff);
            _modeLayer.graphics.drawCircle(50, 50, 30);
            _modeLayer.graphics.endFill();
            
            var swfRoot :MovieClip = MovieClip(SwfResource.getSwfDisplayRoot("UI"));
            _modeLayer.addChild(swfRoot);
            _modeLayer.mouseEnabled = false;
            swfRoot.mouseEnabled = false;
            
            _playerPlacerMain = MovieClip(swfRoot["player_placer_main"]);
            _playerPlacerMain.mouseEnabled = false;
            Constants.GUI_MIDDLE_BOARD_CENTER = _playerPlacerMain.x;
            
            _playerPlacerEast = MovieClip(swfRoot["player_placer_east"]);
            _playerPlacerEast.mouseEnabled = false;
            Constants.GUI_EAST_BOARD_LEFT = _playerPlacerEast.x + 65;
            
            _playerPlacerWest = MovieClip(swfRoot["player_placer_west"]);
            _playerPlacerWest.mouseEnabled = false;
            Constants.GUI_WEST_BOARD_RIGHT = _playerPlacerWest.x - 65;
            
            _extraPlacerEast = MovieClip(swfRoot["extra_placer_east"]);
            _extraPlacerEast.mouseEnabled = false;
            
            _extraPlacerWest = MovieClip(swfRoot["extra_placer_west"]);
            _extraPlacerWest.mouseEnabled = false;
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            _gameModel = GameContext.gameModel; //new JoinGameModel(AppContext.gameCtrl);
            
            _bg = ImageResource.instantiateBitmap("BG");
            
            if(_bg != null) {
                _modeLayer.addChild(_bg);
                AppContext.gameWidth = _bg.width;
                AppContext.gameHeight = _bg.height;
            }
            else {
                log.error("!!!!!Background is null!!!");
            }
            
            _id2HeadshotSceneObject = new HashMap();
            
            for each (var id :int in _gameModel._initialSeatedPlayerIds) {
                var headshot :DisplayObject = GameContext.getHeadshot(id);
                var so :SimpleSceneObject = new SimpleSceneObject(headshot);
                _id2HeadshotSceneObject.put(id, so);
                so.x = 100;
                so.y = 100;
                addObject( so, _modeLayer);
            }
//            placeHeadshotsToStartLocation();
//            animateHeadshotsToLocation();
            
            _modeLayer.mouseEnabled = true;
            
            
            _boardsView = new JoinGameBoardsView(GameContext.gameModel, AppContext.gameCtrl);
            addObject( _boardsView, _modeLayer);
            
            _boardsView.addEventListener(InternalJoinGameEvent.PLAYER_REMOVED, playerRemoved);
            _boardsView.addEventListener(InternalJoinGameEvent.PLAYER_ADDED, playerAdded);
            _boardsView.addEventListener(InternalJoinGameEvent.GAME_OVER, handleGameOver);
            
            
            animateHeadshotsToLocation();
            _boardsView.updateBoardDisplays();
            _boardsView.adjustZoomOfPlayAreaBasedOnCurrentPlayersBoard();
            
            
            if( AppContext.isSinglePlayer ) {
                var swf :SwfResource = (ResourceManager.instance.getResource("UI") as SwfResource);
                var _intro_panel_Class :Class = swf.getClass("intro_panel");
                var _intro_panel :MovieClip = new _intro_panel_Class();
                var mainMenuButton :MovieClip = MovieClip(_intro_panel["levela"]);
                mainMenuButton.level_name.text = "Menu";
                mainMenuButton.level_name.selectable = false;
                Command.bind(mainMenuButton, MouseEvent.CLICK, GameController.MAIN_MENU);
                Command.bind(mainMenuButton, MouseEvent.MOUSE_OVER, GameController.MOUSE_OVER, mainMenuButton);
                Command.bind(mainMenuButton, MouseEvent.MOUSE_OUT, GameController.MOUSE_OUT, mainMenuButton);
                Command.bind(mainMenuButton, MouseEvent.MOUSE_DOWN, GameController.MOUSE_DOWN, mainMenuButton);
                modeSprite.addChild( mainMenuButton );
                mainMenuButton.scaleX = 0.5;
                mainMenuButton.scaleY = mainMenuButton.scaleX;
                mainMenuButton.x = mainMenuButton.width;
                mainMenuButton.y = mainMenuButton.height;
            }
            
            
            if (_shouldFadeIn) {
                fadeIn();
            }
            
        }
        
        
        /** Called when a key is pressed while this mode is active */
        override public function onKeyDown (keyCode :uint) :void
        {
            if( keyCode == KeyboardCodes.A) {
                AppContext.messageManager.sendMessage( new AddPlayerMessage(0, false, false));
            }
            
        }
        
        protected function messageReceived (event :MessageReceivedEvent) :void
        {
            log.debug(event.name + " " + JoinGameMessage(event.value).name);
            if (event.value is GoToObserverModeMessage) {
                handleGoToObserverMode( GoToObserverModeMessage(event.value) );
            }
            else if (event.value is WaveDefeatedMessage) {
                handleWaveDefeated( WaveDefeatedMessage(event.value) );
            }
        }
        
        protected function handleWaveDefeated( event :WaveDefeatedMessage ) :void
        {
            GameContext.gameModel._tempNewPlayerCookie = event.userCookieData;
            
//            GameContext.mainLoop.unwindToMode(new SinglePlayerWaveDefeatedMode());
//            GameContext.mainLoop.unwindToMode(new FadeOutMode(_modeLayer, SinglePlayerWaveDefeatedMode));
            fadeOutToMode( new SinglePlayerWaveDefeatedMode());
            
        }
        
        protected function handleGoToObserverMode( event :GoToObserverModeMessage ) :void
        {
            if( event.playerId == AppContext.playerId ) {
//                GameContext.mainLoop.unwindToMode(new ObserverMode());
                fadeOutToMode( new ObserverMode() );
            }    
        }
        
        protected function handleGameOver( e :InternalJoinGameEvent ) :void
        {
//            trace( ClassUtil.shortClassName(this) + " handleGameOver()");
            if( AppContext.isSinglePlayer ) {
                log.debug("Single Player: Game Over");
                if( GameContext.gameModel._singlePlayerGameType == Constants.SINGLE_PLAYER_GAME_TYPE_CHOOSE_OPPONENTS ) {
                    fadeOutToMode( new ObserverMode() );
//                    GameContext.mainLoop.unwindToMode(new ObserverMode());    
                }
                else if(GameContext.gameModel._singlePlayerGameType == Constants.SINGLE_PLAYER_GAME_TYPE_WAVES) {
//                    GameContext.mainLoop.unwindToMode(new SinglePlayerGameOverMode());
                    fadeOutToMode( new SinglePlayerGameOverMode() );
                }
                else {
                    log.error("handleGameOver(), but unknown single player game type=" + GameContext.gameModel._singlePlayerGameType);
                }
                
            }
            else {
                log.debug("Multi Player: Game Over");
                fadeOutToMode( new ObserverMode() );
//                GameContext.mainLoop.unwindToMode(new ObserverMode());
            }
        }
        protected function playerRemoved( e :InternalJoinGameEvent ) :void
        {
            if( AppContext.isSinglePlayer ) {
                if( e.boardPlayerID == AppContext.playerId ) {
                    GameContext.mainLoop.unwindToMode(new SinglePlayerGameOverMode());
                }
                else {
                    if( GameContext.gameModel.currentSeatingOrder.length <= 1) {
//                        GameContext.mainLoop.pushMode(new SinglePlayerWaveDefeatedMode());
//                        GameContext.mainLoop.unwindToMode(new SinglePlayerWaveDefeatedMode());
                    }
                }
            }
            else if (e.boardPlayerID == AppContext.playerId || _gameModel.currentSeatingOrder.length <= 1) {

                    var sim  :SimObject = new SimObject();
                    addObject(sim);
                    var serialTask :SerialTask = new SerialTask();
                    serialTask.addTask( new FunctionTask(startObserverMode) );
                    
                    sim.addTask( serialTask);
            }
            
            animateHeadshotsToLocation();
        }
        
        protected function playerAdded( e :InternalJoinGameEvent ) :void
        {
            var id :int = e.boardPlayerID;
            var headshot :DisplayObject = GameContext.getHeadshot(id);
            var so :SimpleSceneObject = new SimpleSceneObject(headshot);
            _id2HeadshotSceneObject.put(id, so);
            so.x = -100;
            so.y = 100;
            addObject( so, _modeLayer);
            
            log.debug("playerAdded( " + e.boardPlayerID + "), animating headshots");
            animateHeadshotsToLocation();
        }
        
        override protected function exit() :void 
        {
            AppContext.messageManager.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            
            log.debug("exiting " + ClassUtil.shortClassName(PlayPuzzleMode));
            if(_boardsView != null) {
                _boardsView.removeEventListener(InternalJoinGameEvent.PLAYER_REMOVED, playerRemoved);
                _boardsView.removeEventListener(InternalJoinGameEvent.PLAYER_ADDED, playerAdded);
                _boardsView.removeEventListener(InternalJoinGameEvent.GAME_OVER, handleGameOver);
                _boardsView.destroySelf();
                _boardsView = null;
            }
//            while(_modeLayer.numChildren > 0) {_modeLayer.removeChildAt(0);}
            
            super.exit();
        }
        
        
        
        protected function placeHeadshotsToStartLocation() :void
        {
            return;
            var headshotIdsAlreadyPlaced :Array = new Array();
            
            var myid :int = AppContext.playerId;
            /* Place the centre piece */
            var headshot :SceneObject = _id2HeadshotSceneObject.get( myid ) as SceneObject;
            headshot.x = _playerPlacerMain.x - 40;
            headshot.y = _playerPlacerMain.y - 30;
            headshotIdsAlreadyPlaced.push(myid);
            
            /* Place the left piece */
            var id :int = _gameModel.getPlayerIDToLeftOfPlayer(myid) as int;
            if( _gameModel.getPlayerIDToRightOfPlayer(myid) != id ||  _gameModel._initialSeatedPlayerIds.length == 2 ){
                headshot = _id2HeadshotSceneObject.get( id ) as SceneObject;
                if( headshot != null ) {
                    headshot.x =  0;
                    headshot.y = _playerPlacerWest.y - 30;
                    headshotIdsAlreadyPlaced.push(id);
                }
            }
            
            
            /* Place the right piece */
            id = _gameModel.getPlayerIDToRightOfPlayer(myid) as int;
            if( _gameModel.getPlayerIDToLeftOfPlayer(myid) != id){
                headshot = _id2HeadshotSceneObject.get( id ) as SceneObject;
                if( headshot != null ) {
                    headshot.x = _modeLayer.width + 80;
                    headshot.y = _playerPlacerEast.y - 30;
                    headshotIdsAlreadyPlaced.push(id);
                }
            }
            
            
            /* Starting with the left, place the other players alternating left and right*/
            var numberPlayersEachSideToFit :Number =  ((_gameModel.currentSeatingOrder.length - headshotIdsAlreadyPlaced.length) / 2) + (_gameModel.currentSeatingOrder.length - headshotIdsAlreadyPlaced.length) % 2;
            var spaceForEachHeadshot : Number = _extraPlacerWest.x / numberPlayersEachSideToFit;
            var headshotScaleToFit :Number = spaceForEachHeadshot / 80.0 ;
            headshotScaleToFit = Math.min(headshotScaleToFit, 0.3);
            var isLeft :Boolean = true;
            var leftPlayerIds :Array = new Array();
            var rightPlayerIds :Array = new Array();
            while( headshotIdsAlreadyPlaced.length < _gameModel.currentSeatingOrder.length) {
                
                if(isLeft) {
                    if(leftPlayerIds.length == 0) {
                        id = _gameModel.getPlayerIDToLeftOfPlayer( _gameModel.getPlayerIDToLeftOfPlayer(myid) );
                    }
                    else {
                        id = _gameModel.getPlayerIDToLeftOfPlayer( leftPlayerIds[leftPlayerIds.length - 1] );
                    }
                }
                else {
                    if(rightPlayerIds.length == 0) {
                        id = _gameModel.getPlayerIDToRightOfPlayer( _gameModel.getPlayerIDToRightOfPlayer(myid) );
                    }
                    else {
                        id = _gameModel.getPlayerIDToRightOfPlayer( rightPlayerIds[rightPlayerIds.length - 1] );
                    }
                }
                
                if(id != 0) {
                    
                    var distanceFromSideAnchor :int = (isLeft ? -(leftPlayerIds.length+1) : rightPlayerIds.length) * 80 * headshotScaleToFit;
                    var toX :int = (isLeft ? -80 - spaceForEachHeadshot: _modeLayer.width + 80) + distanceFromSideAnchor;
                    var toY :int = _extraPlacerWest.y;
                    headshot = _id2HeadshotSceneObject.get( id ) as SceneObject;
                    
                    if( headshot != null ) {
                        headshot.x = toX;
                        headshot.y = toY;
                        headshot.scaleX = headshotScaleToFit;
                        headshot.scaleY = headshotScaleToFit;
                    }
                    else {
                        trace(" no headshot for id=" + id);
                    }
                    
                    headshotIdsAlreadyPlaced.push(id);
                     (isLeft ? leftPlayerIds : rightPlayerIds).push( id );          
                }
                
                isLeft = !isLeft;
            }
            
            
            
        }
        
        protected function checkHeadShotArray() :void
        {
            var so :SimpleSceneObject;
            
            if( _id2HeadshotSceneObject == null ) {
                _id2HeadshotSceneObject = new HashMap();
            }
            var ids :Array = _gameModel.currentSeatingOrder;
            for each ( var idWithHeadshot :int in _id2HeadshotSceneObject.keys()) {
                so = _id2HeadshotSceneObject.get(idWithHeadshot) as SimpleSceneObject;
                if( !ArrayUtil.contains( ids, idWithHeadshot) && so != null && so.isLiveObject) {
                    so.destroySelf();
                }
            }
            
            
            for each (var id :int in ids) {
                if( !_id2HeadshotSceneObject.containsKey( id) ) {
                    var headshot :DisplayObject = GameContext.getHeadshot(id);
                    so = new SimpleSceneObject(headshot);
                    _id2HeadshotSceneObject.put(id, so);
                    so.x = 100;
                    so.y = 100;
                    addObject( so, _modeLayer);
                }
                
            }
        } 
        
        protected function animateHeadshotsToLocation() :void
        {
            checkHeadShotArray();
            var myid :int = AppContext.playerId;
            if( !ArrayUtil.contains( _gameModel.currentSeatingOrder, myid)) {
                log.warning("animating headshots but should be in observer mode");
                return;
            }
            
            var headshotIdsAlreadyPlaced :Array = new Array();
            
            
            var toX :int;
            var toY :int;
            /* Animate the centre piece */
            var headshot :SceneObject = _id2HeadshotSceneObject.get( myid ) as SceneObject;
//            if(headshot == null) {
//                return;
//            }
            var scaleTask :ScaleTask = new ScaleTask(1.0, 1.0, Constants.HEADSHOT_MOVEMENT_TIME);
            var moveTask :LocationTask = LocationTask.CreateEaseOut(_playerPlacerMain.x - 40, _playerPlacerMain.y - 30, Constants.HEADSHOT_MOVEMENT_TIME);
            var parallelTask :ParallelTask = new ParallelTask( scaleTask, moveTask);
            headshot.addTask( parallelTask );
            headshotIdsAlreadyPlaced.push(myid);
            
            /* Animate the left piece */
            var id :int = _gameModel.getPlayerIDToLeftOfPlayer(myid) as int;
            if( true || _gameModel.getPlayerIDToRightOfPlayer(myid) != id ||  _gameModel._initialSeatedPlayerIds.length == 2 ){
                var serialTask :SerialTask;
                headshot = _id2HeadshotSceneObject.get( id ) as SceneObject;
                if( headshot != null ) {
                    toX = _playerPlacerWest.x - 40;
                    toY = _playerPlacerWest.y - 30;
                    
                    serialTask = new SerialTask();
                    if( headshot.x > toX) {
                        serialTask.addTask( LocationTask.CreateEaseOut( AppContext.gameWidth - _modeLayer.width, headshot.y, Constants.HEADSHOT_MOVEMENT_TIME/2  ));
                        serialTask.addTask( LocationTask.CreateLinear( 0, headshot.y, 0  ));
                        scaleTask = new ScaleTask(1.0, 1.0, Constants.HEADSHOT_MOVEMENT_TIME/2);
                        moveTask = LocationTask.CreateEaseOut(toX, toY, Constants.HEADSHOT_MOVEMENT_TIME/2);
                        parallelTask = new ParallelTask( scaleTask, moveTask);
                        serialTask.addTask( parallelTask );
                    }
                    else {
                        scaleTask = new ScaleTask(1.0, 1.0, Constants.HEADSHOT_MOVEMENT_TIME);
                        moveTask = LocationTask.CreateEaseOut(toX, toY, Constants.HEADSHOT_MOVEMENT_TIME);
                        parallelTask = new ParallelTask( scaleTask, moveTask);
                        serialTask.addTask( parallelTask );
                    }
                    
                    headshot.addTask( serialTask );
                    headshotIdsAlreadyPlaced.push(id);
                }
            }
            /* Animate the right piece */
            id = _gameModel.getPlayerIDToRightOfPlayer(myid) as int;
            if( _gameModel.getPlayerIDToLeftOfPlayer(myid) != id){
                headshot = _id2HeadshotSceneObject.get( id ) as SceneObject;
                if( headshot != null ) {
                    toX = _playerPlacerEast.x - 40;
                    toY = _playerPlacerEast.y - 30;
                    
                    serialTask = new SerialTask();
                    if( headshot.x < toX) {
                        serialTask.addTask( LocationTask.CreateEaseOut( 0 - 80, headshot.y, Constants.HEADSHOT_MOVEMENT_TIME/2  ));
                        serialTask.addTask( LocationTask.CreateLinear( _modeLayer.width, headshot.y, 0  ));
                        scaleTask = new ScaleTask(1.0, 1.0, Constants.HEADSHOT_MOVEMENT_TIME/2);
                        moveTask = LocationTask.CreateEaseOut(toX, toY, Constants.HEADSHOT_MOVEMENT_TIME/2);
                        parallelTask = new ParallelTask( scaleTask, moveTask);
                        serialTask.addTask( parallelTask );
                    }
                    else {
                        scaleTask = new ScaleTask(1.0, 1.0, Constants.HEADSHOT_MOVEMENT_TIME);
                        moveTask = LocationTask.CreateEaseOut(toX, toY, Constants.HEADSHOT_MOVEMENT_TIME);
                        parallelTask = new ParallelTask( scaleTask, moveTask);
                        serialTask.addTask( parallelTask );
                    }
                    
                    headshot.addTask( serialTask );
                    headshotIdsAlreadyPlaced.push(id);
                }
            }
            /* Starting with the right, move the remaining players alternating left and right*/
            var numberPlayersEachSideToFit :Number =  ((_gameModel.currentSeatingOrder.length - headshotIdsAlreadyPlaced.length) / 2) + (_gameModel.currentSeatingOrder.length - headshotIdsAlreadyPlaced.length) % 2;
            var spaceForEachHeadshot : Number = _extraPlacerWest.x / numberPlayersEachSideToFit;
            var headshotScaleToFit :Number = spaceForEachHeadshot / 80.0 ;
            headshotScaleToFit = Math.min(headshotScaleToFit, 0.3);
            var isLeft :Boolean = false;
            var leftPlayerIds :Array = new Array();
            var rightPlayerIds :Array = new Array();
            while( headshotIdsAlreadyPlaced.length < _gameModel.currentSeatingOrder.length) {
                
                if(isLeft) {
                    if(leftPlayerIds.length == 0) {
                        id = _gameModel.getPlayerIDToLeftOfPlayer( _gameModel.getPlayerIDToLeftOfPlayer(myid) );
                    }
                    else {
                        id = _gameModel.getPlayerIDToLeftOfPlayer( leftPlayerIds[leftPlayerIds.length - 1] );
                    }
                }
                else {
                    if(rightPlayerIds.length == 0) {
                        id = _gameModel.getPlayerIDToRightOfPlayer( _gameModel.getPlayerIDToRightOfPlayer(myid) );
                    }
                    else {
                        id = _gameModel.getPlayerIDToRightOfPlayer( rightPlayerIds[rightPlayerIds.length - 1] );
                    }
                }
                
                if(id != 0) {
                    
                    var distanceFromSideAnchor :int = (isLeft ? -(leftPlayerIds.length+1) : rightPlayerIds.length) * 80 * headshotScaleToFit;
                    toX = (isLeft ? _extraPlacerWest.x : _extraPlacerEast.x) + distanceFromSideAnchor;
                    toY = _extraPlacerWest.y;
                    headshot = _id2HeadshotSceneObject.get( id ) as SceneObject;
                    
                    if( headshot != null ) {
                        
                        serialTask = new SerialTask();
                        if(isLeft) {
                            if( headshot.x > toX) {
                                serialTask.addTask( LocationTask.CreateEaseOut( _modeLayer.width, headshot.y, Constants.HEADSHOT_MOVEMENT_TIME/2  ));
                                serialTask.addTask( LocationTask.CreateLinear( 0 - 80, headshot.y, 0  ));
                                scaleTask = new ScaleTask(headshotScaleToFit, headshotScaleToFit, Constants.HEADSHOT_MOVEMENT_TIME/2);
                                moveTask = LocationTask.CreateEaseOut(toX, toY, Constants.HEADSHOT_MOVEMENT_TIME/2);
                                parallelTask = new ParallelTask( scaleTask, moveTask);
                                serialTask.addTask( parallelTask );
                                headshot.addTask( serialTask );
                            }
                            else {
                                scaleTask = new ScaleTask(headshotScaleToFit, headshotScaleToFit, Constants.HEADSHOT_MOVEMENT_TIME);
                                moveTask = LocationTask.CreateEaseOut(toX, toY, Constants.HEADSHOT_MOVEMENT_TIME);
                                parallelTask = new ParallelTask( scaleTask, moveTask);
                                headshot.addTask( parallelTask );
                            }
                        }
                        else {
                            
                            if( headshot.x < toX) {
                                serialTask.addTask( LocationTask.CreateEaseOut( 0 - 80, headshot.y, Constants.HEADSHOT_MOVEMENT_TIME/2  ));
                                serialTask.addTask( LocationTask.CreateLinear( _modeLayer.width, headshot.y, 0  ));
                                scaleTask = new ScaleTask(headshotScaleToFit, headshotScaleToFit, Constants.HEADSHOT_MOVEMENT_TIME/2);
                                moveTask = LocationTask.CreateEaseOut(toX, toY, Constants.HEADSHOT_MOVEMENT_TIME/2);
                                parallelTask = new ParallelTask( scaleTask, moveTask);
                                serialTask.addTask( parallelTask );
                                headshot.addTask( serialTask );
                            }
                            else {
                                scaleTask = new ScaleTask(headshotScaleToFit, headshotScaleToFit, Constants.HEADSHOT_MOVEMENT_TIME);
                                moveTask = LocationTask.CreateEaseOut(toX, toY, Constants.HEADSHOT_MOVEMENT_TIME);
                                parallelTask = new ParallelTask( scaleTask, moveTask);
                                headshot.addTask( parallelTask );
                            }
                        }
                        
                    }
                    else {
                        trace(" no headshot for id=" + id);
                    }
                    
                    headshotIdsAlreadyPlaced.push(id);
                     (isLeft ? leftPlayerIds : rightPlayerIds).push( id );           
                }
                
                isLeft = !isLeft;
            }
            
            /* Then place the ousted players */
            for each (var oustedPlayerId :int in _gameModel._playerIdsInOrderOfLoss) {
                headshot = _id2HeadshotSceneObject.get( oustedPlayerId ) as SceneObject;
                if( headshot != null ) {
                    headshot.addTask( new SelfDestructTask() );
                }
            }
            
        }
        
        protected function handleResourceLoadErr (err :String) :void
        {
//            GameContext.mainLoop.unwindToMode(new ResourceLoadErrorMode(err));
        }

        
//        /** Respond to messages from other clients. */
//        public function messageReceived (event :MessageReceivedEvent) :void
//        {
//            var id :int;
//            if (event.name == JoingameServer.PLAYER_REMOVED)
//            {
//                id = int(event.value[0]);
//                
//                if(id == AppContext.myid)
//                {
//                    var sim  :SimObject = new SimObject();
//                    addObject(sim);
//                    var serialTask :SerialTask = new SerialTask();
//                    serialTask.addTask( new TimedTask( Constants.BOARD_DISTRUCTION_TIME) );
//                    serialTask.addTask( new FunctionTask(startObserverMode) );
//                    
//                    sim.addTask( serialTask);
//                }
//            }
//        }
        
        protected function startObserverMode() :void
        {
            GameContext.mainLoop.unwindToMode(new ObserverMode());
        }
        
//        protected function startSinglePlayerGameOverMode() :void
//        {
//            GameContext.mainLoop.unwindToMode(new SinglePlayerGameOverMode());
//        }
        
        protected var allOpponentsView :AllOpponentsView;
        protected var _boardsView :JoinGameBoardsView;
        protected var _bg :DisplayObject;
        
        
        /*This variable represents the entire game state */
        protected var _gameModel: JoinGameModel;
        
        protected var _id2HeadshotSceneObject :HashMap;
        
        protected var _playerPlacerMain :MovieClip;
        protected var _playerPlacerEast :MovieClip;
        protected var _playerPlacerWest :MovieClip;
        
        protected var _extraPlacerEast :MovieClip;
        protected var _extraPlacerWest :MovieClip;
        
        
        private static const log :Log = Log.getLog(PlayPuzzleMode);
    }
}
