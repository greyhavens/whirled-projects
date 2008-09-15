package joingame.view
{
    import com.threerings.util.Random;
    import com.whirled.contrib.simplegame.*;
    import com.whirled.contrib.simplegame.audio.*;
    import com.whirled.contrib.simplegame.objects.*;
    import com.whirled.contrib.simplegame.tasks.*;
    import com.whirled.contrib.simplegame.util.*;
    import com.whirled.game.GameControl;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    import joingame.*;
    import joingame.model.*;
    import joingame.net.JoinGameEvent;
    
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
            
            _rand = new Random();
            
            _sprite = new Sprite();
            _sprite.mouseEnabled = false;
            _sprite.mouseChildren = false;
            
            _columnHighlight = new Sprite();
            
            _boardPieces = new Array();
            
//            this.tileSize = Constants.PUZZLE_TILE_SIZE;
            _tileSize = Constants.PUZZLE_TILE_SIZE;
            
            
            
            _updateTimer = new Timer(1000, 0);
            _updateTimer.addEventListener(TimerEvent.TIMER, checkAndUpdateBoardState);
            _updateTimer.start();
            
            
//            _sprite.graphics.lineStyle(1, 0, 1 ); 
//            _sprite.graphics.beginFill(1, 0);               
//            _sprite.graphics.drawRect( 0 , 0 , _tileSize*Constants.PUZZLE_STARTING_COLS - 1, Constants.PUZZLE_HEIGHT - 1);
//            _sprite.graphics.endFill();
            
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
        
        
        
            
            
            
            _activePlayersBoard = activePlayersBoard;
            
            //Add mouse listeners if appropriate
            if(_activePlayersBoard)
            {
                _sprite.mouseEnabled = true;
                _sprite.addEventListener(MouseEvent.CLICK, mouseClicked);
                _sprite.addEventListener(MouseEvent.ROLL_OUT, mouseOut);
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
                         
            if(e.localX <= 0 || e.localX >= _sprite.width || e.localY <= 0 || e.localY >= _sprite.height) { 
                mouseClicked( e );
            }
        }
        
        public function doBoardDistructionAnimation() :void
        {
            var piece :JoinGamePiece;
            for each ( piece in _boardPieces) {
                _sprite.removeChild( piece.displayObject);
            }
            
            _sprite.graphics.beginFill(0,0);
            _sprite.graphics.drawRect(0,0,400, 2000);
            _sprite.graphics.endFill();
            
            for each ( piece in _boardPieces) {
                _sprite.addChild( piece.displayObject);
            }
            
            var fallingTime :Number = 1.0;
            for each ( piece in _boardPieces) {
                var toX :int = piece.x + _rand.nextInt(3) * (_rand.nextBoolean() ? 1 : -1);
                var toY :int = piece.y + 300 + _rand.nextInt(10);
                var fallingTask :LocationTask = LocationTask.CreateLinear( toX, toY, fallingTime);
                var fallingTask2 :LocationTask = LocationTask.CreateEaseIn( toX, toY, fallingTime);
                var rotationTask :RotationTask = RotationTask.CreateLinear( _rand.nextInt(360) * (_rand.nextBoolean() ? 1 : -1), fallingTime);
                var parallelTask :ParallelTask = new ParallelTask( fallingTask, rotationTask);
                var serialAnimation :SerialTask = new SerialTask(); 
                var delay :Number = ((_rows - 1) - idxToY( piece.boardIndex)) * 0.07 ;
//                AppContext.LOG("delay=" + delay);
                var timerTask :TimedTask = new TimedTask( delay );
                serialAnimation.addTask( timerTask );
                serialAnimation.addTask( parallelTask );
                serialAnimation.addTask( new SelfDestructTask() );
                piece.removeAllTasks();
                piece.addTask( serialAnimation );
            }
            serialAnimation = new SerialTask();
            serialAnimation.addTask( new TimedTask( 5000 ) );
//            serialAnimation.addTask( LocationTask.CreateEaseOut( this.x, this.y + this.height + 100, 5.8));
            serialAnimation.addTask( new SelfDestructTask() );
            this.addTask( serialAnimation );
            
        }
        
        override public function destroySelf():void
        {
            _updateTimer.removeEventListener(TimerEvent.TIMER, checkAndUpdateBoardState);
            _updateTimer.stop();


            for each (var piece :JoinGamePiece in _boardPieces) {
                if(piece != null) {
                    piece.destroySelf();
                }
            }
            
            if(_activePlayersBoard)
            {
                _sprite.removeEventListener(MouseEvent.CLICK, mouseClicked);
                _sprite.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
                _sprite.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
            }
            super.destroySelf();
        }
        
        public function doBoardEnterFromSideAnimation( fromDirection :int) :void//, toX :int, toY :int
        {
            x = Constants.GUI_MIDDLE_BOARD_CENTER + 800*(fromDirection == Constants.LEFT ? -1 : 1) ;
            var toX :int = (fromDirection == Constants.LEFT ? Constants.GUI_LEFT_BOARD_CENTER : Constants.GUI_RIGHT_BOARD_CENTER) - this.width/2;
            updateYBasedOnBoardHeight();
            
//            for each (var piece :JoinGamePiece in _boardPieces) {
//                var toX :int = piece.x + _rand.nextInt(5) * (_rand.nextBoolean() ? 1 : -1);
//                var toY :int = piece.y + _rand.nextInt(20);
//                var fallingTask :LocationTask = LocationTask.CreateEaseOut( toX, toY, 5.8);
//                var rotationTask :RotationTask = RotationTask.CreateEaseOut( _rand.nextInt(360) * (_rand.nextBoolean() ? 1 : -1), 5.0);
//                var parallelTask :ParallelTask = new ParallelTask( fallingTask, rotationTask);
//                var serialAnimation :SerialTask = new SerialTask(); 
//                serialAnimation.addTask( parallelTask );
//                serialAnimation.addTask( new SelfDestructTask() );
//                piece.removeAllTasks();
//                piece.addTask( serialAnimation );
//            }
            this.addTask( LocationTask.CreateEaseIn( toX, this.y, Constants.BOARD_ENTER_DELAY) );
            
        }
        
        public function doBoardEnterFromBottomAnimation( toX :int) :void//, toX :int, toY :int
        {
            x = toX ;
            updateYBasedOnBoardHeight();
            var toY :int = y;
            y = 1000;
//            for each (var piece :JoinGamePiece in _boardPieces) {
//                var toX :int = piece.x + _rand.nextInt(5) * (_rand.nextBoolean() ? 1 : -1);
//                var toY :int = piece.y + _rand.nextInt(20);
//                var fallingTask :LocationTask = LocationTask.CreateEaseOut( toX, toY, 5.8);
//                var rotationTask :RotationTask = RotationTask.CreateEaseOut( _rand.nextInt(360) * (_rand.nextBoolean() ? 1 : -1), 5.0);
//                var parallelTask :ParallelTask = new ParallelTask( fallingTask, rotationTask);
//                var serialAnimation :SerialTask = new SerialTask(); 
//                serialAnimation.addTask( parallelTask );
//                serialAnimation.addTask( new SelfDestructTask() );
//                piece.removeAllTasks();
//                piece.addTask( serialAnimation );
//            }
            this.addTask( LocationTask.CreateEaseIn( toX, toY, Constants.BOARD_ENTER_DELAY) );
            
        }
        
        private function checkAndUpdateBoardState(event: TimerEvent):void
        {
            if( _boardRepresentation.playerID <= 0) {
                return;
            }
//            AppContext.gameCtrl.game.systemMessage("checkAndUpdateBoardState");
//            resetPositionOfPiecesNotMoving();
            
            
            var isDeadBottomRow :Boolean = true;
            var i :int;
            var piece :JoinGamePiece;
            
            for(i = 0; i < _cols; i++) {
                piece = getPieceAt( i, _rows - 1);
                if(piece != null && piece.type == Constants.PIECE_TYPE_NORMAL) {
                    isDeadBottomRow = false;
                    break;
                }
            }
            if(isDeadBottomRow) {
                AppContext.LOG("animating bottom wobble");
                for(i = 0; i < _cols; i++) {
                    piece = getPieceAt( i, _rows - 1);
                    if(piece != null && piece.type != Constants.PIECE_TYPE_INACTIVE) {
                        
                        var serialAnimation :SerialTask = new SerialTask(); 
                        serialAnimation.addTask( LocationTask.CreateEaseIn(piece.x - 2, piece.y, 0.05) );
                        serialAnimation.addTask( LocationTask.CreateEaseIn(piece.x + 2, piece.y, 0.1) );
                        serialAnimation.addTask( LocationTask.CreateEaseIn(piece.x, piece.y, 0.05) );
                        piece.addNamedTask(JoinGameBoardsView.WOBBL_TASK_NAME, serialAnimation, true);  
                    }
                }
            }
                
        }
        
        override public function get displayObject () :DisplayObject
        {
            return _sprite;
        } 
        
        
        
        
        /** Respond to messages from other clients. */
        protected function boardChanged (event :JoinGameEvent) :void
        {
            AppContext.LOG("DEPRECATED, should not be called, BoardUpdateEvent: Board updated, so updating display");
            updatePieceDimensionsAndCoordinatesAndAddPiecesIfNecessaryOLD();            
        }
        
        
        public function getPieceXLoc (xCoord :int) :int
        {
//            return ((xCoord + 0.5) * _tileSize) - xCoord;
            return xCoord * _tileSize;
        }
    
        public function getPieceYLoc (yCoord :int) :int
        {
//            var gapBetweenTopOfPuzzleAndTopOfBoardSprite :int = Constants.PUZZLE_HEIGHT - (_rows * _tileSize);
//            AppContext.LOG("_sprite.height="+_sprite.height);
//            AppContext.LOG("_rows="+_rows);
//            AppContext.LOG("_tileSize="+_tileSize);
//            AppContext.LOG("gapBetweenTopOfPuzzleAndTopOfBoardSprite="+gapBetweenTopOfPuzzleAndTopOfBoardSprite);
//            AppContext.LOG("for yCoord="+yCoord+", Yloc="+ (yCoord * _tileSize + gapBetweenTopOfPuzzleAndTopOfBoardSprite) );
//            return yCoord * _tileSize + gapBetweenTopOfPuzzleAndTopOfBoardSprite;
            
            return yCoord * _tileSize;
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
//            AppContext.LOG("\nupdatePieceDimensionsAndCoordinatesAndAddPiecesIfNecessary()\n ");
            removeAllBoardComponents();
            
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
//                AppContext.LOG(" piece color="+piece.color + ", x="+piece.x + ", piece.y="+piece.x + ", size="+piece.size);
            }
            
//            
            addAllBoardComponents();
            
            
        }
        
        public function updateYBasedOnBoardHeight() :void
        {
//            if(this.y != AppContext.gameHeight - _rows*_tileSize) {
//                this.y = AppContext.gameHeight - _rows*_tileSize;
                this.y = AppContext.gameHeight - _sprite.height - Constants.GUI_BOARD_FLOOR_GAP;
                
                //Update the pieces too. 
//                for each (var piece :JoinGamePiece in _boardPieces) {
//                    if(piece != null && !piece.hasTasks()) {
//                        piece.x = getPieceXLoc( idxToX( piece.boardIndex));
//                        piece.y = getPieceYLoc( idxToY( piece.boardIndex));
//                    }
//                }    
//            }
            
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
////                        AppContext.LOG(" no db for adding the piece");
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
        
        
                
        protected function mouseClicked (e :MouseEvent) :void
        {
//            AppContext.LOG("\nmouseClicked");
//            AppContext.gameCtrl.game.systemMessage
//            AppContext.LOG("mouseclicked, width, height=" + this.width + ", " + this.height);
            
//            _boardRepresentation.playerID = _control.game.getMyId();
//            AppContext.gameCtrl.net.sendMessageToAgent(Server.BOARD_UPDATE_REQUEST,  {});
            
//            resetPositionOfPiecesNotMoving();
            if( _selectedPiece != null )
            {
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
//                AppContext.LOG("mouseclicked, coords=" + mouseIndexX + ", " + mouseIndexY);
//                AppContext.LOG("_selectedPiece = (" + _selectedPiece.x + ", " + _selectedPiece.y + ")");
                var row:int = _boardRepresentation.idxToX( _selectedPiece.boardIndex);
                var pieceToSwap:JoinGamePiece = getPieceAt(row, mouseIndexY);
                
                var highestPiece :JoinGamePiece = getHighestSwappablePiece(_selectedPiece);
                var lowestY :int = getPieceYLoc( idxToY(highestPiece.boardIndex));
                var lowestPiece :JoinGamePiece = getLowestSwappablePiece(_selectedPiece);
                var highestY :int = getPieceYLoc( idxToY(lowestPiece.boardIndex)) ;
                var barHeight :int = highestY - lowestY;
                
//                AppContext.LOG("_selectedPiece=" + _selectedPiece);
//                AppContext.LOG("before check: pieceToSwap=" + pieceToSwap);
//                
//                AppContext.LOG("before check: highestPiece=" + highestPiece);
//                AppContext.LOG("before check: lowestY=" + lowestY);
//                AppContext.LOG("before check: lowestPiece=" + lowestPiece);
//                AppContext.LOG("before check: highestY=" + highestY);
                
                if( _selectedPiece.y <= lowestY){
                    _selectedPiece.y = lowestY;
                    pieceToSwap = highestPiece;
//                    AppContext.LOG("swapping swap and highest");
                }
                else if( _selectedPiece.y >= highestY){
                    _selectedPiece.y = highestY;
                    pieceToSwap = lowestPiece;
//                    AppContext.LOG("swapping swap and lowest");
                }
                
//                AppContext.LOG("after check: highestPiece=" + highestPiece);
//                AppContext.LOG("after check: lowestPiece=" + lowestPiece);
//                   
//                   
//                AppContext.LOG("after check: pieceToSwap=" + pieceToSwap);
                 
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
                AppContext.LOG("selected piece is null");
            }
        }
        
        
        protected function requestMove( from :JoinGamePiece, target :JoinGamePiece) :void
        {
            
            if(from != null && target != null && from.boardIndex != target.boardIndex)
            {
                
                //We assume the move is legal, as far as we know.  The server checks the legality of the move.
                var msg :Object = new Object;
                msg[0] = _control.game.getMyId();
                msg[1] = _boardRepresentation.playerID;
                msg[2] = _boardRepresentation.idxToX(from.boardIndex);
                msg[3] = _boardRepresentation.idxToY(from.boardIndex);
                msg[4] = _boardRepresentation.idxToX(target.boardIndex);
                msg[5] = _boardRepresentation.idxToY(target.boardIndex);
                
                
                _control.net.agent.sendMessage(Server.BOARD_DELTA_REQUEST, msg);
                AppContext.LOG("client requesting move " + from + " -> " + target );
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
//            var gapBetweenTopOfPuzzleAndTopOfBoardSprite :int = _sprite.height - (_rows * _tileSize);
//            var gapBetweenTopOfPuzzleAndTopOfBoardSprite :int = Constants.PUZZLE_HEIGHT - (_rows * _tileSize);
//            return (localY - gapBetweenTopOfPuzzleAndTopOfBoardSprite) / _tileSize;
            return localY / _tileSize;;
        }
       

        public function resetPositionOfPiecesNotMoving() :void
        {
//            if(_selectedPiece == null) {
                for each (var piece :JoinGamePiece in _boardPieces) {
                    if(piece != null) {
                        if(! piece.hasTasks()) {
                            piece.x = getPieceXLoc(  idxToX(piece.boardIndex));
                            piece.y = getPieceYLoc(  idxToY(piece.boardIndex));
                        }
                    }
                }   
//            }
        }
        
        public function resetPositionOfPieces() :void
        {
                for each (var piece :JoinGamePiece in _boardPieces) {
                    if(piece != null) {
                        piece.removeAllTasks();
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
//            AppContext.LOG("raw mouse (" + e.localX + ", " + e.localY + ")");
            /* Adjust mouse for difference between board sprite and puzzle height */
//            var gapBetweenTopOfPuzzleAndTopOfBoardSprite :int = _sprite.height - (_rows * _tileSize);
//            mouseIndexY = (e.localY - gapBetweenTopOfPuzzleAndTopOfBoardSprite) / _tileSize;
                
//            AppContext.LOG("adjusted mouse (" + mouseIndexX + ", " + mouseIndexY + ")");
//            AppContext.gameCtrl.game.systemMessage("raw mouse (" + e.localX + ", " + e.localY + ")\nadjusted mouse (" + mouseIndexX + ", " + mouseIndexY + ")");
            var row :int;
//            AppContext.LOG(" mouse move " + mouseIndexX + ", " + mouseIndexY);
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
                            AppContext.LOG("We have already swapped that piece. WTF is this doing");
                            return;
                        }
                        _mostRecentSwappedPiece = pieceToSwap;
                        
                        
                        
                        
//                        return;
                        
//                        var wasSwaps:Boolean = false;
                        var currentSelectedPieceY :int = _selectedPiece.y;
                        movePieceToLocationAndShufflePieces(idxToX(_selectedPiece.boardIndex), idxToY(_selectedPiece.boardIndex), idxToX(pieceToSwap.boardIndex), idxToY(pieceToSwap.boardIndex), false);
                        AppContext.LOG("view after move and shuffle " + toString() );
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
         * is the move sent to the server.
         * 
         */
        protected function shufflePieceToLocation(pieceX :int, pieceY :int, locX :int, locY :int) :void
        {
            AppContext.LOG("Function deprecated, shufflePieceToLocation()!!!!!");
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
//            AppContext.LOG("Function deprecated, movePieceToLocationAndShufflePiecesOLDDELETE()!!!!!");
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
         * confirmation from the server.
         */
        public function movePieceToLocationAndShufflePieces(px1 :int, py1 :int, px2 :int, py2 :int, changeIndex :Boolean = true) :void
        {
            if( px1 != px2){
                AppContext.LOG("movePieceToLocationAndShufflePieces, pieces in idfferent rows, doing nothing");
                return;
            }
//            AppContext.LOG("movePieceToLocationAndShufflePieces( " + index1 + ", " + index2 + ")");
//            var px1 :int = idxToX(index1);
//            var py1 :int = idxToY(index1);
//            var py2 :int = idxToY(index2);
            
            var j :int;
            if(py1 == py2)
            {
                AppContext.LOG("movePieceToLocationAndShufflePieces, y coords same, doing nothing");
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
            
            
//            AppContext.LOG("Before moving, Selected piece.y="+(_boardPieces[index1] as JoinGamePiece).y);
            (_boardPieces[coordsToIdx(px1, py1)] as JoinGamePiece).y = getPieceYLoc( idxToY(coordsToIdx(px1, py2)));
//            AppContext.LOG("Setting selected piece.y="+(_boardPieces[index1] as JoinGamePiece).y);
            if(changeIndex){
                (_boardPieces[coordsToIdx(px1, py1)] as JoinGamePiece).boardIndex = coordsToIdx(px2, py2);
            }
            
            //Then go through the in between pieces, adjusting thier y coord by one piece height increment
            //If the first piece starts with a higher (lower y) than the second piece, it moves down, so 
            //all the other pieces must move up by one (lower their y by one).
            var increment:int = py1 < py2 ? 1 : -1;
            //Swap up or down, depending on the relative position of the pieces.
            for( j = py1 + increment; py1 > py2 ? j >= py2 : j <= py2 ; j+= increment) {
//                AppContext.LOG("changing piece (" + px1 + ", " + j + "), index=" + getPieceAt(px1, j).boardIndex);
                if( getPieceAt(px1, j) != null){
                    getPieceAt(px1, j).y = getPieceYLoc( idxToY( coordsToIdx(px1, j - increment)));
                    
                    if(changeIndex){
                        getPieceAt(px1, j).boardIndex = coordsToIdx(px1, j - increment);
                    }
                }
//                AppContext.LOG("setting y=" + getPieceAt(px1, j).y);
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
         
        protected function swapPiecesInternal (index1 :int, index2 :int) :void
        {
            AppContext.LOG("Function deprecated, swapPiecesInternal()!!!!!");
//            var piece1 :JoinGamePiece = (_board[index1] as JoinGamePiece);
//            var piece2 :JoinGamePiece = (_board[index2] as JoinGamePiece);
//    
//            if (null != piece1) {
//                piece1.boardIndex = index2;
//            }
//    
//            if (null != piece2) {
//                piece2.boardIndex = index1;
//            }
//    
//            _board[index1] = piece2;
//            _board[index2] = piece1;
        }


        public function swapPieces (index1 :int, index2 :int) :void
        {
            AppContext.LOG("Function deprecated, swapPieces()!!!!!");
//            swapPiecesInternal(index1, index2);
//            var px1 :int = getPieceXLoc( idxToX(index1));
//            var py1 :int = getPieceYLoc( idxToY(index1));
//            var px2 :int = getPieceXLoc( idxToX(index2));
//            var py2 :int = getPieceYLoc( idxToY(index2));
//    
//            var piece1 :JoinGamePiece = _board[index1];
//            var piece2 :JoinGamePiece = _board[index2];
//            
//            piece1.x = px1;
//            piece1.y = py1;
//            piece2.x = px2;
//            piece2.y = py2;
        }
            
        protected function mouseDown (e :MouseEvent) :void
        {
            
//                LOG("mouseDown");
//                var mouseIndexX :int = (e.localX / (_tileSize - 1));
//                var mouseIndexY :int = (e.localY / (_tileSize - 1));
                
                var mouseIndexX :int = ((e.localX) / (_tileSize));
//                var mouseIndexY :int = ((e.localY) / (_tileSize ));
                var mouseIndexY :int = getYRelativeToPuzzleArea(e.localY);
                
//                AppContext.LOG(" mouse down " + mouseIndexX + ", " + mouseIndexY);
                
                if(_selectedPiece == null)
                {
                    
//                    AppContext.gameCtrl.game.systemMessage(" mouseDown local=(" + e.localX + ", " + e.localY + "), " + mouseIndexX + ", " + mouseIndexY);
                    _selectedPiece = getPieceAt(mouseIndexX, mouseIndexY);
//                    return;
                    
                    
                    if(_selectedPiece != null){
                        var col :int = idxToX( _selectedPiece.boardIndex);
                        for( var j :int = 0; j < _rows; j++){
                            var piece :JoinGamePiece = getPieceAt(col, j) as JoinGamePiece;
                            if(piece != null && piece != _selectedPiece){
                                piece.y = getPieceYLoc(idxToY(piece.boardIndex));
                            }
                        }
                    }
                    
                    
//                    _lastSelectedPieceRow = -1;
                    if(_selectedPiece != null  && _selectedPiece.type == Constants.PIECE_TYPE_NORMAL)//Handle the row highlighting
                    {
                        
                        
                        
                        
//                        _selectedIndex = _selectedPiece.boardIndex;
//                        _selectedColor = _selectedPiece.color;
//                    
//                        
////                        _selectedPieceSprite.color = _selectedPiece.color; //Covers the current piece
////                        _selectedPieceSprite.size = _selectedPiece.size;
//                        
//                        
////                        addChild(_columnHighlight);
////                        setChildIndex( _selectedPiece, numChildren - 1);//Make sure it's on top  of the other pieces
                        _columnHighlight.graphics.clear();
                        _columnHighlight.graphics.lineStyle(4, 0xf2f2f2, 0.5);
                        var highestPiece:JoinGamePiece = getHighestSwappablePiece(_selectedPiece);
                        var highestY:int = getPieceYLoc( idxToY(highestPiece.boardIndex));
//                        
////                        LOG("\nHighest piece = (" + idxToX(highestPiece.boardIndex) + ", " + idxToY(highestPiece.boardIndex) + ")");
//                        
//                        
                        var lowestPiece:JoinGamePiece = getLowestSwappablePiece(_selectedPiece);
                        var lowestY:int = getPieceYLoc( idxToY(lowestPiece.boardIndex)) + _tileSize;
                        var barHeight:int = lowestY - highestY  ;
//                        
////                        LOG("\nLowest piece = (" + idxToX(lowestPiece.boardIndex) + ", " + idxToY(lowestPiece.boardIndex) + ")");
//                        
                        _columnHighlight.graphics.drawRect(  getPieceXLoc( idxToX(_selectedPiece.boardIndex)),   highestY  , _tileSize, barHeight);
//                        
                        
                        _sprite.addChild(_columnHighlight);
                        
                    }
                    else
                    {
                        _selectedPiece = null;
                    }
                }
                else //How does this happen
                {
                    
                    AppContext.LOG("\nNot sure about this, mouse down, but we already have a selected piece.  Resetting positions just to be sure.");
                    
                    var col :int = idxToX( _selectedPiece.boardIndex);
                    for( var j :int = 0; j < _rows; j++){
                        var piece :JoinGamePiece = getPieceAt(col, j) as JoinGamePiece;
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
        
        
//        public function set tileSize (newsize :int) :void
//        {
//            AppContext.LOG("\nsetting tilesize=" + newsize + ", height=" + _sprite.height);
//            _tileSize = newsize;
//            if(_boardPieces != null)
//            {
//                for each (var piece :JoinGamePiece in _boardPieces) {
//                    if(piece != null) {
//                        _sprite.removeChild(piece.displayObject);
//                    }
//                }
//                for each (piece in _boardPieces) {
//                    if(piece != null) {
//                        piece.size = _tileSize;
//                        piece.x = getPieceXLoc(  idxToX(piece.boardIndex));
//                        piece.y = getPieceYLoc(  idxToY(piece.boardIndex));
//                        _sprite.addChild(piece.displayObject);
//                    }
//                }
//            }
//            updateYBasedOnBoardHeight();
//            AppContext.LOG("end setting tilesize=" + _tileSize + ", height=" + _sprite.height);
//        }
        
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
            
            
//            if(_boardRepresentation != null)
//            {
//                _boardRepresentation.removeEventListener(JoinGameEvent.BOARD_UPDATED, this.boardChanged);
//            }
            
            _boardRepresentation = board;
            
            if(board != null)
            {
                //We listen for when the board (representation on the server) is changed and add
                //animations accordingly.
//                _boardRepresentation.addEventListener(JoinGameEvent.BOARD_UPDATED, this.boardChanged);
            }
            
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
        
        
        public function addPieceAtPosition(i :int, j :int, type :int, color :int) :void
        {
            if( getPieceAt(i, j) != null){
                AppContext.LOG("adding a piece to (" + i + ", " + j + "), but a piece already exists="+getPieceAt(i, j) );
                _boardPieces[ coordsToIdx(i, j) ] = null;
//                getPieceAt(i, j).destroySelf();
//                _boardPieces[ ArrayUtil.indexOf( _boardPieces, getPieceAt(i, j)) ] = null;
            }
            
            var piece :JoinGamePiece = new JoinGamePiece(Constants.PUZZLE_TILE_SIZE);
            piece.type = type;
            piece.color = color;
            piece.boardIndex = coordsToIdx(i, j);
            _boardPieces[ coordsToIdx(i, j) ] = piece;
            piece.x = getPieceXLoc( i );
            piece.y = getPieceYLoc( j );
            
            if(this.db != null) {
                // add the Piece to the mode, as a child of the board sprite
                this.db.addObject(piece, _sprite);
                /* Make sure the addes pieces are UNDER any any pieces, it looks better*/
                _sprite.setChildIndex( piece.displayObject, 0);
            }
            else {
                AppContext.LOG(" no db for adding the piece");
            }
            
        }
        /**
        * Events update the pieces board index, this must
        * then be reflected in the actual array position.
        * 
        */
        public function resetPiecesArrayPosition() :void
        {
//            AppContext.LOG("view resetPiecesArrayPosition()");
            var tempPieceArray :Array = _boardPieces.slice();
            _boardPieces.length = 0;
            
            for(var k :int = 0; k < tempPieceArray.length; k++){
                if( tempPieceArray[k] != null){
                    _boardPieces[ (tempPieceArray[k] as JoinGamePiece).boardIndex ] = tempPieceArray[k];
                }
            }
            
//            AppContext.LOG("after changing game area: _boardPieces");
//            for(var j :int = 0; j < _boardPieces.length; j++) {
//                AppContext.LOG(j + "=" + _boardPieces[j]);
//            }
        }
        
        
        public function isModelAndViewSame() :Boolean
        {
            for(var k :int = 0; k < _boardRepresentation._boardPieceTypes.length; k++){
                var piece :JoinGamePiece = _boardPieces[k] as JoinGamePiece;
                if( piece != null) {
                    if(piece.type != _boardRepresentation._boardPieceTypes[k] || piece.color != _boardRepresentation._boardPieceColors[k]){
                        
                        
                        AppContext.LOG("view != model: " + _boardRepresentation + this);
                        
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
        
//        public function adjustAllChildrenY( y_adjust :int) :void
//        {
//            for( var i :int = 0; i < _sprite.numChildren; i++){
//                if( _sprite.getChildAt(i) != null){
//                    _sprite.getChildAt(i).y += y_adjust;
//                }
//            }
//        }
        
        private var _activePlayersBoard:Boolean;
        public var _boardRepresentation: JoinGameBoardRepresentation;
        private var _tileSize : int;
        public var _boardPieces: Array;
        
        private var _selectedPiece : JoinGamePiece;
        private var _mostRecentSwappedPiece : JoinGamePiece;
        
        private var _columnHighlight :Sprite;
        
        
        //Game control needed to send move requests.
        public var _control :GameControl;
        
        private var LOG_TO_GAME:Boolean = false;
        
        
        protected static var SWF_CLASSES :Array;
        protected static const SWF_CLASS_NAMES :Array = [ "piece_01", "piece_02", "piece_03", "piece_04", "piece_05" ];
        
        public var _sprite :Sprite;
        
        public var _rows :int;
        public var _cols :int;
        
        /**
        * Sometimes the board view gets out of sync because of numerous simultaneous updates.
        * Every half a second, the board checks itself and it's pieces, correcting if necessary.
        */
        private var _updateTimer:Timer;
        
        private var _rand :Random;
        
    }
}

