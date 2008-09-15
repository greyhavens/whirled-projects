package 
{
    import com.threerings.util.ArrayUtil;
    import com.threerings.util.Random;
    import com.whirled.ServerObject;
    import com.whirled.game.GameControl;
    import com.whirled.game.GameSubControl;
    import com.whirled.game.OccupantChangedEvent;
    import com.whirled.net.MessageReceivedEvent;
    
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    import joingame.Constants;
    import joingame.SeatingManager;
    import joingame.model.*;
    import joingame.net.JoinGameEvent;
    
    
    public class Server extends ServerObject
    {
        //IF we give a non-null GameControl, we assume that the server side is not running properly 
        public function Server(gameControl: GameControl = null)
        {
            _firstGame = true;
//            _playerIDsInOrderOfPlay = new Array();
            _currentActivePlayers = new Array();
            _playersReady = new Array();
            _playersReceivedStartGameState = new Array();
//            _currentActivePlayers = new Array();
//            _currentActivePlayers = new Array();
            _playersThatWantToPlayAgain = new Array();
            
            _gameRestartTimer = new Timer(1000, 0);
            _gameRestartTimer.addEventListener(TimerEvent.TIMER, gameTimer);
            _totalTimeElapsedSinceNewGameTimerStarted = 0;
            
            trace("Hello world! I'm your Joingame server!");
            
            _gameCtrl = new GameControl(this);
            
            //We only add the listeners if we are running on the server, 
            //not just used by another class as a stop-gap for the lack of server side code.
            // send incoming message notifications to the messageReceived() method
            //We only add the listeners if we are running on the server, 
            _gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
                
            // send incoming message notifications to the messageReceived() method
            _gameCtrl.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT, occupantLeft);
            _gameModel = new JoinGameModel(_gameCtrl, false);
            _gameModel.addEventListener(JoinGameEvent.GAME_OVER, gameOver);
            _gameModel.addEventListener(JoinGameEvent.PLAYER_KNOCKED_OUT, listenForPlayerEliminated);
//            _gameModel.addEventListener(JoinGameEvent.REMOVE_ROW_NOTIFICATION, gameOver);
            SeatingManager.init(_gameCtrl);
            
                    
        }

        protected function gameTimer(  e :TimerEvent) :void
        {
            _totalTimeElapsedSinceNewGameTimerStarted++;
            trace("seconds elapsed for new game start " + _totalTimeElapsedSinceNewGameTimerStarted 
                + " / " + Constants.GAME_RESTART_TIME);
            if(_totalTimeElapsedSinceNewGameTimerStarted >= Constants.GAME_RESTART_TIME) {
                restartGameTimerComplete(e);
            }
        }

        protected function restartGameTimerComplete( e :TimerEvent) :void
        {
            trace("restartGameTimerComplete(), _playersThatWantToPlayAgain=" + _playersThatWantToPlayAgain);
            _totalTimeElapsedSinceNewGameTimerStarted = 0;
            _gameRestartTimer.reset();
            
            if(_playersThatWantToPlayAgain.length > 1) {
                _currentActivePlayers = _playersThatWantToPlayAgain;
                createNewModel();
            }
        }
    
        protected function gameOver( e: JoinGameEvent) :void
        {
            trace("Server side: game over, assigning scores");
            /* We assign scores according to an exponential scale, so the winner gets a big pot,
            while those knocked out early get very little. The winner gets half the pot, followed
            by 2nd place getting a quarter, 3rd gets 1/8 and so on.*/
            
            var totalScore :int = 1000*_gameModel._initialSeatedPlayerIds.length;
            var playerIds :Array = new Array();
            var scores :Array = new Array();
            var playerIdsInOrderOfLoss :Array = _gameModel._playerIdsInOrderOfLoss.slice();
            
            
            playerIds.push( _gameModel.currentSeatingOrder[0]);
            var denominator :int = 2;
            scores.push( int(  totalScore*(1.0/denominator)  ));
            denominator *= 2;
            while( playerIdsInOrderOfLoss.length > 0) {
                playerIds.push( playerIdsInOrderOfLoss.pop() );
                scores.push( int(  totalScore*(1.0/denominator)  ));
                denominator *= 2;
            }
            
            
            
            trace("Awarding scores:\nPlayer\t|\tScore");
            for(var i :int = 0; i < playerIds.length; i++) {
                trace(playerIds[i] + "\t|\t" + scores[i] );
            }
            
            var msg :Object = new Object;
            msg[0] = playerIds;
            msg[1] = scores;
            _gameCtrl.net.sendMessage( GAME_OVER, msg);
            _gameCtrl.game.endGameWithScores(playerIds, scores, GameSubControl.TO_EACH_THEIR_OWN);

            _gameRestartTimer.start();
            
        }




        public function messageReceived (event :MessageReceivedEvent) :void
        {
//            trace("Server messageReceived="+event);
            var msg :Object;
            var k: int;
            var id :int;
            var clientid :int;

            /* If all players have registered that they are ready, send the game state to all.*/   
            if (event.name == Server.REGISTER_PLAYER)
            {
                trace(REGISTER_PLAYER + " for player " + event.senderId);
                if(!ArrayUtil.contains( _currentActivePlayers, event.senderId))
                {
                    _currentActivePlayers.push( event.senderId );
                    
                    if( _currentActivePlayers.length >= SeatingManager.numExpectedPlayers)
                    {
                        /* We send all the random number generator seeds to the players.
                           This is to ease the sync requirements.  That way, new pieces are still 
                           random, but identical on server and client. */
                        var playerids:Array = _gameCtrl.game.seating.getPlayerIds();
                        
                        _currentActivePlayers = playerids;
                        createNewModel();
                        _gameCtrl.net.sendMessage( REPLAY_CONFIRM, {});
                    }
                }
                
            }
            else if (event.name == Server.PLAYER_READY)
            {
                trace("Server PLAYER_READY for player " + event.senderId);
                if(!ArrayUtil.contains( _playersReady, event.senderId))
                {
                    _playersReady.push( event.senderId );
                    
                    if( _playersReady.length >= _currentActivePlayers.length )
                    {
                        msg = new Object;
                        msg[0] = _gameModel.getModelMemento();
                        _gameCtrl.net.sendMessage(ALL_PLAYERS_READY, msg );
                    }
                }
                trace("_playersReady=" + _playersReady);
            }
            if (event.name == Server.PLAYER_RECEIVED_START_GAME_STATE)
            {
                trace("Server PLAYER_RECEIVED_START_GAME_STATE for player " + event.senderId);
                
                
                if(!ArrayUtil.contains( _playersReceivedStartGameState, event.senderId) && ArrayUtil.contains( _currentActivePlayers, event.senderId) )
                {
                    _playersReceivedStartGameState.push( event.senderId );
                    
                    if( _playersReceivedStartGameState.length >= _currentActivePlayers.length)//SeatingManager.numExpectedPlayers
                    {
                        trace("Server sending to all platers: " + START_PLAY);
                        _gameCtrl.net.sendMessage( START_PLAY, {});
                    }
                }
            }
            else if (event.name == Server.BOARD_DELTA_REQUEST)
            {
                //Only the owner can change her own board.
                if(event.senderId == event.value[0])
                {
//                    trace(Server.BOARD_DELTA_REQUEST+ "[ " + event.value[0]+ " " + event.value[1]+ " " + event.value[2] + " " + event.value[3] + " ]");
                    moveRequest(int(event.value[0]), int(event.value[2]), int(event.value[3]), int(event.value[4]), int(event.value[5]));
                }
            }
            else 
            if (event.name == Server.BOARD_UPDATE_REQUEST)
            {
                
                clientid = int(event.value[0]);
                var boardplayerid:int =  int(event.value[1]);
                
                if(boardplayerid >= 0 && isPlayerActive(boardplayerid))
                {
                
//                    var alsoUpdatePlayerIDS:Boolean = false;
                    //If there is no board we have to generate one.
                    var board:JoinGameBoardRepresentation;
                    if(!_gameModel.isPlayer(boardplayerid))//This also means we haven't registered the player
                    {
                        board = createNewRandomBoard(boardplayerid);
                        _gameModel.addPlayer(boardplayerid, board);
                    }
                    board = _gameModel.getBoardForPlayerID(boardplayerid);
                    
                    
    //                trace("!!!Server: Sending update, clientid="+clientid+", boardplayerid="+boardplayerid+", board.getBoardAsCompactRepresentation()="+board.getBoardAsCompactRepresentation());
                    msg = new Object;
                    msg[0] = clientid;
                    msg[1] = boardplayerid;
                    msg[2] = board.getBoardAsCompactRepresentation();
                    
                    _gameCtrl.net.sendMessage(Server.BOARD_UPDATE_CONFIRM, msg, clientid );
                    
                    
                }
                else//If the player ID doesn't exist, send a dead board.
                {
                    board = new JoinGameBoardRepresentation();
                    board._rows = Constants.PUZZLE_STARTING_ROWS;
                    board._cols = Constants.PUZZLE_STARTING_COLS;
//                    trace("creating a board, here are the colors:");
                    for(k = 0; k < board._rows*board._cols; k++)
                    {
                        board._boardPieceColors[k] = 0;
                        board._boardPieceTypes[k] = Constants.PIECE_TYPE_DEAD;
                    }
                        
                    msg = new Object;
                    msg[0] = clientid;
                    msg[1] = boardplayerid;
                    msg[2] = board.getBoardAsCompactRepresentation();
                    _gameCtrl.net.sendMessage(Server.BOARD_UPDATE_CONFIRM, msg, clientid );
                }
            }
            else 
            if (event.name == MODEL_REQUEST)
            {
                trace(Server.MODEL_REQUEST + " for player " + event.senderId);
                trace("Seating ids=" + _gameCtrl.game.seating.getPlayerIds());
                msg = new Object;
                msg[0] = _gameModel.getModelMemento();
                trace("sending " + MODEL_CONFIRM + " to player " + event.senderId);
                _gameCtrl.net.sendMessage(MODEL_CONFIRM, msg);//, event.senderId );
            }
            else if (event.name == Server.BOARD_REMOVE_ROW_CONFIRM)
            {
                
                id = int(event.value[0]);
                if(id >= 0)
                {
                    _gameModel.doRemoveBottomRow( _gameModel.getBoardForPlayerID( id) );
                }
            }
            else if (event.name == Server.REPLAY_REQUEST)
            {
                trace(Server.REPLAY_REQUEST);
                id = event.senderId;
//                trace("id=" + id);
                if(id >= 0 && !ArrayUtil.contains(_playersThatWantToPlayAgain, id) && ArrayUtil.contains(_currentActivePlayers, id))
                {
                    _playersThatWantToPlayAgain.push( id);
                    trace("_playersThatWantToPlayAgain=" + _playersThatWantToPlayAgain);
                    if( _playersThatWantToPlayAgain.length == _currentActivePlayers.length && _currentActivePlayers.length > 1 ) {
                        _gameRestartTimer.reset();
//                        _playersThatWantToPlayAgain = new Array();//Use this to track the players checking in
                        createNewModel();
                        
                    }
                }
            }
        }


        protected function createNewModel() :void
        {
            trace("Server.createNewModel()");
            var k :int;
            
            _playersThatWantToPlayAgain = new Array();
            _playersReceivedStartGameState = new Array();
            _currentActivePlayers = randomizeArray(_currentActivePlayers);
            _playersReady = new Array();

            _gameModel.removeAllPlayers();
            
            for(k = 0; k < _currentActivePlayers.length; k++)
            {
                _gameModel.addPlayer(_currentActivePlayers[k], createNewRandomBoard(_currentActivePlayers[k]));
            }
            _gameModel._initialSeatedPlayerIds = _currentActivePlayers.slice();
            _gameModel.currentSeatingOrder = _currentActivePlayers.slice();
            
            
            
            
            var msg :Object = new Object;
            msg[0] = _currentActivePlayers;
            _gameCtrl.net.sendMessage(REPLAY_CONFIRM, msg);
            
//            trace("Server sending " + ALL_PLAYERS_READY);
//            _gameCtrl.net.sendMessage( ALL_PLAYERS_READY, msg);
            

        }


        protected function randomizeArray( array :Array) :Array {
            var l:Number = array.length-1;
            for (var it :int = 0; it<l; it++) {
                var r :int = Math.round(Math.random()*l)
                var tmp = array[it];
                array[it] = array[r];
                array[r] = tmp;
            }
            return array;
        }
            
        private function createNewRandomBoard(playerid:int): JoinGameBoardRepresentation
        {
//            trace("createNewRandomBoard");
            var board:JoinGameBoardRepresentation = new JoinGameBoardRepresentation();
            board.playerID = playerid;
            board._rows = Constants.PUZZLE_STARTING_ROWS;
            board._cols = Constants.PUZZLE_STARTING_COLS;
            board.randomSeed = int(Math.random()*1000);
            while(board.randomSeed == 0)
            {
                board.randomSeed = int(Math.random()*1000); 
            }
            board._numberOfCallsToRandom = 0;
            for(var k:int = 0; k < board._rows*board._cols; k++)
            {
                board._boardPieceColors[k] = generateRandomPieceColor();
                board._boardPieceTypes[k] = Constants.PIECE_TYPE_NORMAL;
            }
            var joins:Array = board.checkForJoins();
            while(joins.length > 0)
            {
                joins = board.checkForJoins();
                for(var i :int = 0; i < joins.length; i++)
                {
                    var join :JoinGameJoin = joins[i] as JoinGameJoin;
                    /* Remove pieces in the join */
                    for(var piecei :int = 0; piecei < join._piecesX.length; piecei++)
                    {
                        board._boardPieceTypes[ board.coordsToIdx( join._piecesX[piecei], join._piecesY[piecei]) ]  = Constants.PIECE_TYPE_EMPTY;
//                        trace("setting empty piece=" + join._piecesX[piecei] + ", " + join._piecesY[piecei] );
                    }
                    
//                    _gameModel.doHorizontalJoinEffects(board, joins[i], false, false);
                }
                _gameModel.doPiecesFall(board);
                _gameModel.addNewPieces(board);
                joins = board.checkForJoins();
            }
            return board;
        }
        protected static function generateRandomBoardRepresentation(rows:int, cols:int): Array
        {
            var rep: Array = new Array();
            rep[0] = rows;
            rep[1] = cols;
            
            var colors:Array = new Array();
            var types:Array = new Array();
            
            for(var k: int = 0; k < rows*cols; k++)
            {
                colors[k] = generateRandomPieceColor();
                types[k] = Constants.PIECE_TYPE_NORMAL;
            }
            rep[2] = colors;
            rep[3] = types;
            
            return rep;
        }

        //If someone leaves the game, they are eliminated immediately
        protected function occupantLeft( event: OccupantChangedEvent): void
        {
            trace(" occupantLeft="+event);
            if(event.player)//If a player and not a spectator.
            {
                playerLeftOrKnockedOut( event.occupantId );
                
                /* Remove the possibility of this player replaying*/
                if( ArrayUtil.contains( _currentActivePlayers, event.occupantId )) {
                    _currentActivePlayers.splice( _currentActivePlayers.indexOf( event.occupantId ), 1 );
                }
            }
            
            
            
        }    
        

        
        protected static function generateRandomPieceColor(): int
        {
//            return  Constants.PIECE_COLORS_ARRAY[randomNumber(0, Constants.PIECE_COLORS_ARRAY.length - 1)];
            return randomNumber(1, Constants.PIECE_COLORS_ARRAY.length);
        }

        /** 
        * Generate a random number
        * @return Random Number
        * @error throws Error if low or high is not provided
        */  
        private static function randomNumber(low:Number=NaN, high:Number=NaN):Number
        {
            var low:Number = low;
            var high:Number = high;
        
            if(isNaN(low))
            {
                throw new Error("low must be defined");
            }
            if(isNaN(high))
            {
                throw new Error("high must be defined");
            }
        
            return Math.round(Math.random() * (high - low)) + low;
        }
        

        
        
        protected function moveRequest(playerID:int, oldX:int, oldY:int, newX:int, newY:int): void
        {
            var board: JoinGameBoardRepresentation = _gameModel.getBoardForPlayerID(playerID);
            
            var fromIndex:int = board.coordsToIdx( oldX, oldY);
            var toIndex:int = board.coordsToIdx( newX, newY);
            
            var msg :Object = new Object;
            
            if( isLegalMove(playerID, fromIndex, toIndex)){
                _gameModel.deltaConfirm(playerID, fromIndex, toIndex);
                
                //Send updates to players 
                
                msg[0] = playerID;
                msg[1] = fromIndex;
                msg[2] = toIndex;
                
                _gameCtrl.net.sendMessage(BOARD_DELTA_CONFIRM, msg);
            }
            else{
                msg[0] = playerID;
                msg[1] = _gameModel.getBoardForPlayerID(playerID).getBoardAsCompactRepresentation();
                
                _gameCtrl.net.sendMessage(RESET_VIEW_TO_MODEL, msg, playerID);
                trace("Illegal move, sending board reset to player " + playerID);
            }
        }
        
        

        
        
        
        /**
         * This is the main role of the server: checking the validity of moves
         * to prevent cheating.  Only valid moves are returned approved.
         */
        protected function isLegalMove(playerID:int, fromIndex:int, toIndex:int): Boolean
        {
            
            if(!isPlayerActive(playerID))
            {
                return false;
            }
            var board: JoinGameBoardRepresentation = _gameModel.getBoardForPlayerID(playerID);
            if(board == null)
            {
                return false;
            }
            
            //Make sure the pieces are in the same column
            var i:int = board.idxToX(fromIndex);
            if(i < 0 || i != board.idxToX(toIndex) )
            {
                return false;
            }
            
            //And finally check that both pieces are valid, and all the inbetween pieces.
            for(var j:int =  Math.min( board.idxToY( fromIndex), board.idxToY(toIndex)); j <=  Math.max( board.idxToY(fromIndex), board.idxToY(toIndex)); j++)
            {
                if( board._boardPieceTypes[ board.coordsToIdx( i, j)] != Constants.PIECE_TYPE_NORMAL)
                {
                    return false;    
                }
            }
            return true;
        }
        


        protected function isPlayerActive(playerID:int): Boolean
        {
//            var playerIDsInOrderOfPlay:Array = _gameCtrl.net.get(Server.PLAYER_ORDER) as Array;
            if(_currentActivePlayers != null && ArrayUtil.contains(_currentActivePlayers, playerID))
            {
                return true;
            }
            return false;
        }


        /**
         * 
         * If someone leaves the game, they are eliminated immediately
         * 
         */
        protected function occupantChanged( event: OccupantChangedEvent): void
        {
            trace(" occupantChanged="+event);
            if(event.player && ArrayUtil.contains( _gameModel.currentSeatingOrder, event.occupantId))//If a player and not a spectator.
            {
                playerLeftOrKnockedOut( event.occupantId );
            }
            /* Remove the possibility of this player replaying*/
            if( ArrayUtil.contains( _currentActivePlayers, event.occupantId )) {
                _currentActivePlayers.splice( _currentActivePlayers.indexOf( event.occupantId ), 1 );
                trace("removing from _currentActivePlayers, =" + _currentActivePlayers);
            }
        }

        protected function listenForPlayerEliminated( event :JoinGameEvent ) :void 
        {
            if(ArrayUtil.contains( _gameModel.currentSeatingOrder, event.boardPlayerID))//If a player and not a spectator.
            {
                playerLeftOrKnockedOut( event.boardPlayerID );
            }
        }

        protected function playerLeftOrKnockedOut( playerid :int) :void
        {
            trace("playerLeftOrKnockedOut( " + playerid + " )");
            _gameModel.removePlayer(playerid);
            
            
            var msg :Object = new Object;
            msg[0] = playerid;
            
            trace("Server sending message=" + PLAYER_KNOCKED_OUT + " " + playerid + " )");
            _gameCtrl.net.sendMessage(PLAYER_KNOCKED_OUT, msg);
            
            trace("Seating ids=" + _gameCtrl.game.seating.getPlayerIds());
        }





        public var _gameCtrl :GameControl;
        
        //This variable represents the entire game state
        private var _gameModel: JoinGameModel;
        
        
        //The game is played in a circle.  As players are eliminated.        
//        public var _playerIDsInOrderOfPlay: Array;
//        public var _playerToBoardMap :HashMap;
        
        //When all players are here, we proceed to the game.
        public var _currentActivePlayers: Array;
        
        //When all players have received the start game state
        public var _playersReceivedStartGameState: Array;
        
        //Players that quit during the game are not eligible to play again
//        public var _currentActivePlayers: Array;
        public var _playersThatWantToPlayAgain: Array;
        
        public var _playersReady: Array;
        
        private var _random: Random = new Random();
        
        protected var _gameRestartTimer :Timer;
        
        protected var _firstGame :Boolean;
        
        protected var _totalTimeElapsedSinceNewGameTimerStarted :int;
        
        //Server states
//        private var _isGameStateSent: Boolean = false;
        
        public static const BOARD_DELTA_REQUEST :String = "Server:Board Delta Request";
        public static const BOARD_DELTA_CONFIRM :String = "Server:Board Delta Confirm"; 
        public static const BOARD_UPDATE_REQUEST :String = "Server:Board Update Request";
        public static const BOARD_UPDATE_CONFIRM :String = "Server:Board Update Confirm";
        
        public static const MODEL_REQUEST :String = "Server:Model Request";
        public static const MODEL_CONFIRM :String = "Server:Model Confirm";
        
        /**
        * If conflicts occur due to timing of events, tell a board to reset it's view.
        */
        public static const BOARD_REMOVE_ROW_CONFIRM :String = "Server:Board Remove Row Confirm";
        
        public static const RESET_VIEW_TO_MODEL :String = "Server:Reset View To Model";   
        
        public static const ALL_PLAYERS_READY :String = "Server:All Players Ready";
        public static const PLAYER_READY :String = "Server:Player Ready";
        public static const PLAYER_RECEIVED_START_GAME_STATE :String = "Server:Player Recieved Start Game State";
        public static const START_PLAY :String = "Server:Start Play";
        public static const GAME_OVER :String = "Server:Game Over";   
        
        public static const REPLAY_REQUEST :String = "Server:Request Replay";
        public static const REPLAY_CONFIRM :String = "Server:Confirm Replay"; 
        public static const REGISTER_PLAYER :String = "Server:Register Player"; 
//        public static const ALL_PLAYERS_REGISTERED :String = "Server:All Players Registered";  
        
        /** Name of the shared property that will hold everyone's scores. */
//        public static const PLAYER_ORDER :String = "Server:Player Order";
        
        public static const PLAYER_KNOCKED_OUT :String = "Server:Player Knocked Out";
        
        /** The seeds for the random number generators generatoing the random piece colors */
//        public static const RANDOM_NUMBER_SEEDS :String = "Server:Random Seeds";
        
        
        /** Request the entire game state */
        public static const REQUEST_START_STATE :String = "Server:Request Start State";
        
        private var LOG_TO_GAME:Boolean = false;
    }
}