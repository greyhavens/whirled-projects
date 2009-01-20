package joingame.model
{
    import com.threerings.util.ArrayUtil;
    import com.threerings.util.ClassUtil;
    import com.threerings.util.HashMap;
    import com.threerings.util.Log;
    import com.threerings.util.Random;
    import com.whirled.game.GameControl;
    import com.whirled.net.MessageReceivedEvent;
    
    import flash.events.EventDispatcher;
    import flash.utils.getTimer;
    
    import joingame.AppContext;
    import joingame.Constants;
    import joingame.UserCookieDataSourcePlayer;
    import joingame.net.AddPlayerMessage;
    import joingame.net.BoardRowRemoveConfirmtoServer;
    import joingame.net.BoardUpdateConfirmMessage;
    import joingame.net.BottomRowRemovalConfirmMessage;
    import joingame.net.DeltaConfirmMessage;
    import joingame.net.GameOverMessage;
    import joingame.net.InternalJoinGameEvent;
    import joingame.net.JoinGameMessage;
    import joingame.net.PlayerDestroyedMessage;
    import joingame.net.PlayerRemovedMessage;
    import joingame.net.ResetViewToModelMessage;
    
    /**
     * The state of the entire game is represented by this class.
     * It contains as many JoinGameBoardRepresentationss as there are players.
     * Each player, and the server, maintain an instance of this 
     * class, synchronised by the JoingameServer.
     * 
     * 
     * Main listener to the JoingameServer.  Notifies other, more graphically
     * oriented classes of changes that require animations and other similar changes.
     */
    public class JoinGameModel extends EventDispatcher
    {
        private static const log :Log = Log.getLog(JoinGameModel);
        
        public function JoinGameModel(gameControl:GameControl, isServerModel :Boolean = false)
        {
//            Log.setLevel(ClassUtil.getClassName(JoinGameModel), Log.INFO);
            _gameCtrl = gameControl;
            
//            if( _gameCtrl != null && !_gameCtrl.net.isConnected() ) {
//                throw new Error( "GameControl must be connected if passing to " + ClassUtil.shortClassName(this));
//            }
            
            
            _playerToBoardMap = new HashMap();
            _currentSeatedPlayerIds = new Array();
            _initialSeatedPlayerIds = new Array();
            _playerIdsInOrderOfLoss = new Array();
            _isServerModel = isServerModel;
            
            _gameOver = false;
            
            //Add the null board, for showing destroyed or missing players
            var board :JoinGameBoardRepresentation = new JoinGameBoardRepresentation();
            board.playerID = -1;
            board._rows = Constants.PUZZLE_STARTING_ROWS;
            board._cols = Constants.PUZZLE_STARTING_COLS;
            for(var k:int = 0; k < board._rows*board._cols; k++)
            {
                board._boardPieceColors[k] = 0;
                board._boardPieceTypes[k] = Constants.PIECE_TYPE_INACTIVE;
            }
            
            _playerToBoardMap.put(-1, board);
            
//            _singlePlayerLevel = 0;
            //Add ourselves to listen to events from the server, if we are a model on a client
            //We listen for when the board (representation on the server) is changed and 
            //update our model and add animations accordingly.
            if( !_isServerModel)
            {
                AppContext.messageManager.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            }
        }

        

        public function getComputerIdsAdjacentToHumanPlayer () :Array
        {
            var humanId :int = humanPlayerId;
            if( humanId > 0) {
                return [ getPlayerIDToLeftOfPlayer( humanId), getPlayerIDToRightOfPlayer( humanId) ];
            }
            
            log.info("getComputerIdsAdjacentToHumanPlayer(), humanId=" + humanId + ", returning []");
            return [];
        }
        
        public function get humanPlayerId () :int
        {
            return _singlePlayerHumanId;
//            for each (var id :int in currentSeatingOrder) {
//                if( id > 0) {
//                    return id;
//                }
//            }
//            //We throw an error.  We should never expect a human Id when there isn't any.
//            throw new Error("No human id found in currentSeatingOrder=" + currentSeatingOrder);
//            log.warning("getHumanPlayerId(), no human found in currentSeatingOrder=" + currentSeatingOrder + ", returning 0");
//            return 0;
        }
        
        public function set humanPlayerId ( id :int) :void
        {
            _singlePlayerHumanId = id;
            if( AppContext.isMultiplayer ) {
                log.warning("It makes no sense to set the single player id in a multiplayer game");
            }
        }
        
        
        protected function handleGameOver( event :GameOverMessage ) :void
        {
            _gameOver = true;
            _tempNewPlayerCookie = event.userCookieData;
            if( event.userCookieData == null) {
                log.warning("handleGameOver(), event has no user cookie");
            }
            
            log.debug("handleGameOver()");
            dispatchEvent( new InternalJoinGameEvent( -1, InternalJoinGameEvent.GAME_OVER));
        }
        
        protected function handleAddPlayer( event :AddPlayerMessage ) :void
        {
            if( event.fromServer ) {
                var board :JoinGameBoardRepresentation = new JoinGameBoardRepresentation();
                board.setBoardFromCompactRepresentation( event.board );
                addPlayer( board.playerID, board, event.addToLeft);
//                if( event.seatingOrder != null ) {
//                    currentSeatingOrder = event.seatingOrder;
//                }
            }
        }

        protected function handleDeltaConfirm( event :DeltaConfirmMessage ) :void
        {
            if( _gameOver ) {
                log.warning("handleDeltaConfirm(), game over, so nothing done.");
                return;
            }
            log.debug((_isServerModel ? "SERVER: " : "CLIENT: " ) +event);
            var board :JoinGameBoardRepresentation = _playerToBoardMap.get(event.playerId) as JoinGameBoardRepresentation;
            
            if(board != null) {
                deltaConfirm(event.playerId, event.fromIndex, event.toIndex);
            }
            else {
                log.error("BOARD_DELTA_CONFIRM sent but no board with id="+event.playerId);
            }
        }
        
        protected function handleBoardUpdateConfirm( event :BoardUpdateConfirmMessage ) :void
        {
            log.debug(event);
            var board :JoinGameBoardRepresentation = _playerToBoardMap.get(event.boardId) as JoinGameBoardRepresentation;
            var boardRep:Array = event.board;
            board.setBoardFromCompactRepresentation(boardRep);
        }
        
        protected function handlePlayerDestroyed( event :PlayerDestroyedMessage ) :void
        {
//            if( _gameOver ) {
//                log.warning("handlePlayerDestroyed(), game over, so nothing done.");
//                return;
//            }
            
            log.debug(event);
            dispatchEvent( new InternalJoinGameEvent( event.playerId, InternalJoinGameEvent.PLAYER_DESTROYED));
            
        }
        
        protected function handlePlayerRemoved( event :PlayerRemovedMessage ) :void
        {
//            if( _gameOver ) {
//                log.warning("handlePlayerRemoved(), game over, so nothing done.");
//                return;
//            }
            
            log.debug(event);
            var id :int = event.playerId;
            if(id != 0)
            {
                removePlayer(id);
                if( _isServerModel ) {//The server model notifies the server itself.
                    dispatchEvent( new InternalJoinGameEvent( id, InternalJoinGameEvent.PLAYER_REMOVED));
                }
            }
        }
        
        protected function handleBoardRemoveRowConfirm( event :BottomRowRemovalConfirmMessage ) :void
        {
            log.debug(event);
            doRemoveBottomRow( getBoardForPlayerID( event.playerId) );
        }
        
        protected function handleResetViewToModel( event :ResetViewToModelMessage ) :void
        {
            log.debug(event);
            dispatchEvent( new InternalJoinGameEvent( event.playerId, InternalJoinGameEvent.RESET_VIEW_FROM_MODEL));
        }
        
        public function destroy() :void 
        {
            AppContext.messageManager.removeEventListener( MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
//            AppContext.messageManager.removeEventListener( DeltaConfirmMessage.NAME, handleDeltaConfirm);
//            AppContext.messageManager.removeEventListener( BoardUpdateConfirmMessage.NAME, handleBoardUpdateConfirm);
//            AppContext.messageManager.removeEventListener( PlayerDestroyedMessage.NAME, handlePlayerDestroyed);
//            AppContext.messageManager.removeEventListener( PlayerRemovedMessage.NAME, handlePlayerRemoved);
//            AppContext.messageManager.removeEventListener( BottomRowRemovalConfirmMessage.NAME, handleBoardRemoveRowConfirm);
                
            for each (var board :JoinGameBoardRepresentation in _playerToBoardMap.values()) {
                if( board != null) { 
                    board.destroy();
                }
            }
        }


        /**
        * Returns a copy.
        */
        public function get currentSeatingOrder() :Array
        {
//            if( AppContext.isConnected ) {
////                if( _gameCtrl.net.get( CURRENT_PLAYERS_STRING ) == null) {
////                    _gameCtrl.net.set( CURRENT_PLAYERS_STRING, [], true);
////                }
//                return (_gameCtrl.net.get( CURRENT_PLAYERS_STRING ) as Array).slice();
//            }
//            else {
                return _currentSeatedPlayerIds.slice();
//            }
        }
        
        public function set currentSeatingOrder( playerids :Array) :void
        {
//            if(!_isServerModel) {
//                log.error("Client models cannot set currentSeatingOrder");
//                return;
//            }
//            if( AppContext.isConnected) {
//                if( !_isServerModel) {
//                    log.error("Setting currentSeatingOrder, but we are not on the server!!!");
//                }
//                else {
//                    _gameCtrl.net.set( CURRENT_PLAYERS_STRING, playerids, true);
//                }
//            }
//            else {
                _currentSeatedPlayerIds = playerids.slice();
//            }
        }
        
        /**
        * An array representation of the model.
        */
        public function getModelMemento(): Array
        {
            var boards:Array = new Array();

            boards.push(currentSeatingOrder.slice());
            boards.push(_initialSeatedPlayerIds.slice());
            boards.push(_playerIdsInOrderOfLoss.slice());
            boards.push(_singlePlayerHumanId);
            boards.push(_singlePlayerGameType);
            
            var keys:Array = _playerToBoardMap.keys();
            
            for(var i: int = 0; i < keys.length; i++)
            {
                boards.push(  (_playerToBoardMap.get( keys[i] ) as JoinGameBoardRepresentation).getBoardAsCompactRepresentation()  );
            }
            return boards;
        }
        
        public function setModelMemento(representation:Array): void
        {
            var keys:Array = _playerToBoardMap.keys();
            var i: int;
            var board:JoinGameBoardRepresentation;
            
            for( i = 0; i < keys.length; i++)
            {
                board = _playerToBoardMap.get( keys[i]  )  as JoinGameBoardRepresentation;
                board.destroy();
            }
            
            _playerToBoardMap.clear();
            
            currentSeatingOrder = representation[0] as Array;
            _initialSeatedPlayerIds = representation[1] as Array;
            _playerIdsInOrderOfLoss = representation[2] as Array;
            _singlePlayerHumanId = representation[3] as int;
            _singlePlayerGameType = representation[4] as String;
            
            for( i = 5; i < representation.length; i++)
            {
                var currentBoardRep:Array = representation[i] as Array;
                var playerID:int = currentBoardRep[0] as int;
                board = new JoinGameBoardRepresentation();
                board.setBoardFromCompactRepresentation( currentBoardRep );
                _playerToBoardMap.put( playerID, board);
            }
            
            dispatchEvent(new InternalJoinGameEvent(-1, InternalJoinGameEvent.RECEIVED_BOARDS_FROM_SERVER));
        }
        

        private static function getPlayerIDToLeft(myid:int, _playerIDsInOrderOfPlay:Array): int 
        {
            if( _playerIDsInOrderOfPlay == null || _playerIDsInOrderOfPlay.length <= 1) {
                log.warning("getPlayerIDToLeft( " + myid + ", " + _playerIDsInOrderOfPlay + "), _playerIDsInOrderOfPlay null or empty, returning 0");
                return 0;
            }
            
            var myIDIndex: int = ArrayUtil.indexOf(_playerIDsInOrderOfPlay, myid );
            if( myIDIndex != -1)
            {
                if(myIDIndex == 0)
                {
                    return _playerIDsInOrderOfPlay[_playerIDsInOrderOfPlay.length - 1];
                }
                else
                {
                    return _playerIDsInOrderOfPlay[ myIDIndex - 1];
                }
            }
            log.warning("getPlayerIDToLeft( " + myid + ", " + _playerIDsInOrderOfPlay + "), myIDIndex == -1, returning 0");
            return 0;
        }
        
        private static function getPlayerIDToRight(myid:int, _playerIDsInOrderOfPlay:Array): int 
        {
            if(  _playerIDsInOrderOfPlay == null ||  _playerIDsInOrderOfPlay.length <= 1) {
                log.warning("getPlayerIDToRight( " + myid + ", " + _playerIDsInOrderOfPlay + "), _playerIDsInOrderOfPlay null or empty, returning 0");
                return 0;
            }
                
            var myIDIndex: int = ArrayUtil.indexOf(_playerIDsInOrderOfPlay, myid);
            if( myIDIndex != -1)
            {
                if(myIDIndex >= _playerIDsInOrderOfPlay.length - 1)
                {
                    return _playerIDsInOrderOfPlay[0];
                }
                else
                {
                    return _playerIDsInOrderOfPlay[ myIDIndex + 1];
                }
            }
            log.warning("getPlayerIDToRight( " + myid + ", " + _playerIDsInOrderOfPlay + "), myIDIndex == -1, returning 0");
            return 0;
        }



        /**
         * Returns the id of the player sitting to the left of the
         * player, otherwise -1 if nobody is to the left.
         */
        public function getPlayerIDToLeftOfPlayer(playerid:int): int 
        {
            return getPlayerIDToLeft( playerid, currentSeatingOrder);
            
        }
        
        /**
         * Returns the id of the player sitting to the right of the
         * player, otherwise -1 if nobody is to the left.
         */
        public function getPlayerIDToRightOfPlayer(playerid:int): int 
        {
            return getPlayerIDToRight( playerid, currentSeatingOrder);
            
        }

        /**
         * board: the board that performed the joins.
         * 
         */
        public function doHorizontalJoinEffects(board :JoinGameBoardRepresentation, join :JoinGameJoin, 
             doJoinEffects :Boolean = true, doHealing :Boolean = false): void
        {
            var i :int;
            var piecex :int;
            var piecey :int;
                /* Do the join effect,
                   then remove pieces, then animate the falling pieces.  */

            if(join != null)
            {
                //If there are "dead" pieces adjacent to the cleared pieces, "heal" them
                if(doHealing)
                {
                    for(i = 0; i < join._piecesWithHealingPower.length; i++)
                    {
                        piecex = board.idxToX( join._piecesWithHealingPower[i] as int);
                        piecey = board.idxToY( join._piecesWithHealingPower[i]);
                        var adjacentPiecesIndicies:Array = board.getAdjacentPieceIndices(piecex, piecey);
                        for(var k: int = 0; k < adjacentPiecesIndicies.length; k++)
                        {
                            var adjacentPieceIndex: int = adjacentPiecesIndicies[k];
                            if( board._boardPieceTypes[adjacentPieceIndex] == Constants.PIECE_TYPE_DEAD)
                            {
                                board._boardPieceTypes[adjacentPieceIndex] = Constants.PIECE_TYPE_NORMAL;
                            }
                        }
                    }
                }
                
                
                
                var atackevent :InternalJoinGameEvent;
                if(doJoinEffects)
                {
                    //Attack the other side
                    if(join._widthInPieces > 1 )
                    {
                        var idLeft: int = getPlayerIDToLeftOfPlayer(board.playerID);
                        var idRight: int = getPlayerIDToRightOfPlayer(board.playerID);
                        var idOfPlayerToAttack: int = join.attackSide == JoinGameJoin.LEFT ? idLeft : idRight;
                        var sideAttackComesFromForAttacked: int = join.attackSide == JoinGameJoin.LEFT ? JoinGameJoin.RIGHT : JoinGameJoin.LEFT;  
                        var damageFor7Join:int = 2;
                        
                        if( join._widthInPieces == 4)
                        {
//                            if( !(board.playerID < 0 && idOfPlayerToAttack < 0) ) {
                                doAttack(board.playerID, _playerToBoardMap.get( idOfPlayerToAttack), sideAttackComesFromForAttacked, join.attackRow, 1);
//                            }
                            atackevent = new InternalJoinGameEvent( board.playerID, InternalJoinGameEvent.ATTACKING_JOINS);
                            atackevent.joins = [join];
                            atackevent.boardAttacked = idOfPlayerToAttack;
                            atackevent.row = join.attackRow;
                            atackevent.damage = 1;
                            atackevent.side = sideAttackComesFromForAttacked;
                            dispatchEvent( atackevent);
                            
                        }    
                        else if( join._widthInPieces == 5)
                        {
//                            if( !(board.playerID < 0 && idLeft < 0) ) {
                                doAttack(board.playerID, _playerToBoardMap.get(idLeft), Constants.RIGHT, join.attackRow, 1);
//                            }
//                            if( !(board.playerID < 0 && idRight < 0) ) {
                                doAttack(board.playerID, _playerToBoardMap.get(idRight), Constants.LEFT, join.attackRow, 1);
//                            }
                            
                            atackevent = new InternalJoinGameEvent( board.playerID, InternalJoinGameEvent.ATTACKING_JOINS);
                            atackevent.joins = [join];
                            atackevent.boardAttacked = idLeft;
                            atackevent.row = join.attackRow;
                            atackevent.damage = 1;
                            atackevent.side = Constants.RIGHT;
                            dispatchEvent( atackevent);
                            
                            atackevent = new InternalJoinGameEvent( board.playerID, InternalJoinGameEvent.ATTACKING_JOINS);
                            atackevent.joins = [join];
                            atackevent.boardAttacked = idRight;
                            atackevent.row = join.attackRow;
                            atackevent.damage = 1;
                            atackevent.side = Constants.LEFT;
                            dispatchEvent( atackevent);
                        }    
                        if( join._widthInPieces ==6)
                        {
//                            if( !(board.playerID < 0 && idOfPlayerToAttack < 0) ) {
                                doAttack(board.playerID, _playerToBoardMap.get(idOfPlayerToAttack), sideAttackComesFromForAttacked, join.attackRow, damageFor7Join);
//                            }
                            atackevent = new InternalJoinGameEvent( board.playerID, InternalJoinGameEvent.ATTACKING_JOINS);
                            atackevent.joins = [join];
                            atackevent.boardAttacked = idOfPlayerToAttack;
                            atackevent.row = join.attackRow;
                            atackevent.damage = damageFor7Join;
                            atackevent.side = sideAttackComesFromForAttacked;
                            dispatchEvent( atackevent);
                        }    
                        if( join._widthInPieces ==7)
                        {
                            
                            if(false && idLeft == idRight)
                            {
                                if(_random.nextBoolean())
                                {
                                    doAttack(board.playerID, _playerToBoardMap.get(idLeft), Constants.RIGHT, join.attackRow, damageFor7Join);
                                    
                                    atackevent = new InternalJoinGameEvent( board.playerID, InternalJoinGameEvent.ATTACKING_JOINS);
                                    atackevent.joins = [join];
                                    atackevent.boardAttacked = idLeft;
                                    atackevent.row = join.attackRow;
                                    atackevent.damage = damageFor7Join;
                                    atackevent.side = Constants.RIGHT;
                                    dispatchEvent( atackevent);
                                }
                                else
                                {
                                    doAttack(board.playerID, _playerToBoardMap.get(idRight), Constants.RIGHT, join.attackRow, damageFor7Join);
                                    
                                    atackevent = new InternalJoinGameEvent( board.playerID, InternalJoinGameEvent.ATTACKING_JOINS);
                                    atackevent.joins = [join];
                                    atackevent.boardAttacked = idRight;
                                    atackevent.row = join.attackRow;
                                    atackevent.damage = damageFor7Join;
                                    atackevent.side = Constants.RIGHT;
                                    dispatchEvent( atackevent);
                                }
                                
                            }
                            else
                            {
//                                if( !(board.playerID < 0 && idLeft < 0) ) {
                                    doAttack(board.playerID, _playerToBoardMap.get(idLeft), Constants.RIGHT, join.attackRow, damageFor7Join);
//                                }
//                                if( !(board.playerID < 0 && idRight < 0) ) {
                                    doAttack(board.playerID, _playerToBoardMap.get(idRight), Constants.LEFT, join.attackRow, damageFor7Join);
//                                }
                                
                                atackevent = new InternalJoinGameEvent( board.playerID, InternalJoinGameEvent.ATTACKING_JOINS);
                                atackevent.joins = [join];
                                atackevent.boardAttacked = idLeft;
                                atackevent.row = join.attackRow;
                                atackevent.damage = damageFor7Join;
                                atackevent.side = Constants.RIGHT;
                                dispatchEvent( atackevent);
                                
                                atackevent = new InternalJoinGameEvent( board.playerID, InternalJoinGameEvent.ATTACKING_JOINS);
                                atackevent.joins = [join];
                                atackevent.boardAttacked = idRight;
                                atackevent.row = join.attackRow;
                                atackevent.damage = damageFor7Join;
                                atackevent.side = Constants.LEFT;
                                dispatchEvent( atackevent);
                                
                            }
                        }    
                    }
                     
                }              
            } 
        }
  
  
        /**
        * Adds new empty piece places to the top of column of the vertical join, 
        * plus the columns immediately adjacent.
        */
        public function doSingleVerticalJoinEffects(board :JoinGameBoardRepresentation, join :JoinGameJoin, 
             doJoinEffects :Boolean = true, doHealing :Boolean = false): void
        {
            var i :int;
            var piecex :int;
            var piecey :int;

            if(join != null)
            {
                if(doJoinEffects)
                {
                    /* Build up */
                    if(join._heighInPiecest > 1 )
                    {
                        var event :InternalJoinGameEvent = new InternalJoinGameEvent( board.playerID, InternalJoinGameEvent.VERTICAL_JOIN);
                        
                        
//                        trace("model: doSingleVerticalJoinEffects() before clear row: " + board);
                        var clearBottomRow :Boolean = false;
                        
                        if( Constants.TESTING_NEW_MECHANIC) {
                            for each ( i in [join._buildCol - 1, join._buildCol, join._buildCol + 1] ){
                                if(i >= 0 && i < board._cols) {
                                    if( board._rows - board.getHighestActiveRow(i) >= Constants.MAX_ROWS) {
                                        clearBottomRow = true;
                                        break;
                                    }
                                }
                            }
                        }
                        
                        board.addNewPieceToColumnAndLeftAndRight(join._buildCol );
                        
                        if(clearBottomRow) {
                            board.clearRow( board._rows - 1);
                            event.alternativeVerticalJion = true;
                        }
                        else {
                            event.alternativeVerticalJion = false;
                        }
                        
                        
//                        trace("model: doSingleVerticalJoinEffects() after clear row, sendin event: " + board);
                        event._searchIteration = join._searchIteration;
                        event.joins = [join];
                        event.col = join._buildCol;
                        dispatchEvent( event);
                    }  
                }              
            } 
        }      
        
        /**
        * Add new pieces to fall wherever we have empty piece slots.
        */
        public function addNewPieces( board :JoinGameBoardRepresentation, searchIteration :int,  delay :Number ): void
        {
            var addPiecesEvent :InternalJoinGameEvent = new InternalJoinGameEvent(board.playerID,  InternalJoinGameEvent.ADD_NEW_PIECES);
            addPiecesEvent.delay = delay;
            addPiecesEvent._searchIteration = searchIteration;
            for( var i: int = 0; i < board._boardPieceTypes.length; i++)
            {
                if(board._boardPieceTypes[i] == Constants.PIECE_TYPE_EMPTY)
                {
                    board._boardPieceTypes[i] = Constants.PIECE_TYPE_NORMAL;
                    board._boardPieceColors[i] = board.generateRandomPieceColor();
                    
                    //We record this for syncing the boards between players
                    board._numberOfCallsToRandom++;
                }
            }
            dispatchEvent( addPiecesEvent);
        }
        

        
        
        /**
         * Pieces fall wherever there are gaps.  Listeners are notified.
         */
        public function doPiecesFall(board :JoinGameBoardRepresentation, searchIteration :int, delay :int, sendEvent :Boolean = true): void
        {
            //Start at the bottom row moving up
            //If there are any empty pieces, swap with the next highest fallable block
            
            var fallEvent :InternalJoinGameEvent = new InternalJoinGameEvent(board.playerID, InternalJoinGameEvent.DO_PIECES_FALL);
            fallEvent._searchIteration = searchIteration;
            fallEvent.delay = delay;
            var newIndex2OldIndex :HashMap = new HashMap();
            
            for(var j: int = board._rows - 2; j >= 0 ; j--)
            {
                for(var i: int = 0; i <  board._cols ; i++)
                {
                    var pieceIndex :int = board.coordsToIdx(i, j);
            
                    
                    //Now drop the piece as far as there are empty spaces below it.
                    if( !(board._boardPieceTypes[pieceIndex] == Constants.PIECE_TYPE_NORMAL || board._boardPieceTypes[pieceIndex] == Constants.PIECE_TYPE_DEAD || board._boardPieceTypes[pieceIndex] == Constants.PIECE_TYPE_POTENTIALLY_DEAD))
                    {
                        continue;
                    }
                    
                    if( board._boardPieceTypes[pieceIndex] == Constants.PIECE_TYPE_INACTIVE || board._boardPieceTypes[pieceIndex] == Constants.PIECE_TYPE_EMPTY) {
                        log.error("uh oh, inactive or empty pieces should not be dropped");
                        
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
                        if( !newIndex2OldIndex.containsKey( board.coordsToIdx(i, yToFall) )){
                            newIndex2OldIndex.put( board.coordsToIdx(i, yToFall), board.coordsToIdx(i, j) );
                        }
                        else
                        {
                            var index :int = newIndex2OldIndex.get( board.coordsToIdx(i, yToFall) ) as int;
                            newIndex2OldIndex.put( board.coordsToIdx(i, yToFall), board.coordsToIdx(i, j) );
                            newIndex2OldIndex.put( board.coordsToIdx(i, j), index );
                            
                        }
                        fallEvent.toFall.push( [ i, j, i, yToFall ] );
                    }
                }
            }
            
            var keys :Array = newIndex2OldIndex.keys();
            for( var k :int = 0; k < keys.length; k++){
                fallEvent.newIndices.push( keys[k] );
                fallEvent.oldIndices.push( newIndex2OldIndex.get( keys[k] ));
            }
            
            if(sendEvent) {
                dispatchEvent( fallEvent );    
            }
        }
        
        
        /**
        * Attacks other boards from a given side.
        */
        public function doAttack(attackingPlayerId :int, board: JoinGameBoardRepresentation, side:int, rowsFromBottom: int, attackValue: int): void
        {
            if( board == null)
            {
                log.warning("doAttack( board is null)");
                return;
            }
            var targetRow: int = (board._rows-1) - rowsFromBottom;
            while(attackValue > 0)
            {
                board.turnPieceDeadAtRowAndSide( targetRow, side);
                attackValue--;
                board.changeCurrentPotentialJoin = true;//Recheck what joins we possibly can do.
                
            }
            AppContext.database.addDamage( attackingPlayerId, board.playerID, attackValue);
        }

        public function getBoardForPlayerID( playerID:int): JoinGameBoardRepresentation
        {
            if(playerID == -1 && !_playerToBoardMap.containsKey(-1)) {
                var board :JoinGameBoardRepresentation = new JoinGameBoardRepresentation();
                board.playerID = -1;
                board._rows = Constants.PUZZLE_STARTING_ROWS;
                board._cols = Constants.PUZZLE_STARTING_COLS;
                for(var k:int = 0; k < board._rows*board._cols; k++)
                {
                    board._boardPieceColors[k] = 0;
                    board._boardPieceTypes[k] = Constants.PIECE_TYPE_INACTIVE;
                }
                
                _playerToBoardMap.put(-1, board);
            }
            
            return _playerToBoardMap.get(playerID);
        }

        public function isPlayer(playerID:int):Boolean
        {
            return _playerToBoardMap.containsKey(playerID);
        }
        
        public function addPlayer(playerID:int, board:JoinGameBoardRepresentation, addToLeft :Boolean):void
        {
            log.debug((_isServerModel ? "Server" : "Client") + " adding new player=" + playerID);
            if( _playerToBoardMap.containsKey( playerID ) )
            {
                log.debug("addplayer( " + playerID + " ), but player already exists. Not adding.");
                return;   
            }
            
            _playerToBoardMap.put(playerID, board);
            
            if( _isServerModel && !ArrayUtil.contains( currentSeatingOrder, playerID))
            {
                var tempArray :Array = currentSeatingOrder != null ? currentSeatingOrder : [];
                if( addToLeft ) {
                    tempArray.unshift( playerID );
                }
                else {
                    tempArray.push( playerID );
                }
//                tempArray.splice(tempArray.length - 1, 0, playerID)
                currentSeatingOrder = tempArray;
            }
            
            if( !ArrayUtil.contains( _initialSeatedPlayerIds, playerID))
            {
                _initialSeatedPlayerIds.push(playerID);
            }
            
            if(board != null && _isServerModel)
            {
                //We listen for when the board (representation on the server) is changed and add
                //animations accordingly.
                board.addEventListener(InternalJoinGameEvent.REMOVE_ROW_NOTIFICATION, listenToRemoveBottomRowEvent);
            }
            _gameOver = false;
            
            log.debug((_isServerModel ? "Server" : "Client") + " currentSeatingOrder=" + currentSeatingOrder);
            var event :InternalJoinGameEvent = new InternalJoinGameEvent(playerID, InternalJoinGameEvent.PLAYER_ADDED);
            dispatchEvent(event);
        }
        
        /**
        * Only called on the server side, as only server side boards time the bottom row
        * destruction.
        */
        protected function listenToRemoveBottomRowEvent( e :InternalJoinGameEvent ) :void
        {
//            if( _isServerModel) {
//                log.debug("!!!!!Should only be called on the server");
//            }
            
            if(_isServerModel) {
//                var msg :Object = new Object;
//                msg[0] = e.boardPlayerID;
//                _gameCtrl.net.agent.sendMessage(JoingameServer.BOARD_REMOVE_ROW_CONFIRM_TO_SERVER, msg);
                
                AppContext.messageManager.sendMessage( new BoardRowRemoveConfirmtoServer( e.boardPlayerID));
            }
        }
        
        public function doRemoveBottomRow(board: JoinGameBoardRepresentation): Boolean
        {
            if( board == null || board._rows <= 0) {
                return false;
            }
            
            var removeRowAndDropPiecesEvent :InternalJoinGameEvent = new InternalJoinGameEvent( board.playerID, InternalJoinGameEvent.REMOVE_BOTTOM_ROW_AND_DROP_PIECES);
            dispatchEvent( removeRowAndDropPiecesEvent );
            
            
            for( var i :int = 0; i < board._cols; i++) {
                board._boardPieceTypes[ board.coordsToIdx( i, board._rows - 1 ) ] = Constants.PIECE_TYPE_EMPTY;
            }
            doPiecesFall(board, 0, 0, false);
            
            
            /* Replace empty pieces with inactive  */
            for( var k :int = 0; k < board._boardPieceTypes.length; k++){
                if( board._boardPieceTypes[k] == Constants.PIECE_TYPE_EMPTY){
                    board._boardPieceTypes[k] = Constants.PIECE_TYPE_INACTIVE;
                }
            }
            board.removeRow(0);
                    
            checkForDeadRegions(board);
            return true;
        }
        
        
        public function destroyPlayer(playerID:int):void
        {
            if( _playerToBoardMap.containsKey( playerID ) )
            {
                
                var board :JoinGameBoardRepresentation = _playerToBoardMap.get( playerID ) as JoinGameBoardRepresentation;
                if( board._state > JoinGameBoardRepresentation.STATE_ACTIVE ) {
                    log.info("destroyPlayer( " + playerID + "), but player is already asploding, so ignoring.");
                }
                else {
                    board._state = JoinGameBoardRepresentation.STATE_GETTING_KNOCKED_OUT;
                    var event :InternalJoinGameEvent = new InternalJoinGameEvent(playerID, InternalJoinGameEvent.PLAYER_DESTROYED);
                    dispatchEvent(event);
                }
            }
            else {
                log.debug("destroyPlayer( " + playerID + "), but no player exists");
            }
        }
        public function removePlayer(playerID:int):void
        {
            var event :InternalJoinGameEvent;
            var board :JoinGameBoardRepresentation;
            if( _playerToBoardMap.containsKey( playerID ) )
            {
                board = _playerToBoardMap.get(playerID) as JoinGameBoardRepresentation;
                board.destroy();
                board._state = JoinGameBoardRepresentation.STATE_REMOVED;
                _playerToBoardMap.remove(playerID);
//                if(_isServerModel) {
                    if( currentSeatingOrder.indexOf( playerID ) >= 0)
                    {
                        _currentSeatedPlayerIds = currentSeatingOrder;
                        _currentSeatedPlayerIds.splice( _currentSeatedPlayerIds.indexOf( playerID ), 1);
                        currentSeatingOrder = _currentSeatedPlayerIds;
                        
                    }
                    else
                    {
                        log.info("removePlayer " + playerID + " but no player exists in currentSeatingOrder");
                        return;
                    }
//                }
                
                _playerIdsInOrderOfLoss.push(playerID);
                
                
                event = new InternalJoinGameEvent(playerID, InternalJoinGameEvent.PLAYER_REMOVED);
                dispatchEvent(event);
                
                if( AppContext.isSinglePlayer) {
                    if( AppContext.playerId == playerID && !_gameOver) {
//                        _gameOver = true;
//                        event = new InternalJoinGameEvent(-1, InternalJoinGameEvent.GAME_OVER);
//                        dispatchEvent(event);
                    }
                }
                else if( currentSeatingOrder.length <= 1  ) {
                    _gameOver = true;
                    event = new InternalJoinGameEvent(-1, InternalJoinGameEvent.GAME_OVER);
                    dispatchEvent(event);

                }
                
            }
            else
            {
                log.error("removePlayer(" + playerID + ") but no such player exists");
            }
        }
        
      
        
        
        
        override public function toString():String
        {
            return "Players=" + _playerToBoardMap.keys().toString() + "\n Boards=" + _playerToBoardMap.values().toString();
        }
        
        /**
        * Confirms a delta (board change) that is sent from server, or called from the server itself.
        */
        public function deltaConfirm(boardId :int, fromIndex :int, toIndex :int) :void
        {
            log.debug( ClassUtil.shortClassName( JoinGameModel) + (_isServerModel ? " Server " : " Client ") + "deltaConfirm()"); 
//            AppContext.database.addDelta( boardId );
            
            //Update the player cookie
            if( AppContext.isSinglePlayer && boardId > 0) {
                AppContext.singlePlayerCookie.currentDeltas++;
            }
            
            if( _isServerModel ) {
                AppContext.database.addDelta( boardId );
            }
            
            var time :int = getTimer();
            
            var board: JoinGameBoardRepresentation = _playerToBoardMap.get(boardId) as JoinGameBoardRepresentation;;
            
//            if( !_isServerModel) {
//                log.debug("Client board before delta:" + board);
//            }
            
                
            var i :int;
            var j :int;
            var k :int;
            var join :JoinGameJoin;
            
            if( board == null)
            {
                log.warning("delta confirm for a null board with id=" + boardId);
                return;
            }    
               
            
            /* Move the pieces, and notify listeners to also change piece indices */
            board.movePieceToLocationAndShufflePieces( fromIndex, toIndex);            
            
            if( _isServerModel ) {
                AppContext.messageManager.sendMessage( new DeltaConfirmMessage( boardId, fromIndex, toIndex) );
            }
            
            
            var deltaEvent :InternalJoinGameEvent = new InternalJoinGameEvent( board.playerID, InternalJoinGameEvent.DELTA_CONFIRM);
            deltaEvent.deltaPiece1X = board.idxToX(fromIndex);
            deltaEvent.deltaPiece1Y = board.idxToY(fromIndex);
            deltaEvent.deltaPiece2X = board.idxToX(toIndex);
            deltaEvent.deltaPiece2Y = board.idxToY(toIndex);
            dispatchEvent(deltaEvent);
            
            
            //Ok up till here, then sync problems
            
            
            
            var wasJoins :Boolean = false;
            var wasHorizontalJoin :Boolean = false; //If true, we update the property state 
            var wasVerticalJoin :Boolean = false; //If true, we update the property state
            var verticalJoinCol: int = -1; 
            var joins:Array = board.checkForJoins();
            
            //If the AI creates a join, we should look for another potential join.
            if( joins.length > 0) { board.changeCurrentPotentialJoin = true;}
            
            var numberOfTimesJoinsSearched :int = 1;
            var joinSearchInteration :int = 0;
            
            
            var startlooptime :Number = getTimer();
            
            while(joins.length > 0)
            {
//                LOG("doing joins, iteration " + joinSearchInteration + ", joins found: " + joins.length);
                
                
                if( joinSearchInteration == 0) {
                    dispatchEvent( new InternalJoinGameEvent(board.playerID, InternalJoinGameEvent.START_NEW_ANIMATIONS) );
                }
                
                /* All joined pieces are now null. */
                wasJoins = true;
                for( i = 0; i < joins.length; i++)
                {
                    join = joins[i] as JoinGameJoin;
                    join._searchIteration = joinSearchInteration;
                    join._delay = joinSearchInteration*(Constants.VERTICAL_JOIN_ANIMATION_TIME+Constants.PIECE_DROP_TIME+Constants.PIECE_BOUNCE_TIME);
                    /* Remove pieces in the join */
                    for(var piecei :int = 0; piecei < join._piecesX.length; piecei++)
                    {
                        board._boardPieceTypes[ board.coordsToIdx( join._piecesX[piecei], board.convertFromBottomYToFromTopY(join._piecesYFromBottom[piecei])) ]  = Constants.PIECE_TYPE_EMPTY;
//                        LOG("setting empty piece=" + join._piecesX[piecei] + ", " + join._piecesY[piecei] );
                    }
                    
                    if(join._widthInPieces > 1){
                        board.changeCurrentPotentialJoin = true;
                        wasHorizontalJoin = true;
                        join._delay = Math.max(0, joinSearchInteration*(Constants.VERTICAL_JOIN_ANIMATION_TIME + Constants.PIECE_DROP_TIME + Constants.PIECE_BOUNCE_TIME) - (getTimer() - startlooptime)/1000.0);
                        doHorizontalJoinEffects(board, join, true, Constants.HEALING_ALLOWED);
                        
                        if( _isServerModel ) {
                            AppContext.database.addJoin(boardId, join._widthInPieces, true);
                            
                        }
                    }
                }
                /* Send the event for vertical joins */
                
                for( j = 0; j < joins.length; j++)
                {
                    /* Adds the extra pieces, and rows if neccesary, and sends the animation event */
                    var vjoin :JoinGameJoin = joins[j] as JoinGameJoin;
                    if(vjoin._heighInPiecest > 1){
//                        board.changeCurrentPotentialJoin = true;//The height might alter the target of the 
                        wasVerticalJoin = true;
                        vjoin._delay = Math.max(0, joinSearchInteration*(Constants.VERTICAL_JOIN_ANIMATION_TIME + Constants.PIECE_DROP_TIME + Constants.PIECE_BOUNCE_TIME) - (getTimer() - startlooptime)/1000.0);
                        verticalJoinCol = vjoin._buildCol;
                        doSingleVerticalJoinEffects(board, vjoin, true, Constants.HEALING_ALLOWED);
                    }
                }
                
                var delay :Number = Math.max(0, joinSearchInteration*(Constants.VERTICAL_JOIN_ANIMATION_TIME + Constants.PIECE_DROP_TIME + Constants.PIECE_BOUNCE_TIME) - (getTimer() - startlooptime)/1000.0); 
                doPiecesFall(board, joinSearchInteration, delay );
                delay = Math.max(0, joinSearchInteration*(Constants.VERTICAL_JOIN_ANIMATION_TIME + Constants.PIECE_DROP_TIME + Constants.PIECE_BOUNCE_TIME) - (getTimer() - startlooptime)/1000.0);
                addNewPieces(board, joinSearchInteration, delay );
                checkForDeadRegions(board);
                joins = board.checkForJoins();
                
                numberOfTimesJoinsSearched++;
                
//           
                joinSearchInteration++;     
                startlooptime = getTimer();
            }
            
            
            
            if(wasJoins)
            {
                checkForDeadRegions(board);
            }
            
            
            
            
            checkForDeadBoards(board.playerID);
    
    
            dispatchEvent( new InternalJoinGameEvent(board.playerID, InternalJoinGameEvent.DONE_COMPLETE_DELTA) );
            
            if(_isServerModel) {
                
                if(board != null) {
                    board.setIntoPropertySpacesWhereDifferent( _gameCtrl);
                }
            
                if(wasHorizontalJoin) {
                    var leftBoard :JoinGameBoardRepresentation = getBoardForPlayerID( getPlayerIDToLeftOfPlayer( board.playerID) );
                    if(leftBoard != null) {
                        leftBoard.setIntoPropertySpacesWhereDifferent(_gameCtrl);
                    }
                    
                    var rightBoard :JoinGameBoardRepresentation = getBoardForPlayerID( getPlayerIDToRightOfPlayer( board.playerID) );
                    if(rightBoard != null && (leftBoard == null || rightBoard.playerID != leftBoard.playerID)) {
                        rightBoard.setIntoPropertySpacesWhereDifferent(_gameCtrl);
                    }
                }
            }
            

        }
        
        
        /**
        * Called on the server, results sent to clients.
        */
        protected function checkForDeadBoards(currentDeltaPlayerId :int) :void
        {
            if( _isServerModel) {
                for each (var playerid :int in currentSeatingOrder) {
                    var board :JoinGameBoardRepresentation =  _playerToBoardMap.get(playerid) as JoinGameBoardRepresentation;
                    if(board != null && !board.isAlive()) {
                        var event :InternalJoinGameEvent = new InternalJoinGameEvent( playerid, InternalJoinGameEvent.PLAYER_REMOVED)
                        dispatchEvent( event);
                        AppContext.database.addPlayerKilledPlayer( currentDeltaPlayerId, board.playerID);
                        //Update the player cookie
//                        if( AppContext.isSinglePlayer && currentDeltaPlayerId > 0) {
//                            AppContext.singlePlayerCookie.currentKills++;
//                        }
                    }
                }
            }
        }
        
        
        protected function checkForDeadRegions( board :JoinGameBoardRepresentation ) :void
        {
            if( board == null) {
                log.error("checkForDeadRegions( board == null )");
                return; 
            }
            var id :int;
            var adjacentBoard :JoinGameBoardRepresentation;
                
            convertDeadToDead(board);
            var event :InternalJoinGameEvent = new InternalJoinGameEvent(board.playerID, InternalJoinGameEvent.DO_DEAD_PIECES);
            dispatchEvent( event );
            
            if(_isServerModel){ /*If running on the server, adjust/start the bottom row timer if necessary */
                if(board.isBottomRowDead()){
                    board.startBottomRowTimer();/* There should be a timer running, if so leave it, if not start one */
                }
                else{
                    board.stopBottomRowTimer();
                }
            }
        
            id = getPlayerIDToLeftOfPlayer(board.playerID);
            if(id != 0) {
                adjacentBoard = getBoardForPlayerID(id);
                if( adjacentBoard != null) {
                    convertDeadToDead(adjacentBoard);
                    event = new InternalJoinGameEvent(id, InternalJoinGameEvent.DO_DEAD_PIECES);
                    dispatchEvent( event );
                    
                    if(_isServerModel){ /*If running on the server, adjust/start the bottom row timer if necessary */
                        if(adjacentBoard.isBottomRowDead()){
                            adjacentBoard.startBottomRowTimer();/* There should be a timer running, if so leave it, if not start one */
                        }
                        else{
                            adjacentBoard.stopBottomRowTimer();
                        }
                    }
                }
            }
            id = getPlayerIDToRightOfPlayer(board.playerID);
            if(id != 0)
            {
                adjacentBoard = getBoardForPlayerID(id);
                if( adjacentBoard != null) {
                    convertDeadToDead(adjacentBoard);
                    event = new InternalJoinGameEvent(id, InternalJoinGameEvent.DO_DEAD_PIECES);
                    dispatchEvent( event );
                    
                    if(_isServerModel){ /*If running on the server, adjust/start the bottom row timer if necessary */
                        if(adjacentBoard.isBottomRowDead()){
                            adjacentBoard.startBottomRowTimer();/* There should be a timer running, if so leave it, if not start one */
                        }
                        else{
                            adjacentBoard.stopBottomRowTimer();
                        }
                    }
                }
            }
        }

        
        /**
         * Converts the pieces that cannot possiblly form joins into 
         * "dead" pieces, marking them as unavailable.
         * 
         * Also starts the timer for the bottom row, if present on the JoingameServer.
         * 
         */
        private function convertDeadToDead(board :JoinGameBoardRepresentation, serverside :Boolean = false) :Boolean
        {
            if( board == null) {
                log.error("convertDeadToDead(board==null)");
                return false;
            }
            
            var k: int;
            var i: int;
            var isDeadPiecesFound :Boolean = false;
            
            
            
            for(k = 0; k < board._boardPieceTypes.length; k++)
            {
                if(board._boardPieceTypes[k] == Constants.PIECE_TYPE_POTENTIALLY_DEAD)
                {
                    board._boardPieceTypes[k] = Constants.PIECE_TYPE_NORMAL;
                }
            }
            var contiguousRegions:Array = board.getContiguousRegions();
            
            for(k = 0; k < contiguousRegions.length; k++)
            {
                var arrayOfContiguousPieces:Array = contiguousRegions[k] as Array;
                var convertToDead: Boolean = true;
                for(i = 0; i < arrayOfContiguousPieces.length; i++)
                {
                    var pieceIndex: int = int(arrayOfContiguousPieces[i]);
                    
                    if( !board.isNoMoreJoinsPossibleWithPiece( board.idxToX(pieceIndex), board.idxToY(pieceIndex)) )
                    {
                        convertToDead = false;
                        break;
                    } 
                }
                
                if(convertToDead)
                {
                    for(i = 0; i < arrayOfContiguousPieces.length; i++)
                    {
                        isDeadPiecesFound = true;
                        board._boardPieceTypes[ int(arrayOfContiguousPieces[i]) ] = Constants.PIECE_TYPE_POTENTIALLY_DEAD;
                    }
                }
            }
            
            return isDeadPiecesFound;
        }
        
        
        
        
        /** Respond to messages from other clients. */
        protected function messageReceived (event :MessageReceivedEvent) :void
        {
            if (event.value is DeltaConfirmMessage) {
                handleDeltaConfirm( DeltaConfirmMessage(event.value) );
            }
            else if (event.value is BoardUpdateConfirmMessage) {
                handleBoardUpdateConfirm( BoardUpdateConfirmMessage(event.value) );
            }
            else if (event.value is PlayerDestroyedMessage) {
                handlePlayerDestroyed( PlayerDestroyedMessage(event.value) );
            }
            else if (event.value is PlayerRemovedMessage) {
                handlePlayerRemoved( PlayerRemovedMessage(event.value) );
            }
            else if (event.value is BottomRowRemovalConfirmMessage) {
                handleBoardRemoveRowConfirm( BottomRowRemovalConfirmMessage(event.value) );
            }
            else if (event.value is AddPlayerMessage) {
                handleAddPlayer( AddPlayerMessage(event.value) );
            }
            else if (event.value is GameOverMessage) {
                handleGameOver( GameOverMessage(event.value) );
            }
            else {
                log.debug("messageReceived(), ignored: " + JoinGameMessage(event.value).name);
            }
                
                
//            log.error("Deprecated");
//            var id :int;
//            var board: JoinGameBoardRepresentation;
            
            //If the update refers to us, update, and notify the display
//            if (event.name == JoingameServer.BOARD_DELTA_CONFIRM)
//            {
//                
//                id = int(event.value[0]);
//                board = _playerToBoardMap.get(id) as JoinGameBoardRepresentation;
//                var fromIndex :int = int(event.value[1]);
//                var toIndex :int = int(event.value[2]);
//                
//                
//                if(board != null)
//                {
//                    deltaConfirm(id, fromIndex, toIndex);
//                }
//                else
//                {
//                    LOG("BOARD_DELTA_CONFIRM sent but no board with id="+id);
//                }
//            }
//            else
//            if (event.name == JoingameServer.BOARD_UPDATE_CONFIRM)
//            {
//                
//                id = int(event.value[0]);
//                
//                board = _playerToBoardMap.get(id) as JoinGameBoardRepresentation;
//                var boardRep:Array = event.value[1] as Array;
//                board.setBoardFromCompactRepresentation(boardRep);
//            }
//            else if (event.name == JoingameServer.PLAYER_DESTROYED)
//            {
//                
//                id = int(event.value[0]);
//                if(id >= 0)
//                {
//                    dispatchEvent( new InternalJoinGameEvent( id, InternalJoinGameEvent.PLAYER_DESTROYED));
//                }
//            }
//            else if (event.name == JoingameServer.PLAYER_REMOVED)
//            {
//                
//                id = int(event.value[0]);
//                if(id >= 0)
//                {
//                    removePlayer(id);
//                    if( _isServerModel ) {//The server model notifies the server itself.
//                        dispatchEvent( new InternalJoinGameEvent( id, InternalJoinGameEvent.PLAYER_REMOVED));
//                    }
//                }
//            }
//            else if (event.name == JoingameServer.BOARD_REMOVE_ROW_CONFIRM)
//            {
//                
//                id = int(event.value[0]);
//                if(id >= 0)
//                {
//                    doRemoveBottomRow( getBoardForPlayerID( id) );
//                }
//            }
//            else if (event.name == JoingameServer.RESET_VIEW_TO_MODEL)
//            {
//                id = int(event.value[0]);
//                if(id >= 0) {
//                    dispatchEvent( new InternalJoinGameEvent( id, InternalJoinGameEvent.RESET_VIEW_FROM_MODEL));
//                }
//            }
            
        }
        
        
//        public function LOG(s: String): void
//        {
//            if(false && _gameCtrl != null && _gameCtrl.local != null && _gameCtrl.net.isConnected())
//            {
//                _gameCtrl.local.feedback(s);
//            }
//            else
//            {
//                if( Constants.PLAYER_ID_TO_LOG == _gameCtrl.game.getMyId() || _gameCtrl.game.amServerAgent()) {
//                    trace(s);
//                }
//            }
//        }
        
        
        public function removeAllPlayers() :void
        {
            _playerIdsInOrderOfLoss = [];
            _initialSeatedPlayerIds = [];
//            if( _isServerModel ) {
                currentSeatingOrder = [];
//            }
//            else {
//                log.warning("Client should not set currentSeatingOrder");
//            }
            
            
            var keys :Array = _playerToBoardMap.keys();
            for each (var k :int in keys) {
                (_playerToBoardMap.get(k) as JoinGameBoardRepresentation).destroy();
            }
            _playerToBoardMap.clear();
        }
        
        public function setModelIntoPropertySpaces() :void
        {
            if( !_isServerModel ) {
                log.error("We are not a server model, so no model written to property spaces.");
                return;
            }
            
            if( !AppContext.isConnected ) {
                log.warning("We are not connected, so no model written to property spaces.");
                return;
            }
            log.debug("Writing model to property spaces");
            _gameCtrl.net.set(CURRENT_PLAYERS_STRING, currentSeatingOrder);
            _gameCtrl.net.set(INITIAL_PLAYERS_STRING, _initialSeatedPlayerIds);
            _gameCtrl.net.set(SINGLE_PLAYER_GAME_TYPE, _singlePlayerGameType);
            
            _playerToBoardMap.forEach( write2Properties);
            
            function write2Properties( key :int, value :JoinGameBoardRepresentation) :void {
                (value as JoinGameBoardRepresentation).setIntoPropertySpaces(_gameCtrl);
            }
        }
        
        public function getModelFromPropertySpaces() :void
        {
            if( !AppContext.isConnected ) {
                throw new Error("Cannot get model from property spaces when not connected");
            }
            currentSeatingOrder = _gameCtrl.net.get(CURRENT_PLAYERS_STRING) as Array;
            _initialSeatedPlayerIds = _gameCtrl.net.get(INITIAL_PLAYERS_STRING) as Array;
            _singlePlayerGameType = _gameCtrl.net.get(SINGLE_PLAYER_GAME_TYPE) as String;
            
            _playerToBoardMap.clear();
            
            for each (var id :int in currentSeatingOrder) {
                var board :JoinGameBoardRepresentation = new JoinGameBoardRepresentation(id, _gameCtrl);
                _playerToBoardMap.put( id, board);
            }
        }
        
        public function get activePlayers () :int
        {
            var activePlayers :int = 0;
            for each ( var playerid :int in currentSeatingOrder) {
                var board :JoinGameBoardRepresentation = _playerToBoardMap.get(playerid) as JoinGameBoardRepresentation;
                if( board != null && board._state == JoinGameBoardRepresentation.STATE_ACTIVE) {
                    activePlayers++;
                }
            }
            return activePlayers;
        }
        
//        public function get potentialPlayerIds () :Array
//        {
//            if( AppContext.isConnected ) {
//                return (_gameCtrl.net.get( POTENTIAL_PLAYERS) as Array).slice();
//            }
//            else {
//                return _potentialPlayerIds.slice();
//            }
//        }
//        
//        public function set potentialPlayerIds (playerids :Array) :void
//        {
//            if( AppContext.isConnected && _isServerModel) {
//                _gameCtrl.net.set( POTENTIAL_PLAYERS, playerids);
//            }
//            else {
//                _potentialPlayerIds = playerids;
//            }
//        }
        
//        public function get singlePlayerLevel () :int
//        {
//                return _singlePlayerLevel;    
//        }
//        
//        public function set singlePlayerLevel (level :int) :void
//        {
//                _singlePlayerLevel = level;
//        }
        
        
        public function get gameOver () :Boolean
        {
            return _gameOver;
//            if( AppContext.isConnected ) {
//                return _gameCtrl.net.get( SINGLE_PLAYER_LEVEL_STRING) as int;
//            }
//            else {
//                return _singlePlayerLevel;    
//            }
        }
        
        public function set gameOver (gameover :Boolean) :void
        {
            _gameOver = gameover;
//            if( AppContext.isConnected ) {
//                return _gameCtrl.net.get( SINGLE_PLAYER_LEVEL_STRING) as int;
//            }
//            else {
//                return _singlePlayerLevel;    
//            }
        }
        
        
        public static const CURRENT_PLAYERS_STRING: String = "CurrentPlayers";
        public static const INITIAL_PLAYERS_STRING: String = "InitialPlayers";
        public static const DELTA_STRING: String = "Delta";
        public static const SINGLE_PLAYER_LEVEL_STRING: String = "Single Player Level";
        public static const SINGLE_PLAYER_ID: String = "Single Player Id";
        public static const SINGLE_PLAYER_GAME_TYPE: String = "Single Player Game Type";
        
        /** All players that have not permamnently left the game */
        public static const POTENTIAL_PLAYERS :String = "Server:Potential Players";
        
        private var _gameCtrl :GameControl;
        private var _playerToBoardMap :HashMap;
        private var _currentSeatedPlayerIds:Array;
        public var _initialSeatedPlayerIds:Array;
        public var _playerIdsInOrderOfLoss:Array;
        private var _isServerModel :Boolean;
        
        private var _potentialPlayerIds :Array;
        
//        protected var _singlePlayerLevel :int;
        public var _singlePlayerGameType :String;
        
        private var _random: Random = new Random();
        
        private var _dateNow :Date = new Date();  
        
        private var _gameOver :Boolean;
        
        private var _singlePlayerHumanId :int = -1;
        
        public var _tempNewPlayerCookie :UserCookieDataSourcePlayer;
    }
}