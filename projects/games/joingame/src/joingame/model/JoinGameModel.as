package joingame.model
{
    import com.threerings.util.ArrayUtil;
    import com.threerings.util.HashMap;
    import com.threerings.util.Random;
    import com.whirled.game.GameControl;
    import com.whirled.game.NetSubControl;
    import com.whirled.net.MessageReceivedEvent;
    
    import flash.events.EventDispatcher;
    
    import joingame.Constants;
    import joingame.net.JoinGameEvent;
    
    /**
     * The state of the entire game is represented by this class.
     * It contains as many JoinGameBoardRepresentationss as there are players.
     * Each player, and the server, maintain an instance of this 
     * class, synchronised by the server.
     * 
     * 
     * Main listener to the server.  Notifies other, more graphically
     * oriented classes of changes that require animations and other similar changes.
     */
    public class JoinGameModel extends EventDispatcher
    {
        
        public function JoinGameModel(gameControl:GameControl, isClientModel :Boolean = true)
        {
            _gameCtrl = gameControl;
            _playerToBoardMap = new HashMap();
            _currentSeatedPlayerIds = new Array();
            _initialSeatedPlayerIds = new Array();
            _playerIdsInOrderOfLoss = new Array();
            _isClientModel = isClientModel;
            
            
            //Add the null board, for showing destroyed or missing players
            var board :JoinGameBoardRepresentation = new JoinGameBoardRepresentation();
            board.playerID = -1;
            board._rows = Constants.PUZZLE_STARTING_ROWS;
            board._cols = Constants.PUZZLE_STARTING_COLS;
            for(var k:int = 0; k < board._rows*board._cols; k++)
            {
                board._boardPieceColors[k] = 0;
                board._boardPieceTypes[k] = Constants.PIECE_TYPE_DEAD;
            }
            
            _playerToBoardMap.put(-1, board);
            
            
            //Add ourselves to listen to events from the server, if we are a model on a client
            //We listen for when the board (representation on the server) is changed and 
            //update our model and add animations accordingly.
            if( isClientModel)
            {
                _gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            }
        }


        public function get currentSeatingOrder() :Array
        {
            return _currentSeatedPlayerIds.slice();
        }
        
        public function set currentSeatingOrder( playerids :Array) :void
        {
            _currentSeatedPlayerIds = playerids;
        }
        
        public function getModelMemento(): Array
        {
            //Not sure if HashMaps can be transferred via messages
            var boards:Array = new Array();

            boards.push(_currentSeatedPlayerIds);
            boards.push(_initialSeatedPlayerIds);
            boards.push(_playerIdsInOrderOfLoss);
            
            var keys:Array = _playerToBoardMap.keys();
            
            for(var i: int = 0; i < keys.length; i++)
            {
                //playerIDToBoardRepresentationDict[ keys[i] ] = (_playerToBoardMap.get( keys[i] ) as JoinGameBoardRepresentation).getBoardAsCompactRepresentation;
                boards.push(  (_playerToBoardMap.get( keys[i] ) as JoinGameBoardRepresentation).getBoardAsCompactRepresentation()  );
            }
            
//            trace("\n getModelMemento():\n " + boards);
            
            return boards;
        }
        
        public function setModelMemento(representation:Array): void
        {
//            trace("setModelMemento()");
            var keys:Array = _playerToBoardMap.keys();
            var i: int;
            var board:JoinGameBoardRepresentation;
            
            for( i = 0; i < keys.length; i++)
            {
                board = _playerToBoardMap.get( keys[i]  )  as JoinGameBoardRepresentation;
                board.destroy();
            }
            
            _playerToBoardMap.clear();
            
            _currentSeatedPlayerIds = representation[0] as Array;
            _initialSeatedPlayerIds = representation[1] as Array;
            _playerIdsInOrderOfLoss = representation[2] as Array;
            
//            trace("_currentSeatedPlayerIds=" + _currentSeatedPlayerIds);
//            trace("_initialSeatedPlayerIds=" + _initialSeatedPlayerIds);
//            trace("_playerIdsInOrderOfLoss=" + _playerIdsInOrderOfLoss);
            
            for( i = 3; i < representation.length; i++)
            {
                var currentBoardRep:Array = representation[i] as Array;
                var playerID:int = currentBoardRep[0] as int;
                board = new JoinGameBoardRepresentation(_gameCtrl);
                board.setBoardFromCompactRepresentation( currentBoardRep );
                _playerToBoardMap.put( playerID, board);
//                trace("putting board for player=" + playerID);
            }
            
            dispatchEvent(new JoinGameEvent(-1, JoinGameEvent.RECEIVED_BOARDS_FROM_SERVER));
            
        }
        

        private static function getPlayerIDToLeft(myid:int, _playerIDsInOrderOfPlay:Array): int 
        {
            if( _playerIDsInOrderOfPlay== null || _playerIDsInOrderOfPlay.length <= 1)
                return -1;
            
            
            var myIDIndex: int = ArrayUtil.indexOf(_playerIDsInOrderOfPlay, myid );
            if( myIDIndex != -1)
            {
                //If there is only me, I am to my left
//                if(_playerIDsInOrderOfPlay.length == 1)
//                {
//                    return myid;
//                }
                
                if(myIDIndex == 0)
                {
                    //Two player games are not circular
                    if( _playerIDsInOrderOfPlay.length == 2)
                    {
                        return -1;
                    }
                    return _playerIDsInOrderOfPlay[_playerIDsInOrderOfPlay.length - 1];
                }
                else
                {
                    return _playerIDsInOrderOfPlay[ myIDIndex - 1];
                }
            }
            return -1;
        }
        
        private static function getPlayerIDToRight(myid:int, _playerIDsInOrderOfPlay:Array): int 
        {
            if(  _playerIDsInOrderOfPlay == null ||  _playerIDsInOrderOfPlay.length <= 1)
                return -1;
                
            var myIDIndex: int = ArrayUtil.indexOf(_playerIDsInOrderOfPlay, myid);
            if( myIDIndex != -1)
            {
//                if(_playerIDsInOrderOfPlay.length == 1)
//                {
//                    return myid ;
//                }
                
                if(myIDIndex >= _playerIDsInOrderOfPlay.length - 1)
                {
                    //Two player games are not circular
                    if( _playerIDsInOrderOfPlay.length == 2)
                    {
                        return -1;
                    }
                    
                    return _playerIDsInOrderOfPlay[0];
                }
                else
                {
                    return _playerIDsInOrderOfPlay[ myIDIndex + 1];
                }
            }
            return -1;
        }



        /**
         * Returns the id of the player sitting to the left of the
         * player, otherwise -1 if nobody is to the left.
         */
        public function getPlayerIDToLeftOfPlayer(playerid:int): int 
        {
            
            var playerIDsInOrderOfPlay:Array = _currentSeatedPlayerIds; //_gameCtrl.net.get(Server.PLAYER_ORDER) as Array;
            
            return getPlayerIDToLeft( playerid, playerIDsInOrderOfPlay);
            
        }
        
        public function getPlayerIDToRightOfPlayer(playerid:int): int 
        {
            var playerIDsInOrderOfPlay:Array = _currentSeatedPlayerIds;//_gameCtrl.net.get(Server.PLAYER_ORDER) as Array;
            return getPlayerIDToRight( playerid, playerIDsInOrderOfPlay);
            
        }

        /**
         * board: the board that performed the joins.
         * 
         */
        public function doHorizontalJoinEffects(board :JoinGameBoardRepresentation, join :JoinGameJoin, 
             doJoinEffects :Boolean = true, doHealing :Boolean = false): void
        {
//            trace("model doHorizontalJoinEffects() for player=" + board.playerID);
            var i :int;
            var piecex :int;
            var piecey :int;
                /* Do the join effect,
                   then remove pieces, then animate the falling pieces.  */

                if(join != null)
                {
//                    trace("model doing " + join.toString());
                    
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
                    
                    
                    
                    
                    
                    var atackevent :JoinGameEvent;
                
                
                    if(doJoinEffects)
                    {
                        
                        //Attack the other side
                        if(join._widthInPieces > 1 )
                        {
                            var idLeft: int = getPlayerIDToLeftOfPlayer(board.playerID);
                            var idRight: int = getPlayerIDToRightOfPlayer(board.playerID);
                            
//                            trace("in attack, idLeft=" + idLeft + ", idRight=" + idRight);
                            
                            var idOfPlayerToAttack: int = join.attackSide == JoinGameJoin.LEFT ? idLeft : idRight;
//                            trace("in attack, idOfPlayerToAttack=" + idOfPlayerToAttack);
                            var sideAttackComesFromForAttacked: int = join.attackSide == JoinGameJoin.LEFT ? JoinGameJoin.RIGHT : JoinGameJoin.LEFT;  
                            
                            var damageFor7Join:int = 2;
                            
                            
                            
                            
                            if( join._widthInPieces == 4)
                            {
    
                                doAttack(_playerToBoardMap.get(idOfPlayerToAttack), sideAttackComesFromForAttacked, join.attackRow, 1);
                                
                                atackevent = new JoinGameEvent( board.playerID, JoinGameEvent.ATTACKING_JOINS);
                                atackevent.joins = [join];
                                atackevent.boardAttacked = idOfPlayerToAttack;
                                atackevent.row = join.attackRow;
                                atackevent.damage = 1;
                                atackevent.side = sideAttackComesFromForAttacked;
                                dispatchEvent( atackevent);
                                
    //                            sendMessageAttackPlayerFromSideAndRowWithValue(idOfPlayerToAttack, sideAttackComesFromForAttacked, join.attackRow, 1);
                            }    
                            else if( join._widthInPieces == 5)
                            {
    //                            sendMessageAttackPlayerFromSideAndRowWithValue(idLeft, JoinGameJoin.RIGHT, join.attackRow, 1);
    //                            sendMessageAttackPlayerFromSideAndRowWithValue(idRight, JoinGameJoin.LEFT, join.attackRow, 1);
                                
                                doAttack(_playerToBoardMap.get(idLeft), Constants.ATTACK_RIGHT, join.attackRow, 1);
                                doAttack(_playerToBoardMap.get(idRight), Constants.ATTACK_LEFT, join.attackRow, 1);
                                
                                atackevent = new JoinGameEvent( board.playerID, JoinGameEvent.ATTACKING_JOINS);
                                atackevent.joins = [join];
                                atackevent.boardAttacked = idLeft;
                                atackevent.row = join.attackRow;
                                atackevent.damage = 1;
                                atackevent.side = Constants.ATTACK_RIGHT;
                                dispatchEvent( atackevent);
                                
                                atackevent = new JoinGameEvent( board.playerID, JoinGameEvent.ATTACKING_JOINS);
                                atackevent.joins = [join];
                                atackevent.boardAttacked = idRight;
                                atackevent.row = join.attackRow;
                                atackevent.damage = 1;
                                atackevent.side = Constants.ATTACK_LEFT;
                                dispatchEvent( atackevent);
                                
                                
                            }    
                            if( join._widthInPieces ==6)
                            {
    //                            sendMessageAttackPlayerFromSideAndRowWithValue(idOfPlayerToAttack, sideAttackComesFromForAttacked, join.attackRow, damageFor7Join);
                                doAttack(_playerToBoardMap.get(idOfPlayerToAttack), sideAttackComesFromForAttacked, join.attackRow, damageFor7Join);
                                
                                atackevent = new JoinGameEvent( board.playerID, JoinGameEvent.ATTACKING_JOINS);
                                atackevent.joins = [join];
                                atackevent.boardAttacked = idOfPlayerToAttack;
                                atackevent.row = join.attackRow;
                                atackevent.damage = damageFor7Join;
                                atackevent.side = sideAttackComesFromForAttacked;
                                dispatchEvent( atackevent);
                                
                                
                            }    
                            if( join._widthInPieces ==7)
                            {
                                
                                if(idLeft == idRight)
                                {
                                    if(_random.nextBoolean())
                                    {
                                        doAttack(_playerToBoardMap.get(idLeft), Constants.ATTACK_RIGHT, join.attackRow, damageFor7Join);
                                        
                                        atackevent = new JoinGameEvent( board.playerID, JoinGameEvent.ATTACKING_JOINS);
                                        atackevent.joins = [join];
                                        atackevent.boardAttacked = idLeft;
                                        atackevent.row = join.attackRow;
                                        atackevent.damage = damageFor7Join;
                                        atackevent.side = Constants.ATTACK_RIGHT;
                                        dispatchEvent( atackevent);
    //                                    sendMessageAttackPlayerFromSideAndRowWithValue(idLeft, JoinGameJoin.RIGHT, join.attackRow, damageFor7Join);
                                    }
                                    else
                                    {
    //                                    sendMessageAttackPlayerFromSideAndRowWithValue(idRight, JoinGameJoin.LEFT, join.attackRow, damageFor7Join);
                                        doAttack(_playerToBoardMap.get(idRight), Constants.ATTACK_RIGHT, join.attackRow, damageFor7Join);
                                        
                                        atackevent = new JoinGameEvent( board.playerID, JoinGameEvent.ATTACKING_JOINS);
                                        atackevent.joins = [join];
                                        atackevent.boardAttacked = idRight;
                                        atackevent.row = join.attackRow;
                                        atackevent.damage = damageFor7Join;
                                        atackevent.side = Constants.ATTACK_RIGHT;
                                        dispatchEvent( atackevent);
                                    }
                                    
                                }
                                else
                                {
    //                                sendMessageAttackPlayerFromSideAndRowWithValue(idLeft, JoinGameJoin.RIGHT, join.attackRow, damageFor7Join);
    //                                sendMessageAttackPlayerFromSideAndRowWithValue(idRight, JoinGameJoin.LEFT, join.attackRow, damageFor7Join);
                                    doAttack(_playerToBoardMap.get(idLeft), Constants.ATTACK_RIGHT, join.attackRow, damageFor7Join);
                                    doAttack(_playerToBoardMap.get(idRight), Constants.ATTACK_LEFT, join.attackRow, damageFor7Join);
                                    
                                    atackevent = new JoinGameEvent( board.playerID, JoinGameEvent.ATTACKING_JOINS);
                                    atackevent.joins = [join];
                                    atackevent.boardAttacked = idLeft;
                                    atackevent.row = join.attackRow;
                                    atackevent.damage = damageFor7Join;
                                    atackevent.side = Constants.ATTACK_RIGHT;
                                    dispatchEvent( atackevent);
                                    
                                    atackevent = new JoinGameEvent( board.playerID, JoinGameEvent.ATTACKING_JOINS);
                                    atackevent.joins = [join];
                                    atackevent.boardAttacked = idRight;
                                    atackevent.row = join.attackRow;
                                    atackevent.damage = damageFor7Join;
                                    atackevent.side = Constants.ATTACK_LEFT;
                                    dispatchEvent( atackevent);
                                    
                                }
                            }    
                        }
                         
                    }              
                } 
            
//            if(Constants.ENCLOSED_UNCONNECTABLE_REGIONS_BECOME_DEAD)
//            {
//                board.markPotentiallyDead();
//            }
            
//            trace("end doHorizontalJoinEffects() for player=" + board.playerID + "\n" + board);
        }
  
  
        public function doVerticalJoinEffects(board :JoinGameBoardRepresentation, join :JoinGameJoin, 
             doJoinEffects :Boolean = true, doHealing :Boolean = false): void
        {
//            trace("model doVerticalJoinEffects() for player=" + board.playerID + "\n" + board);
            var i :int;
            var piecex :int;
            var piecey :int;

            if(join != null)
            {
//                trace("model doing " + join.toString());
//                
//                //If there are "dead" pieces adjacent to the cleared pieces, "heal" them
//                if(doHealing)
//                {
//                    for(i = 0; i < join._piecesWithHealingPower.length; i++)
//                    {
//                        piecex = board.idxToX( join._piecesWithHealingPower[i] as int);
//                        piecey = board.idxToY( join._piecesWithHealingPower[i]);
//                        var adjacentPiecesIndicies:Array = board.getAdjacentPieceIndices(piecex, piecey);
//                        for(var k: int = 0; k < adjacentPiecesIndicies.length; k++)
//                        {
//                            var adjacentPieceIndex: int = adjacentPiecesIndicies[k];
//                            if( board._boardPieceTypes[adjacentPieceIndex] == Constants.PIECE_TYPE_DEAD)
//                            {
//                                board._boardPieceTypes[adjacentPieceIndex] = Constants.PIECE_TYPE_NORMAL;
//                            }
//                        }
//                    }
//                }
                
              
                
                
                
            
            
                if(doJoinEffects)
                {
                    /* Build up */
                    if(join._heighInPiecest > 1 )
                    {
                        
                        board.addNewPieceToColumnAndLeftAndRight(join._buildCol );
                        
                        
                        var event :JoinGameEvent = new JoinGameEvent( board.playerID, JoinGameEvent.VERTICAL_JOIN);
                        event.joins = [join];
                        event.col = join._buildCol;
                        dispatchEvent( event);
                                
                                
//                        if(Constants.ENCLOSED_UNCONNECTABLE_REGIONS_BECOME_DEAD)
//                        {
//                            board.markPotentiallyDead();
//                        }
                        
                    }  
                }              
            } 
            
//            if(Constants.ENCLOSED_UNCONNECTABLE_REGIONS_BECOME_DEAD)
//            {
//                board.markPotentiallyDead();
//            }
//            trace("end model doVerticalJoinEffects() for player=" + board.playerID + "\n" + board);
            
        }      
        public function addNewPieces( board :JoinGameBoardRepresentation ): void
        {
//            trace("model addNewPieces()");
            var addPiecesEvent :JoinGameEvent = new JoinGameEvent(board.playerID,  JoinGameEvent.ADD_NEW_PIECES);
            
            for( var i: int = 0; i < board._boardPieceTypes.length; i++)
            {
                if(board._boardPieceTypes[i] == Constants.PIECE_TYPE_EMPTY)
                {
                    board._boardPieceTypes[i] = Constants.PIECE_TYPE_NORMAL;
                    board._boardPieceColors[i] = board.generateRandomPieceColor();
                    
                    //We record this for syncing the boards between players
                    board._numberOfCallsToRandom++;
                    
//                    addPiecesEvent.newIndices.push( i );
//                    addPiecesEvent.newColors.push( board._boardPieceColors[i] );
                }
            }
            dispatchEvent( addPiecesEvent);
        }
        
        protected function addNewPiecesFromJoinClear( board :JoinGameBoardRepresentation, join :JoinGameJoin ): void
        {
            for( var i: int = 0; i < join._piecesX.length; i++){
                
                var pieceIndex :int = board.coordsToIdx(join._piecesX[i], join._piecesY[i] );
                board._boardPieceTypes[ pieceIndex ] = Constants.PIECE_TYPE_NORMAL;
                board._boardPieceColors[ pieceIndex ] = board.generateRandomPieceColor();
                board._numberOfCallsToRandom++;
            }
        }
        
        public function doPiecesFall(board :JoinGameBoardRepresentation, sendEvent :Boolean = true): void
        {
//            trace("model doPiecesFall");   
            //Start at the bottom row moving up
            //If there are any empty pieces, swap with the next highest fallable block
            
            var fallEvent :JoinGameEvent = new JoinGameEvent(board.playerID, JoinGameEvent.DO_PIECES_FALL);
            
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
//                        board.movePieceToLocationAndShufflePieces(board.coordsToIdx(i, j), board.coordsToIdx(i, yToFall));
                        
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
        
        
        
        public function doAttack(board: JoinGameBoardRepresentation, side:int, rowsFromBottom: int, attackValue: int): void
        {
            if( board == null)
            {
                trace("doAttack( board is null)");
                return;
            }
//            trace("attacking!!!!");
            var targetRow: int = (board._rows-1) - rowsFromBottom;
            while(attackValue > 0)
            {
                trace("attacking row=" + targetRow);
                board.turnPieceDeadAtRowAndSide( targetRow, side);
                attackValue--;
            }
//            var update:JoinGameEvent = new JoinGameEvent(JoinGameEvent.BOARD_UPDATED);
//            update.boardPlayerID = board.playerID;
//            board.dispatchEvent(update);
        }

        public function getBoardForPlayerID( playerID:int): JoinGameBoardRepresentation
        {
            return _playerToBoardMap.get(playerID);
        }

        public function isPlayer(playerID:int):Boolean
        {
            return _playerToBoardMap.containsKey(playerID);
        }
        
        public function addPlayer(playerID:int, board:JoinGameBoardRepresentation):void
        {
            _playerToBoardMap.put(playerID, board);
            
            if( !ArrayUtil.contains( _currentSeatedPlayerIds, playerID))
            {
                _currentSeatedPlayerIds.push(playerID);
            }
            
            if( !ArrayUtil.contains( _initialSeatedPlayerIds, playerID))
            {
                _initialSeatedPlayerIds.push(playerID);
            }
            
            if(board != null && !_isClientModel)
            {
                //We listen for when the board (representation on the server) is changed and add
                //animations accordingly.
//                board.addEventListener(BoardUpdateEvent.BOARD_UPDATED, boardChanged);
//                board.addEventListener(BoardUpdateEvent.ATTACKING_JOINS, boardChanged);

                board.addEventListener(JoinGameEvent.REMOVE_ROW_NOTIFICATION, listenToRemoveBottomRowEvent);
            }
//            else{
//                trace("addPlayer(" + playerID + "), board should not be null");
//            }
        }
        
        /**
        * Only called on the server side, as only server side boards time the bottom row
        * destruction.
        */
        protected function listenToRemoveBottomRowEvent( e :JoinGameEvent ) :void
        {
            trace("listenToRemoveBottomRowEvent for " + e.boardPlayerID);
//            doRemoveBottomRow( getBoardForPlayerID( e.boardPlayerID) );
            if( _isClientModel) {
                trace("!!!!!Should only be called on the server");
            }
            
            if(!_isClientModel) {
                var msg :Object = new Object;
                msg[0] = e.boardPlayerID;
                _gameCtrl.net.sendMessage(Server.BOARD_REMOVE_ROW_CONFIRM, msg);//Broadcast to everybody, including our server
            }
        }
        
        public function doRemoveBottomRow(board: JoinGameBoardRepresentation): void
        {
            
            
            
            var removeRowAndDropPiecesEvent :JoinGameEvent = new JoinGameEvent( board.playerID, JoinGameEvent.REMOVE_BOTTOM_ROW_AND_DROP_PIECES);
            dispatchEvent( removeRowAndDropPiecesEvent );
            
            
            for( var i :int = 0; i < board._cols; i++) {
                board._boardPieceTypes[ board.coordsToIdx( i, board._rows - 1 ) ] = Constants.PIECE_TYPE_EMPTY;
            }
            doPiecesFall(board, false);
            
            
            /* Replace empty pieces with inactive  */
            for( var k :int = 0; k < board._boardPieceTypes.length; k++){
                if( board._boardPieceTypes[k] == Constants.PIECE_TYPE_EMPTY){
                    board._boardPieceTypes[k] = Constants.PIECE_TYPE_INACTIVE;
                }
            }
            board.removeRow(0);
                    
            checkForDeadRegions(board);  
                    
                    
                    
                    
/*             if( board == null)
            {
                trace("doRemoveBottomRow( board is null)");
                return;
            }
//            trace("doRemoveBottomRow() for " + board.playerID + " : \n" + board);
            
            for( var i :int = 0; i < board._cols; i++) {
                board._boardPieceTypes[ board.coordsToIdx( i, board._rows - 1 ) ] = Constants.PIECE_TYPE_EMPTY;
            }
            
            var removeRowPiecesEvent :JoinGameEvent = new JoinGameEvent( board.playerID, JoinGameEvent.REMOVE_ROW_PIECES);
            removeRowPiecesEvent.row = board._rows - 1;
            dispatchEvent( removeRowPiecesEvent );
            
            doPiecesFall(board);
            board.removeRow(0);
//            for( i = 0; i < board._cols; i++) {
//                board._boardPieceTypes[ board.coordsToIdx( i, 0 ) ] = Constants.PIECE_TYPE_INACTIVE;
//            }
            
            var removeRowEvent :JoinGameEvent = new JoinGameEvent( board.playerID, JoinGameEvent.DELETE_ROW_FROM_VIEW);
            removeRowEvent.row = 0;
            dispatchEvent( removeRowEvent );
            
            if( !_isClientModel) {
                if( board.isBottomRowDead()) {
                    trace("doRemoveBottomRow() starting timer again ");
                    board.startBottomRowTimer();
                }
                else {
                    trace("doRemoveBottomRow() stopping timer");
                    board.stopBottomRowTimer();
                }
                
                
            }
            trace("end doRemoveBottomRow() for " + board.playerID + " : \n" + board); */
        }
        
        
        public function removePlayer(playerID:int):void
        {
            if( _playerToBoardMap.containsKey( playerID ) )
            {
                _playerToBoardMap.remove(playerID);
                if( _currentSeatedPlayerIds.indexOf( playerID ) >= 0)
                {
                    _currentSeatedPlayerIds.splice( _currentSeatedPlayerIds.indexOf( playerID ), 1);
                }
                else
                {
                    throw new Error("removePlayer " + playerID + " but no player exists in _currentSeatedPlayerIds");
                }
                
                _playerIdsInOrderOfLoss.push(playerID);
            }
            else
            {
                trace("removePlayer(" + playerID + ") but no such player exists");
            }
            trace("player " + playerID + " removed from model");
            trace("end of removePlayer, _currentSeatedPlayerIds="+_currentSeatedPlayerIds);
            
            var event :JoinGameEvent = new JoinGameEvent(playerID, JoinGameEvent.PLAYER_KNOCKED_OUT);
            dispatchEvent(event);
            
            if( _currentSeatedPlayerIds.length <= 1)
            {
                
                
                
                event = new JoinGameEvent(-1, JoinGameEvent.GAME_OVER);
                dispatchEvent(event);
            }
        }
        
        
        
//        /** Respond to messages from other clients. */
//        protected function boardChanged (event :BoardUpdateEvent) :void
//        {
//            
//            
//            if (event.type == BoardUpdateEvent.ATTACKING_JOINS)
//            {
//                
//                // Convert the event value back to an object, and pop the info
//                var id :int = event.boardPlayerID;
//                
//                var board:JoinGameBoardRepresentation = _playerToBoardMap.get(id);
//                
////                LOG("Attack to rowsFromBottom  " + rowsFromBottom);
//                if(board != null)
//                {
//                    
//                    
//                    
//                    
//                    
//                    
//                    var side:int = event.value[1] as int;
//                    var rowsFromBottom:int = event.value[2] as int;
//                    var value:int = event.value[3] as int;
//                
//                    var targetRow: int = (getMyBoard().getRows()-1) - rowsFromBottom;
//                    
////                    LOG("\nmyid="+_gameCtrl.game.getMyId()+", Attack to row  " + targetRow + " from " + id + ", at side=" + side);
//                    
//                    
//                    
////                    LOG("\nplayerids=  " + _playerIDsInOrderOfPlay);
//                    
//                    while(value> 0)
//                    {
//                        getMyBoard().turnPieceDeadAtRowAndSide( targetRow, side);
//                        value--;
//                    }
//                    
//                    
//                    
////                    if(id == getPlayerIDToLeft() && side ==  JoinGameJoin.LEFT)
////                    {
////                        while(value> 0)
////                        {
////                            _board.turnPieceDeadAtRowAndSide( targetRow, JoinGameJoin.LEFT);
////                            value--;
////                        }
////                    }
////                    else if(id == getPlayerIDToRight() && side ==  JoinGameJoin.RIGHT)
////                    {
////                        while(value> 0)
////                        {
////                            _board.turnPieceDeadAtRowAndSide( targetRow, JoinGameJoin.RIGHT);
////                            value--;
////                        }
////                    }
//                    
//                    if(Constants.ENCLOSED_UNCONNECTABLE_REGIONS_BECOME_DEAD)
//                    {
//                        getMyBoard().convertDeadToDead();
//                    }
//                    if(! checkForBoardDeath())
//                        getMyBoard().sendServerCurrentState();
//                    
//                     
//                    
////                    if(targetRow >= 0 && targetRow < _board.getRows())
////                    {
////                    
////                        if(_board._shieldsLeft >= 1)
////                        {
////                            _board._shieldsLeft--;
////                            _board._shieldsRight--;
////                            _board.drawShields();
////                        }
////                        else
////                        {
////                            
////                            _board.turnPieceDeadAtRowAndSide( targetRow, true);
////                            
////                            if(_board.getRows() > 6)
////                            {
//////                                _board.removeRow(targetRow);
//////                                _board.setBoardFromCompactRepresentation(_board.getBoardAsCompactRepresentation());
//////                                _boardRIGHT.drawPartialNewRow();
////                            }
////                        }
////                        _board.sendServerCurrentState();
////                    }
////                    else
////                        LOG("Attack to row  " + targetRow + " but row doesn't exist");
//                }
//            }
//            
//            
//            /*If there are joins resulting in attacks, make the pieces in the other boards dead*/
//            updatePieceDimensionsAndCoordinatesAndAddPiecesIfNecessary();            
//        }
        
        override public function toString():String
        {
            return "Players=" + _playerToBoardMap.keys().toString() + "\n Boards=" + _playerToBoardMap.values().toString();
        }
        
        /**
        * Confirms a delta (board change) that is sent from server, or called from the server itself.
        */
        public function deltaConfirm(boardId :int, fromIndex :int, toIndex :int) :void
        {
//            trace("model deltaConfirm()");
            var board: JoinGameBoardRepresentation = _playerToBoardMap.get(boardId) as JoinGameBoardRepresentation;;    
                
            if( board == null)
            {
                trace("delta confirm for a null board with id=" + boardId);
                return;
            }    
               
            
            /* Move the pieces, and notify listeners to also change piece indices */
            board.movePieceToLocationAndShufflePieces( fromIndex, toIndex);
            
            var deltaEvent :JoinGameEvent = new JoinGameEvent( board.playerID, JoinGameEvent.DELTA_CONFIRM);
            deltaEvent.deltaPiece1X = board.idxToX(fromIndex);
            deltaEvent.deltaPiece1Y = board.idxToY(fromIndex);
            deltaEvent.deltaPiece2X = board.idxToX(toIndex);
            deltaEvent.deltaPiece2Y = board.idxToY(toIndex);
            dispatchEvent(deltaEvent);
            
            
            //Ok up till here, then sync problems
            
            
            
            var wasJoins :Boolean = false;    
            var joins:Array = board.checkForJoins();
            var numberOfTimesJoinsSearched :int = 1;
            while(joins.length > 0)
            {
                trace("doing joins");
                /**
                 *  Send the join effect animation.  This is not send in the doJoinEffect method
                 *  because the multiple joins should be animated simultaneously.
                 */
//                var joinAnimationEvent :JoinGameEvent = new JoinGameEvent(board.playerID, JoinGameEvent.DO_JOIN_VISUALIZATIONS);
//                joinAnimationEvent.joins = joins;
//                dispatchEvent( joinAnimationEvent );
                
                
//                
//                /* All joined pieces are now null. */
                wasJoins = true;
                for(var i :int = 0; i < joins.length; i++)
                {
                    var join :JoinGameJoin = joins[i] as JoinGameJoin;
                    /* Remove pieces in the join */
                    for(var piecei :int = 0; piecei < join._piecesX.length; piecei++)
                    {
                        board._boardPieceTypes[ board.coordsToIdx( join._piecesX[piecei], join._piecesY[piecei]) ]  = Constants.PIECE_TYPE_EMPTY;
//                        trace("setting empty piece=" + join._piecesX[piecei] + ", " + join._piecesY[piecei] );
                    }
                    
                    if(join._widthInPieces > 1){
                        doHorizontalJoinEffects(board, join, true, Constants.HEALING_ALLOWED);
                    }
                }
                /* Send the event for vertical joins */
                
                for(var j :int = 0; j < joins.length; j++)
                {
                    /* Adds the extra pieces, and rows if neccesary, and sends the animation event */
                    var vjoin :JoinGameJoin = joins[j] as JoinGameJoin;
                    if(vjoin._heighInPiecest > 1){
                        doVerticalJoinEffects(board, vjoin, true, Constants.HEALING_ALLOWED);
                    }
                }
//                
                doPiecesFall(board);
                addNewPieces(board);
                
                
//                while( board._rows > Constants.MAXIMUM_ROWS) {
//                    
////                    trace("sending JoinGameEvent.REMOVE_BOTTOM_ROW_AND_DROP_PIECES"); 
//                    var removeRowAndDropPiecesEvent :JoinGameEvent = new JoinGameEvent( board.playerID, JoinGameEvent.REMOVE_BOTTOM_ROW_AND_DROP_PIECES);
//                    dispatchEvent( removeRowAndDropPiecesEvent );
//                    
//                    
//                    for( i = 0; i < board._cols; i++) {
//                        board._boardPieceTypes[ board.coordsToIdx( i, board._rows - 1 ) ] = Constants.PIECE_TYPE_EMPTY;
//                    }
//                    
//                    
//                    
//                    doPiecesFall(board, false);
//                    
//                    
//                    /* Replace empty pieces with inactive  */
//                    for( var k :int = 0; k < board._boardPieceTypes.length; k++){
//                        if( board._boardPieceTypes[k] == Constants.PIECE_TYPE_EMPTY){
//                            board._boardPieceTypes[k] = Constants.PIECE_TYPE_INACTIVE;
//                        }
//                    }
//                    board.removeRow(0);
////                    trace("end doRemoveBottomRow() for " + board.playerID + " : \n" + board);
//                }
                checkForDeadRegions(board);
                joins = board.checkForJoins();
                
                numberOfTimesJoinsSearched++;
                
//                if( numberOfTimesJoinsSearched > 20)
//                {
//                    trace("Very low likelihood that 20 consecutive joins found, it's a bug, so quitting");
//                    var players :Array = _currentSeatedPlayerIds.slice();
//                    for( k = 0; k < players.length; k++)
//                    {
//                        removePlayer( players[k] );
//                    }
//                    break;
//                    
//                }
//                
            }
            
            
            
            if(wasJoins)
            {
                checkForDeadRegions(board);
                
                
            }
            
            
            
    
            if( !board.isAlive())
            {
                removePlayer(board.playerID);
            }
        }
        
        
        
        protected function checkForDeadRegions( board :JoinGameBoardRepresentation ) :void
        {
            var id :int;
            var adjacentBoard :JoinGameBoardRepresentation;
                
            if(Constants.ENCLOSED_UNCONNECTABLE_REGIONS_BECOME_DEAD){
                convertDeadToDead(board);
                var event :JoinGameEvent = new JoinGameEvent(board.playerID, JoinGameEvent.DO_DEAD_PIECES);
                dispatchEvent( event );
                
                if(!_isClientModel){ /*If running on the server, adjust/start the bottom row timer if necessary */
                    if(board.isBottomRowDead()){
                        board.startBottomRowTimer();/* There should be a timer running, if so leave it, if not start one */
                    }
                    else{
                        board.stopBottomRowTimer();
                    }
                }
            
                id = getPlayerIDToLeftOfPlayer(board.playerID);
                if(id >= 0) {
                    adjacentBoard = getBoardForPlayerID(id);
                    convertDeadToDead(adjacentBoard);
                    event = new JoinGameEvent(id, JoinGameEvent.DO_DEAD_PIECES);
                    dispatchEvent( event );
                    
                    if(!_isClientModel){ /*If running on the server, adjust/start the bottom row timer if necessary */
                        if(adjacentBoard.isBottomRowDead()){
                            adjacentBoard.startBottomRowTimer();/* There should be a timer running, if so leave it, if not start one */
                        }
                        else{
                            adjacentBoard.stopBottomRowTimer();
                        }
                    }
                }
                id = getPlayerIDToRightOfPlayer(board.playerID);
                if(id >= 0)
                {
                    adjacentBoard = getBoardForPlayerID(id);
                    convertDeadToDead(adjacentBoard);
                    event = new JoinGameEvent(id, JoinGameEvent.DO_DEAD_PIECES);
                    dispatchEvent( event );
                    
                    if(!_isClientModel){ /*If running on the server, adjust/start the bottom row timer if necessary */
                        if(adjacentBoard.isBottomRowDead()){
                            adjacentBoard.startBottomRowTimer();/* There should be a timer running, if so leave it, if not start one */
                        }
                        else{
                            adjacentBoard.stopBottomRowTimer();
                        }
                    }
                }
            }
            
            id = getPlayerIDToLeftOfPlayer(board.playerID);
            if(id >= 0)
            {
                if( !getBoardForPlayerID(id).isAlive())
                {
                    removePlayer(id);
                }
                
            }
            
            id = getPlayerIDToRightOfPlayer(board.playerID);
            if(id >= 0)
            {
                if( !getBoardForPlayerID(id).isAlive())
                {
                    removePlayer(id);
                }
                
            }
        }

        
        /**
         * Converts the pieces that cannot possiblly form joins into 
         * "dead" pieces, marking them as unavailable.
         * 
         * Also starts the timer for the bottom row, if present on the server.
         * 
         */
        private function convertDeadToDead(board :JoinGameBoardRepresentation, serverside :Boolean = false) :Boolean
        {
            var k: int;
            var i: int;
            var isDeadPiecesFound :Boolean = false;
            
//            var isBottomRowAlreadyDead :Boolean = true;
//            for(i = 0; i < board._cols; i++){
//                var pieceType :int = board._boardPieceTypes[ board.coordsToIdx(i, board._rows - 1) ] as int;
//                if( pieceType == Constants.PIECE_TYPE_NORMAL){
//                    isBottomRowAlreadyDead = false;
//                    break;
//                }
//            }
            
            
//            trace("convertDeadToDead for board " + board.playerID + ":\n" + board);
            
            for(k = 0; k < board._boardPieceTypes.length; k++)
            {
                if(board._boardPieceTypes[k] == Constants.PIECE_TYPE_POTENTIALLY_DEAD)
                {
                    board._boardPieceTypes[k] = Constants.PIECE_TYPE_NORMAL;
                }
            }
//            trace("convertDeadToDead for board after reset " + board.playerID + ":\n" + board);
            var contiguousRegions:Array = board.getContiguousRegions();
            
//            trace("contiguousRegions.length=" + contiguousRegions.length);
            
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
//                    trace("converting to dead=" + arrayOfContiguousPieces);
                    for(i = 0; i < arrayOfContiguousPieces.length; i++)
                    {
                        isDeadPiecesFound = true;
                        board._boardPieceTypes[ int(arrayOfContiguousPieces[i]) ] = Constants.PIECE_TYPE_POTENTIALLY_DEAD;
                    }
                }
                else
                {
//                    trace("Not converting to dead");
                }
            }
//            trace("finished convertDeadToDead for board " + board.playerID + ":\n" + board);

            

            
            return isDeadPiecesFound;
        }
        
        
        
        
        /** Respond to messages from other clients. */
        public function messageReceived (event :MessageReceivedEvent) :void
        {
            
            var id :int;
            var board: JoinGameBoardRepresentation;
            
            //If the update refers to us, update, and notify the display
            if (event.name == Server.BOARD_DELTA_CONFIRM)
            {
                
//                if(_playerID >= 0)
//                {
//                    trace("Player: " + AppContext.gameCtrl.game.getMyId() + ", " + Server.BOARD_DELTA_CONFIRM+ "[ " + event.value[0]+ " " + event.value[1]+ " " + event.value[2] + " ]");
//                }
                id = int(event.value[0]);
                board = _playerToBoardMap.get(id) as JoinGameBoardRepresentation;
                var fromIndex :int = int(event.value[1]);
                var toIndex :int = int(event.value[2]);
                
                
//                trace("Player: " + _gameCtrl.game.getMyId() + ", " + Server.BOARD_DELTA_CONFIRM+ "[ board=" + event.value[0]+ " " + event.value[1]+ " " + event.value[2] + " ]");
                
                
                if(board != null)
                {
                    deltaConfirm(id, fromIndex, toIndex);
                }
                else
                {
                    trace("BOARD_DELTA_CONFIRM sent but no board with id="+id);
                }
            }
            else
            if (event.name == Server.BOARD_UPDATE_CONFIRM)
            {
                
                id = int(event.value[0]);
//                var boardID :int = int(event.value[1]);
                
                board = _playerToBoardMap.get(id) as JoinGameBoardRepresentation;
                var boardRep:Array = event.value[1] as Array;
                board.setBoardFromCompactRepresentation(boardRep);
//                dispatchEvent(new JoinGameEvent(id, JoinGameEvent.BOARD_UPDATED));
            }
            else if (event.name == Server.PLAYER_KNOCKED_OUT)
            {
                
                id = int(event.value[0]);
                if(id >= 0)
                {
                    removePlayer(id);
                }
            }
            else if (event.name == Server.BOARD_REMOVE_ROW_CONFIRM)
            {
                
                id = int(event.value[0]);
                if(id >= 0)
                {
                    doRemoveBottomRow( getBoardForPlayerID( id) );
                }
            }
            
        }
        
//        public function act
        
//        /**
//         * 
//         * The game is played in a circle.  As players are eliminated.
//         */         
//        public function get playerIDsInOrderOfPlay():Array
//        {
//            return _gameCtrl.net.get(Server.PLAYER_ORDER) as Array;
//        }
        
        private var _gameCtrl :GameControl;
        private var _playerToBoardMap :HashMap;
        private var _currentSeatedPlayerIds:Array;
        public var _initialSeatedPlayerIds:Array;
        public var _playerIdsInOrderOfLoss:Array;
        private var _isClientModel :Boolean;
        
        private var _random: Random = new Random();
    }
}