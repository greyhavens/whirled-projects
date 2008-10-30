package 
{
    import com.whirled.ServerObject;
    import com.whirled.game.GameControl;
    
    import joingame.AppContext;
    import joingame.JoingameServer;
    import joingame.net.JoinMessageManager;
    
    
    public class Server extends ServerObject
    {
        public function Server(gameControl: GameControl = null)
        {
            AppContext.gameCtrl = new GameControl(this);
            AppContext.isConnected = AppContext.gameCtrl.isConnected();
            AppContext.messageManager = new JoinMessageManager( AppContext.gameCtrl );
            var gameserver :JoingameServer = new JoingameServer( AppContext.gameCtrl );
            
//            _firstGame = true;
//            _currentActivePlayers = new Array();
//            _playersReady = new Array();
//            _playersReceivedStartGameState = new Array();
//            _playersThatWantToPlayAgain = new Array();
//            
//            _gameRestartTimer = new Timer(1000, 0);
//            _gameRestartTimer.addEventListener(TimerEvent.TIMER, gameTimer);
//            _totalTimeElapsedSinceNewGameTimerStarted = 0;
//            
////            trace("Hello world! I'm your Politik server!");
//            
//            _gameCtrl = new GameControl(this);
//            
//            _gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
//            _gameCtrl.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT, occupantLeft);
//            _gameCtrl.game.addEventListener(OccupantChangedEvent.OCCUPANT_ENTERED, occupantEntered);
//            
//            _gameModel = new JoinGameModel(_gameCtrl, true);
//            _gameModel.addEventListener(JoinGameEvent.GAME_OVER, gameOver);
//            _gameModel.addEventListener(JoinGameEvent.PLAYER_REMOVED, listenForPlayerEliminated);
//            SeatingManager.init(_gameCtrl);
//            
//            _gameCtrl.net.set(JoinGameModel.DELTA_STRING, [0,0,0,0]);
//            
//                    
        }
//
//        protected function gameTimer(  e :TimerEvent) :void
//        {
//            _totalTimeElapsedSinceNewGameTimerStarted++;
//            if(_totalTimeElapsedSinceNewGameTimerStarted >= Constants.GAME_RESTART_TIME) {
//                restartGameTimerComplete(e);
//            }
//        }
//
//        protected function restartGameTimerComplete( e :TimerEvent) :void
//        {
//            _totalTimeElapsedSinceNewGameTimerStarted = 0;
//            _gameRestartTimer.reset();
//            
//            if(_playersThatWantToPlayAgain.length > 1) {
//                _currentActivePlayers = _playersThatWantToPlayAgain;
//                createNewMultiPlayerModel();
//            }
//        }
//    
//        protected function gameOver( e: JoinGameEvent) :void
//        {
//            /* We assign scores according to an exponential scale, so the winner gets a big pot,
//            while those knocked out early get very little. The winner gets half the pot, followed
//            by 2nd place getting a quarter, 3rd gets 1/8 and so on.*/
//            
////            var totalScore :int = 1000*_gameModel._initialSeatedPlayerIds.length;
//            var playerIds :Array = new Array();
//            var scores :Array = new Array();
//            var playerIdsInOrderOfLoss :Array = _gameModel._playerIdsInOrderOfLoss.slice();
//            playerIdsInOrderOfLoss.push( _gameModel.currentSeatingOrder[0]);
//            
//            for( var k :int = 0; k < playerIdsInOrderOfLoss.length; k++) {
//                playerIds.push( playerIdsInOrderOfLoss[k] );
////                scores.push( scoreFunction(k+1) );
//                scores.push( (k+1) * 100 );
//            }
//            
////            function scoreFunction( playersDefeated :int) :int{
////                return playersDefeated*( 1.0 + (playersDefeated*1.1));
////            }
//            
//            /* Changed the score due losers in two player games not getting anything. */
//            
//            
//            
//            
//            trace("Awarding scores:\nPlayer\t|\tScore");
//            for(var i :int = 0; i < playerIds.length; i++) {
//                trace(playerIds[i] + "\t|\t" + scores[i] );
//            }
//            
//            var msg :Object = new Object;
//            msg[0] = playerIds;
//            msg[1] = scores;
//            _gameCtrl.game.endGameWithScores(playerIds, scores, GameSubControl.TO_EACH_THEIR_OWN);
//            _gameCtrl.net.sendMessage( GAME_OVER, msg);
////            _gameRestartTimer.start();
//            
//        }
//
//
//
//
//        public function messageReceived (event :MessageReceivedEvent) :void
//        {
//            var msg :Object;
//            var k: int;
//            var id :int;
//            var clientid :int;
//
//            trace(event.name);
//            /* If all players have registered that they are ready, send the game state to all.*/   
//            if (event.name == Server.REGISTER_PLAYER)
//            {
//                if(!ArrayUtil.contains( _currentActivePlayers, event.senderId))
//                {
//                    _currentActivePlayers.push( event.senderId );
//                    trace("adding "  + event.senderId + " to " + _currentActivePlayers);
//                    if( _currentActivePlayers.length >= SeatingManager.numExpectedPlayers)
//                    {
//                        trace("ok start the game");
//                        /* We send all the random number generator seeds to the players.
//                           This is to ease the sync requirements.  That way, new pieces are still 
//                           random, but identical on server and client. */
//                        var playerids:Array = _gameCtrl.game.seating.getPlayerIds();
//                        
//                        _gameCtrl.net.set( POTENTIAL_PLAYERS, playerids);
//                        _currentActivePlayers = playerids;
//                        
//                        Constants.isMultiplayer = _gameCtrl.game.seating.getPlayerIds().length > 1;
//                        
//                        if(Constants.isMultiplayer) {
//                            createNewMultiPlayerModel();
//                            
//                            msg = new Object;
//                            msg[0] = _currentActivePlayers;
//                            msg[1] = _gameModel.getModelMemento();
//                            trace("sending multiplayer" + REPLAY_CONFIRM);
//                            _gameCtrl.net.sendMessage(REPLAY_CONFIRM, msg);
//                        }
//                        else {
//                            trace("sending singlepplayer" + ALL_PLAYERS_READY);
//                            createNewSinglePlayerModel();
//                            msg = new Object;
//                            msg[0] = _gameModel.getModelMemento();
//                            _gameCtrl.net.sendMessage(ALL_PLAYERS_READY, msg);
//                        }
//    
//                    }
//                }
//                
//            }
//            else if (event.name == Server.PLAYER_READY)
//            {
//                if(!ArrayUtil.contains( _playersReady, event.senderId))
//                {
//                    _playersReady.push( event.senderId );
//                    
//                    if( _playersReady.length >= _currentActivePlayers.length )
//                    {
//                        msg = new Object;
//                        msg[0] = _gameModel.getModelMemento();
//                        _gameCtrl.net.sendMessage(ALL_PLAYERS_READY, msg );
//                    }
//                }
//            }
//            if (event.name == Server.PLAYER_RECEIVED_START_GAME_STATE)
//            {
//                
//                if(!ArrayUtil.contains( _playersReceivedStartGameState, event.senderId) && ArrayUtil.contains( _currentActivePlayers, event.senderId) )
//                {
//                    _playersReceivedStartGameState.push( event.senderId );
//                    
//                    if( _playersReceivedStartGameState.length >= _currentActivePlayers.length)//SeatingManager.numExpectedPlayers
//                    {
//                        _gameCtrl.net.sendMessage( START_PLAY, {});
//                    }
//                }
//            }
//            else if (event.name == Server.BOARD_DELTA_REQUEST)
//            {
//                //Only the owner can change her own board.
//                if(event.senderId == event.value[0])
//                {
//                    deltaRequest(int(event.value[0]), int(event.value[2]), int(event.value[3]), int(event.value[4]), int(event.value[5]));
//                }
//            }
//            else if (event.name == Server.BOARD_BOTTOM_ROW_REMOVAL_REQUEST_FROM_BUTTON)
//            {
//                //Only the owner can change her own board.
//                if(event.senderId == event.value[0])
//                {
//                    msg = new Object();
//                    msg[0] = event.senderId;
//                    if(_gameModel.doRemoveBottomRow( _gameModel.getBoardForPlayerID( event.senderId) ) ) {
//                        _gameCtrl.net.sendMessage(Server.BOARD_REMOVE_ROW_CONFIRM, msg);
//                    }
//                }
//            }
//            else if (event.name == Server.BOARD_REMOVE_ROW_CONFIRM_TO_SERVER)
//            {
//                id = int(event.value[0]);
//                if(id >= 0)
//                {
//                    msg = new Object();
//                    msg[0] = id;
//                    if(_gameModel.doRemoveBottomRow( _gameModel.getBoardForPlayerID( id) ) ) {
//                        _gameCtrl.net.sendMessage(Server.BOARD_REMOVE_ROW_CONFIRM, msg);
//                    }
//                    
//                }
//            }
//            else if (event.name == Server.BOARD_UPDATE_REQUEST)
//            {
//                
//                clientid = int(event.value[0]);
//                var boardplayerid:int =  int(event.value[1]);
//                
//                if(boardplayerid >= 0 && isPlayerActive(boardplayerid))
//                {
//                
//                    //If there is no board we have to generate one.
//                    var board:JoinGameBoardRepresentation;
//                    if(!_gameModel.isPlayer(boardplayerid))//This also means we haven't registered the player
//                    {
//                        board = createNewRandomBoard(boardplayerid);
//                        _gameModel.addPlayer(boardplayerid, board);
//                    }
//                    board = _gameModel.getBoardForPlayerID(boardplayerid);
//                    
//                    msg = new Object;
//                    msg[0] = clientid;
//                    msg[1] = boardplayerid;
//                    msg[2] = board.getBoardAsCompactRepresentation();
//                    
//                    _gameCtrl.net.sendMessage(Server.BOARD_UPDATE_CONFIRM, msg, clientid );
//                }
//                else//If the player ID doesn't exist, send a dead board.
//                {
//                    board = new JoinGameBoardRepresentation();
//                    board._rows = Constants.PUZZLE_STARTING_ROWS;
//                    board._cols = Constants.PUZZLE_STARTING_COLS;
//                    for(k = 0; k < board._rows*board._cols; k++)
//                    {
//                        board._boardPieceColors[k] = 0;
//                        board._boardPieceTypes[k] = Constants.PIECE_TYPE_DEAD;
//                    }
//                        
//                    msg = new Object;
//                    msg[0] = clientid;
//                    msg[1] = boardplayerid;
//                    msg[2] = board.getBoardAsCompactRepresentation();
//                    _gameCtrl.net.sendMessage(Server.BOARD_UPDATE_CONFIRM, msg, clientid );
//                }
//            }
//            else if (event.name == MODEL_REQUEST)
//            {
//                msg = new Object;
//                msg[0] = _gameModel.getModelMemento();
//                _gameCtrl.net.sendMessage(MODEL_CONFIRM, msg);//, event.senderId );
//            }
//            else if (event.name == Server.REPLAY_REQUEST)
//            {
//                id = event.senderId;
//                trace("id=" + id + ", _playersThatWantToPlayAgain=" + _playersThatWantToPlayAgain + ", _currentActivePlayers="+_currentActivePlayers);
//                if(id >= 0 && !ArrayUtil.contains(_playersThatWantToPlayAgain, id) && ArrayUtil.contains(_currentActivePlayers, id))
//                {
//                    _playersThatWantToPlayAgain.push( id);
//                    _totalTimeElapsedSinceNewGameTimerStarted = 0;
////                    _gameRestartTimer.reset();
////                    _gameRestartTimer.start();
//                    if( _playersThatWantToPlayAgain.length == _currentActivePlayers.length && _currentActivePlayers.length > 1 ) {
////                        _gameRestartTimer.reset();
//                        createNewMultiPlayerModel();
//                        
//                        msg = new Object;
//                        msg[0] = _currentActivePlayers;
//                        msg[1] = _gameModel.getModelMemento();
//                        trace("sending multiplayer" + REPLAY_CONFIRM);
//                        _gameCtrl.net.sendMessage(REPLAY_CONFIRM, msg);
//                            
//                    }
//                }
//            }
//        }
//
//
//        protected function createNewMultiPlayerModel() :void
//        {
//            var k :int;
//            
//            _playersThatWantToPlayAgain = new Array();
//            _playersReceivedStartGameState = new Array();
//            _currentActivePlayers = randomizeArray(_currentActivePlayers);
//            _playersReady = new Array();
//            _gameModel.removeAllPlayers();
//            
//            for(k = 0; k < _currentActivePlayers.length; k++)
//            {
//                _gameModel.addPlayer(_currentActivePlayers[k], createNewRandomBoard(_currentActivePlayers[k]));
//            }
//            
//            _gameModel._initialSeatedPlayerIds = _currentActivePlayers.slice();
//            _gameModel.currentSeatingOrder = _currentActivePlayers.slice();
//           _gameModel.setModelIntoPropertySpaces();
//        }
//        
//        protected function createNewSinglePlayerModel() :void
//        {
//            _gameModel.removeAllPlayers();
//            _gameModel.addPlayer(_currentActivePlayers[0], createNewRandomBoard(_currentActivePlayers[0]));
//            /* Add 1 players to left and right.  These will get regenerated as they are killed */
//            /* Use ids below -1 to indicate computer players */
//            for each ( var id :int in [-2, -3]) {
//                _gameModel.addPlayer(id, createNewRandomBoard(id));
//            } 
//            _gameModel._initialSeatedPlayerIds = [_currentActivePlayers[0], -2, -3];
//            _gameModel.currentSeatingOrder = _gameModel._initialSeatedPlayerIds.slice();
//           _gameModel.setModelIntoPropertySpaces();
//            
//        }
//
//
//        protected function randomizeArray( array :Array) :Array {
//            var l:Number = array.length-1;
//            for (var it :int = 0; it<l; it++) {
//                var r :int = Math.round(Math.random()*l)
//                var tmp :int = array[it] as int;
//                array[it] = array[r];
//                array[r] = tmp;
//            }
//            return array;
//        }
//            
//        private function createNewRandomBoard(playerid:int): JoinGameBoardRepresentation
//        {
//            var board:JoinGameBoardRepresentation = new JoinGameBoardRepresentation();
//            board.playerID = playerid;
//            board._rows = Constants.PUZZLE_STARTING_ROWS;
//            board._cols = Constants.PUZZLE_STARTING_COLS;
//            board.randomSeed = int(Math.random()*1000);
//            while(board.randomSeed == 0)
//            {
//                board.randomSeed = int(Math.random()*1000); 
//            }
//            board._numberOfCallsToRandom = 0;
//            for(var k:int = 0; k < board._rows*board._cols; k++)
//            {
//                board._boardPieceColors[k] = generateRandomPieceColor();
//                board._boardPieceTypes[k] = Constants.PIECE_TYPE_NORMAL;
//            }
//            var joins:Array = board.checkForJoins();
//            while(joins.length > 0)
//            {
//                joins = board.checkForJoins();
//                for(var i :int = 0; i < joins.length; i++)
//                {
//                    var join :JoinGameJoin = joins[i] as JoinGameJoin;
//                    /* Remove pieces in the join */
//                    for(var piecei :int = 0; piecei < join._piecesX.length; piecei++)
//                    {
//                        board._boardPieceTypes[ board.coordsToIdx( join._piecesX[piecei], board.convertFromBottomYToFromTopY(join._piecesYFromBottom[piecei])) ]  = Constants.PIECE_TYPE_EMPTY;
//                    }
//                }
//                _gameModel.doPiecesFall(board, 0, 0);
//                _gameModel.addNewPieces(board, 0, 0);
//                joins = board.checkForJoins();
//            }
//            return board;
//        }
//        protected static function generateRandomBoardRepresentation(rows:int, cols:int): Array
//        {
//            var rep: Array = new Array();
//            rep[0] = rows;
//            rep[1] = cols;
//            
//            var colors:Array = new Array();
//            var types:Array = new Array();
//            
//            for(var k: int = 0; k < rows*cols; k++)
//            {
//                colors[k] = generateRandomPieceColor();
//                types[k] = Constants.PIECE_TYPE_NORMAL;
//            }
//            rep[2] = colors;
//            rep[3] = types;
//            
//            return rep;
//        }
//
//        //If someone leaves the game, they are eliminated immediately
//        protected function occupantLeft( event: OccupantChangedEvent): void
//        {
//            if(event.player)//If a player and not a spectator.
//            {
//                playerLeftOrKnockedOut( event.occupantId );
//                
//                var ids :Array = _gameCtrl.net.get( POTENTIAL_PLAYERS) as Array;
//                if( ArrayUtil.contains( ids, event.occupantId ) ) {
//                    ids.splice( ArrayUtil.indexOf( ids, event.occupantId), 1);
//                    _gameCtrl.net.set( POTENTIAL_PLAYERS, ids);
//                }
//            
//                /* Remove the possibility of this player replaying*/
//                if( ArrayUtil.contains( _currentActivePlayers, event.occupantId )) {
//                    _currentActivePlayers.splice( _currentActivePlayers.indexOf( event.occupantId ), 1 );
//                }
//                
//                if( _gameModel.currentSeatingOrder.length <= 0) {
//                    _gameRestartTimer.removeEventListener(TimerEvent.TIMER, gameTimer);
//                }
//            }
//            
//            
//            
//        }    
//        
//        
//        protected function destroy() :void
//        {
//            _gameRestartTimer.removeEventListener(TimerEvent.TIMER, gameTimer);
//        }
//        
//        protected function occupantEntered( event: OccupantChangedEvent): void
//        {
//            if(!event.player)//If a player and not a spectator.
//            {
//                var msg :Object = new Object;
//                msg[0] = _gameModel.getModelMemento();
//                _gameCtrl.net.sendMessage(MODEL_CONFIRM, msg, event.occupantId );
//            }
//            
//        } 
//
//        
//        protected static function generateRandomPieceColor(): int
//        {
//            return randomNumber(1, Constants.PIECE_COLORS_ARRAY.length);
//        }
//
//        /** 
//        * Generate a random number
//        * @return Random Number
//        * @error throws Error if low or high is not provided
//        */  
//        private static function randomNumber(low:Number=NaN, high:Number=NaN):Number
//        {
//            var low:Number = low;
//            var high:Number = high;
//        
//            if(isNaN(low))
//            {
//                throw new Error("low must be defined");
//            }
//            if(isNaN(high))
//            {
//                throw new Error("high must be defined");
//            }
//        
//            return Math.round(Math.random() * (high - low)) + low;
//        }
//        
//
//        
//        
//        protected function deltaRequest(playerID:int, oldX:int, oldY:int, newX:int, newY:int): void
//        {
//            var board: JoinGameBoardRepresentation = _gameModel.getBoardForPlayerID(playerID);
//            
//            var fromIndex:int = board.coordsToIdx( oldX, oldY);
//            var toIndex:int = board.coordsToIdx( newX, newY);
//            
//            var msg :Object = new Object;
//            
//            if( isLegalMove(playerID, fromIndex, toIndex)){
//                _gameModel.deltaConfirm(playerID, fromIndex, toIndex);
//                
//                //Send updates to players 
//                
//                msg[0] = playerID;
//                msg[1] = fromIndex;
//                msg[2] = toIndex;
//                
//                _gameCtrl.net.sendMessage(BOARD_DELTA_CONFIRM, msg);
//            }
//            else{
//                msg[0] = playerID;
//                msg[1] = _gameModel.getBoardForPlayerID(playerID).getBoardAsCompactRepresentation();
//                
//                _gameCtrl.net.sendMessage(RESET_VIEW_TO_MODEL, msg, playerID);
//                trace("Illegal move, sending board reset to player " + playerID);
//            }
//        }
//        
//        
//
//        
//        
//        
//        /**
//         * This is the main role of the server: checking the validity of moves
//         * to prevent cheating.  Only valid moves are returned approved.
//         */
//        protected function isLegalMove(playerID:int, fromIndex:int, toIndex:int): Boolean
//        {
//            
//            if(!isPlayerActive(playerID))
//            {
//                return false;
//            }
//            var board: JoinGameBoardRepresentation = _gameModel.getBoardForPlayerID(playerID);
//            if(board == null)
//            {
//                return false;
//            }
//            
//            //Make sure the pieces are in the same column
//            var i:int = board.idxToX(fromIndex);
//            if(i < 0 || i != board.idxToX(toIndex) )
//            {
//                return false;
//            }
//            
//            //And finally check that both pieces are valid, and all the inbetween pieces.
//            for(var j:int =  Math.min( board.idxToY( fromIndex), board.idxToY(toIndex)); j <=  Math.max( board.idxToY(fromIndex), board.idxToY(toIndex)); j++)
//            {
//                if( board._boardPieceTypes[ board.coordsToIdx( i, j)] != Constants.PIECE_TYPE_NORMAL)
//                {
//                    return false;    
//                }
//            }
//            return true;
//        }
//        
//
//
//        protected function isPlayerActive(playerID:int): Boolean
//        {
////            var playerIDsInOrderOfPlay:Array = _gameCtrl.net.get(Server.PLAYER_ORDER) as Array;
//            if(_currentActivePlayers != null && ArrayUtil.contains(_currentActivePlayers, playerID))
//            {
//                return true;
//            }
//            return false;
//        }
//
//        protected function listenForPlayerEliminated( event :JoinGameEvent ) :void 
//        {
//            if(ArrayUtil.contains( _gameModel.currentSeatingOrder, event.boardPlayerID))//If a player and not a spectator.
//            {
//                playerLeftOrKnockedOut( event.boardPlayerID );
//            }
//        }
//
//        protected function playerLeftOrKnockedOut( playerid :int) :void
//        {
//            
//            if( _gameModel.activePlayers > 1) {
//                
//                
//                
//                var msg :Object = new Object;
//                msg[0] = playerid;
//                
//                var time :int = getTimer();
//                _gameCtrl.net.sendMessage(PLAYER_DESTROYED, msg);
//                
//                var removePlayerOutAfterDelayTimer :Timer = new Timer( Constants.BOARD_DISTRUCTION_TIME * 1000, 1);
//                removePlayerOutAfterDelayTimer.addEventListener(TimerEvent.TIMER, removePlayer);
//                removePlayerOutAfterDelayTimer.start();
//            }
//            
//            function removePlayer( e :TimerEvent ) :void
//            {
//                removePlayerOutAfterDelayTimer.removeEventListener(TimerEvent.TIMER, removePlayer);
//                _gameModel.removePlayer(playerid);
//                _gameCtrl.net.set( JoinGameModel.CURRENT_PLAYERS_STRING, _gameModel.currentSeatingOrder);
//                
//                var msg :Object = new Object;
//                msg[0] = playerid;
//                
//                _gameCtrl.net.sendMessage(PLAYER_REMOVED, msg);
//            }
//        }
//
//
//
//
//
//        public var _gameCtrl :GameControl;
//        
//        //This variable represents the entire game state
//        private var _gameModel: JoinGameModel;
//        
//        //When all players have received the start game state
//        public var _playersReceivedStartGameState: Array;
//        
//        //Players that quit during the game are not eligible to play again
//        public var _currentActivePlayers: Array;
//        public var _playersThatWantToPlayAgain: Array;
//        
//        public var _playersReady: Array;
//        
//        private var _random: Random = new Random();
//        
//        protected var _gameRestartTimer :Timer;
//        
//        protected var _firstGame :Boolean;
//        
//        protected var _totalTimeElapsedSinceNewGameTimerStarted :int;
//        
//        
//        public static const BOARD_DELTA_REQUEST :String = "Server:Board Delta Request";
//        public static const BOARD_DELTA_CONFIRM :String = "Server:Board Delta Confirm"; 
//        public static const BOARD_UPDATE_REQUEST :String = "Server:Board Update Request";
//        public static const BOARD_UPDATE_CONFIRM :String = "Server:Board Update Confirm";
//        
//        public static const BOARD_BOTTOM_ROW_REMOVAL_REQUEST_FROM_BUTTON :String = "Server:Board Bottom Row Removal Request From Button";
//        public static const BOARD_BOTTOM_ROW_REMOVAL_CONFIRM_FROM_BUTTON :String = "Server:Board Bottom Row Removal Confirm From Button";
//        
//        
//        public static const MODEL_REQUEST :String = "Server:Model Request";
//        public static const MODEL_CONFIRM :String = "Server:Model Confirm";
//        
//        /**
//        * If conflicts occur due to timing of events, tell a board to reset it's view.
//        */
//        public static const BOARD_REMOVE_ROW_CONFIRM :String = "Server:Board Remove Row Confirm";
//        public static const BOARD_REMOVE_ROW_CONFIRM_TO_SERVER :String = "Server:Board Remove Row Confirm Server Only";
//        
//        
//        public static const RESET_VIEW_TO_MODEL :String = "Server:Reset View To Model";   
//        
//        public static const ALL_PLAYERS_READY :String = "Server:All Players Ready";
//        public static const PLAYER_READY :String = "Server:Player Ready";
//        public static const PLAYER_RECEIVED_START_GAME_STATE :String = "Server:Player Recieved Start Game State";
//        public static const START_PLAY :String = "Server:Start Play";
//        public static const GAME_OVER :String = "Server:Game Over";   
//        
//        public static const REPLAY_REQUEST :String = "Server:Request Replay";
//        public static const REPLAY_CONFIRM :String = "Server:Confirm Replay"; 
//        public static const REGISTER_PLAYER :String = "Server:Register Player"; 
//        
//        
//        public static const PLAYER_DESTROYED :String = "Server:Player Destroyed";
//        public static const PLAYER_REMOVED :String = "Server:Player Removed";
//        
//        /** Request the entire game state */
//        public static const REQUEST_START_STATE :String = "Server:Request Start State";
//        
//        /** All players that have not permamnently left the game */
//        public static const POTENTIAL_PLAYERS :String = "Server:Potential Players";
//        
//        private var LOG_TO_GAME:Boolean = false;
    }
}