package joingame.view
{
    import com.threerings.util.ArrayUtil;
    import com.threerings.util.HashMap;
    import com.threerings.util.Log;
    import com.threerings.util.Random;
    import com.whirled.contrib.simplegame.*;
    import com.whirled.contrib.simplegame.audio.*;
    import com.whirled.contrib.simplegame.objects.*;
    import com.whirled.contrib.simplegame.resource.*;
    import com.whirled.contrib.simplegame.tasks.*;
    import com.whirled.contrib.simplegame.util.*;
    import com.whirled.game.GameControl;
    
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    
    import joingame.*;
    import joingame.model.*;
    import joingame.net.InternalJoinGameEvent;
    
    /**
     * Draws the boards, and creates the animations of board pieces
     * via events from JoinGameModel.
     */
    public class JoinGameBoardsView extends SceneObject
    {
        public function JoinGameBoardsView(joinGameModel :JoinGameModel, gameControl :GameControl, 
         observerState :Boolean = false)
        {
            if (joinGameModel == null || gameControl == null){
                throw new Error("JoinGameBoardsView() JoinGameModel or GameControl cannot be null");
            }
            
            _gameModel = joinGameModel; 
            _gameControl = gameControl;
            _observer = observerState;
            
            _id2Board = new HashMap();
            _sprite = new Sprite();
            
            var swf :SwfResource = (ResourceManager.instance.getResource("puzzlePieces") as SwfResource);
            _piece_break_eastwardClass = swf.getClass("piece_break_eastward");
            _piece_break_westwardClass = swf.getClass("piece_break_westward");
            
            _gameModel.addEventListener(InternalJoinGameEvent.START_NEW_ANIMATIONS, startNewBoardAnimations);
            _gameModel.addEventListener(InternalJoinGameEvent.PLAYER_DESTROYED, playerDestroyed);
            _gameModel.addEventListener(InternalJoinGameEvent.PLAYER_REMOVED, playerRemoved);
            _gameModel.addEventListener(InternalJoinGameEvent.RECEIVED_BOARDS_FROM_SERVER, updateBoardDisplays);
            _gameModel.addEventListener(InternalJoinGameEvent.DELTA_CONFIRM, deltaConfirm);
            _gameModel.addEventListener(InternalJoinGameEvent.DO_PIECES_FALL, doPiecesFall);
            _gameModel.addEventListener(InternalJoinGameEvent.ADD_NEW_PIECES, doAddNewPieces);
            _gameModel.addEventListener(InternalJoinGameEvent.VERTICAL_JOIN, doSingleVerticalJoin);
            _gameModel.addEventListener(InternalJoinGameEvent.ATTACKING_JOINS, doHorizontalAttack);
            _gameModel.addEventListener(InternalJoinGameEvent.BOARD_UPDATED, boardUpdated);
            _gameModel.addEventListener(InternalJoinGameEvent.DO_DEAD_PIECES, doDeadPieces);
            _gameModel.addEventListener(InternalJoinGameEvent.REMOVE_ROW_PIECES, doRemoveRowPieces);
            _gameModel.addEventListener(InternalJoinGameEvent.REMOVE_BOTTOM_ROW_AND_DROP_PIECES, removeBottomRowAndDropPieces);
            _gameModel.addEventListener(InternalJoinGameEvent.RESET_VIEW_FROM_MODEL, resetViewFromModel);
            _gameModel.addEventListener(InternalJoinGameEvent.DONE_COMPLETE_DELTA, doFinishAnimations);
            _gameModel.addEventListener(InternalJoinGameEvent.PLAYER_ADDED, doPlayerAdded);
            _gameModel.addEventListener(InternalJoinGameEvent.GAME_OVER, handleGameOver);
            
//            _destroyBottomRowButton  = new SimpleTextButton("Destroy Bottom Row");
//            _destroyBottomRowButton.addEventListener( REMOVE_BOTTOM_ROW_BUTTON, requestBottomRowRemoval);
//            _sprite.addChild( _destroyBottomRowButton );
        }
        
        
//        protected function requestBottomRowRemoval( e :Event) :void
//        {
//            if( _myBoardDisplay != null && !AppContext.isObserver) {
//                
//                AppContext.messageManager.sendMessage( new BottomRowRemovalRequestMessage
//                
//                var msg :Object = new Object;
//                msg[0] = _myBoardDisplay._boardRepresentation.playerID;
//                
//                AppContext.gameCtrl.net.agent.sendMessage(JoingameServer.BOARD_BOTTOM_ROW_REMOVAL_REQUEST_FROM_BUTTON, msg);
//            }
//        }
        
        
        protected function handleGameOver( e :InternalJoinGameEvent) :void
        {
//            trace( ClassUtil.shortClassName(this) + " handleGameOver()");
            dispatchEvent( new InternalJoinGameEvent( -1, InternalJoinGameEvent.GAME_OVER));
        }
        
        protected function doFinishAnimations( e :InternalJoinGameEvent) :void
        {
            var board :JoinGameBoardGameArea = getBoardView( e.boardPlayerID );
            if( board != null && board._boardRepresentation._state > JoinGameBoardRepresentation.STATE_ACTIVE ) {
                board.updating = false;
            }
        }
        
        protected function startNewBoardAnimations( e :InternalJoinGameEvent) :void
        {
            var board :JoinGameBoardGameArea = getBoardView( e.boardPlayerID );
            if( board != null && board._boardRepresentation._state == JoinGameBoardRepresentation.STATE_ACTIVE && board.isMovingPieces()) {
                board.removePieceTasksAndSetCorrectLocations();
                board.updating = true;
            }
        }
        
        
        protected function resetViewFromModel( e :InternalJoinGameEvent) :void
        {
            var board :JoinGameBoardGameArea = getBoardView( e.boardPlayerID );
            if( board != null) {
                board.resetPositionOfPieces();
                doGraphicsAndAnimationForDeadBottomRow(board);
            }
        }
        
        /**
        * Animates the destruction of the bottom row.
        */
        protected function removeBottomRowAndDropPieces( e :InternalJoinGameEvent) :void
        {
            var board :JoinGameBoardGameArea = getBoardView( e.boardPlayerID );
            var piece :JoinGamePiece;
            var k :int;
            
            if( board != null) {
                for( var i :int = 0; i < board._cols; i++) {
                    piece = board.getPieceAt(i, board._rows - 1) as JoinGamePiece;
                    if(piece != null ){
                        
                        //Remove the piece from the board.
                        board._boardPieces[ board.coordsToIdx(i, board._rows - 1) ] = null;
                        piece.boardIndex = -1;
                        if( piece.isLiveObject) {
                            piece.destroySelf();
                        }
                        
                        
                        createTimedExplosionForPiece( board, piece, 0); 
                        
                        
//                        var newPiece :JoinGamePiece = createPieceFromBoard(board, i, board._rows - 1);
//                        newPiece.color = piece.color;
//                        newPiece.type = piece.type
//                        db.addObject( newPiece, board._sprite);
//                        
//                        var pieceAnim :SerialTask = new SerialTask();
//                        pieceAnim.addTask(ScaleTask.CreateEaseOut(0.3, 0.3, Constants.PIECE_SCALE_DOWN_TIME));
//                        pieceAnim.addTask(new SelfDestructTask());
//                        newPiece.addTask(pieceAnim);
                    }
                }
                board._boardPieces.splice((board._rows - 1)*board._cols, board._cols);
                board._rows--;
                board.updateNumberOfPieceBackgrounds();
                
                /* Animate the background falling */
                for( k = 0; k < board._backgroundPieces.length; k++) {
                    var back :SceneObject = board._backgroundPieces[k] as SceneObject;
                    if(back != null) {
                        back.addTask(LocationTask.CreateEaseIn( 
                            board.getPieceXLoc(board.idxToX(k)), 
                            board.getPieceYLoc(board.idxToY(k)),
                            Constants.PIECE_DROP_TIME));
                    }
                }
                
                
                
                for( k = 0; k < board._boardPieces.length; k++) {
                    piece = board._boardPieces[k] as JoinGamePiece;
                    if(piece != null){
                        piece.boardIndex = k;
                    }
                }
                
                for( k = 0; k < board._boardPieces.length; k++) {
                    piece = board._boardPieces[k] as JoinGamePiece;
                    if(piece != null){
                        var toX :Number = board.getPieceXLoc( board.idxToX(k));
                        var toY :Number = board.getPieceYLoc( board.idxToY(k));
                    
                        piece.addNamedTask(MOVE_TASK_NAME,
                        LocationTask.CreateEaseIn(toX, toY, Constants.PIECE_DROP_TIME), true);
                    }
                }
                
                for( k = 0; k < board._boardPieces.length; k++) {
                    piece = board._boardPieces[k] as JoinGamePiece;
                    if(piece == null){
                        board.addPieceAtPosition( board._boardRepresentation.idxToX(k), board._boardRepresentation.idxToY(k), Constants.PIECE_TYPE_INACTIVE, 1);
                    }
                }
                
//                board.removeAndAddDisplayChildren();
                
                    //Drop the board
                toY = (AppContext.gameHeight - board.height - Constants.GUI_BOARD_FLOOR_GAP) + Constants.PUZZLE_TILE_SIZE*board._sprite.scaleX;
//                toY = board.y + Constants.PUZZLE_TILE_SIZE*board._sprite.scaleX;
                
                var taskAnimation :SerialTask= new SerialTask();
                taskAnimation.addTask( new TimedTask(0) );
                taskAnimation.addTask( LocationTask.CreateEaseIn(board.x, toY + Constants.DISTANCE_OVER_TARGET_DROPPED_PIECES_FALL, Constants.PIECE_DROP_TIME) );
                taskAnimation.addTask( new TimedTask(Constants.PIECE_DROP_BOUNCE1_TIME) );
                taskAnimation.addTask( LocationTask.CreateEaseIn(board.x, toY - Constants.DISTANCE_OVER_TARGET_DROPPED_PIECES_FALL/2, Constants.PIECE_DROP_BOUNCE1_TIME) );
                taskAnimation.addTask( LocationTask.CreateEaseIn(board.x, toY, Constants.PIECE_DROP_BOUNCE1_TIME * 0.7));
                    
                    
                    
//                board.addNamedTask(MOVE_TASK_NAME, taskAnimation, true); 
                
                
                
                doGraphicsAndAnimationForDeadBottomRow(board);  //Doesn't work WTF!!!!
                
//                adjustZoomOfPlayAreaBasedOnCurrentPlayersBoard();
                
                
                
//                board.updateYBasedOnBoardHeight();
//                board.updating = false;                
            }
            else {
                log.debug("!!!!!deleteRow(" + e.boardPlayerID + ") board is null");
            }
            adjustZoomOfPlayAreaBasedOnCurrentPlayersBoard();
//            log.debug("view removeBottomRowAndDropPieces() board after: " + board);
                    
        }
        

        
        
        protected function doRemoveRowPieces( e :InternalJoinGameEvent ) :void
        {
            var board :JoinGameBoardGameArea = getBoardView( e.boardPlayerID );
            if( board != null) {
//                board.updating = true;
//                log.debug("view doRemoveRowPieces() before: " + board);
                var row :int = e.row;
                for( var i :int = 0; i < board._cols; i++) {
                    var piece :JoinGamePiece = board.getPieceAt( i, row) as JoinGamePiece;
                    if(piece == null){/* If it's part of another join, it may already be removed */
                        continue;
                    }
                    var pieceAnim :SerialTask = new SerialTask();
                    pieceAnim.addTask(ScaleTask.CreateEaseOut(0.3, 0.3, Constants.PIECE_SCALE_DOWN_TIME));
                    pieceAnim.addTask(new SelfDestructTask());
                    piece.addTask(pieceAnim);
                    board._boardPieces[ board.coordsToIdx(i, row) ] = null;
                    piece.boardIndex = -1;//Test
                     
                    if( ArrayUtil.contains( board._boardPieces, piece) ){
                        log.debug("!!!doJoinVisualizations(), " + piece + " should be removed, but it's still there WTF? at index="+ ArrayUtil.indexOf(board._boardPieces, piece) );
                    }
                }
//                log.debug("view doRemoveRowPieces() after: " + board);
//                board.updating = false;
            }
            else {
                log.debug("!!!!!doRemoveRowPieces(" + e.boardPlayerID + ") board is null");
            }
        }
        
        protected function doDeadPieces( e :InternalJoinGameEvent ) :void
        {
//            log.debug("doDeadPieces()");
            var board :JoinGameBoardGameArea = getBoardView( e.boardPlayerID );
            if( board != null){
//                board.updating = true;
                doGraphicsAndAnimationForDeadBottomRow(board);
//                board.updating = false;         
            }
        }
        
        
        public function doGraphicsAndAnimationForDeadBottomRow( board :JoinGameBoardGameArea) :void
        {
            if( board != null){
//                board._updating = true;
                for( var k :int = 0; k < board._boardPieces.length; k++){
                    
                    if(board == null || board._boardPieces[k] == null) {
                        continue;
                    }
                    if( board._boardRepresentation._boardPieceTypes[k] == Constants.PIECE_TYPE_POTENTIALLY_DEAD){
                        (board._boardPieces[k] as JoinGamePiece).type = Constants.PIECE_TYPE_POTENTIALLY_DEAD;
//                        (board._boardPieces[k] as JoinGamePiece).removeNamedTasks(WOBBL_TASK_NAME);
                    }
                    else {
                        (board._boardPieces[k] as JoinGamePiece).removeNamedTasks(WOBBL_TASK_NAME);
                    }
                }
                
                var isDeadBottomRow :Boolean = true;
                var i :int;
                var piece :JoinGamePiece;
                
                for(i = 0; i < board._cols; i++) {
                    piece = board.getPieceAt( i, board._rows - 1);
                    if(piece != null && piece.type == Constants.PIECE_TYPE_NORMAL) {
                        isDeadBottomRow = false;
                        break;
                    }
                }
                if(isDeadBottomRow) {
                    board.startTimedBottomRowWobble();
//                    for(i = 0; i < board._cols; i++) {
//                        piece = board.getPieceAt( i, board._rows - 1);
//                        if(piece != null && piece.type != Constants.PIECE_TYPE_INACTIVE) {
//                            
//                            var serialAnimation :SerialTask = new SerialTask(); 
//                            serialAnimation.addTask( LocationTask.CreateEaseIn(piece.x - 2, piece.y, 0.05) );
//                            serialAnimation.addTask( LocationTask.CreateEaseIn(piece.x + 2, piece.y, 0.1) );
//                            serialAnimation.addTask( LocationTask.CreateEaseIn(piece.x, piece.y, 0.05) );
//                            
//                            var taskAnimation :RepeatingTask = new RepeatingTask(serialAnimation);
//                            piece.addNamedTask(WOBBL_TASK_NAME, taskAnimation);  
//                        }
//                    }
                }
                else {
                    board.stopTimedBottomRowWobble();
                }
                
//                board.updatePieceBackgrounds();
//                board._updating = false;
            }
        }
        
        protected function boardUpdated( e :InternalJoinGameEvent ) :void
        {
//            log.debug("JoinGameBoardsView.boardUpdated, this should only be called in an emergency");
            getBoardView(e.boardPlayerID).updatePieceDimensionsAndCoordinatesAndAddPiecesIfNecessaryOLD();
        }
        
        /**
        * The returned piece is positioned relative to the board
        * 
        */
        protected function createPieceFromBoard( board :JoinGameBoardGameArea, i :int, j :int) :JoinGamePiece
        {
            var newPiece :JoinGamePiece = new JoinGamePiece();
            newPiece.x = board.getPieceXLoc(i);
            newPiece.y = board.getPieceYLoc(j);
            
            return newPiece;
        }
        
        protected function doHorizontalAttack( e :InternalJoinGameEvent ) :void
        {
            var boardAttacked :JoinGameBoardGameArea = getBoardView( e.boardAttacked );
            var sourceboard :JoinGameBoardGameArea = getBoardView( e.boardPlayerID );
            
            var i :int;
            var k :int;
            var piece :JoinGamePiece;
            var join :JoinGameJoin = e.joins[0] as JoinGameJoin;
            
            /* Determine the animation coords */
            var toX :int;
            var toY :int;
            var xToStartFromAfterWrapping :int;
            var xToShootBeforeWrappingAround :int;

            var pieceToHJoinTime :Number = Constants.VERTICAL_JOIN_ANIMATION_TIME * 0.6;
            var serialTask :SerialTask;
            var timeToStartJoin :Number;
            
            log.debug("doHorizontalAttack(), source=" + (sourceboard != null ? sourceboard._boardRepresentation.playerID : "null ( " + e.boardPlayerID + ")") + " , attacked=" 
                + (boardAttacked != null ? boardAttacked._boardRepresentation.playerID : "null ( " + e.boardAttacked + ")"));
            if( boardAttacked != null && sourceboard != null) {
                var rowIndex :int = boardAttacked._rows - 1 - join.attackRow;
                var alreadyDamagedOffset :int = 0;
                if(e.side == Constants.LEFT) {//This means its attacking the target's left
                    toX = (boardAttacked.x - sourceboard.x) * (1/sourceboard.scaleX) - Constants.PUZZLE_TILE_SIZE*join._widthInPieces;
                }
                else {
                    toX = (boardAttacked.x + Constants.PUZZLE_STARTING_COLS * Constants.PUZZLE_TILE_SIZE * boardAttacked.scaleX  - sourceboard.x) * (1/sourceboard.scaleX);
                }
                
                /* Find the smallest distance between any of the pieces, and the target piece */
                var smallestDistanceBetweenJoinAndTargetPiece :int = 10000;
                for( k = 0; k < join._piecesX.length; k++) {
                    var pieceX :int = sourceboard.getPieceXLoc( join._piecesX[k] );
                    smallestDistanceBetweenJoinAndTargetPiece = Math.min( Math.abs(toX - pieceX), smallestDistanceBetweenJoinAndTargetPiece );
                }
                smallestDistanceBetweenJoinAndTargetPiece += Constants.PUZZLE_TILE_SIZE/2;
                if( sourceboard.x > boardAttacked.x) {
                    smallestDistanceBetweenJoinAndTargetPiece = -smallestDistanceBetweenJoinAndTargetPiece;
                }
                
                /* Convert the pieces to the horizontal join graphic */
                var xBounce :int;
                var yBounce :int;
                var bounceMoveTask :ObjectTask;
                var bounceRotationTask :ObjectTask;
                
                
                
                var joinSprite :Sprite = new Sprite();
                var mostLeftPieceX :int = 10000;
                for( k = 0; k < join._piecesX.length; k++) {
                    mostLeftPieceX = Math.min( mostLeftPieceX,  join._piecesX[k]);
                }
                joinSprite.x = sourceboard.getPieceXLoc(mostLeftPieceX);
                joinSprite.y = sourceboard.getPieceYLoc( sourceboard.convertFromBottomYToFromTopY(join._piecesYFromBottom[0]) );
                var joinSceneObject :SceneObject = new SimpleSceneObject(joinSprite);
                db.addObject( joinSceneObject, sourceboard._sprite);
                for( k = 0; k < join._piecesX.length; k++) {
                    
                    timeToStartJoin = pieceToHJoinTime * ((Math.abs(join._piecesX[k] - join._lastSwappedX) as Number) / (join._widthInPieces - 1));
                    piece = sourceboard.getPieceAt( join._piecesX[k], sourceboard.convertFromBottomYToFromTopY(join._piecesYFromBottom[k]));
                    if(piece != null){/* If it's part of another join, it may already be removed */
                        sourceboard._boardPieces[ piece.boardIndex ] = null;

                        serialTask = new SerialTask();
                        serialTask.addTask( new TimedTask( join._delay  ) );
                        serialTask.addTask( new SelfDestructTask() );
                        piece.addTask( serialTask );
                    }
                    
                    
                    var newPiece :JoinGamePiece = new JoinGamePiece(); 
                    
                    newPiece.color = join._color;
                    newPiece.visible = false;
                    db.addObject( newPiece, joinSprite);
                    newPiece.x = (join._piecesX[k] - mostLeftPieceX) * Constants.PUZZLE_TILE_SIZE;
                    var pieceAnim :SerialTask = new SerialTask();
                    pieceAnim.addTask( new TimedTask( join._delay) );
                    pieceAnim.addTask( new VisibleTask(true) );
                    pieceAnim.addTask( new TimedTask( timeToStartJoin) );
                    pieceAnim.addTask( new PlaySoundTask("windup") );
                    pieceAnim.addTask( new FunctionTask(newPiece.toHorizontalJoin) );
                    newPiece.addTask( pieceAnim );
                }
                
                var joinAnim :SerialTask = new SerialTask();
                joinAnim.addTask( new TimedTask( join._delay + pieceToHJoinTime) );
                var distance2Side :Number;
                var distanceFromOtherSide2Target :Number;
                var xOnTheOtherSideRelativeToBoardSprite :int;
                if( e.side == Constants.LEFT && sourceboard.x > boardAttacked.x) {
                    xToShootBeforeWrappingAround = Constants.PUZZLE_TILE_SIZE * (Constants.PUZZLE_STARTING_COLS + 2);
                    xToStartFromAfterWrapping = toX - 2*Constants.PUZZLE_TILE_SIZE*join._widthInPieces;
                    
                    joinAnim.addTask(LocationTask.CreateLinear(xToShootBeforeWrappingAround, joinSceneObject.y, (Constants.VERTICAL_JOIN_ANIMATION_TIME - pieceToHJoinTime) * 0.5));
                    joinAnim.addTask(LocationTask.CreateLinear(xToStartFromAfterWrapping, joinSceneObject.y, 0 ));
                    joinAnim.addTask(LocationTask.CreateLinear(toX, joinSceneObject.y, (Constants.VERTICAL_JOIN_ANIMATION_TIME - pieceToHJoinTime) * 0.5 ));
                    
                        
                }
                else if ( e.side == Constants.RIGHT && sourceboard.x < boardAttacked.x) {
                    
                    xToShootBeforeWrappingAround = -Constants.PUZZLE_TILE_SIZE*(join._widthInPieces + 2);
                    xToStartFromAfterWrapping = toX + Constants.PUZZLE_TILE_SIZE*(join._widthInPieces + 2);
                    
                    joinAnim.addTask(LocationTask.CreateLinear(xToShootBeforeWrappingAround, joinSceneObject.y, (Constants.VERTICAL_JOIN_ANIMATION_TIME - pieceToHJoinTime) * 0.5));
                    joinAnim.addTask(LocationTask.CreateLinear(xToStartFromAfterWrapping, joinSceneObject.y, 0 ));
                    joinAnim.addTask(LocationTask.CreateLinear(toX, joinSceneObject.y, (Constants.VERTICAL_JOIN_ANIMATION_TIME - pieceToHJoinTime) * 0.5 ));
                    
                }
                else {
                    joinAnim.addTask(LocationTask.CreateLinear(toX, joinSceneObject.y, (Constants.VERTICAL_JOIN_ANIMATION_TIME - pieceToHJoinTime) ));
                }
                
                joinAnim.addTask( new PlaySoundTask("crash") );
                joinAnim.addTask(new SelfDestructTask());
                joinSceneObject.addTask(joinAnim);
                
                boardAttacked._animationsToDestroyWhenIDie.push( joinSceneObject );
                
            }
            else if( sourceboard != null){
                log.debug("boardAttacked == null, sourceboard id=" + e.boardPlayerID);
                
                for( k = 0; k < join._piecesX.length; k++) {
                    
                    timeToStartJoin = pieceToHJoinTime * ((Math.abs(join._piecesX[k] - join._lastSwappedX) as Number) / (join._widthInPieces - 1));
                    
                    piece = sourceboard.getPieceAt( join._piecesX[k], sourceboard.convertFromBottomYToFromTopY(join._piecesYFromBottom[k]));
                    if(piece != null){/* If it's part of another join, it may already be removed */
                        sourceboard._boardPieces[ piece.boardIndex ] = null;

                        serialTask = new SerialTask();
                        serialTask.addTask( new TimedTask( join._delay  ) );
                        serialTask.addTask( new SelfDestructTask() );
                        piece.addTask( serialTask );
                    }
                }
                return;
            }
            else {
                log.error("Major error in doHorizontalAttack().  Source board is null. WTF?????");
                return;
            }
            
            
            
            var attackAnimation :JoinAttackAnimation;
            var xLocToAttack :int;
            var attackAnimTask :SerialTask;
            var coverPiece :JoinGamePiece;
            var coverAnimTask :SerialTask;
            
            var localRowIndex :int = (boardAttacked._boardRepresentation._rows - 1) - e.row;
            var piecesDestroyed :Array = new Array();
            
            if( boardAttacked != null){
                /* This means FROM the the left */
                if( e.side == Constants.LEFT || e.side == Constants.ATTACK_BOTH){
                    
                    for(var leftAttackCount :int = 0; leftAttackCount < e.damage; leftAttackCount++){
                        for(var leftColIndex :int = 0; leftColIndex < boardAttacked._cols; leftColIndex++){
                            var leftPiece :JoinGamePiece = boardAttacked.getPieceAt( leftColIndex, localRowIndex) as JoinGamePiece;
                            if(leftPiece != null && (leftPiece.type == Constants.PIECE_TYPE_NORMAL || leftPiece.type == Constants.PIECE_TYPE_POTENTIALLY_DEAD)){
                                leftPiece.type = Constants.PIECE_TYPE_DEAD;
                                piecesDestroyed.push(leftPiece);
                                break;
                            }
                        }
                    }
                }
                
                if( e.side == Constants.RIGHT|| e.side == Constants.ATTACK_BOTH){
                    for(var rightAttackCount :int = 0; rightAttackCount < e.damage; rightAttackCount++){
                        for(var rightColIndex :int = boardAttacked._cols - 1; rightColIndex >= 0; rightColIndex--){
                            var rightPiece :JoinGamePiece = boardAttacked.getPieceAt( rightColIndex, localRowIndex) as JoinGamePiece;
                            if(rightPiece != null && (rightPiece.type == Constants.PIECE_TYPE_NORMAL || rightPiece.type == Constants.PIECE_TYPE_POTENTIALLY_DEAD)){
                                rightPiece.type = Constants.PIECE_TYPE_DEAD;
                                piecesDestroyed.push(rightPiece);
                                break;
                            }
                        }
                    }
                }
                
//                Convert the damaged piece by animating a cover piece
                if(piecesDestroyed.length > 0){
                    
                    for( k = 0; k < piecesDestroyed.length; k++) {
                        
                        var pieceDestroyed :JoinGamePiece = piecesDestroyed[k] as JoinGamePiece;
                        coverPiece = new JoinGamePiece();
                        coverPiece.color = boardAttacked._boardRepresentation._boardPieceColors[ pieceDestroyed.boardIndex ];
                        coverPiece.x = pieceDestroyed.x;
                        coverPiece.y = pieceDestroyed.y;
                        
                        boardAttacked._animationsToDestroyWhenIDie.push( coverPiece );
                        
                        boardAttacked.db.addObject(coverPiece, boardAttacked._sprite);
                        
                        coverAnimTask = new SerialTask();
                        coverAnimTask.addTask(new TimedTask(Constants.VERTICAL_JOIN_ANIMATION_TIME + join._delay));
                        coverAnimTask.addTask(ScaleTask.CreateEaseOut(0.1, 0.1, Constants.PIECE_SCALE_DOWN_TIME));
                        coverAnimTask.addTask(new SelfDestructTask());
                        coverPiece.addTask( coverAnimTask );
                        
                        /* And show an asplosion */
                        var explosionMovie :MovieClip = new _piece_break_eastwardClass();
                        var asplosionSprite :Sprite = new Sprite();
                        asplosionSprite.addChild( explosionMovie);
                        var asplosionScene :SceneObject = new SimpleSceneObject(asplosionSprite);
                        boardAttacked.db.addObject(asplosionScene, boardAttacked._sprite);
                        boardAttacked._animationsToDestroyWhenIDie.push( asplosionScene );
                        asplosionScene.x = pieceDestroyed.x;
                        asplosionScene.y = pieceDestroyed.y;
                        asplosionScene.visible = false;
                        
                        coverAnimTask = new SerialTask();
                        coverAnimTask.addTask(new TimedTask(Constants.VERTICAL_JOIN_ANIMATION_TIME + join._delay));
                        coverAnimTask.addTask(new VisibleTask(true));
                        coverAnimTask.addTask(new TimedTask(0.4));
                        coverAnimTask.addTask(new SelfDestructTask());
                        asplosionScene.addTask( coverAnimTask );
                        
                    }
                    
                    
                    /* Then make the pieces in the vicinity wobble from the shockwave */
                    var colForShockwave :int = e.side == Constants.RIGHT ? boardAttacked._cols - 1 : 0;
                    var colIncrement :int = e.side == Constants.RIGHT ? - 1 : 1;
                    var shockwaveDistanceMax :int = boardAttacked._cols;
                    var shockwavePieceMoveDistance :int = 60;
                    var currentShockwaveDistance :int = 0;
                    while( currentShockwaveDistance <= shockwaveDistanceMax) {
                        var pieceToShock :JoinGamePiece = boardAttacked.getPieceAt( colForShockwave, localRowIndex) as JoinGamePiece;
                        shockwavePieceMoveDistance *= 0.6;
                        if(pieceToShock != null) {
                            var shockAnimTask :SerialTask = new SerialTask();
                            shockAnimTask.addTask( new TimedTask(Constants.VERTICAL_JOIN_ANIMATION_TIME + join._delay + currentShockwaveDistance*0.05) );
                            shockAnimTask.addTask( LocationTask.CreateEaseOut(pieceToShock.x + shockwavePieceMoveDistance*colIncrement*(1.0/(currentShockwaveDistance+1)), pieceToShock.y, 0.2) );
                            shockAnimTask.addTask( LocationTask.CreateEaseIn(pieceToShock.x, pieceToShock.y, 0.05) );
                            pieceToShock.addTask( shockAnimTask );
                        }
                        
                        /* Do the row above and below as well */
                        if(localRowIndex - 1 >= 0) {
                            
                        }
                        
                        colForShockwave += colIncrement;
                        currentShockwaveDistance++;
                    }
                }
                else {
                    log.debug("piecesDestroyed.length == 0 WTF");
                }
            }
            
            doGraphicsAndAnimationForDeadBottomRow(boardAttacked);
            
        }
        

        
        /**
        * Animate the join, and add and animate the new falling pieces.
        */
        protected function doSingleVerticalJoin( e :InternalJoinGameEvent ) :void
        {
                      
            var board :JoinGameBoardGameArea = getBoardView( e.boardPlayerID );
            var join :JoinGameJoin = e.joins[0] as JoinGameJoin;
            var k :int;
            var i :int;
            var j :int;
            var col :int;
            var piece :JoinGamePiece;
            var serialTask :SerialTask;
//            log.debug("view doVerticalJoins() view before:\n" + board + ", model before:\n" + board._boardRepresentation);
            var startPositionTask :LocationTask;
            
            if( board != null) {
//            log.debug("view doVerticalJoins(), delay=" + e.delay + " model: " + board._boardRepresentation.playerID + "\nview:" + board );    
//                board.updating = true;
               /* The join shoots up, pushing the pieces above until either the pushed pieces
                or the join are one piece above the column height, at which point the join
                dissappears and the new pieces 'roll' in.
                 */
                
                /* First make sure that the view and the board correspond with the same number
                   of rows */
                while( board._rows < board._boardRepresentation._rows) {
                    board._rows++;
                    /* Add a new row to the pieces list */ 
                    for( var c :int = 0; c < board._cols; c++){
                        board._boardPieces.unshift(null); //Add nulls to the beginning
                    }
                    
                    /* Add inactive piece placeholders  */ 
                    for( var colForNewPiece :int = 0; colForNewPiece < board._cols; colForNewPiece++){
                        piece = board.addPieceAtPosition(colForNewPiece, 0, Constants.PIECE_TYPE_INACTIVE, 0);
                    }
                }
//                log.debug("view doVerticalJoins() after adding a new row view:\n" + board + "model:\n" + board._boardRepresentation);
                board.resetIndices();
                
                
                updateBoardDisplays();
                board.updateNumberOfPieceBackgrounds(false);
                board.updatePieceBackgroundsPositions(false);
                
                /* Find the highest piece in the join */
                var highestPointInJoin :int = AppContext.gameHeight;
                for( k = 0; k < join._piecesX.length; k++) {
                    var index :int = board.coordsToIdx( join._piecesX[k], board.convertFromBottomYToFromTopY( join._piecesYFromBottom[k]));
                    var absoluteY :int = board.y + board.getPieceYLoc(board.idxToY(index)) * board._sprite.scaleY;
                    highestPointInJoin = Math.min( absoluteY, highestPointInJoin);
                }
                
                /* Do the join animations */
                
                /* Create the join sprite.  Real pieces deleted, fake pieces created to animate.*/
                var joinSprite :Sprite = new Sprite();
                var currentY :int = 0;
                var joinSpriteX :int = 0;
                
                var joinSpriteY :int = Constants.MAX_PUZZLE_HEIGHT;
                
                for( k = 0; k < join._piecesX.length; k++) {
//                    log.debug("destroying (" + join._piecesX[k] + ", " + board.convertFromBottomYToFromTopY( join._piecesYFromBottom[k]) + ")");
                    piece = board.getPieceAt( join._piecesX[k], board.convertFromBottomYToFromTopY( join._piecesYFromBottom[k]));
                    if(piece != null){/* If it's part of another join, it may already be removed */
                        board._boardPieces[ piece.boardIndex ] = null;
                        serialTask = new SerialTask();
                        serialTask.addTask( new TimedTask( join._delay) );
                        serialTask.addTask( new SelfDestructTask() );
                        piece.addTask( serialTask );
                        
                        piece.boardIndex = -1;
//                        piece.destroySelf();
                    }
                    
                    
                    
                    var volatilePiece :JoinGamePiece = createPieceFromBoard( board, join._piecesX[k], board.convertFromBottomYToFromTopY( join._piecesYFromBottom[k]));
                    joinSpriteX = volatilePiece.x;
                    joinSpriteY = Math.min( joinSpriteY, volatilePiece.y);
                    
                    volatilePiece.color = join._color;
                    volatilePiece.toVerticalJoin();
                    
                    
                    ///////Experiment
                    joinSprite.addChild( volatilePiece.displayObject );
                    joinSpriteX = volatilePiece.x;
                    volatilePiece.displayObject.x = 0;
                    volatilePiece.displayObject.y = currentY;
                    currentY += volatilePiece.displayObject.height;
                    
                }
                
//                log.debug("view doVerticalJoins() after join animations, view:\n" + board + "model:\n" + board._boardRepresentation);
                
                
                
                /* Animate the join to move up one tile, then dissappear. */
                var joinSceneObject :SceneObject = new SimpleSceneObject( joinSprite );
                db.addObject( joinSceneObject, board._sprite);
                joinSceneObject.x = joinSpriteX;
                joinSceneObject.y = joinSpriteY
                joinSceneObject.visible = false;
                
                var joinAnim :SerialTask = new SerialTask();
                joinAnim.addTask(new TimedTask( join._delay));
                joinAnim.addTask( new VisibleTask(true));
                joinAnim.addTask( new PlaySoundTask("vertical_join_moves_up"));
                
                var toY :int = joinSceneObject.y - Constants.PUZZLE_TILE_SIZE*board._sprite.scaleX 
                joinAnim.addTask(LocationTask.CreateEaseIn(joinSceneObject.x, toY, Constants.VERTICAL_JOIN_ANIMATION_TIME));
                var parallelTask :ParallelTask = new ParallelTask(
                    LocationTask.CreateLinear(joinSceneObject.x + joinSceneObject.width/2 , toY + joinSceneObject.height/2 , Constants.VERTICAL_JOIN_DISSAPPEAR_TIME),
                    new ScaleTask(0, 0, Constants.VERTICAL_JOIN_DISSAPPEAR_TIME)  );
                
                joinAnim.addTask(parallelTask);
                joinAnim.addTask(new SelfDestructTask());
                joinSceneObject.addTask(joinAnim);
                
                
                /* Animate the pieces above the join to also move up, the to fall down*/
                /* Find the highest y coord */
                
                /* Find the highest piece in the join */
                var lowestYInJoin :int = 3000;
                for( k = 0; k < join._piecesX.length; k++) {
                    lowestYInJoin = Math.min( board.convertFromBottomYToFromTopY( join._piecesYFromBottom[k]), lowestYInJoin);
                }
                /* Animate the pieces above the join to move up with it */
                /* And the columns left and right */
                /* And the pieces below (left and right) to abosrb the shocks*/
                /* And the piece backgrounds */
                if(true)
                for each ( col in [join._buildCol - 1, join._buildCol, join._buildCol+1]) {
                    for( j = lowestYInJoin - 1; j >= 0; j--) {
                        piece = board.getPieceAt( col, j);
                        
                        
                        if( piece != null && piece.type != Constants.PIECE_TYPE_INACTIVE) { 
                            
                            serialTask = new SerialTask();
                            serialTask.addTask(new TimedTask( join._delay));
    //                        serialTask.addTask( new FunctionTask(moveToHome));
                            serialTask.addTask(LocationTask.CreateEaseIn(piece.x, board.getPieceYLoc( board.idxToY(piece.boardIndex)) - Constants.PUZZLE_TILE_SIZE, Constants.VERTICAL_JOIN_ANIMATION_TIME));
                            piece.addTask( serialTask );
                            
                            
                            if(  col != join._buildCol ) {
                                
                                serialTask = new SerialTask();
                                serialTask.addTask( new TimedTask( Constants.VERTICAL_JOIN_ANIMATION_TIME + join._delay));
//                                serialTask.addTask( ChangableTargetLocationTask.CreateEaseIn(piece.x, board.getPieceYLoc( board.idxToY(piece.boardIndex)), Constants.PIECE_DROP_TIME) );
//                                serialTask.addTask( LocationTask.CreateEaseIn(piece.x, board.getPieceYLoc( board.idxToY(piece.boardIndex)), Constants.PIECE_DROP_TIME) );
                                piece._targetX = piece.x;
                                piece._targetY = board.getPieceYLoc( board.idxToY(piece.boardIndex));
                                serialTask.addTask( LocationTask.CreateEaseIn(piece.x, board.getPieceYLoc( board.idxToY(piece.boardIndex)), Constants.PIECE_DROP_TIME) );
                                serialTask.addTask( LocationTask.CreateEaseIn(piece.x, board.getPieceYLoc( board.idxToY(piece.boardIndex))  + Constants.DISTANCE_OVER_TARGET_DROPPED_PIECES_FALL, Constants.PIECE_BOUNCE_TIME*0.5) );
                                serialTask.addTask( LocationTask.CreateEaseIn(piece.x, board.getPieceYLoc( board.idxToY(piece.boardIndex)) , Constants.PIECE_BOUNCE_TIME * 0.5));

//                                piece.addNamedTask((e.joins[0] as JoinGameJoin)._searchIteration + FALL_AND_BOUNCE_TASK_NAME, serialTask, true);
                                piece.addTask(serialTask);
                            }
                    
                            
                            
                        }
                        /* The shock absorbing pieces left and right (the middle gets the shock animation
                        from the doPiecesFall */
                        if(true);
                        if( col != join._buildCol ) {
                            piece = board.getPieceAt( col, j + 1);
                            if( piece != null && piece.type != Constants.PIECE_TYPE_INACTIVE && !board.isEmptyPiecesUnderThisPiece(piece)) {

                                var toX :int = board.getPieceXLoc(board.idxToX(piece.boardIndex));
                                toY = board.getPieceYLoc(board.idxToY(piece.boardIndex));
                                
                                var taskAnimation :SerialTask = new SerialTask();
                                taskAnimation.addTask( new TimedTask(Constants.VERTICAL_JOIN_ANIMATION_TIME + Constants.PIECE_DROP_TIME + join._delay) );
                                taskAnimation.addTask( LocationTask.CreateEaseOut(toX, toY + Constants.DISTANCE_OVER_TARGET_DROPPED_PIECES_FALL, Constants.PIECE_BOUNCE_TIME*0.5) );
                                taskAnimation.addTask( LocationTask.CreateEaseIn(toX, toY, Constants.PIECE_BOUNCE_TIME * 0.5) );
                                piece.addNamedTask((e.joins[0] as JoinGameJoin)._searchIteration + FALL_AND_BOUNCE_TASK_NAME,  taskAnimation );
                                
                            }
                        }
                        
                    }
                    
                    
                }
                
                function moveToHome(piece :JoinGamePiece) :void
                {
                    piece.x = board.getPieceXLoc( board.idxToX( piece.boardIndex ));
                    piece.y = board.getPieceYLoc( board.idxToY( piece.boardIndex ));
                }
                
                if(e.alternativeVerticalJion) {
                    
                    for( i = 0; i < board._cols; i++) {
                        piece = board.getPieceAt( i, board._rows - 1);
                        if( piece != null) {
                            board._boardPieces[ piece.boardIndex ] = null;
                            serialTask = new SerialTask();
                            serialTask.addTask( new TimedTask( Constants.VERTICAL_JOIN_ANIMATION_TIME + join._delay + 0.1) );
                            serialTask.addTask( new SelfDestructTask() );
                            piece.addTask( serialTask );
                            
                            piece.boardIndex = -1;
                            createTimedExplosionForPiece( board, piece, Constants.VERTICAL_JOIN_ANIMATION_TIME + join._delay); 
                            
//                            var explosionMovieE :MovieClip = new _piece_break_eastwardClass();
//                            var explosionMovieW :MovieClip = new _piece_break_westwardClass();
//                            var asplosionSprite :Sprite = new Sprite();
//                            asplosionSprite.addChild( explosionMovieE)
//                            asplosionSprite.addChild( explosionMovieW);
//                            var asplosionScene :SceneObject = new SimpleSceneObject(asplosionSprite);
//                            board.db.addObject(asplosionScene, board._sprite);
//                            board._animationsToDestroyWhenIDie.push( asplosionScene );
//                            asplosionScene.x = piece.x;
//                            asplosionScene.y = piece.y;
//                            asplosionScene.visible = false;
//                            
//                            
//                            var coverAnimTask :SerialTask = new SerialTask();
//                            coverAnimTask.addTask(new TimedTask(Constants.VERTICAL_JOIN_ANIMATION_TIME + join._delay));
//                            coverAnimTask.addTask(new VisibleTask(true));
//                            coverAnimTask.addTask(new TimedTask(0.4));
//                            coverAnimTask.addTask(new SelfDestructTask());
//                            asplosionScene.addTask( coverAnimTask );
                            
                        }
                    }
                    
//                    board.clearBottomRow();
                }
//                else {
                    /* Animate the piece backgrounds */
                for each ( col in [join._buildCol - 1, join._buildCol, join._buildCol+1]) {
                    if(col >= 0 && col < board._cols) {
                        j = board._boardRepresentation.getHighestActiveRow(col);
                        var back :SceneObject = board._backgroundPieces[ board.coordsToIdx( col, j) ];
                        if(back != null) {
                            back.visible = false;
                            serialTask = new SerialTask();
                            serialTask.addTask( new TimedTask( join._searchIteration * (Constants.VERTICAL_JOIN_ANIMATION_TIME + Constants.PIECE_DROP_TIME + Constants.PIECE_BOUNCE_TIME)) );
                            serialTask.addTask(LocationTask.CreateLinear(back.x, board.getPieceYLoc(j + 1),  0));
                            serialTask.addTask(new VisibleTask(true));
                            serialTask.addTask(LocationTask.CreateEaseIn(back.x, board.getPieceYLoc(j), Constants.VERTICAL_JOIN_ANIMATION_TIME));
                            back.addTask( serialTask);
                        }   
                        
                    }
                }
//                }
                
                
                
            }
//            log.debug("view doVerticalJoins() board after:\n" + board);
            
        }
        
        protected function createTimedExplosionForPiece( board :JoinGameBoardGameArea, piece :JoinGamePiece, delay :Number) :void
        {
            var explosionMovieE :MovieClip = new _piece_break_eastwardClass();
            var explosionMovieW :MovieClip = new _piece_break_westwardClass();
            var asplosionSprite :Sprite = new Sprite();
            asplosionSprite.addChild( explosionMovieE)
            asplosionSprite.addChild( explosionMovieW);
            var asplosionScene :SceneObject = new SimpleSceneObject(asplosionSprite);
            board.db.addObject(asplosionScene, board._sprite);
            board._animationsToDestroyWhenIDie.push( asplosionScene );
            asplosionScene.x = piece.x;
            asplosionScene.y = piece.y;
            asplosionScene.visible = false;
            
            
            var coverAnimTask :SerialTask = new SerialTask();
            coverAnimTask.addTask(new TimedTask(delay));
            coverAnimTask.addTask(new VisibleTask(true));
            coverAnimTask.addTask(new TimedTask(0.3));
            coverAnimTask.addTask(new SelfDestructTask());
            asplosionScene.addTask( coverAnimTask );
            
        }
        
        
        
        protected function doAddNewPieces( e :InternalJoinGameEvent ) :void
        {
            log.debug("view doAddNewPieces()");
            var toY :int;
            var toX :int;
            var board :JoinGameBoardGameArea = getBoardView( e.boardPlayerID );
            var index :int;
            var pieceToChange :JoinGamePiece;
            var dropFrom :int;
            var parallelTask :ParallelTask;
            
//            New pieces start out 
            
            if( board != null) {
//                board.updating = true;
//                log.debug("view addNewPieces(), view=" + board);
//                log.debug("view addNewPieces(), model=" + board._boardRepresentation);
                
//                /* Convert all nulls to inactives */
//                for( index ; index < board._boardPieces.length; index++){
//                    pieceToChange = board._boardPieces[index] as JoinGamePiece;
//                    if(pieceToChange == null){
//                        pieceToChange = board.addPieceAtPosition( board._boardRepresentation.idxToX(index), board._boardRepresentation.idxToY(index), Constants.PIECE_TYPE_INACTIVE, 1);
//                    }
//                }
                
                
                /* Find out how many pieces above and below this one are also to be added*/
                var col2NewPieces :HashMap = new HashMap();
                var col2HighestNullPieceRow :HashMap = new HashMap();
                var index2NewPiecesBelow :HashMap = new HashMap();
                for( var i :int = 0; i < board._cols; i++) {
                    var newPieceCount :int = 0;
                    for( var j :int = 0; j < board._rows; j++) {
                        index = board.coordsToIdx( i, j);
                        pieceToChange = board._boardPieces[index] as JoinGamePiece;
                        if( pieceToChange == null || pieceToChange.type == Constants.PIECE_TYPE_INACTIVE && board._boardRepresentation._boardPieceTypes[index] == Constants.PIECE_TYPE_NORMAL) {
                            newPieceCount++;
                            if( !col2HighestNullPieceRow.containsKey( i)) {
                                col2HighestNullPieceRow.put( i, j);
                            }
                            else {
                                col2HighestNullPieceRow.put( i, Math.min(col2HighestNullPieceRow.get( i), j));
                            }
                            
                            var newPiecesBelowThisOne :int = 0;
                            for( var _j :int = j + 1; _j < board._rows; _j++) {
                                var lowerindex :int = board.coordsToIdx( i, _j);
                                var pieceLower :JoinGamePiece = board._boardPieces[lowerindex] as JoinGamePiece;
                                if( pieceLower == null || pieceLower.type == Constants.PIECE_TYPE_INACTIVE && board._boardRepresentation._boardPieceTypes[lowerindex] == Constants.PIECE_TYPE_NORMAL) {
                                    newPiecesBelowThisOne++;
                                }
                            }
                            index2NewPiecesBelow.put( index, newPiecesBelowThisOne);
                        }
                    }
                    col2NewPieces.put( i, newPieceCount);
                    
                }
//                trace("col2NewPieces=" + col2NewPieces);
//                col2NewPieces.forEach( function print( key :int, value :int) :void
//                {
//                    trace( key + "=" + value);
//                });
                
                
//                trace("index2NewPiecesBelow=" + index2NewPiecesBelow);
//                index2NewPiecesBelow.forEach( function print( key :int, value :int) :void
//                {
//                    trace( key + "=" + value);
//                });
                
                
                
                for( index = 0; index < board._boardPieces.length; index++){
                    pieceToChange = board._boardPieces[index] as JoinGamePiece;
                    
                    if(pieceToChange == null){
                        pieceToChange = board.addPieceAtPosition( board._boardRepresentation.idxToX(index), board._boardRepresentation.idxToY(index), Constants.PIECE_TYPE_INACTIVE, 1);
                    }
                    
                    
//                    board.updating = true;
                    /* Change the piece type if we haven't filled in an empty piece */
                    if( pieceToChange.type != board._boardRepresentation._boardPieceTypes[index]){// || pieceToChange.color != board._boardRepresentation._boardPieceColors[index] ){//&& pieceToChange.type == Constants.PIECE_TYPE_EMPTY
                        
//                        pieceToChange.x = board.getPieceXLoc( board.idxToX( pieceToChange.boardIndex ));
                        pieceToChange.y = 0;
                        
                        board._sprite.setChildIndex( pieceToChange.displayObject, 1);
                        pieceToChange.color = board._boardRepresentation._boardPieceColors[index];
                        pieceToChange.type = board._boardRepresentation._boardPieceTypes[index];
                        pieceToChange.visible = false;
//                        continue;
                        /*  We could rotate the pieces in */
//                        var pieceAnim :SerialTask = new SerialTask();
//                        pieceAnim.addTask(RotationTask.CreateLinear(360*1, 0.8));//.CreateEaseIn(1.0, 1.0, Constants.PIECE_SCALE_DOWN_TIME));
//                        pieceToChange.addTask(pieceAnim);
                        
                        
                        
                        
                        /* We place the piece half a piece above the lowest empty tile */
                        toY = board.getPieceYLoc( board.idxToY( pieceToChange.boardIndex ));
                        
                        var appearAnim :SerialTask = new SerialTask();
                        appearAnim.addTask( new TimedTask(e.delay));
                        
                        var rowWhenStartBeingVisible :int = board._boardRepresentation.getHighestActiveRow( board.idxToX( pieceToChange.boardIndex) );
//                        var dropFrom :int = board.getPieceYLoc( rowToDropFrom ) - Constants.PUZZLE_TILE_SIZE / 2;


                        var fallTask :LocationTask = LocationTask.CreateEaseIn(pieceToChange.x, toY, Constants.PIECE_DROP_TIME); 
                        
                        
                        
                        
                        
                        if( rowWhenStartBeingVisible == board.idxToY( pieceToChange.boardIndex ) && col2NewPieces.get(board.idxToX( pieceToChange.boardIndex )) <= 1 ) {
                            dropFrom = board.getPieceYLoc( board.idxToY( pieceToChange.boardIndex ) ) - Constants.PUZZLE_TILE_SIZE;
                        }
                        else {
                            dropFrom = board.getPieceYLoc( board.idxToY( pieceToChange.boardIndex ) ) - Constants.PUZZLE_TILE_SIZE * col2NewPieces.get(board.idxToX( pieceToChange.boardIndex ));
                        }
                        appearAnim.addTask( LocationTask.CreateLinear( board.getPieceXLoc( board.idxToX( pieceToChange.boardIndex )), dropFrom, 0) );
                        appearAnim.addTask( new TimedTask(Constants.VERTICAL_JOIN_ANIMATION_TIME ) );
                        pieceToChange._yTrigger = board.getPieceYLoc( rowWhenStartBeingVisible ) - Constants.PUZZLE_TILE_SIZE/2;
                        pieceToChange._visibiltyDependsOnY = true;
//                        parallelTask = new ParallelTask( new RepeatingTask( new FunctionTask(pieceToChange.makeVisibleWhenOverYTrigger)), 
//                            fallTask);
                        appearAnim.addTask( fallTask );
                        toX = board.getPieceXLoc( board.idxToX( pieceToChange.boardIndex ));
                        
                        appearAnim.addTask( LocationTask.CreateEaseIn(toX, toY + Constants.DISTANCE_OVER_TARGET_DROPPED_PIECES_FALL, Constants.PIECE_BOUNCE_TIME * 0.5));
                        appearAnim.addTask( LocationTask.CreateEaseIn(toX, toY, Constants.PIECE_BOUNCE_TIME*0.5));
//                        pieceToChange.addTask(appearAnim);
                        
                        pieceToChange.addNamedTask(e._searchIteration + FALL_AND_BOUNCE_TASK_NAME, appearAnim, true);
                        
                    }
                    
                    /*We may have added the piece via vertical joins, but then we didnt know the 
                    color.  We know it now, so change it*/
                    if( pieceToChange.color != board._boardRepresentation._boardPieceColors[index]){// || pieceToChange.color != board._boardRepresentation._boardPieceColors[index] ){//&& pieceToChange.type == Constants.PIECE_TYPE_EMPTY
                        pieceToChange.color = board._boardRepresentation._boardPieceColors[index];
                    }
                    
                    
                }
//                board.updating = false;
            }
            
        }
        
        

        
        
        protected function doPiecesFall( e :InternalJoinGameEvent) :void
        {
            log.debug("view doPiecesFall(), delay=" + e.delay);
            var taskAnimation :SerialTask;
            var toX :Number;
            var toY :Number;
            if( getBoardView( e.boardPlayerID ) != null)
            {
//              

                var board :JoinGameBoardGameArea = getBoardView( e.boardPlayerID );
//                board.updating = true;
                
//                log.debug("view doPiecesFall() before: " + board);
                
                var highestRowIndexToAbsorbShockForEachColumnWithFallingPieces :HashMap = new HashMap();
//                var fallingPieces :Array = [];
                
                /* Before pieces fall, animate the pieces  */
                
                var newBoardPieces :Array = new Array();
                for( var i :int = 0; i < e.toFall.length; i++) {
//                    log.debug(" to fall: " + e.toFall[i] );
                    var fallArray :Array = e.toFall[i] as Array;
                    var piece :JoinGamePiece = board._boardPieces[ board.coordsToIdx( fallArray[0], fallArray[1]) ];
                    
                    if(piece == null){
                        continue;
                    }
                    
//                    fallingPieces.push(piece);
                    
                    var rowIndexUnderThisPiece :int = fallArray[3] + 1;
                    if( rowIndexUnderThisPiece >= 0 && rowIndexUnderThisPiece < board._rows) {
                        if( highestRowIndexToAbsorbShockForEachColumnWithFallingPieces.containsKey( fallArray[0]) ) {
                            highestRowIndexToAbsorbShockForEachColumnWithFallingPieces.put( fallArray[0], Math.max( rowIndexUnderThisPiece, highestRowIndexToAbsorbShockForEachColumnWithFallingPieces.get( fallArray[0])));
                        }
                        else {
                            highestRowIndexToAbsorbShockForEachColumnWithFallingPieces.put( fallArray[0], rowIndexUnderThisPiece);
                        }
                    }
                    
//                    if( !ArrayUtil.contains( columnsWithFallingPieces, fallArray[0])) {
//                        columnsWithFallingPieces.push( fallArray[0] );
//                    }
                    
//                    piece.visible = false;
                    
                    toX = board.getPieceXLoc(fallArray[2]);
                    toY = board.getPieceYLoc(fallArray[3]);
                    taskAnimation = new SerialTask();
                    taskAnimation.addTask( new TimedTask( e.delay + Constants.VERTICAL_JOIN_ANIMATION_TIME) );
                    
                    
                    taskAnimation.addTask( LocationTask.CreateEaseIn(toX, toY , Constants.PIECE_DROP_TIME ));// - dropTime) );
                    taskAnimation.addTask( new PlaySoundTask("pieces_land"));
                    
                    taskAnimation.addTask( LocationTask.CreateEaseIn(toX, toY + Constants.DISTANCE_OVER_TARGET_DROPPED_PIECES_FALL, Constants.PIECE_BOUNCE_TIME * 0.5));// - dropTime) );
                    taskAnimation.addTask( LocationTask.CreateEaseIn(toX, toY, Constants.PIECE_BOUNCE_TIME*0.5));

                        
                    piece.addNamedTask(e._searchIteration + FALL_AND_BOUNCE_TASK_NAME, taskAnimation, true);
                    
                    
                    piece._targetX = piece.x;
                    piece._targetY = toY;
                                  
                                  
                    board._boardPieces[ piece.boardIndex ] = null;
                    piece.boardIndex = board.coordsToIdx( fallArray[2], fallArray[3]);
                    
                    board._boardPieces[ piece.boardIndex ] = piece;
                    
//                    log.debug("so, piece at index=" + piece.boardIndex + " is " + piece);
                }
                
                
                /* Animate the column absorbing the shock of the falling pieces */
//                log.debug("highestRowIndexToAbsorbShockForEachColumnWithFallingPieces=" + highestRowIndexToAbsorbShockForEachColumnWithFallingPieces);

                if(true) {
                    for each ( var key: int in highestRowIndexToAbsorbShockForEachColumnWithFallingPieces.keys()) {
                        i = key;
                        var j :int = highestRowIndexToAbsorbShockForEachColumnWithFallingPieces.get(key) as int;
    //                    log.debug("key=" + key + ", value=" + j);
    //                    for( var j :int = 0; j < board._rows; j++) {
                            var nonFallingPiece :JoinGamePiece = board._boardPieces[ board.coordsToIdx( i, j) ];
                            if( nonFallingPiece != null) { /* Only act on non-falling pieces */
    //                            log.debug("Animating ( " + i + ", " + j + ")");
    
    
                                toX = board.getPieceXLoc(board.idxToX(nonFallingPiece.boardIndex));
                                toY = board.getPieceYLoc(board.idxToY(nonFallingPiece.boardIndex));
                                
                                taskAnimation = new SerialTask();
                                taskAnimation.addTask( new TimedTask(e.delay + Constants.VERTICAL_JOIN_ANIMATION_TIME + Constants.PIECE_DROP_TIME) );
                                taskAnimation.addTask( LocationTask.CreateEaseOut(toX, toY + Constants.DISTANCE_OVER_TARGET_DROPPED_PIECES_FALL/2, Constants.PIECE_BOUNCE_TIME*0.5) );
                                taskAnimation.addTask( LocationTask.CreateEaseIn(toX, toY, Constants.PIECE_BOUNCE_TIME * 0.5) );
    //                            nonFallingPiece.removeAllTasks();
                                nonFallingPiece.addTask( taskAnimation );
                            }
    //                        else { log.debug(" piece null ");}
    //                    }
                         
                    }
                }
//                board._updating = false;    
            }
            else {log.debug("doPiecesFall() no board found for id=" + e.boardPlayerID );}
        }
        
//        protected function redoFallingAnimationsDueToBoardSizeChange( board :JoinGameBoardGameArea) :void
//        {
//            for each ( var piece :JoinGamePiece in board._boardPieces) {
//                if (piece != null ) {
//                    if( piece.hasTasksNamed( FALL_AND_BOUNCE_TASK_NAME ) ){
//                        piece.re
//                    }
//                }
//            }
//        }
        
        
        /**
        * 
        * If the model sends us a confirm, we update the indices of 
        * the pieces.  A previous call of movePieceToLocationAndShufflePieces
        * only changes the positions, which was temporary.
        */
        protected function deltaConfirm( e :InternalJoinGameEvent) :void
        {
            var boardview :JoinGameBoardGameArea = getBoardView( e.boardPlayerID );
            if( boardview != null)
            {
                boardview.updating = true;
                boardview.movePieceToLocationAndShufflePieces( e.deltaPiece1X, e.deltaPiece1Y, e.deltaPiece2X, e.deltaPiece2Y);
                boardview._pendingDelta = false;
                boardview.updating = false;
            }
        }
        
        
        
        /**
        * Updates position and placement of game boards.
        * 
        */
        public function updateBoardDisplays(event :InternalJoinGameEvent = null) :void
        {
            var animationDelay :int = 0;
            if(event != null) {
                animationDelay = Constants.HEADSHOT_MOVEMENT_TIME;
            }
//            log.debug("\updateBoardDisplays, _observer="+_observer);
            if(_observer) {
                updateBoardDisplaysForObserver(animationDelay);
            }
            else {
                updateBoardDisplaysFor3BoardViews(animationDelay);
            }
        }
        
        protected function updateBoardDisplaysFor3BoardViews(movementDelay :int = 0) :void 
        {
            log.debug("updateBoardDisplaysFor3BoardViews()");
            if( !ArrayUtil.contains( _gameModel.currentSeatingOrder, AppContext.playerId))
            {
                log.debug("Humans are dead, not updating the boardview");
                return;
            }
//            Check if any board are acive but shouldn't


//            if( !_sprite.contains( _destroyBottomRowButton)) {
//                _sprite.addChild( _destroyBottomRowButton);
//            }
            
            if(_myBoardDisplay != null && _myBoardDisplay.board.playerID != AppContext.playerId)
            {
                if(_myBoardDisplay.isLiveObject) {
                    _myBoardDisplay.addTask( new SerialTask( new TimedTask( Constants.BOARD_DISTRUCTION_TIME), new SelfDestructTask()));
                }
                _myBoardDisplay.board = null;
            }
                
            if(_myBoardDisplay == null)
            {
                _myBoardDisplay = new JoinGameBoardGameArea( _gameControl, true);
                this.db.addObject(_myBoardDisplay, _sprite);
                /* The board must be added AFTER the display is added to the db, so all the pieces
                are added to the db also. */
                _myBoardDisplay.board = _gameModel.getBoardForPlayerID( AppContext.playerId );
                adjustZoomOfPlayAreaBasedOnCurrentPlayersBoard();
//                _sprite.addChild(_myBoardDisplay);
                _myBoardDisplay.doBoardEnterFromBottomAnimation( Constants.GUI_MIDDLE_BOARD_CENTER );
                
                // add the BoardView to the mode, as a child of the board sprite
                
                
        
            }
            
            if(_myBoardDisplay != null) {
//                _myBoardDisplay.updatePieceBackgrounds();
                _myBoardDisplay.updateYBasedOnBoardHeight();
                if(_sprite.contains( _myBoardDisplay.displayObject)) {
                    _sprite.setChildIndex( _myBoardDisplay.displayObject, _sprite.numChildren - 1);
                }
                
                
            }

            var leftPlayerId :int =  _gameModel.getPlayerIDToLeftOfPlayer(AppContext.playerId);
            var rightPlayerId :int =  _gameModel.getPlayerIDToRightOfPlayer(AppContext.playerId);
            log.debug("     leftPlayerId=" + leftPlayerId + ", rightPlayerId=" + rightPlayerId);
            if(_leftBoardDisplay != null && _leftBoardDisplay.board.playerID != _gameModel.getPlayerIDToLeftOfPlayer(AppContext.playerId))
            {
                log.debug("     removing player on left, as " + _leftBoardDisplay.board.playerID + "!=" + _gameModel.getPlayerIDToLeftOfPlayer(AppContext.playerId) );
                if(_leftBoardDisplay.isLiveObject) {
                    _leftBoardDisplay.addTask( new SerialTask( new TimedTask( Constants.BOARD_DISTRUCTION_TIME), new SelfDestructTask()));
//                    _leftBoardDisplay.destroySelf();
                }
                _leftBoardDisplay = null;
            }
            if(_leftBoardDisplay == null && _gameModel.currentSeatingOrder.length > 1 && _gameModel.getBoardForPlayerID( leftPlayerId )._state == JoinGameBoardRepresentation.STATE_ACTIVE)
            {
                log.debug("     adding board to my left");
                _leftBoardDisplay = new JoinGameBoardGameArea( _gameControl );
//                _sprite.addChild(_leftBoardDisplay);
                
                // add the BoardView to the mode, as a child of the board sprite
                this.db.addObject(_leftBoardDisplay, _sprite);
//                if( leftPlayerId != rightPlayerId ) {

//                    log.debug("me==" + AppContext.gameCtrl.game.getMyId() + ", leftPlayerId=" + leftPlayerId );
                    _leftBoardDisplay.board = _gameModel.getBoardForPlayerID( leftPlayerId );
                    if(_leftBoardDisplay._boardRepresentation._state == JoinGameBoardRepresentation.STATE_ACTIVE) {
                        log.debug("     left board from player " + _leftBoardDisplay.board.playerID + " entering from the side");
                        _leftBoardDisplay.doBoardEnterFromSideAnimation(Constants.LEFT);
                    }
            }
            else{
                log.error("Should be adding board to my left but for some reason cannot:");
                log.error("  _gameModel.currentSeatingOrder.length=" + _gameModel.currentSeatingOrder.length);
                log.error("  _gameModel.getBoardForPlayerID( leftPlayerId=" + leftPlayerId + " ) == null " + (_leftBoardDisplay == null));
                if( _gameModel.getBoardForPlayerID( leftPlayerId ) != null) {
                    log.error("  _gameModel.getBoardForPlayerID( leftPlayerId )._state=" + _gameModel.getBoardForPlayerID( leftPlayerId )._state);    
                }
                
            }
            
            if(_leftBoardDisplay != null) {
//                _leftBoardDisplay.updatePieceBackgrounds();
                _leftBoardDisplay.updateYBasedOnBoardHeight();
                if( _sprite.contains( _leftBoardDisplay.displayObject )) {
                    _sprite.setChildIndex( _leftBoardDisplay.displayObject, 1);
                }
                
            }
            
            
            if( _rightBoardDisplay != null && _leftBoardDisplay != null && _leftBoardDisplay.board.playerID == _gameModel.getPlayerIDToRightOfPlayer(AppContext.playerId)) {
                _rightBoardDisplay.addTask( new SerialTask( LocationTask.CreateEaseOut( 2000, _rightBoardDisplay.y, 0.5), new SelfDestructTask() ));
                _rightBoardDisplay = null;
            }
            
            if(_rightBoardDisplay != null && _rightBoardDisplay.board.playerID != _gameModel.getPlayerIDToRightOfPlayer(AppContext.playerId))
            {
                if(_rightBoardDisplay.isLiveObject) {
                    _rightBoardDisplay.addTask( new SerialTask( new TimedTask( Constants.BOARD_DISTRUCTION_TIME), new SelfDestructTask()));
//                    _rightBoardDisplay.destroySelf();
                }
                _rightBoardDisplay = null;
            }
            if(_rightBoardDisplay == null)
            {
                _rightBoardDisplay = new JoinGameBoardGameArea(_gameControl);
                this.db.addObject(_rightBoardDisplay, _sprite);
                if( leftPlayerId != rightPlayerId) {
                    _rightBoardDisplay.board = _gameModel.getBoardForPlayerID( rightPlayerId );
                }
                else {
                    _rightBoardDisplay.board = _gameModel.getBoardForPlayerID( -1 );
                }
                
//                _rightBoardDisplay.board = _gameModel.getBoardForPlayerID( _gameModel.getPlayerIDToRightOfPlayer(AppContext.playerId));
                _rightBoardDisplay.doBoardEnterFromSideAnimation(Constants.RIGHT);
            }
            
            if(_rightBoardDisplay != null) {
//                _rightBoardDisplay.updatePieceBackgrounds();
                _rightBoardDisplay.updateYBasedOnBoardHeight();
                if( _sprite.contains( _rightBoardDisplay.displayObject )) {
                    _sprite.setChildIndex( _rightBoardDisplay.displayObject, 1);
                }
                
            }
            adjustZoomOfPlayAreaBasedOnCurrentPlayersBoard();
//            log.debug("\nWhen id="+AppContext.playerId+" starts, left="+_gameModel.getPlayerIDToLeftOfPlayer(AppContext.playerId )+ ", right="+_gameModel.getPlayerIDToRightOfPlayer(AppContext.playerId ));
//            updateGameField();
        }
        
        protected function updateBoardDisplaysForObserver( movementDelay :int = 0) :void 
        {
            
            var board :JoinGameBoardGameArea;  
            var id :int;
            var scaleTask: ScaleTask;
            var moveTask :LocationTask;
            var parallelTask :ParallelTask;
            var toX :int;
            var toY :int;   
                 
                 
//            if( _sprite.contains( _destroyBottomRowButton)) {
//                _sprite.removeChild( _destroyBottomRowButton);
//            }     
            
                      
            for each ( id in _gameModel.currentSeatingOrder) {
                
                if( _gameModel.getBoardForPlayerID( id ) == null) {
                    throw new Error("updateBoardDisplaysForObserver(), but id is in currentSeatingOrder=" + _gameModel.currentSeatingOrder + ", but no board");
                }
                if( !_id2Board.containsKey( id) && _gameModel.getBoardForPlayerID( id )._state == JoinGameBoardRepresentation.STATE_ACTIVE) {//Create the board
                    board = new JoinGameBoardGameArea(null);
                    this.db.addObject(board, _sprite);
                    board.board = _gameModel.getBoardForPlayerID( id );
                    _id2Board.put( id, board );
                }
            }
            
            
            var boardWidth :int = Constants.PUZZLE_TILE_SIZE * Constants.PUZZLE_STARTING_COLS;
            
            var availableHorizontalSpaceForBoards :Number = AppContext.gameWidth - 2*Constants.GUI_OBSERVER_VIEW_GAP_BETWEEN_BORDER_AND_BOARDS;
//            log.debug("availableHorizontalSpaceForBoards=" + availableHorizontalSpaceForBoards);
            var playerCount :int = _gameModel.currentSeatingOrder.length;
            var boardScale :Number = ((availableHorizontalSpaceForBoards - (Constants.GUI_OBSERVER_VIEW_GAP_BETWEEN_BOARDS * playerCount  + 1))/ playerCount) / boardWidth;
//            log.debug("boardScale=" + boardScale);
            boardScale = Math.min(0.7, boardScale);
            var actualBoardWidth :int = boardWidth * boardScale;
            var totalWidthOfAllBoards :int = actualBoardWidth * playerCount + Constants.GUI_OBSERVER_VIEW_GAP_BETWEEN_BOARDS * (playerCount - 1);
            var adjustedXOffset :int = (availableHorizontalSpaceForBoards - totalWidthOfAllBoards)/2;
//            log.debug("boardScale=" + boardScale);
            var currentXPosition :int = Constants.GUI_OBSERVER_VIEW_GAP_BETWEEN_BORDER_AND_BOARDS + adjustedXOffset;
            
            var boardHeight :int;
            for each ( id in _gameModel.currentSeatingOrder) {
                
                board = _id2Board.get(id) as JoinGameBoardGameArea;
                
                if(board == null) {
                    board = new JoinGameBoardGameArea(null);
                    
                }
//                board.updatePieceBackgrounds();
                
//                boardHeight = board.height; //Constants.PUZZLE_TILE_SIZE * board._rows * boardScale;
                toX = currentXPosition;
//                toY = (AppContext.gameHeight - boardHeight) - Constants.GUI_OBSERVER_VIEW_GAP_BETWEEN_FLOOR_AND_BOARDS;
                toY = -Constants.MAX_PUZZLE_HEIGHT*boardScale + (AppContext.gameHeight - Constants.GUI_OBSERVER_VIEW_GAP_BETWEEN_FLOOR_AND_BOARDS);
                
//                trace("bottom of board is toY=" + toY);
                scaleTask = new ScaleTask(boardScale, boardScale, movementDelay);
                moveTask = LocationTask.CreateEaseOut(toX, toY, movementDelay);
                parallelTask = new ParallelTask( scaleTask, moveTask);
                board.addTask( parallelTask ); 
                currentXPosition +=  actualBoardWidth + Constants.GUI_OBSERVER_VIEW_GAP_BETWEEN_BOARDS;
                
            }
            
//            adjustZoomOfPlayAreaBasedOnCurrentPlayersBoard();
        }
        
        
        /** Respond to messages from other clients. */
        protected function playerDestroyed (e :InternalJoinGameEvent) :void
        {
            log.debug("playerDestroyed( boardId=" + e.boardPlayerID + ")");
//            _gameControl.local.feedback("BoardsView.playerKnockedOut(" + e.boardPlayerID + ")");
            //Play a board distruction animation
            if( getBoardView( e.boardPlayerID ) != null)
            {
                /* Don't do board destruction animation if the winning player leaves. */
                if( _gameModel.activePlayers > 1) {
                    var boardview :JoinGameBoardGameArea = getBoardView( e.boardPlayerID );
                    boardview._boardRepresentation._state = JoinGameBoardRepresentation.STATE_GETTING_KNOCKED_OUT;
                    boardview.doBoardDistructionAnimation();
                }
//                log.debug("view deltaConfirm() model " + e.boardPlayerID + "==view: " + boardview.isModelAndViewSame());
            }
            else {
                log.debug("    boardview is null");
            }
            dispatchEvent( new InternalJoinGameEvent( e.boardPlayerID, InternalJoinGameEvent.PLAYER_DESTROYED));
//            updateBoardDisplays();
        }
        
        override protected function update( dt:Number) :void
        {
            //Check if we have any 'floating' boards.
            for each ( var board :JoinGameBoardGameArea in _id2Board.values()) {
                if( board != null) {
                    if( !ArrayUtil.contains( _gameModel.currentSeatingOrder, board._boardRepresentation.playerID)) {
                        //Ok the board should not be visible
                        if( board._boardRepresentation._state == JoinGameBoardRepresentation.STATE_REMOVED ) {
                            if( board.isLiveObject) {
                                board.destroySelf();
                                if( board.displayObject.parent != null) {
                                    board.displayObject.parent.removeChild( board.displayObject);
                                }
                            }
                        }
                    }
                }
            }
            super.update(dt);
        }
        
        
        /** Respond to messages from other clients. */
        protected function playerRemoved (e :InternalJoinGameEvent) :void
        {
//            _gameControl.local.feedback("BoardsView.playerKnockedOut(" + e.boardPlayerID + ")");
            //Play a board distruction animation
//            if( getBoardView( e.boardPlayerID ) != null)
//            {
//                var boardview :JoinGameBoardGameArea = getBoardView( e.boardPlayerID );
////                log.debug("view deltaConfirm() model " + e.boardPlayerID + "==view: " + boardview.isModelAndViewSame());
//            }
            
            dispatchEvent( new InternalJoinGameEvent( e.boardPlayerID, InternalJoinGameEvent.PLAYER_REMOVED));
            updateBoardDisplays();
        }
        
        
        
        
        
        
        
        protected function getBoardView( playerid :int) :JoinGameBoardGameArea
        {
            if(_observer) {
                return _id2Board.get( playerid ) as JoinGameBoardGameArea;
            }
            else {
                if( _myBoardDisplay != null && playerid == _myBoardDisplay._boardRepresentation.playerID )
                {
                    return _myBoardDisplay;
                }
                else if( _leftBoardDisplay != null && playerid == _leftBoardDisplay._boardRepresentation.playerID )
                {
                    return _leftBoardDisplay;
                }
                else if( _rightBoardDisplay != null && playerid == _rightBoardDisplay._boardRepresentation.playerID )
                {
                    return _rightBoardDisplay;
                }
            }
            return null;
        }
        
        
        public function adjustZoomOfPlayAreaBasedOnCurrentPlayersBoard() :void
        {
            
            
//            log.debug("\nadjustZoomOfPlayAreaBasedOnCurrentPlayersBoard, _myBoardDisplay.height=" + (_myBoardDisplay != null ?_myBoardDisplay.height : "null"));
            
            if( _myBoardDisplay != null && _myBoardDisplay._rows >= Constants.MAX_ROWS) {
                
                _myBoardDisplay.scaleX = 1.0;
                _myBoardDisplay.scaleY = 1.0;
                var newScale :Number = Constants.MAX_ROWS / Number(_myBoardDisplay._rows);
                _myBoardDisplay.scaleX = newScale;
                _myBoardDisplay.scaleY = newScale;
                
                if(_leftBoardDisplay != null) {
                    _leftBoardDisplay.scaleX = newScale;
                    _leftBoardDisplay.scaleY = newScale;
                }
                
                if(_rightBoardDisplay != null) {
                    _rightBoardDisplay.scaleX = newScale;
                    _rightBoardDisplay.scaleY = newScale;
                }
            }
            
            
            
            if(_myBoardDisplay != null) {
                _myBoardDisplay.updateYBasedOnBoardHeight();
                _myBoardDisplay.x = Constants.GUI_MIDDLE_BOARD_CENTER - _myBoardDisplay.scaleX*Constants.PUZZLE_STARTING_COLS*Constants.PUZZLE_TILE_SIZE/2;//_myBoardDisplay.width/2;
                
//                _destroyBottomRowButton.x = Constants.GUI_MIDDLE_BOARD_CENTER - _destroyBottomRowButton.width/2;
//                _destroyBottomRowButton.y = (AppContext.gameHeight - Constants.GUI_BOARD_FLOOR_GAP) -10;
            }
            
            
            if(_leftBoardDisplay != null) {
                _leftBoardDisplay.updateYBasedOnBoardHeight();
                _leftBoardDisplay.x = Constants.GUI_WEST_BOARD_RIGHT - _leftBoardDisplay.scaleX*Constants.PUZZLE_STARTING_COLS*Constants.PUZZLE_TILE_SIZE/2;
            }
            
            if(_rightBoardDisplay != null) {
                _rightBoardDisplay.updateYBasedOnBoardHeight();
                _rightBoardDisplay.x = Constants.GUI_EAST_BOARD_LEFT - _rightBoardDisplay.scaleX*Constants.PUZZLE_STARTING_COLS*Constants.PUZZLE_TILE_SIZE/2;
            }
            
        }
        
        override public function destroySelf():void
        {
            _gameModel.removeEventListener(InternalJoinGameEvent.START_NEW_ANIMATIONS, startNewBoardAnimations);
            _gameModel.removeEventListener(InternalJoinGameEvent.PLAYER_DESTROYED, playerDestroyed);
            _gameModel.removeEventListener(InternalJoinGameEvent.PLAYER_REMOVED, playerRemoved);
            _gameModel.removeEventListener(InternalJoinGameEvent.RECEIVED_BOARDS_FROM_SERVER, updateBoardDisplays);
            _gameModel.removeEventListener(InternalJoinGameEvent.DELTA_CONFIRM, deltaConfirm);
            _gameModel.removeEventListener(InternalJoinGameEvent.DO_PIECES_FALL, doPiecesFall);
            _gameModel.removeEventListener(InternalJoinGameEvent.ADD_NEW_PIECES, doAddNewPieces);
            _gameModel.removeEventListener(InternalJoinGameEvent.VERTICAL_JOIN, doSingleVerticalJoin);
            _gameModel.removeEventListener(InternalJoinGameEvent.ATTACKING_JOINS, doHorizontalAttack);
            _gameModel.removeEventListener(InternalJoinGameEvent.BOARD_UPDATED, boardUpdated);
            _gameModel.removeEventListener(InternalJoinGameEvent.DO_DEAD_PIECES, doDeadPieces);
            _gameModel.removeEventListener(InternalJoinGameEvent.REMOVE_ROW_PIECES, doRemoveRowPieces);
            _gameModel.removeEventListener(InternalJoinGameEvent.REMOVE_BOTTOM_ROW_AND_DROP_PIECES, removeBottomRowAndDropPieces);
            _gameModel.removeEventListener(InternalJoinGameEvent.RESET_VIEW_FROM_MODEL, resetViewFromModel);
            _gameModel.removeEventListener(InternalJoinGameEvent.DONE_COMPLETE_DELTA, doFinishAnimations);
            _gameModel.removeEventListener(InternalJoinGameEvent.PLAYER_ADDED, doPlayerAdded);
            _gameModel.removeEventListener(InternalJoinGameEvent.GAME_OVER, handleGameOver);
            super.destroySelf();
        }
        
        
        protected function doPlayerAdded( event :InternalJoinGameEvent) :void
        {
            log.debug("doPlayerAdded(), updating displays.");
            updateBoardDisplays();
            var newEvent :InternalJoinGameEvent = new InternalJoinGameEvent(event.boardPlayerID, InternalJoinGameEvent.PLAYER_ADDED);
            dispatchEvent( newEvent ); 
        }
        
//        protected function   
 
        override public function get displayObject () :DisplayObject
        {
            return _sprite;
        }     
        
        private var _myBoardDisplay :JoinGameBoardGameArea;
        private var _leftBoardDisplay :JoinGameBoardGameArea;
        private var _rightBoardDisplay :JoinGameBoardGameArea;
        
        private var _id2Board :HashMap;
        
        private var rand :Random = new Random();
        
        
        /*This variable represents the entire game state */
        private var _gameModel :JoinGameModel;
        
        private var _gameControl :GameControl;
        
        protected var _sprite :Sprite;
        
        
        protected static const MOVE_TASK_NAME :String = "move";
        
        protected static const SHOCKWAVE_TASK_NAME :String = "shock";
        public static const WOBBL_TASK_NAME :String = "wobble";
        
        public static const FALL_AND_BOUNCE_TASK_NAME :String = "fall and bounce";
        public static const PUSH_UP_FROM_VERTICAL_JOIN_NAME :String = "push up";
        
        public static const REMOVE_BOTTOM_ROW_BUTTON :String = "Request bottom row removal";
        
        private var _piece_break_eastwardClass :Class;
        private var _piece_break_westwardClass :Class;
        
        private var _observer :Boolean;    
        
        private static const log :Log = Log.getLog(JoinGameBoardsView);
        
//        private var _destroyBottomRowButton :SimpleTextButton; 

        
        
//        protected static var SWF_VERT_CLASSES :Array;
//        protected static const SWF_VERT_CLASS_NAMES :Array = [ "01_vert", "02_vert", "03_vert", "04_vert", "05_vert"];
//        protected static var SWF_HORIZ_CLASSES :Array;
//        protected static const SWF_HORIZ_CLASS_NAMES :Array = [ "01_horiz", "02_horiz", "03_horiz", "04_horiz", "05_horiz" ];
        

    }
}