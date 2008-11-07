package joingame.view
{
    import com.threerings.util.ClassUtil;
    import com.threerings.util.Log;
    import com.threerings.util.Random;
    import com.whirled.contrib.simplegame.*;
    import com.whirled.contrib.simplegame.audio.*;
    import com.whirled.contrib.simplegame.objects.*;
    import com.whirled.contrib.simplegame.resource.ResourceManager;
    import com.whirled.contrib.simplegame.resource.SwfResource;
    import com.whirled.contrib.simplegame.tasks.*;
    import com.whirled.contrib.simplegame.util.*;
    import com.whirled.game.GameControl;
    
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    import joingame.*;
    import joingame.model.*;
    import joingame.net.DeltaRequestMessage;
    import joingame.net.InternalJoinGameEvent;
    
    /**
    * Visual representation of a board.
    * All animations and changes to the board are called from JoinGameBoardsView.  This class does 
    * not directly respond to events.
    * 
    */
    public class JoinGameBoardGameArea extends SceneObject
    {
        public function JoinGameBoardGameArea(  control:GameControl, activePlayersBoard:Boolean = false)//boardRepresentation:JoinGameBoardRepresentation,
        {
            _control = control;
            _activePlayersBoard = activePlayersBoard;
            
            _rand = new Random();
            
            _sprite = new Sprite();
            _sprite.mouseEnabled = false;
            _sprite.mouseChildren = false;
            
            
            wobbleTimer = new Timer(1000, 0);
            wobbleTimer.addEventListener( TimerEvent.TIMER, wobbleBottomRow);
            
            _columnHighlight = new Sprite();
            
            _boardPieces = new Array();
            
//            this.tileSize = Constants.PUZZLE_TILE_SIZE;
            _tileSize = Constants.PUZZLE_TILE_SIZE;
            
            
            
            _updateTimer = new Timer(3000, 0);
            _updateTimer.addEventListener(TimerEvent.TIMER, resetPositionOfPiecesNotMoving);
            _updateTimer.start();
            _updating = false;
            
            
            _sprite.graphics.lineStyle(1, 0, 0 ); 
            _sprite.graphics.drawRect( 0 , 0 , _tileSize*Constants.PUZZLE_STARTING_COLS - 1, Constants.MAX_PUZZLE_HEIGHT - 1);
            
            
            _backgroundSprite = new Sprite();
            _backgroundSprite.graphics.beginFill(0xff3333, 0); 
            _backgroundSprite.graphics.drawRect( 0 , 0 , _tileSize*Constants.PUZZLE_STARTING_COLS, Constants.MAX_PUZZLE_HEIGHT);
//            _backgroundSprite.graphics.drawRect( -1000 , -1000 ,2000,2000);
            _backgroundSprite.graphics.endFill(); 
            _sprite.addChild(_backgroundSprite);
            _backgroundPieces = new Array();
            
            var swf :SwfResource = (ResourceManager.instance.getResource("puzzlePieces") as SwfResource);
            
            _backgroundClassActivePlayer = swf.getClass("piece_back_player");
            _backgroundClassObserver = swf.getClass("piece_back_opponents");  
            
            
            
            _animationsToDestroyWhenIDie = new Array();
            _pendingDelta = false;
//            _backgroundClassActivePlayer = swf.getClass("piece_back_player");
//            var backgroundClassObserver :Class = swf.getClass("piece_back_opponent");
//            
//            
//            
//            var test :MovieClip = new backgroundClassObserver();
            
//            this.y = Constants.PUZZLE_HEIGHT
        
//            this.board = boardRepresentation;
            
            
            
    
//            this.x = 10;
//            this.y = 10;
            
            
            
            
            
            
//            //Get the size by loading up a piece
//            if (null == SWF_CLASSES)
//            {
//                SWF_CLASSES = [];
//                var swf :SwfResource = (ResourceManager.instance.getResource("puzzlePieces") as SwfResource);
//                for each (var className :String in SWF_CLASS_NAMES)
//                {
//                    SWF_CLASSES.push(swf.getClass(className));
//                }
//            }
//
//
//
//            var pieceClass :Class = SWF_CLASSES[1];
//            var pieceMovie :MovieClip = new pieceClass();
//            this.tileSize = pieceMovie.width;
        
        
        
            
            
            
            
            
            //Add mouse listeners if appropriate
            if(_activePlayersBoard)
            {
                _sprite.mouseEnabled = true;
                _sprite.addEventListener(MouseEvent.CLICK, mouseClicked);
//                _sprite.addEventListener(MouseEvent.ROLL_OUT, mouseOut);
                _sprite.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
                _sprite.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
                _sprite.addEventListener(MouseEvent.MOUSE_UP, mouseClicked);
            }
            
        }
        
        
        protected function mouseOut( e :MouseEvent ) :void
        {
//            _control.local.feedback("mouseOut(), e.localX=" + e.localX + 
//                ", e.localY=" + e.localY + ", _sprite.width=" + _sprite.width + 
//                ", _sprite.height=" + _sprite.height);       
//            
//            _control.local.feedback("target is me? " + (e.target == _sprite));       
            e.stopPropagation(); 
                         
                         
            if(e.localX <= 0 || e.localX >= _sprite.width || e.localY <= Constants.MAX_PUZZLE_HEIGHT - (_rows * _tileSize) || e.localY >= _sprite.height) { 
                mouseClicked( e );
            }
        }
        
        public function doBoardDistructionAnimation() :void
        {
            log.debug("doBoardDistructionAnimation()");
            var piece :JoinGamePiece;
            var k :int;
            _updating = true;
            wobbleTimer.stop();
            _updateTimer.stop();
            
            this.addTask( new PlaySoundTask("board_freezing"));
            this.addTask( new SerialTask( new TimedTask(Constants.BOARD_DISTRUCTION_TIME/2), new PlaySoundTask("board_explosion")));
            
            
            for each (var sim :SceneObject in _animationsToDestroyWhenIDie) {
                if(sim != null && sim.isLiveObject) {
                    sim.destroySelf();
                }
            }
            
//            for each ( piece in _boardPieces) {
//                if(piece!= null && _sprite.contains( piece.displayObject)) {
//                    _sprite.removeChild( piece.displayObject);
//                }
//            }
            
            
            
//            _sprite.graphics.beginFill(0,0);
//            _sprite.graphics.drawRect(0,0,400, 2000);
//            _sprite.graphics.endFill();
            
//            for each ( piece in _boardPieces) {
//                _sprite.addChild( piece.displayObject);
//            }
            
            
//            var fallingTime :Number = 1.0;
            
            for each ( piece in _boardPieces) {
                piece.removeAllTasks();
            }
            
            var boardFreezeTime :Number = Constants.BOARD_DISTRUCTION_TIME/4;
            var boardExplodeTime :Number = Constants.BOARD_DISTRUCTION_TIME/4;
            for ( k = _boardPieces.length - 1; k >= 0; k--) {
                
                piece = _boardPieces[k] as JoinGamePiece;
                if(piece == null) {
                    continue;
                }
                piece.removeAllTasks();
                
                var turnDeadAnimation :SerialTask = new SerialTask();
                var freezeDelay :Number = boardFreezeTime*(((_boardPieces.length - 1) - k)/(_boardPieces.length as Number))/2.0;
                turnDeadAnimation.addTask( new TimedTask(  freezeDelay ));
                turnDeadAnimation.addTask( new FunctionTask(freezePiece));
                
                function freezePiece( p :JoinGamePiece ) :void
                {
                    if( p.type == Constants.PIECE_TYPE_NORMAL) {
                        p.type = Constants.PIECE_TYPE_POTENTIALLY_DEAD;
                    }
                    
                }
                
                function deadifyPiece( p :JoinGamePiece ) :void
                {
                    if( p.type != Constants.PIECE_TYPE_INACTIVE) {
                        p.type = Constants.PIECE_TYPE_DEAD;
                    }
                }
                turnDeadAnimation.addTask( new TimedTask(  boardFreezeTime/2 ));
                turnDeadAnimation.addTask( new FunctionTask(deadifyPiece));
                piece.addTask( turnDeadAnimation ); 
                
                
                var serialAnimation :SerialTask = new SerialTask(); 
                serialAnimation.addTask( new TimedTask(  boardFreezeTime ) );
                var toX :int = piece.x + _rand.nextInt(80) * (_rand.nextBoolean() ? 1 : -1);
                var toY :int = piece.y - 100 + _rand.nextInt(50);
                
                var asplosionYPathTask :SerialTask = new SerialTask();
                asplosionYPathTask.addTask( LocationTask.CreateEaseOut( piece.x + (toX - piece.x)/2, toY, boardExplodeTime/2));
                asplosionYPathTask.addTask( LocationTask.CreateEaseIn( toX, piece.y + 400, boardExplodeTime/2));
                serialAnimation.addTask( asplosionYPathTask );
                serialAnimation.addTask( new VisibleTask( false ) );
                
                piece.addTask( serialAnimation );
                
                
                

                
                /* And the backgrounds */
                var backgroundPiece :SceneObject = _backgroundPieces[k] as SceneObject;
                if( backgroundPiece != null) {
                    _sprite.addChildAt(backgroundPiece.displayObject, 0);
                    backgroundPiece.x = backgroundPiece.x;// - (backgroundPiece.width - Constants.PUZZLE_TILE_SIZE)/2;
                    backgroundPiece.y = backgroundPiece.y;// - (backgroundPiece.height - Constants.PUZZLE_TILE_SIZE)/2;
                    
                    serialAnimation = new SerialTask(); 
                    serialAnimation.addTask( new TimedTask(  boardFreezeTime ) );
                
                    asplosionYPathTask = new SerialTask();
                    asplosionYPathTask.addTask( LocationTask.CreateEaseOut( piece.x + (toX - piece.x)/2, toY, boardExplodeTime/2));
                    asplosionYPathTask.addTask( LocationTask.CreateEaseIn( toX, piece.y + 400, boardExplodeTime/2));
                    serialAnimation.addTask( asplosionYPathTask );
                    serialAnimation.addTask( new VisibleTask( false ) );
                    backgroundPiece.addTask( serialAnimation );
                }      
                
                
                
            }
            
            for each ( var back :SceneObject in _backgroundPieces) {
                if(back != null && back.isLiveObject) {
                    
//                    back.destroySelf();
                }
            }
            
            if(_sprite.contains( _backgroundSprite)) {
                _sprite.removeChild( _backgroundSprite);
            }
            
            
//            for each ( piece in _boardPieces) {
//                if( !piece.hasTasks() ) {
//                    trace("piece with no tasks=" + piece.boardIndex);
//                }
//            }
            
            serialAnimation = new SerialTask();
            serialAnimation.addTask( new TimedTask( Constants.BOARD_DISTRUCTION_TIME));
            
            
//            serialAnimation.addTask( LocationTask.CreateEaseOut( this.x, this.y + this.height + 100, 5.8));
            if( this.isLiveObject ) {
                serialAnimation.addTask( new SelfDestructTask() );
            }
            this.addTask( serialAnimation );
        }
        
        
        override protected function update(dt:Number):void
        {
            super.update(dt);
//            trace("board " + _boardRepresentation.playerID + " updated, currentSeatingOrder=" + GameContext.gameModel.currentSeatingOrder);
        }
        override public function destroySelf():void
        {
//            _updateTimer.removeEventListener(TimerEvent.TIMER, checkAndUpdateBoardState);
//            _updateTimer.stop();


//            for each (var piece :JoinGamePiece in _boardPieces) {
//                if(piece != null) {
//                    piece.destroySelf();
//                }
//            }
            
            if(_activePlayersBoard)
            {
                _sprite.removeEventListener(MouseEvent.CLICK, mouseClicked);
                _sprite.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
                _sprite.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
            }
            wobbleTimer.removeEventListener(TimerEvent.TIMER, wobbleBottomRow);
            wobbleTimer.stop();
            
            _updateTimer.removeEventListener(TimerEvent.TIMER, resetPositionOfPiecesNotMoving);
            _updateTimer.stop();
            
            super.destroySelf();
            removeAllTasks();
        }
        
        public function doBoardEnterFromSideAnimation( fromDirection :int) :void
        {
//            x = Constants.GUI_MIDDLE_BOARD_CENTER + 800*(fromDirection == Constants.LEFT ? -1 : 1) ;
//            var toX :int = (fromDirection == Constants.LEFT ? Constants.GUI_WEST_BOARD_RIGHT : Constants.GUI_EAST_BOARD_LEFT) - this.scaleX * Constants.PUZZLE_STARTING_COLS * Constants.PUZZLE_TILE_SIZE/2;
//            updateYBasedOnBoardHeight();
//            this.addTask( LocationTask.CreateEaseIn( toX, this.y, Constants.BOARD_ENTER_DELAY) );
            
            var maxDelay :Number = Constants.HEADSHOT_MOVEMENT_TIME;
            var delay :Number = 0;
            var delayPerRow :Number = maxDelay / _rows;
            
            var direction :int = (fromDirection == Constants.LEFT ? -1 : 1);
            
//            this.addTask( new PlaySoundTask("board_enters") );
            for( var j :int = _rows - 1; j >= 0; j--) {
                for( var i :int = _cols - 1; i >= 0; i--) {
                    var piece :JoinGamePiece = getPieceAt( i, j) as JoinGamePiece;
                    if( piece != null) {
                        var toX :int = piece.x;
                        var toY :int = piece.y;
                        
                        if( fromDirection == Constants.LEFT) {
                            piece.x = -this.x * (1 / this.scaleX) - Constants.PUZZLE_STARTING_COLS * Constants.PUZZLE_TILE_SIZE * (1 / this.scaleX);
                        }
                        else {
                            piece.x = (AppContext.gameWidth - this.x) * (1 / this.scaleX);
                        }
                        var moveAnimation :SerialTask = new SerialTask();
                        moveAnimation.addTask( new TimedTask( delay ));
                        var rowMultiplier :int = _rows - j;
//                        var timeForThisPieceToGetThere :Number = maxDelay
//                        moveAnimation.addTask( LocationTask.CreateEaseOut( toX + rowMultiplier*8, toY, delayPerRow * 1.8 * rowMultiplier ));
//                        moveAnimation.addTask( new TimedTask( j * delayPerRow ));
//                        moveAnimation.addTask( LocationTask.CreateEaseOut( toX - rowMultiplier, toY, delayPerRow * (1/1.8) * (Math.max(0,rowMultiplier - 1))));
//                        moveAnimation.addTask( new TimedTask( j * delayPerRow ));
                        moveAnimation.addTask( LocationTask.CreateEaseOut( toX, toY, delayPerRow * rowMultiplier));
                        piece.addTask( moveAnimation );
                    }
                }
                delay += delayPerRow;
            }
            
        }
        
        public function doBoardEnterFromBottomAnimation( toCenterX :int) :void//, toX :int, toY :int
        {
            x = toCenterX - this.scaleX * Constants.PUZZLE_STARTING_COLS * Constants.PUZZLE_TILE_SIZE/2;
            updateYBasedOnBoardHeight();
            var toY :int = y;
            y = toY - 1000;
            
            
            
//            this.addTask( new PlaySoundTask("board_enters") );
            this.addTask( LocationTask.CreateEaseIn( x, toY, Constants.BOARD_ENTER_DELAY) );
        }
        
        private function XXXDELETEMEcheckAndUpdateBoardState(event: TimerEvent):void
        {
//            if( _boardRepresentation.playerID <= 0) {
//                return;
//            }
//            AppContext.gameCtrl.game.systemMessage("checkAndUpdateBoardState");
            resetPositionOfPiecesNotMoving(null);
            
//            return;
//            
//            var isDeadBottomRow :Boolean = true;
//            var i :int;
//            var piece :JoinGamePiece;
//            
//            for(i = 0; i < _cols; i++) {
//                piece = getPieceAt( i, _rows - 1);
//                if(piece != null && piece.type == Constants.PIECE_TYPE_NORMAL) {
//                    isDeadBottomRow = false;
//                    break;
//                }
//            }
//            if(isDeadBottomRow) {
//                log.debug("animating bottom wobble");
//                for(i = 0; i < _cols; i++) {
//                    piece = getPieceAt( i, _rows - 1);
//                    if(piece != null && piece.type != Constants.PIECE_TYPE_INACTIVE) {
//                        
//                        var serialAnimation :SerialTask = new SerialTask(); 
//                        serialAnimation.addTask( LocationTask.CreateEaseIn(piece.x - 2, piece.y, 0.05) );
//                        serialAnimation.addTask( LocationTask.CreateEaseIn(piece.x + 2, piece.y, 0.1) );
//                        serialAnimation.addTask( LocationTask.CreateEaseIn(piece.x, piece.y, 0.05) );
//                        piece.addNamedTask(JoinGameBoardsView.WOBBL_TASK_NAME, serialAnimation, true);  
//                    }
//                }
//            }
                
        }
        
        override public function get displayObject () :DisplayObject
        {
            return _sprite;
        } 
        
        
        
        
        /** Respond to messages from other clients. */
        protected function boardChanged (event :InternalJoinGameEvent) :void
        {
            log.debug("DEPRECATED, should not be called, BoardUpdateEvent: Board updated, so updating display");
            updatePieceDimensionsAndCoordinatesAndAddPiecesIfNecessaryOLD();            
        }
        
        
        public function getPieceXLoc (xCoord :int) :int
        {
//            return ((xCoord + 0.5) * _tileSize) - xCoord;
            return xCoord * Constants.PUZZLE_TILE_SIZE ;//+ Constants.PUZZLE_TILE_SIZE * 0.5;
        }
    
        public function getPieceYLoc (yCoord :int) :int
        {
            var gapBetweenTopOfPuzzleAndTopOfBoardSprite :int = Constants.MAX_PUZZLE_HEIGHT - (_rows * Constants.PUZZLE_TILE_SIZE);
//            log.debug("_sprite.height="+_sprite.height);
//            log.debug("_rows="+_rows);
//            log.debug("_tileSize="+_tileSize);
//            log.debug("gapBetweenTopOfPuzzleAndTopOfBoardSprite="+gapBetweenTopOfPuzzleAndTopOfBoardSprite);
//            log.debug("for yCoord="+yCoord+", Yloc="+ (yCoord * _tileSize + gapBetweenTopOfPuzzleAndTopOfBoardSprite) );
            return yCoord * Constants.PUZZLE_TILE_SIZE + gapBetweenTopOfPuzzleAndTopOfBoardSprite ;// + Constants.PUZZLE_TILE_SIZE * 0.5;
            
//            return yCoord * _tileSize;
        }
        
        
        
        public function removeAndAddDisplayChildren() :void 
        {
            for each (var piece :JoinGamePiece in _boardPieces) {
                if( piece != null && _sprite.contains(piece.displayObject)) {
                    _sprite.removeChild(piece.displayObject);
                }
            }
            for each (piece in _boardPieces) {
                if( piece != null) {
                    _sprite.addChild(piece.displayObject);
                }
            }
        }
        
        
        public function updatePieceDimensionsAndCoordinatesAndAddPiecesIfNecessaryOLD(): void
        {
//            log.debug("\nupdatePieceDimensionsAndCoordinatesAndAddPiecesIfNecessary()\n ");
//            removeAllBoardComponents();
            
            if(_boardRepresentation == null)
                return;
            
            var boardSize:int = _boardRepresentation._rows*_boardRepresentation._cols;
            if(_boardPieces == null)
            {
                _boardPieces = new Array(boardSize);
            }
        
            while(_boardPieces.length < boardSize)
            {
                _boardPieces.push(null);
            }
            while(_boardPieces.length > boardSize)
            {
                _boardPieces.pop();
            }
            
            
            
            
            
            for( var k: int = 0; k < boardSize; k++)
            {
                if(_boardPieces[k] == null)
                {
                    _boardPieces[k] = new JoinGamePiece(this._tileSize);
                    // add the Piece to the mode, as a child of the board sprite
                    this.db.addObject(_boardPieces[k], _sprite);
                }
                var piece: JoinGamePiece = _boardPieces[k] as JoinGamePiece;
                piece.boardIndex = k;
                piece.type = _boardRepresentation._boardPieceTypes[k];
                piece.color = _boardRepresentation._boardPieceColors[k];
                
                piece.x = getPieceXLoc(  _boardRepresentation.idxToX(k));
                piece.y = getPieceYLoc(  _boardRepresentation.idxToY(k));
//                log.debug(" piece color="+piece.color + ", x="+piece.x + ", piece.y="+piece.x + ", size="+piece.size);
            }
            
//            
            addAllBoardComponents();
            updateNumberOfPieceBackgrounds();
            updatePieceBackgroundsPositions();
            
            
            
            
        }
        
        public function updateNumberOfPieceBackgrounds(newPiecesVisible :Boolean = true) :void
        {
            log.debug("updatePieceBackgrounds");
            var backgroundMovie :MovieClip;
            var backgroundSprite :Sprite;
            
            if( _boardRepresentation.playerID == 0) {
                return;
            }
            
//            while(_backgroundSprite.numChildren > 0) {
//                _backgroundSprite.removeChildAt(0);
//            }
            if(_backgroundPieces == null)
            {
                _backgroundPieces = new Array(_boardPieces.length);
            }
        
            while(_backgroundPieces.length < _boardPieces.length)
            {
                _backgroundPieces.splice(0,0,null);
            }
            while(_backgroundPieces.length > _boardPieces.length)
            {
                trace("remoing back piece")
                var pb :SceneObject = _backgroundPieces.pop() as SceneObject;
                if(pb != null) { 
                    trace("doestroying");
                     pb.destroySelf();
                     trace("parent=" + pb.displayObject.parent);
                }
            }
            
            for( var k: int = 0; k < _boardPieces.length; k++)
            {
                var backgroundPiece :SceneObject = _backgroundPieces[ k ] as SceneObject;
                if(backgroundPiece == null && _boardRepresentation._boardPieceTypes[k] != Constants.PIECE_TYPE_INACTIVE) {
                    if(_activePlayersBoard) {
                        backgroundMovie = new _backgroundClassActivePlayer();
                    }
                    else {
                        backgroundMovie = new _backgroundClassObserver();
                    }
                    
                    backgroundSprite = new Sprite();
                    backgroundSprite.addChild(backgroundMovie);
//                    backgroundMovie.x = -backgroundMovie.width * 0.5;
//                    backgroundMovie.y = -backgroundMovie.height * 0.5;
                    
                    backgroundPiece = new SimpleSceneObject( backgroundSprite );
                    backgroundPiece.visible = newPiecesVisible;
                    
                    _backgroundPieces[ k ] = backgroundPiece;
                    db.addObject( backgroundPiece, _backgroundSprite);
                }
                else if( backgroundPiece != null && _boardRepresentation._boardPieceTypes[k] == Constants.PIECE_TYPE_INACTIVE ) {
                    if(_backgroundSprite.contains( backgroundPiece.displayObject ) ) {
                        backgroundPiece.destroySelf();
                    }
                    _backgroundPieces[ k ] = null;
                    backgroundPiece = null;
                }
                
                
//                if( backgroundPiece != null) { 
////                    _backgroundSprite.addChild( backgroundPiece );
//                    backgroundPiece.x = getPieceXLoc(  _boardRepresentation.idxToX(k));
//                    backgroundPiece.y = getPieceYLoc(  _boardRepresentation.idxToY(k));
//                }
                
                
                
            }
            if( _sprite.contains(_backgroundSprite)) {
                _sprite.setChildIndex( _backgroundSprite, 0);
            }
            
        }
        
        public function updatePieceBackgroundsPositions(replaceTasks :Boolean = true, delay :Number = 0) :void
        {
            for( var k: int = 0; k < _boardRepresentation._boardPieceTypes.length; k++)
            {
                var backgroundPiece :SceneObject = _backgroundPieces[ k ] as SceneObject;
                if(backgroundPiece != null ){
                    if(replaceTasks || !backgroundPiece.hasTasks()) {
                        if(delay <= 0 ) {
                            backgroundPiece.x = getPieceXLoc(  _boardRepresentation.idxToX(k));
                            backgroundPiece.y = getPieceYLoc(  _boardRepresentation.idxToY(k));
                        }
                        else {
                            
                        }
                    }
                }
                
            }
        }
        
        public function updateYBasedOnBoardHeight() :void
        {
//            if(this.y != AppContext.gameHeight - _rows*_tileSize) {
//                this.y = AppContext.gameHeight - _rows*_tileSize;
//                this.y = AppContext.gameHeight - _sprite.height - Constants.GUI_BOARD_FLOOR_GAP;
                
                this.y = -Constants.MAX_PUZZLE_HEIGHT*this.scaleX + (AppContext.gameHeight - Constants.GUI_BOARD_FLOOR_GAP);
                
                //Update the pieces too. 
//                for each (var piece :JoinGamePiece in _boardPieces) {
//                    if(piece != null && !piece.hasTasks()) {
//                        piece.x = getPieceXLoc( idxToX( piece.boardIndex));
//                        piece.y = getPieceYLoc( idxToY( piece.boardIndex));
//                    }
//                }    
//            }

//            trace("updating board, y=" + this.y + ", height=" + this.height);
            
        }
        
        
        public function clearBottomRow() :void
        {
            for( var i :int = 0; i < _cols; i++) {
                var piece :JoinGamePiece = getPieceAt( i, _rows - 1);
                if( piece != null) {
                    piece.destroySelf(); 
                    _boardPieces[ coordsToIdx( i, _rows - 1) ] = null;
                    
                }
            }
            trace("after clearBottomRow(), view=" + toString());
        }
        
        
        protected function removeAllBoardComponents(): void
        {
            
//            for( var i: int = 0; i < _boardPieces.length; i++)
//            {
//                if(_boardPieces[i] != null)
//                {
//                    (_boardPieces[i] as JoinGamePiece).destroySelf();
//                }
//            }
            
            
            while(_sprite.numChildren > 0)
            {
                _sprite.removeChildAt(0);
            }
        }
        
        protected function addAllBoardComponents(): void
        {
//            for( var i: int = 0; i < _boardPieces.length; i++){
//                if(_boardPieces[i] != null){
//                    _sprite.addChild( (_boardPieces[i] as JoinGamePiece).displayObject);
////                    if(this.db != null) {
////                        // add the Piece to the mode, as a child of the board sprite
////                        
////                        this.db.addObject(_boardPieces[i], _sprite);
////                    
////                    }
////                    else {
////                        log.debug(" no db for adding the piece");
////                    }
//                    
//                }
//            }
            
//            var headshot:DisplayObject = SeatingManager.getPlayerHeadshot( AppContext.gameCtrl.game.seating.getPlayerPosition(_boardRepresentation.playerID));
//            if(headshot != null)
//            {
////                headshot.x = -headshot.width;
////                headshot.y = -headshot.height;
////                addChild( headshot );
//            }
        }
        
        public function convertFromTopYToFromBottomY( j :int ) :int
        {
            return (_rows - 1) - j;
        }  
        
        public function convertFromBottomYToFromTopY( j :int ) :int
        {
            return (_rows - 1) - j;
        } 
        
                
        protected function mouseClicked (e :MouseEvent) :void
        {
//            log.debug("\nmouseClicked");
//            AppContext.gameCtrl.game.systemMessage
//            log.debug("mouseclicked, width, height=" + this.width + ", " + this.height);
            
//            _boardRepresentation.playerID = _control.game.getMyId();
//            AppContext.gameCtrl.net.sendMessageToAgent(JoingameServer.BOARD_UPDATE_REQUEST,  {});
            
//            resetPositionOfPiecesNotMoving();
            if( _selectedPiece != null )
            {
                _updating = true;
                var mouseAdjustedX :int = e.localX;
                if(mouseAdjustedX < 0) {
                    mouseAdjustedX = 0;
                }
                if(mouseAdjustedX > _sprite.width) {
                    mouseAdjustedX = _sprite.width;
                }
                
                var mouseAdjustedY :int = e.localY;
                if(mouseAdjustedY < 0) {
                    mouseAdjustedY = 0;
                }
                if(mouseAdjustedY > _sprite.height) {
                    mouseAdjustedY = _sprite.height;
                }
                
                var mouseIndexX :int = ((e.localX) / (_tileSize));
//                var mouseIndexY :int = ((e.localY) / (_tileSize ));
                var mouseIndexY :int = getYRelativeToPuzzleArea(e.localY);
//                AppContext.gameCtrl.game.systemMessage("mouse clicked raw mouse (" + e.localX + ", " + e.localY + ")\nadjusted mouse (" + mouseIndexX + ", " + mouseIndexY + ")");
            
//                        
//                log.debug("mouseclicked, coords=" + mouseIndexX + ", " + mouseIndexY);
//                log.debug("_selectedPiece = (" + _selectedPiece.x + ", " + _selectedPiece.y + ")");
                var row:int = _boardRepresentation.idxToX( _selectedPiece.boardIndex);
                var pieceToSwap:JoinGamePiece = getPieceAt(row, mouseIndexY);
                
                var highestPiece :JoinGamePiece = getHighestSwappablePiece(_selectedPiece);
                var lowestY :int = getPieceYLoc( idxToY(highestPiece.boardIndex));
                var lowestPiece :JoinGamePiece = getLowestSwappablePiece(_selectedPiece);
                var highestY :int = getPieceYLoc( idxToY(lowestPiece.boardIndex)) ;
                var barHeight :int = highestY - lowestY;
                
//                log.debug("_selectedPiece=" + _selectedPiece);
//                log.debug("before check: pieceToSwap=" + pieceToSwap);
//                
//                log.debug("before check: highestPiece=" + highestPiece);
//                log.debug("before check: lowestY=" + lowestY);
//                log.debug("before check: lowestPiece=" + lowestPiece);
//                log.debug("before check: highestY=" + highestY);
                
                if( _selectedPiece.y <= lowestY){
                    _selectedPiece.y = lowestY;
                    pieceToSwap = highestPiece;
//                    log.debug("swapping swap and highest");
                }
                else if( _selectedPiece.y >= highestY){
                    _selectedPiece.y = highestY;
                    pieceToSwap = lowestPiece;
//                    log.debug("swapping swap and lowest");
                }
                
//                log.debug("after check: highestPiece=" + highestPiece);
//                log.debug("after check: lowestPiece=" + lowestPiece);
//                   
//                   
//                log.debug("after check: pieceToSwap=" + pieceToSwap);
                 
                /* For improved speed perception, the piece is swapped even though it may not be 
                legal */
                
                _selectedPiece.y = getPieceYLoc( idxToY( pieceToSwap.boardIndex ));
                
                requestMove(_selectedPiece, pieceToSwap);
                
                _sprite.removeChild(_columnHighlight);
                
                _selectedPiece = null;
                _mostRecentSwappedPiece = null;
            }
            else
            {
//                log.debug("selected piece is null");
            }
        }
        
        
        public function requestMove( from :JoinGamePiece, target :JoinGamePiece) :void
        {
            
            if(from != null && target != null && from.boardIndex != target.boardIndex)
            {
                
                //We assume the move is legal, as far as we know.  The server checks the legality of the move.
//                var msg :Object = new Object;
//                msg[0] = _control.game.getMyId();
//                msg[1] = _boardRepresentation.playerID;
//                msg[2] = _boardRepresentation.idxToX(from.boardIndex);
//                msg[3] = _boardRepresentation.idxToY(from.boardIndex);
//                msg[4] = _boardRepresentation.idxToX(target.boardIndex);
//                msg[5] = _boardRepresentation.idxToY(target.boardIndex);

                log.debug("sending " + ClassUtil.shortClassName(DeltaRequestMessage));  
                
                     
                      
                AppContext.messageManager.sendMessage( new DeltaRequestMessage(AppContext.playerId, 
                    _boardRepresentation.idxToX(from.boardIndex),
                    _boardRepresentation.idxToY(from.boardIndex),
                    _boardRepresentation.idxToX(target.boardIndex),
                    _boardRepresentation.idxToY(target.boardIndex)
                ));
//                _control.net.agent.sendMessage(JoingameServer.BOARD_DELTA_REQUEST, msg);
//                log.debug("client requesting move " + from + " -> " + target );
            }
            else
            {
                if(from == target)
                {
                    target.y = getPieceYLoc( _boardRepresentation.idxToY( target.boardIndex));
                }
            }
            
        }
        
        public function getPieceAt (x :int, y :int) :JoinGamePiece
        {
            var piece :JoinGamePiece = null;
    
            if (x >= 0 && x < _boardRepresentation._cols && y >= 0 && y < _boardRepresentation._rows && _boardPieces != null)
            {
                piece = (_boardPieces[_boardRepresentation.coordsToIdx(x, y)] as JoinGamePiece);
            }
    
            return piece;
        }        
        
        private function getYRelativeToPuzzleArea(localY :int) :int
        {
            /* Adjust mouse for difference between board sprite and puzzle height */
            var gapBetweenTopOfPuzzleAndTopOfBoardSprite :int = Constants.MAX_PUZZLE_HEIGHT - (_rows * _tileSize);
//            var gapBetweenTopOfPuzzleAndTopOfBoardSprite :int = _sprite.height - (_rows * _tileSize);
//            var gapBetweenTopOfPuzzleAndTopOfBoardSprite :int = Constants.PUZZLE_HEIGHT - (_rows * _tileSize);
            return (localY - gapBetweenTopOfPuzzleAndTopOfBoardSprite) / _tileSize;
//            return localY / _tileSize;;
        }
       

        public function resetPositionOfPiecesNotMoving( e :TimerEvent) :void
        {
            
            if( _updating || _pendingDelta) {
                return;
            }
            var piece :JoinGamePiece;
            
            for each ( piece in _boardPieces) {
                if(piece != null && piece.hasTasks()) {
                    return;
                }
            }
//            log.debug("resetPositionOfPiecesNotMoving( timer)");
//            log.debug("****Updating piece positions");
            var selectedPieceCol :int = -1;
            if(_selectedPiece != null) {
                selectedPieceCol = idxToX( _selectedPiece.boardIndex);
            }
            
            for each ( piece in _boardPieces) {
                if(piece != null && !piece.hasTasks() && idxToX(piece.boardIndex) != selectedPieceCol) {
                    piece.x = getPieceXLoc(  idxToX(piece.boardIndex));
                    piece.y = getPieceYLoc(  idxToY(piece.boardIndex));
                }
            }   
            
            
            /* Do a little cleanup while we're at it.*/
            var arraycopy :Array = _animationsToDestroyWhenIDie.slice();
            for (var k :int = 0; k < arraycopy.length; k++) {
                var s :SceneObject = arraycopy[k] as SceneObject;
                if( s != null && !s.isLiveObject) {
                    _animationsToDestroyWhenIDie[k] = null;
                }
            }
        }
        
        public function resetPositionOfPieces() :void
        {
//            log.debug("resetPositionOfPieces()");
            for each (var piece :JoinGamePiece in _boardPieces) {
                if(piece != null) {
//                    piece.removeAllTasks();
                    piece.x = getPieceXLoc(  idxToX(piece.boardIndex));
                    piece.y = getPieceYLoc(  idxToY(piece.boardIndex));
                }
            }   
               
        }

        protected function mouseMove (e :MouseEvent) :void
        {
            if(!e.buttonDown) {
                mouseClicked( e);
            }
//            _sprite.graphics.clear();
//            _sprite.graphics.lineStyle(1, 0x00ffff);
//            _sprite.graphics.drawRect( -3, -3, Constants.PUZZLE_TILE_SIZE*_cols + 6, Constants.PUZZLE_TILE_SIZE*_rows + 6);
            
            
            var mouseIndexX :int = ((e.localX) / (_tileSize));
//            var mouseIndexY :int = ((e.localY) / (_tileSize ));
            var mouseIndexY :int = getYRelativeToPuzzleArea(e.localY);
//            log.debug("raw mouse (" + e.localX + ", " + e.localY + ")");
            /* Adjust mouse for difference between board sprite and puzzle height */
//            var gapBetweenTopOfPuzzleAndTopOfBoardSprite :int = _sprite.height - (_rows * _tileSize);
//            mouseIndexY = (e.localY - gapBetweenTopOfPuzzleAndTopOfBoardSprite) / _tileSize;
                
//            log.debug("adjusted mouse (" + mouseIndexX + ", " + mouseIndexY + ")");
//            AppContext.gameCtrl.game.systemMessage("raw mouse (" + e.localX + ", " + e.localY + ")\nadjusted mouse (" + mouseIndexX + ", " + mouseIndexY + ")");
            var row :int;
//            log.debug(" mouse move " + mouseIndexX + ", " + mouseIndexY);
//            AppContext.gameCtrl.game.systemMessage(" mouseMove local=(" + e.localX + ", " + e.localY + "), " + mouseIndexX + ", " + mouseIndexY);
            
                if(_selectedPiece != null)
                {
                    row = _boardRepresentation.idxToX( _selectedPiece.boardIndex);
                    var pieceToSwap:JoinGamePiece = getPieceAt(row, mouseIndexY);
                    
//                    AppContext.gameCtrl.game.systemMessage(" _selectedPiece.y=(" + _selectedPiece.y);
                    
                    _selectedPiece.y = e.localY - _selectedPiece.height/2;
                    
                    _sprite.setChildIndex( _selectedPiece.displayObject, _sprite.numChildren - 1);
                    
                    
                    var highestPiece :JoinGamePiece = getHighestSwappablePiece(_selectedPiece);
                    var lowestY :int = getPieceYLoc( idxToY(highestPiece.boardIndex));
                    var lowestPiece :JoinGamePiece = getLowestSwappablePiece(_selectedPiece);
                    var highestY :int = getPieceYLoc( idxToY(lowestPiece.boardIndex)) ;
                    var barHeight :int = highestY - lowestY;
                    
                    
                    
                    if( _selectedPiece.y < lowestY){
                        _selectedPiece.y = lowestY;
                        pieceToSwap = highestPiece;
//                        return;
                    }
                    else if( _selectedPiece.y > highestY){
                        _selectedPiece.y = highestY;
                        pieceToSwap = lowestPiece;
//                        return;
                    }
                    
//                    else if( _selectedPiece.y  > (_boardRepresentation._rows  - 1)* _selectedPiece.size )
//                    {
//                        _selectedPiece.y = (_boardRepresentation._rows  - 1)* _selectedPiece.size;
//                    }
                    
                    
                    if(pieceToSwap == _selectedPiece){
                        var col :int = idxToX( _selectedPiece.boardIndex);
                        for( var j :int = 0; j < _rows; j++){
                            var piece :JoinGamePiece = getPieceAt(col, j) as JoinGamePiece;
                            if(piece != null && piece != _selectedPiece){
                                piece.y = getPieceYLoc(idxToY(piece.boardIndex));
                            }
                        }
                    }
                    else if(pieceToSwap != _selectedPiece && pieceToSwap.type == Constants.PIECE_TYPE_NORMAL)
                    {
                        
                        
                        if(_mostRecentSwappedPiece == pieceToSwap)
                        {
//                            log.debug("We have already swapped that piece. WTF is this doing");
                            return;
                        }
                        addTask(new PlaySoundTask("piece_move"));
                        _mostRecentSwappedPiece = pieceToSwap;
                        
                        
                        
                        
//                        return;
                        
//                        var wasSwaps:Boolean = false;
                        var currentSelectedPieceY :int = _selectedPiece.y;
                        movePieceToLocationAndShufflePieces(idxToX(_selectedPiece.boardIndex), idxToY(_selectedPiece.boardIndex), idxToX(pieceToSwap.boardIndex), idxToY(pieceToSwap.boardIndex), false);
//                        log.debug("view after move and shuffle " + toString() );
                        _selectedPiece.y = currentSelectedPieceY;
                        
                        
//                        shufflePieceToLocation( , row, , row);
//                        swapPieces (_selectedPiece.boardIndex, pieceToSwap.boardIndex);
//                        _lastSwap[0] =  idxToX(_selectedPiece.boardIndex);
//                        _lastSwap[1] =  idxToY(_selectedPiece.boardIndex);
//                        var joins:Array = updateBoardReturningJoinsThatForm();
//                        
//                        while(joins.length > 0)
//                        {
//                            wasSwaps = true;
//                            (parent as JoinGame).notifyOfJoinsFound(joins);
//                             joins = updateBoardReturningJoinsThatForm();
//                        }
//                        if(!wasSwaps)
//                        {
////                            swapPiecesInternal (_selectedPiece.boardIndex, pieceToSwap.boardIndex);
//                            
////                            var tempIndex = _selectedPiece.boardIndex;
////                            _selectedPiece.boardIndex = pieceToSwap.boardIndex;
////                            pieceToSwap.boardIndex = tempIndex;
////                            pieceToSwap.y = getPieceYLoc( idxToY(_selectedPiece.boardIndex));
////                            _selectedPiece.y = getPieceYLoc( idxToY(pieceToSwap.boardIndex));
////                            
////                            _board[_selectedPiece.boardIndex] = _selectedPiece.boardIndex;
////                            _board[pieceToSwap.boardIndex] = pieceToSwap.boardIndex;
//                        }
//                        else
//                        {
//                            sendServerCurrentState();
//                            _selectedPiece = null;
//                            pieceToSwap = null;
//                            _lastSwappedPiece = null;
//                            updatePieceDimensionsAndCoordinatesAndAddPiecesIfNecessary();
//                        }
                    }
                    
                    
                    return;
                    
                    
                    
                    
                    var lowestSwappableY:int = idxToY(getHighestSwappablePiece( _selectedPiece).boardIndex);
                    var highestSwappableY:int = idxToY(getLowestSwappablePiece( _selectedPiece).boardIndex);
    
                    //Reset the location of the pieces in the same row
                    row = idxToX( _selectedPiece.boardIndex);
//                    for(var j: int = 0; j < _rows ; j++)
//                    {
//                        var piece: JoinGamePiece = getPieceAt(row, j);
//                        if( piece != null && piece != _selectedPiece)
//                        {
//                            piece.y = getPieceYLoc(j);
//                            
//                        }
//                    }
//                    _selectedPiece.y = e.localY - _tileSize/2;
                        
//                    var mouseIndexX :int = (e.localX / (_tileSize - 1));
                    mouseIndexY = (e.localY / (_tileSize ));
                    
                    if(mouseIndexY <=highestSwappableY && mouseIndexY >= lowestSwappableY  )
                    {
                        
                    
                        var pieceToSwap:JoinGamePiece = getPieceAt(row, mouseIndexY);
                        _mouseOverIndex = getPieceAt(row, mouseIndexY).boardIndex;
                        _mouseOverColor = getPieceAt(row, mouseIndexY).color;
//                        
                        if ( _mouseOverIndex != _previousMouseOverIndex )
                        {
                            if(_previousMouseOverIndex != -1)
                                (_board[_previousMouseOverIndex] as JoinGamePiece).color = _previousMouseOverColor;//Reset the previous 
                            _previousMouseOverIndex = _mouseOverIndex;
                            _previousMouseOverColor = _mouseOverColor;
                            
                            (_board[_selectedIndex] as JoinGamePiece).color = _mouseOverColor;
                            if(_previousMouseOverIndex != -1)
                                (_board[_previousMouseOverIndex] as JoinGamePiece).color = _selectedColor;
                            
                            
//                        }

//                        if(_lastSelectedPieceRow != null)
//                        {
//                            _lastSelectedPieceRow.y = getPieceYLoc( idxToY(_lastSelectedPieceRow.boardIndex) );
//                        }
                        
                        //Only do the checking and moving if the selected piece has moved
//                        if(pieceToSwap != null  && pieceToSwap != _selectedPiece && pieceToSwap !=_lastSwappedPiece)
//                        {
//                            _selectedPieceSprite.x = pieceToSwap.x;
//                            _selectedPieceSprite.y = pieceToSwap.y;
//                            addChild(_selectedPieceSprite);
//                            setChildIndex( _selectedPieceSprite, numChildren - 1);//Make sure it's on top  of the other pieces
//                            
//                            _lastSwappedPieceSprite.x = _selectedPiece.x;
//                            _lastSwappedPieceSprite.y = _selectedPiece.y;
//                            addChild(_lastSwappedPieceSprite);
//                            setChildIndex( _lastSwappedPieceSprite, numChildren - 1);//Make sure it's on top  of the other pieces
//                            
//                            _lastSwappedPiece = pieceToSwap;
                            
//                            LOG("\nHERE");
//                            _lastSelectedPieceRow = idxToY(pieceToSwap.boardIndex);
//                            _lastSwappedPiece
    //                        setChildIndex( pieceToSwap, numChildren - 2);//Make sure it's on top  of the other pieces
                            
                            
//                            swapPiecesInternal (_selectedPiece.boardIndex, pieceToSwap.boardIndex);
                            
                            
//                            var tempIndex = _selectedPiece.boardIndex;
//                            _selectedPiece.boardIndex = pieceToSwap.boardIndex;
//                            pieceToSwap.boardIndex = tempIndex;
//                            
//                            _board[_selectedPiece.boardIndex] = _selectedPiece.boardIndex;
//                            _board[pieceToSwap.boardIndex] = pieceToSwap.boardIndex;
                            
                            var wasSwaps:Boolean = false;
                            var joins:Array = updateBoardReturningJoinsThatForm();
                            while(joins.length > 0)
                            {
                                wasSwaps = true;
                                (parent as JoinGame).notifyOfJoinsFound(joins);
                                 joins = updateBoardReturningJoinsThatForm();
                            }
                //            setBoardFromCompactRepresentation(getBoardAsCompactRepresentation());
//                            LOG("\n after remove");
                //            printMatrix();
                            
                            
            
                            if(!wasSwaps)
                            {
//                                LOG(", There were no swaps");
//                                swapPiecesInternal (_selectedPiece.boardIndex, pieceToSwap.boardIndex);
                                
//                                var tempIndex = _selectedPiece.boardIndex;
//                                _selectedPiece.boardIndex = pieceToSwap.boardIndex;
//                                pieceToSwap.boardIndex = tempIndex;
//                                pieceToSwap.y = getPieceYLoc( idxToY(_selectedPiece.boardIndex));
//                                _selectedPiece.y = getPieceYLoc( idxToY(pieceToSwap.boardIndex));
//                                
//                                _board[_selectedPiece.boardIndex] = _selectedPiece.boardIndex;
//                                _board[pieceToSwap.boardIndex] = pieceToSwap.boardIndex;
                            }
                            else
                            {
//                                LOG(", There were swaps");
                                sendServerCurrentState();
                                _selectedPiece = null;
                                pieceToSwap = null;
                                _lastSwappedPiece = null;
                                updatePieceDimensionsAndCoordinatesAndAddPiecesIfNecessary();
                                
                                
                                
                                _previousMouseOverIndex = -1;
                                _previousMouseOverColor = -1;
                                _mouseOverIndex = -1;
                                _mouseOverColor = -1;
                    
                    
//                                _lastSelectedPieceRow = null;
                            }
                            
    //                        LOG("\n_selectedPiece.boardIndex="+_selectedPiece.boardIndex);
    //                        LOG("\nselected piece.y="+_selectedPiece.y);
    //                        LOG("\nadjusting to y="+pieceToSwap.y+" of potential piece ("+row+", " + mouseIndexY +"), color="+pieceToSwap.color);
                        }
                        
                        
//                        setChildIndex( _selectedPiece, numChildren - 1);//Make sure it's on top  of the other pieces
                    }
                }

        }
        
        
        /**
         * "Slides" the selected piece to the new piece location.  Only at the end (mouse release)
         * is the move sent to the JoingameServer.
         * 
         */
        protected function shufflePieceToLocation(pieceX :int, pieceY :int, locX :int, locY :int) :void
        {
            log.debug("Function deprecated, shufflePieceToLocation()!!!!!");
//            if( pieceX == locX || pieceY == locY)
//            {
//                return;
//            }
//            
//            //First set the selected piece to the target coords
//            
//            
//            
//            var increment:int = pieceY > locY ? -1 : 1;
//            //Swap up or down, depending on the relative position of the pieces.
//            for( var j:int = pieceY; pieceY > locY ? j > locY : j < locY ; j+= increment)
//            {
//                var swap1:int  = _boardRepresentation.coordsToIdx(px1, j);
//                var swap2:int  = _boardRepresentation.coordsToIdx(px1, j + increment);
//                
//                swapPieces (swap1,swap2);
//            }
            
        } 
        
//        public function movePieceToLocationAndShufflePiecesOLDDELETE(index1 :int, index2 :int) :void
//        {
//            log.debug("Function deprecated, movePieceToLocationAndShufflePiecesOLDDELETE()!!!!!");
//            
////            var px1 :int = idxToX(index1);
////            var py1 :int = idxToY(index1);
////            var px2 :int = idxToX(index2);
////            var py2 :int = idxToY(index2);
////            
////            if(px1 != px2)
////            {
//////                LOG("movePieceToLocationAndShufflePieces: x coords not identical");
////                return;    
////            }
////            
////            var increment:int = py1 > py2 ? -1 : 1;
//////            LOG("movePieceToLocationAndShufflePieces " + px1 + " " + py1 + " " + px2 + " " + py2 );
////            //Swap up or down, depending on the relative position of the pieces.
////            for( var j:int = py1; py1 > py2 ? j > py2 : j < py2 ; j+= increment)
////            {
////                var swap1:int  = coordsToIdx(px1, j);
////                var swap2:int  = coordsToIdx(px1, j + increment);
////                
//////                LOG("\nSwapping y " + j + " " +  (j + increment));
////                swapPieces (swap1,swap2);
////            }
//        }
        
        /**
         * Moves pieces and optionally change the index.  The index change relies on the 
         * confirmation from the JoingameServer.
         */
        public function movePieceToLocationAndShufflePieces(px1 :int, py1 :int, px2 :int, py2 :int, changeIndex :Boolean = true) :void
        {
            if( px1 != px2){
                log.debug("movePieceToLocationAndShufflePieces, pieces in idfferent rows, doing nothing");
                return;
            }
//            log.debug("movePieceToLocationAndShufflePieces( " + index1 + ", " + index2 + ")");
//            var px1 :int = idxToX(index1);
//            var py1 :int = idxToY(index1);
//            var py2 :int = idxToY(index2);
            
            var j :int;
            if(py1 == py2)
            {
                log.debug("movePieceToLocationAndShufflePieces, y coords same, doing nothing");
                return;    
            }
            
            //First set all the pieces to their normal values, except the first/selected piece
            for( j = 0; j < _rows ; j++)
            {
                if( j != py1 && getPieceAt(px1, j) != _selectedPiece && getPieceAt(px1, j) != null)//We don't reset the selected pieces poisition
                {
                    getPieceAt(px1, j).y = getPieceYLoc( idxToY( coordsToIdx(px1, j)));
                }
            }
//            setChildIndex( (_boardPieces[index1] as JoinGamePiece).displayObject, numChildren - 1);
            
            
//            log.debug("Before moving, Selected piece.y="+(_boardPieces[index1] as JoinGamePiece).y);
            if( _boardPieces[coordsToIdx(px1, py1)] != null) {
                (_boardPieces[coordsToIdx(px1, py1)] as JoinGamePiece).y = getPieceYLoc( idxToY(coordsToIdx(px1, py2)));
    //            log.debug("Setting selected piece.y="+(_boardPieces[index1] as JoinGamePiece).y);
                if(changeIndex){
                    (_boardPieces[coordsToIdx(px1, py1)] as JoinGamePiece).boardIndex = coordsToIdx(px2, py2);
                }
            }
            
            //Then go through the in between pieces, adjusting thier y coord by one piece height increment
            //If the first piece starts with a higher (lower y) than the second piece, it moves down, so 
            //all the other pieces must move up by one (lower their y by one).
            var increment:int = py1 < py2 ? 1 : -1;
            //Swap up or down, depending on the relative position of the pieces.
            for( j = py1 + increment; py1 > py2 ? j >= py2 : j <= py2 ; j+= increment) {
//                log.debug("changing piece (" + px1 + ", " + j + "), index=" + getPieceAt(px1, j).boardIndex);
                if( getPieceAt(px1, j) != null){
                    getPieceAt(px1, j).y = getPieceYLoc( idxToY( coordsToIdx(px1, j - increment)));
                    
                    if(changeIndex){
                        getPieceAt(px1, j).boardIndex = coordsToIdx(px1, j - increment);
                    }
                }
//                log.debug("setting y=" + getPieceAt(px1, j).y);
//                piece.y = getPieceYLoc(  _boardRepresentation.idxToY(k));
            }
            
            if(changeIndex){
                    resetPiecesArrayPosition();
            }
        }
        
        
        protected function doPiecesFall(): void
        {
            //Start at the bottom row moving up
            for(var j: int = _rows - 2; j >= 0 ; j--)
            {
                for(var i: int = 0; i <  _cols ; i++)
                {
                    var pieceIndex :int = coordsToIdx(i, j);
            
                    //Now drop the piece as far as there are empty spaces below it.
                    if( !(board._boardPieceTypes[pieceIndex] == Constants.PIECE_TYPE_NORMAL || board._boardPieceTypes[pieceIndex] == Constants.PIECE_TYPE_DEAD || board._boardPieceTypes[pieceIndex] == Constants.PIECE_TYPE_POTENTIALLY_DEAD))
                    {
                        continue;
                    } 
                    
                    var yToFall: int = j;
                
                
                    while(yToFall < board._rows)
                    {
                        if(  board.isPieceAt(i, yToFall+1) &&  board._boardPieceTypes[ board.coordsToIdx(i, yToFall+1) ] == Constants.PIECE_TYPE_EMPTY)
                        {
                            yToFall++;
                        }
                        else
                        {
                            break;
                        }
                    }
                    
                    
                    if( yToFall != j)
                    {
                        board.swapPieces(board.coordsToIdx(i, j), board.coordsToIdx(i, yToFall));
                    }
                
                
                }
            }
            
        }
         


        protected function mouseDown (e :MouseEvent) :void
        {
            _updating = true;
            var col :int;
            var i :int;
            var j :int;
            var piece :JoinGamePiece;
                
            var mouseIndexX :int = ((e.localX) / (_tileSize));
            var mouseIndexY :int = getYRelativeToPuzzleArea(e.localY);
                
            if(_selectedPiece == null) {
                _selectedPiece = getPieceAt(mouseIndexX, mouseIndexY);
                
                if(_selectedPiece != null){
                    col = idxToX( _selectedPiece.boardIndex);
                    for( j = 0; j < _rows; j++){
                        piece = getPieceAt(col, j) as JoinGamePiece;
                        if(piece != null && piece != _selectedPiece){
                            piece.y = getPieceYLoc(idxToY(piece.boardIndex));
                        }
                    }
                }
                    
                if(_selectedPiece != null  && _selectedPiece.type == Constants.PIECE_TYPE_NORMAL) {//Handle the row highlighting {
                    _columnHighlight.graphics.clear();
                    _columnHighlight.graphics.lineStyle(4, 0xf2f2f2, 0.5);
                    var highestPiece:JoinGamePiece = getHighestSwappablePiece(_selectedPiece);
                    var highestY:int = getPieceYLoc( idxToY(highestPiece.boardIndex));
                    
                    var lowestPiece:JoinGamePiece = getLowestSwappablePiece(_selectedPiece);
                    var lowestY:int = getPieceYLoc( idxToY(lowestPiece.boardIndex)) + _tileSize;
                    var barHeight:int = lowestY - highestY  ;
                    
                    _columnHighlight.graphics.drawRect(  getPieceXLoc( idxToX(_selectedPiece.boardIndex)) ,   highestY , _tileSize, barHeight);
                    _sprite.addChild(_columnHighlight);
                    
                }
                else {
                    _selectedPiece = null;
                }
            }
            else {//How does this happen
                
                log.debug("\nNot sure about this, mouse down, but we already have a selected piece.  Resetting positions just to be sure.");
                
                col = idxToX( _selectedPiece.boardIndex);
                for( j  = 0; j < _rows; j++){
                    piece = getPieceAt(col, j) as JoinGamePiece;
                    if(piece != null){
                        piece.y = getPieceYLoc(idxToY(piece.boardIndex));
                    }
                }
                _selectedPiece = null;
            }
        }
        
        
        protected function getHighestSwappablePiece(piece:JoinGamePiece): JoinGamePiece
        {
            var i:int = idxToX(piece.boardIndex);
            var possiblePiece:JoinGamePiece = null;
            for(var j:int = idxToY(piece.boardIndex) - 1; j >= 0; j--)
            {
                if(getPieceAt(i, j) != null && getPieceAt(i, j).type == Constants.PIECE_TYPE_NORMAL)
                {
                    possiblePiece = getPieceAt(i, j);
                }
                else
                {
                    break;
                }
            }
            return possiblePiece == null ? piece : possiblePiece;
        }
        protected function getLowestSwappablePiece(piece:JoinGamePiece): JoinGamePiece
        {
            var i:int = idxToX(piece.boardIndex);
            var possiblePiece:JoinGamePiece = null;
            for(var j:int = idxToY(piece.boardIndex) + 1; j < _rows; j++)
            {
                if(getPieceAt(i, j) != null && getPieceAt(i, j).type == Constants.PIECE_TYPE_NORMAL)
                {
                    possiblePiece = getPieceAt(i, j);
                }
                else
                {
                    break;
                }
            }
            return possiblePiece == null ? piece : possiblePiece;
        }
        
        
        
        public function get tileSize () :int
        {
            return _tileSize;
        }
        
        public function set board (board :JoinGameBoardRepresentation) :void
        {
            
            if (board == null)
            {
                throw new Error("JoinGameBoardGameArea Problem!!! boardRepresentation should not be null");
            }
            
            _boardRepresentation = board;
            
            _rows = _boardRepresentation._rows;
            _cols = _boardRepresentation._cols;
            
            updatePieceDimensionsAndCoordinatesAndAddPiecesIfNecessaryOLD();
            
            
        }
        
        public function get board () :JoinGameBoardRepresentation
        {
            return _boardRepresentation;
        }


        public function set activePlayersBoard (b :Boolean) :void
        {
            _activePlayersBoard = b;
        }
        
        
        public function coordsToIdx (x :int, y :int) :int
        {
            return (y * _cols) + x;
        }
    
        public function idxToX (index :int) :int
        {
            return (index % _cols);
        }
        
        public function idxToY (index :int) :int
        {
            return (index / _cols);
        }
        
        public function isPieceAt (x :int, y :int) :Boolean
        {
            return x >= 0 && x < _cols && y >= 0 && y < _rows;
        }
        
        public function isEmptyPiecesUnderThisPiece( piece :JoinGamePiece ) :Boolean
        {
            var i :int = idxToX( piece.boardIndex );
            for( var j :int = idxToY( piece.boardIndex) + 1; j < _rows; j++) {
                if( getPieceAt( i, j) == null) {
                    return true;
                }
            }
            return false;
        }
        
        
        public function addPieceAtPosition(i :int, j :int, type :int, color :int) :JoinGamePiece
        {
            if( getPieceAt(i, j) != null){
                log.debug("adding a piece to (" + i + ", " + j + "), but a piece already exists="+getPieceAt(i, j) );
                _boardPieces[ coordsToIdx(i, j) ] = null;
            }
            
            var piece :JoinGamePiece = new JoinGamePiece(Constants.PUZZLE_TILE_SIZE);
            piece.type = type;
            if(piece.type == Constants.PIECE_TYPE_INACTIVE) {
                piece.visible = false;
            }
            piece.color = color;
            piece.boardIndex = coordsToIdx(i, j);
            _boardPieces[ coordsToIdx(i, j) ] = piece;
            piece.x = getPieceXLoc( i );
            piece.y = getPieceYLoc( j );
            
            if(this.db != null) {
                // add the Piece to the mode, as a child of the board sprite
                this.db.addObject(piece, _sprite);
                /* Make sure the addes pieces are UNDER any any pieces, it looks better*/
                _sprite.setChildIndex( piece.displayObject, 1);
            }
            else {
                log.debug(" no db for adding the piece");
            }
            
            
            if( isLiveObject && _sprite.contains( _backgroundSprite)){
                _sprite.setChildIndex( _backgroundSprite, 0);
            }
            return piece;
            
        }
        /**
        * Events update the pieces board index, this must
        * then be reflected in the actual array position.
        * 
        */
        public function resetPiecesArrayPosition() :void
        {
            var tempPieceArray :Array = _boardPieces.slice();
            _boardPieces.length = 0;
            
            for(var k :int = 0; k < tempPieceArray.length; k++){
                if( tempPieceArray[k] != null){
                    _boardPieces[ (tempPieceArray[k] as JoinGamePiece).boardIndex ] = tempPieceArray[k];
                }
            }
            
        }
        
        public function resetIndices() :void
        {
            for(var k :int = 0; k < _boardPieces.length; k++){
                if( _boardPieces[k] != null){
                    (_boardPieces[ k ] as JoinGamePiece).boardIndex = k;
                }
            }
        }
        
        
        public function isModelAndViewSame() :Boolean
        {
            for(var k :int = 0; k < _boardRepresentation._boardPieceTypes.length; k++){
                var piece :JoinGamePiece = _boardPieces[k] as JoinGamePiece;
                if( piece != null) {
                    if(piece.type != _boardRepresentation._boardPieceTypes[k] || piece.color != _boardRepresentation._boardPieceColors[k]){
                        
                        
                        log.debug("view != model: " + _boardRepresentation + this);
                        
                        return false;
                    }
                }
                else {//if the view piece is null, it's in the process of changing, so sadly ignore it.
                    
                }
            }
            return true;
        }
        
        
        override public function toString() :String
        {
            var s :String = "player id=" + _boardRepresentation.playerID + "\n";
            for( var j :int = 0; j < _rows; j++){
                for( var i :int = 0; i < _cols; i++){
                    var piece :JoinGamePiece = getPieceAt(i,j);
                    if(piece == null){
                        s += "\tnull";
                    }
                    else{
                        s += "\t" + piece.boardIndex;
                    }
                }
                s += "\n";
            }
            s += "\n";
            for( j = 0; j < _rows; j++){
                for( i = 0; i < _cols; i++){
                    piece = getPieceAt(i,j);
                    if(piece == null){
                        s += "\tnull";
                    }
                    else{
                        s += "\t" + piece.type;
                    }
                }
                s += "\n";
            }
            return s;
        }
        
        public function getLowestInactiveRow( col :int ) :int
        {
            var row :int = -1;
            for( var j :int = 0; j < _rows; j++) {
                if( getPieceAt( col, j) == null || getPieceAt( col, j).type == Constants.PIECE_TYPE_INACTIVE) {
                    row = j;
                }
            }
            return row;
        } 
        
        public function startTimedBottomRowWobble() :void
        {
            if(!wobbleTimer.running) {
                wobbleTimer.reset();
                wobbleTimer.start();
            }
        }
        public function stopTimedBottomRowWobble() :void
        {
            wobbleTimer.stop();
        }
        
        public function isBottomTimerRunning() :Boolean
        {
            return wobbleTimer.running;
        }
        
        public function wobbleBottomRow( e :TimerEvent ) :void
        {
            for(var i :int = 0; i < _cols; i++) {
                var piece :JoinGamePiece = getPieceAt( i, _rows - 1);
                if(piece != null && piece.type != Constants.PIECE_TYPE_INACTIVE) {
                    
                    var serialAnimation :SerialTask = new SerialTask(); 
                    serialAnimation.addTask( LocationTask.CreateEaseIn( getPieceXLoc( idxToX(piece.boardIndex)) - 2, piece.y, 0.05) );
                    serialAnimation.addTask( LocationTask.CreateEaseIn( getPieceXLoc( idxToX(piece.boardIndex)) + 2, piece.y, 0.1) );
                    serialAnimation.addTask( LocationTask.CreateEaseIn( getPieceXLoc( idxToX(piece.boardIndex)), piece.y, 0.05) );
                    
                    piece.addNamedTask(JoinGameBoardsView.WOBBL_TASK_NAME, serialAnimation);  
                }
            }
        }
        
        
        
        public function get updating() :Boolean
        {
            return _updating;
        }
        public function set updating( u :Boolean ) :void
        {
            _updating = u;
        }
        
        public function isMovingPieces() :Boolean 
        {
            for each (var piece :JoinGamePiece in _boardPieces) {
                if(piece != null) {
                    if( piece.hasTasks() ) {
                        return true;
                    }
                }
            }
            return false;
        }
        
        public function removePieceTasksAndSetCorrectLocations() :void
        {
            log.debug("removePieceTasksAndSetCorrectLocations()");
            var selectedPieceCol :int = -1;
            
            for each (var piece :JoinGamePiece in _boardPieces) {
                if(piece != null && idxToX(piece.boardIndex) != selectedPieceCol) {
                    if( piece.hasTasks() ) {
                        piece.removeAllTasks();
                    }
                    piece.x = getPieceXLoc(  idxToX(piece.boardIndex));
                    piece.y = getPieceYLoc(  idxToY(piece.boardIndex));
                    piece.visible = true;
                    if( piece.color != _boardRepresentation._boardPieceColors[piece.boardIndex]) {
                        piece.color = _boardRepresentation._boardPieceColors[piece.boardIndex];
                    }
                    if( piece.type != _boardRepresentation._boardPieceTypes[piece.boardIndex]) {
                        piece.type = _boardRepresentation._boardPieceTypes[piece.boardIndex];
                    }
                }
            }
        }
        
        
        
        private var wobbleTimer :Timer;
        private var _activePlayersBoard:Boolean;
        public var _boardRepresentation: JoinGameBoardRepresentation;
        private var _tileSize : int;
        public var _boardPieces: Array;
        
        private var _selectedPiece : JoinGamePiece;
        private var _mostRecentSwappedPiece : JoinGamePiece;
        
        private var _columnHighlight :Sprite;
        
        
        public var _control :GameControl;
        
        private var LOG_TO_GAME:Boolean = false;
        
        
        protected static var SWF_CLASSES :Array;
        protected static const SWF_CLASS_NAMES :Array = [ "piece_01", "piece_02", "piece_03", "piece_04", "piece_05" ];
        
        public var _sprite :Sprite;
        
        protected var _backgroundSprite :Sprite;
        public var _backgroundPieces :Array;
        protected var _backgroundClassObserver :Class;
        protected var _backgroundClassActivePlayer :Class;
        public var _pendingDelta :Boolean;
        
        public var _rows :int;
        public var _cols :int;
        
        /**
        * Sometimes the board view gets out of sync because of numerous simultaneous updates.
        * Every half a second, the board checks itself and it's pieces, correcting if necessary.
        */
        private var _updateTimer:Timer;
        private var _updating :Boolean;
        
        private var _rand :Random;
        
        /**
        * Some animations, e.g. joins, are not the children of this objects sprite, 
        * but nevertheless must quickly be destroyed when this object is destroyed
        */
        public var _animationsToDestroyWhenIDie :Array;
        
        private static const log :Log = Log.getLog(JoinGameBoardGameArea);
        
    }
}

