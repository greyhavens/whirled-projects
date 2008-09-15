package joingame.modes
{

    import com.threerings.util.*;
    import com.whirled.contrib.simplegame.*;
    import com.whirled.contrib.simplegame.audio.*;
    import com.whirled.contrib.simplegame.net.*;
    import com.whirled.contrib.simplegame.objects.SceneObject;
    import com.whirled.contrib.simplegame.objects.SimpleSceneObject;
    import com.whirled.contrib.simplegame.resource.*;
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
    
    import joingame.*;
    import joingame.model.*;
    import joingame.net.JoinGameEvent;
    import joingame.view.*;
    
    //The 'game' part of the game
    public class PlayPuzzleMode extends AppMode
    {
        
        /**
         * When this method is called, it assumes that the game starting data
         * has already been downloaded to all clients/players.
         * 
         */
        override protected function setup () :void
        {
            
            trace("\nPlayPuzzleMode");
            if(!AppContext.gameCtrl.isConnected()) {
                return;
            }
            
            var rm :ResourceManager = ResourceManager.instance;

            // gfx
//            trace(" 0.1 " );
//            rm.pendResourceLoad("image", "BG",  { embeddedClass: Resources.IMG_BG });
//            rm.pendResourceLoad("swf", "UI", { embeddedClass: Resources.UI_DATA });
//            rm.load(init, handleResourceLoadErr);
            init();
        }
        
        
        protected function init() :void
        {
//            trace(" 1 " );
            var swfRoot :MovieClip = MovieClip(SwfResource.getSwfDisplayRoot("UI"));
            swfRoot.mouseEnabled = false;
            
            _playerPlacerMain = MovieClip(swfRoot["player_placer_main"]);
            _playerPlacerMain.mouseEnabled = false;
            
            _playerPlacerEast = MovieClip(swfRoot["player_placer_east"]);
            _playerPlacerEast.mouseEnabled = false;
            
            _playerPlacerWest = MovieClip(swfRoot["player_placer_west"]);
            _playerPlacerWest.mouseEnabled = false;
            
            _extraPlacerEast = MovieClip(swfRoot["extra_placer_east"]);
            _extraPlacerEast.mouseEnabled = false;
            
            _extraPlacerWest = MovieClip(swfRoot["extra_placer_west"]);
            _extraPlacerWest.mouseEnabled = false;
            
            // add the swfRoot to stage
            modeSprite.addChild(swfRoot);
            modeSprite.mouseEnabled = false;
            // do something with playerPlacerMain et al
            //i think actually that this is what he intends you to do. you load the swf, put its displayRoot on the screen, and then get the display root's named children ("player_placer_main", etc) and attach headshots and whatnot to them
            //so you never deal with coordinates directly; it's all embedded in the swf for you. you just take care of filling in the dynamic bits of the scene.
            

            
            
            
            
//            trace(" 2 " );
            
            _gameModel = GameContext.gameState; //new JoinGameModel(AppContext.gameCtrl);
            
            _bg = ImageResource.instantiateBitmap("BG");
            
            if(_bg != null) {
                _modeSprite.addChild(_bg);
                AppContext.gameWidth = _bg.width;
                AppContext.gameHeight = _bg.height;
            }
            else {
                trace("!!!!!Background is null!!!");
            }
            
            _id2HeadshotSceneObject = new HashMap();
            
            for each (var id :int in _gameModel._initialSeatedPlayerIds) {
                var headshot :DisplayObject = GameContext.getHeadshot(id);
                var so :SimpleSceneObject = new SimpleSceneObject(headshot);
                _id2HeadshotSceneObject.put(id, so);
                so.x = 10;
                so.y = 10;
                addObject( so, modeSprite);
//                trace("!!!adding headshot from " + id );
            }
//            trace(" 3 " );
            placeHeadshotsToStartLocation();
            animateHeadshotsToLocation();
            
            AppContext.gameCtrl.net.addEventListener(Server.GAME_OVER, gameOver);                
            _modeSprite.mouseEnabled = true;
            
            
            _boardsView = new JoinGameBoardsView(GameContext.gameState, AppContext.gameCtrl);
            
            addObject( _boardsView, _modeSprite);
            _boardsView.updateBoardDisplays();
//            trace(" 4 " );
            
            _boardsView.addEventListener(JoinGameEvent.PLAYER_KNOCKED_OUT, playerKnockedOut);
//            _gameModel.addEventListener(JoinGameEvent.PLAYER_KNOCKED_OUT, playerKnockedOut);s
            
        }
        
        
        protected function playerKnockedOut( e :JoinGameEvent ) :void
        {
            if (e.boardPlayerID == AppContext.gameCtrl.game.getMyId() || _gameModel.currentSeatingOrder.length <= 1) {
                trace("\nPlayer " + e.boardPlayerID + ", I'm knocked out (or seats<=1), going to observermode");
//              this.destroy();
                AppContext.mainLoop.unwindToMode(new ObserverMode());
            }
            else {
                animateHeadshotsToLocation();
            }
        }
        override protected function destroy() :void 
        {
            if(_boardsView != null) {
                _boardsView.removeEventListener(JoinGameEvent.PLAYER_KNOCKED_OUT, animateHeadshotsToLocation);
                _boardsView.destroySelf();
            }
//            if( _gameModel != null) {
//                _gameModel.removeEventListener(JoinGameEvent.PLAYER_KNOCKED_OUT, animateHeadshotsToLocation);
//            }
            AppContext.gameCtrl.net.removeEventListener(Server.GAME_OVER, gameOver); 
            super.destroy();
        }
        
        protected function placeHeadshotsToStartLocation() :void
        {
//            trace("\nplacePiecesToStartLocation()");
            var headshotIdsAlreadyPlaced :Array = new Array();
            
//            trace("\n!!!!!!!!!!animatePiecesToLocation()");
            var myid :int = AppContext.gameCtrl.game.getMyId();
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
                    headshot.x =  - 80;
                    headshot.y = _playerPlacerWest.y - 30;
                    headshotIdsAlreadyPlaced.push(id);
                }
            }
            
            
            /* Place the right piece */
            id = _gameModel.getPlayerIDToRightOfPlayer(myid) as int;
            if( _gameModel.getPlayerIDToLeftOfPlayer(myid) != id){
                headshot = _id2HeadshotSceneObject.get( id ) as SceneObject;
                if( headshot != null ) {
                    headshot.x = modeSprite.width + 80;
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
                
                if(id > 0) {
                    
                    var distanceFromSideAnchor :int = (isLeft ? -(leftPlayerIds.length+1) : rightPlayerIds.length) * 80 * headshotScaleToFit;
                    var toX :int = (isLeft ? -80 - spaceForEachHeadshot: modeSprite.width + 80) + distanceFromSideAnchor;
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
        
        protected function animateHeadshotsToLocation() :void
        {
            
//            trace("\n!!!!!!!!!!animatePiecesToLocation() for player " + AppContext.gameCtrl.game.getMyId());
            var myid :int = AppContext.gameCtrl.game.getMyId();
            if( !ArrayUtil.contains( _gameModel.currentSeatingOrder, myid)) {
                trace("animating headshots but should be in observer mode");
                return;
            }
            
            
            
            var headshotIdsAlreadyPlaced :Array = new Array();
            
            
            var toX :int;
            var toY :int;
            /* Animate the centre piece */
            var headshot :SceneObject = _id2HeadshotSceneObject.get( myid ) as SceneObject;
            var scaleTask :ScaleTask = new ScaleTask(1.0, 1.0, Constants.HEADSHOT_MOVEMENT_TIME);
            var moveTask :LocationTask = LocationTask.CreateEaseOut(_playerPlacerMain.x - 40, _playerPlacerMain.y - 30, Constants.HEADSHOT_MOVEMENT_TIME);
            var parallelTask :ParallelTask = new ParallelTask( scaleTask, moveTask);
            headshot.addTask( parallelTask );
            headshotIdsAlreadyPlaced.push(myid);
            
            /* Animate the left piece */
            var id :int = _gameModel.getPlayerIDToLeftOfPlayer(myid) as int;
//            trace("left player=" + id);
            if( true || _gameModel.getPlayerIDToRightOfPlayer(myid) != id ||  _gameModel._initialSeatedPlayerIds.length == 2 ){
                
//                trace("animating left player");
                var serialTask :SerialTask;
                headshot = _id2HeadshotSceneObject.get( id ) as SceneObject;
                if( headshot != null ) {
                    toX = _playerPlacerWest.x - 40;
                    toY = _playerPlacerWest.y - 30;
                    
                    serialTask = new SerialTask();
                    if( headshot.x > toX) {
                        serialTask.addTask( LocationTask.CreateEaseOut( modeSprite.width, headshot.y, Constants.HEADSHOT_MOVEMENT_TIME/2  ));
                        serialTask.addTask( LocationTask.CreateLinear( 0 - 80, headshot.y, 0  ));
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
//            trace("headshotIdsAlreadyPlaced=" + headshotIdsAlreadyPlaced);
            
            /* Animate the right piece */
            id = _gameModel.getPlayerIDToRightOfPlayer(myid) as int;
//            trace("right player=" + id);
            if( _gameModel.getPlayerIDToLeftOfPlayer(myid) != id){
                
//                trace("animating right player");            
                headshot = _id2HeadshotSceneObject.get( id ) as SceneObject;
                if( headshot != null ) {
                    toX = _playerPlacerEast.x - 40;
                    toY = _playerPlacerEast.y - 30;
                    
                    serialTask = new SerialTask();
                    if( headshot.x < toX) {
                        serialTask.addTask( LocationTask.CreateEaseOut( 0 - 80, headshot.y, Constants.HEADSHOT_MOVEMENT_TIME/2  ));
                        serialTask.addTask( LocationTask.CreateLinear( modeSprite.width, headshot.y, 0  ));
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
//            trace("headshotIdsAlreadyPlaced=" + headshotIdsAlreadyPlaced);
            /* Starting with the right, move the remaining players alternating left and right*/
            var numberPlayersEachSideToFit :Number =  ((_gameModel.currentSeatingOrder.length - headshotIdsAlreadyPlaced.length) / 2) + (_gameModel.currentSeatingOrder.length - headshotIdsAlreadyPlaced.length) % 2;
            var spaceForEachHeadshot : Number = _extraPlacerWest.x / numberPlayersEachSideToFit;
            var headshotScaleToFit :Number = spaceForEachHeadshot / 80.0 ;
            headshotScaleToFit = Math.min(headshotScaleToFit, 0.3);
            var isLeft :Boolean = false;
            var leftPlayerIds :Array = new Array();
            var rightPlayerIds :Array = new Array();
//            trace("headshotIdsAlreadyPlaced=" + headshotIdsAlreadyPlaced);
//            trace("_gameModel.currentSeatingOrder=" + _gameModel.currentSeatingOrder);
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
                
                if(id > 0) {
                    
                    var distanceFromSideAnchor :int = (isLeft ? -(leftPlayerIds.length+1) : rightPlayerIds.length) * 80 * headshotScaleToFit;
                    toX = (isLeft ? _extraPlacerWest.x : _extraPlacerEast.x) + distanceFromSideAnchor;
                    toY = _extraPlacerWest.y;
                    headshot = _id2HeadshotSceneObject.get( id ) as SceneObject;
                    
                    if( headshot != null ) {
                        
                        serialTask = new SerialTask();
                        if(isLeft) {
                            if( headshot.x > toX) {
                                serialTask.addTask( LocationTask.CreateEaseOut( modeSprite.width, headshot.y, Constants.HEADSHOT_MOVEMENT_TIME/2  ));
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
                                serialTask.addTask( LocationTask.CreateLinear( modeSprite.width, headshot.y, 0  ));
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
//            AppContext.mainLoop.unwindToMode(new ResourceLoadErrorMode(err));
        }

        public function gameOver (event :MessageReceivedEvent) :void
        {
            
            var playerIds :Array = event.value[0] as Array;
            var scores :Array = event.value[1] as Array;
                
            
            
                
            trace("game over, going to end screen");
            AppContext.mainLoop.unwindToMode(new GameOverMode(playerIds, scores));
        }
        
        
        /** Respond to messages from other clients. */
        public function messageReceived (event :MessageReceivedEvent) :void
        {
            var id :int;
            if (event.name == Server.PLAYER_KNOCKED_OUT)
            {
                id = int(event.value[0]);
                
                trace("\nPlayer " + AppContext.myid + ", received knockout for player=" + id);
                
                if(id == AppContext.myid)
                {
                    trace("\nPlayer " + id + ", I'm knocked out, going to observermode");
                    AppContext.mainLoop.unwindToMode(new ObserverMode());
                }
            }
        }
        
//        //Must be called after createOrUpdateOtherPlayerDisplay() because we need the player order
//        private function updateGameField(): void
//        {
////            if(GameContext._playerIDsInOrderOfPlay == null)
////            {
////                return;
////            }
//            
//            leftBoardDisplay.x = Constants.GUI_DISTANCE_BOARD_FROM_LEFT;
//            myBoardDisplay.x = leftBoardDisplay.x + leftBoardDisplay.width + Constants.GUI_BETWEEN_BOARDS;
//            rightBoardDisplay.x = myBoardDisplay.x + myBoardDisplay.width + Constants.GUI_BETWEEN_BOARDS;
//            
//        }
        
        
//        /** Responds to property changes. */
//        public function propertyChanged (event :PropertyChangedEvent) :void
//        {
//            
////            trace("\nWhen id="+AppContext.gameCtrl.game.getMyId()+" propertyChanged, left="+_gameModel.getPlayerIDToLeftOfPlayer(AppContext.gameCtrl.game.getMyId() )+ ", right="+_gameModel.getPlayerIDToRightOfPlayer(AppContext.gameCtrl.game.getMyId() ) );
//            
//            //We assume that the random seeds have already been created.
//            if (event.name == Server.PLAYER_ORDER)
//            {
//                
//                
//                var playerToLeft:int = _gameModel.getPlayerIDToLeftOfPlayer( AppContext.gameCtrl.game.getMyId());
//                var playerToRight:int = _gameModel.getPlayerIDToRightOfPlayer( AppContext.gameCtrl.game.getMyId());
//                
//                trace("playerToLeft="+playerToLeft);
//                trace("playerToRight="+playerToRight);
//                
//                //These should request an update if the player id changes.
//                if(leftBoardDisplay._boardRepresentation.playerID != playerToLeft)
//                {
//                    leftBoardDisplay._boardRepresentation.playerID = playerToLeft;
//                    
//                }
//                
//                if(rightBoardDisplay._boardRepresentation.playerID != playerToRight)
//                {
//                    rightBoardDisplay._boardRepresentation.playerID = playerToRight;
//                }
//            }
//            
//        }
        
        

        
        
        protected var allOpponentsView :AllOpponentsView;
//        protected var _elimatedOpponentsView;
        
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
        
        
    
    }
}
