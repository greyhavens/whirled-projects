package 
{
	import com.threerings.util.ArrayUtil;
	import com.threerings.util.Random;
	import com.whirled.ServerObject;
	import com.whirled.game.GameControl;
	import com.whirled.game.OccupantChangedEvent;
	import com.whirled.net.MessageReceivedEvent;
	
	import joingame.Constants;
	import joingame.model.JoinGameBoardRepresentation;
	import joingame.model.JoinGameModel;
	import joingame.SeatingManager;
	import joingame.model.*;
	
	
	public class Server extends ServerObject
	{
		//IF we give a non-null GameControl, we assume that the server side is not running properly 
		public function Server(gameControl: GameControl = null)
		{
			
//			_playerIDsInOrderOfPlay = new Array();
			_playersReady = new Array();
			_playersReceivedStartGameState = new Array();
			
			trace("Hello world! I'm your Joingame server!");
			
			_gameCtrl = new GameControl(this);
	        	
        	
        	//We only add the listeners if we are running on the server, 
        	//not just used by another class as a stop-gap for the lack of server side code.
        	// send incoming message notifications to the messageReceived() method
        	//We only add the listeners if we are running on the server, 
			_gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
				
				// send incoming message notifications to the messageReceived() method
			_gameCtrl.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT, occupantLeft);
//			
//				_gameCtrl.game.addEventListener(OccupantChangedEvent.OCCUPANT_ENTERED, occupantEntered);
//				
//				_playerIDsInOrderOfPlay = _gameCtrl.game.seating.getPlayerIds();
				
				
				
//				trace("\n_playerIDsInOrderOfPlay in constructor="+_gameCtrl.game.seating.getPlayerIds());
//				_gameCtrl.net.set(PLAYER_ORDER, _gameCtrl.game.seating.getPlayerIds());    

			
			_gameModel = new JoinGameModel(_gameCtrl, false);
//			
			SeatingManager.init(_gameCtrl);
			
			    		
		}

		//If the server side code isn't working, this class will be used by
		//one of the clients for the server logic.
		public function initAsClientBasedServer():void
		{
			trace("initAsClientBasedServer");
			//We only add the listeners if we are running on the server, 
			_gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
			
			// send incoming message notifications to the messageReceived() method
			_gameCtrl.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT, occupantLeft);
			
//			trace("\nServer: SeatingManager.numPlayers=" + SeatingManager.numPlayers);
//			for(var seat:int = 0; seat < SeatingManager.numPlayers; seat++)
//			{
//				trace("\n  Server: seat / id = " + seat + " / " + SeatingManager.getPlayerOccupantId(seat));
//			}
			
			
			
//			_playerIDsInOrderOfPlay = _gameCtrl.game.seating.getPlayerIds();
//			_gameCtrl.net.set(PLAYER_ORDER, _gameCtrl.game.seating.getPlayerIds()); 
			
		}



		public function messageReceived (event :MessageReceivedEvent) :void
		{
			trace("Server messageReceived="+event);
			var msg :Object;
			var k: int;

			/* If all players have registered that they are ready, sent the game state to all.*/			
			if (event.name == Server.PLAYER_READY)
			{
				trace("Server PLAYER_READY for player " + event.senderId);
				if(!ArrayUtil.contains( _playersReady, event.senderId))
				{
					_playersReady.push( event.senderId );
					
					if( _playersReady.length >= SeatingManager.numExpectedPlayers)
					{
						
						//We send all the random number generator seeds to the players.
						//This is to ease the sync requirements.  That way, new pieces are still 
						//random, but identical on server and client.
//						var playerID2SeedMap:Object = new Object();
//						
//						var r:Random = new Random();
//						var playerIDs:Array = _gameCtrl.game.seating.getPlayerIds();
//						for(k = 0; k < playerIDs.length; k++)
//						{
//							playerID2SeedMap[ playerIDs[k] ] = r.nextInt();
//						}
//						_gameCtrl.net.set(RANDOM_NUMBER_SEEDS, playerID2SeedMap );
						
						var playerids:Array = _gameCtrl.game.seating.getPlayerIds();
						trace("!!!Player ids=" + playerids);
						
						_gameCtrl.net.set(PLAYER_ORDER, playerids); 
						
						
						trace("!!!Creating initial game state for players " + playerids);
						for(k = 0; k < playerids.length; k++)
						{
							_gameModel.addPlayer(playerids[k], createNewRandomBoard(playerids[k]));
						}
						_gameModel._initialSeatedPlayerIds = playerids.slice();
						_gameModel._currentSeatedPlayerIds = playerids.slice();
						
						msg = new Object;
						msg[0] = _gameModel.getModelMemento();
						
						trace("!!!Sending to all players " + msg[0]);
						
						_gameCtrl.net.sendMessage( ALL_PLAYERS_READY, msg);
												
//						LOG_TO_GAME ? GameContext.LOG("\nSending ALL_PLAYERS_READY"): null;

						
//						_playerIDsInOrderOfPlay = _gameCtrl.game.seating.getPlayerIds();
						
					}
				}
//				LOG_TO_GAME ? GameContext.LOG("\n Player ready="+event.senderId +", _playersReady="+_playersReady): null;
			}
			if (event.name == Server.PLAYER_RECEIVED_START_GAME_STATE)
			{
				trace("Server PLAYER_RECEIVED_START_GAME_STATE for player " + event.senderId);
				
				
				if(!ArrayUtil.contains( _playersReceivedStartGameState, event.senderId))
				{
					_playersReceivedStartGameState.push( event.senderId );
					
					if( _playersReceivedStartGameState.length >= SeatingManager.numExpectedPlayers)
					{
						trace("Server sending GAME START to all players");
						_gameCtrl.net.sendMessage( START_PLAY, {});
					}
				}
			}
			else if (event.name == Server.BOARD_DELTA_REQUEST)
			{
				//Only the owner can change her own board.
				if(event.senderId == event.value[0])
				{
					trace(Server.BOARD_DELTA_REQUEST+ "[ " + event.value[0]+ " " + event.value[1]+ " " + event.value[2] + " " + event.value[3] + " ]");
					moveRequest(int(event.value[0]), int(event.value[2]), int(event.value[3]), int(event.value[4]), int(event.value[5]));
				}
			}
			else 
			if (event.name == Server.BOARD_UPDATE_REQUEST)
			{
				
//				trace("!!!!!!!!!!!!!!!Server Received message BOARD_UPDATE_REQUEST" + event);
//				trace("   From is " + event.senderId + "== " + int(event.value[0]) + ", board id="+int(event.value[1]));
			
			
			
				var clientid :int = int(event.value[0]);
				var boardplayerid:int =  int(event.value[1]);
				
				if(boardplayerid >= 0 && isPlayerActive(boardplayerid))
				{
				
//					var alsoUpdatePlayerIDS:Boolean = false;
					//If there is no board we have to generate one.
					var board:JoinGameBoardRepresentation;
					if(!_gameModel.isPlayer(boardplayerid))//This also means we haven't registered the player
					{
						board = createNewRandomBoard(boardplayerid);
						_gameModel.addPlayer(boardplayerid, board);
					}
					board = _gameModel.getBoardForPlayerID(boardplayerid);
					
					
	//				trace("!!!Server: Sending update, clientid="+clientid+", boardplayerid="+boardplayerid+", board.getBoardAsCompactRepresentation()="+board.getBoardAsCompactRepresentation());
					msg = new Object;
					msg[0] = clientid;
					msg[1] = boardplayerid;
					msg[2] = board.getBoardAsCompactRepresentation();
					
					_gameCtrl.net.sendMessage(Server.BOARD_UPDATE_CONFIRM, msg, clientid );
					
					
					trace("Server. sending board update: " + board.getBoardAsCompactRepresentation());
	//				if(alsoUpdatePlayerIDS)
	//				{
	//					//Not sure if this is the best place for this.  When a player requests an update, also update the player seating order.
	//					//To avoid circular events, the client requests an update if the neighbour player ids have changed.
	//					_playerIDsInOrderOfPlay = _gameCtrl.game.seating.getPlayerIds();
	////					_gameCtrl.net.set(PLAYER_ORDER, _playerIDsInOrderOfPlay); 
	//				}
				}
				else//If the player ID doesn't exist, send a dead board.
				{
					board = new JoinGameBoardRepresentation();
					board._rows = Constants.PUZZLE_STARTING_ROWS;
					board._cols = Constants.PUZZLE_STARTING_COLS;
//					trace("creating a board, here are the colors:");
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
		}


		private function createNewRandomBoard(playerid:int): JoinGameBoardRepresentation
		{
			var board:JoinGameBoardRepresentation = new JoinGameBoardRepresentation();
			board.playerID = playerid;
			board._rows = Constants.PUZZLE_STARTING_ROWS;
			board._cols = Constants.PUZZLE_STARTING_COLS;
			board.randomSeed = int(Math.random()*1000);
			if(board.randomSeed == 0)
			{
				throw new Error("Random seeds cannot be 0"); 
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
			}
			
			return board;
		}
		public static function generateRandomBoardRepresentation(rows:int, cols:int): Array
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
		public function occupantLeft( event: OccupantChangedEvent): void
		{
			trace(" occupantLeft="+event);
			if(event.player)//If a player and not a spectator.
			{
				playerLeftOrKnockedOut( event.occupantId );
			}
			
		}	
		

		
		public static function generateRandomPieceColor(): int
		{
//			return  Constants.PIECE_COLORS_ARRAY[randomNumber(0, Constants.PIECE_COLORS_ARRAY.length - 1)];
			return randomNumber(0, Constants.PIECE_COLORS_ARRAY.length - 1);
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
			
			if( isLegalMove(playerID, fromIndex, toIndex))
			{
				_gameModel.deltaConfirm(playerID, fromIndex, toIndex);
				
//				board.movePieceToLocationAndShufflePieces(fromIndex, toIndex);
				
//				trace("Server, checking for joins");
//				var joins:Array = board.checkForJoins();
//					
//				while(joins.length > 0)
//				{
//					trace(" joins found, checking again");
//					 joins = board.checkForJoins();
//				}
				
				//Send updates to player and players to left and right
//				getPlayerIDToLeftOfPlayer
				var msg :Object = new Object;
				msg[0] = playerID;
				msg[1] = fromIndex;
				msg[2] = toIndex;
				
//				trace("moveRequest, sending to all" );
				
				_gameCtrl.net.sendMessage(BOARD_DELTA_CONFIRM, msg);
				
//				var leftID:int = getPlayerIDToLeftOfPlayer(playerID);
//				var rightID:int = getPlayerIDToRightOfPlayer(playerID);
//				if(leftID!= playerID && leftID >= 0)
//				{
//					_gameCtrl.net.sendMessage(BOARD_DELTA_CONFIRM, msg, leftID);
//					trace("moveRequest, sending left to " + leftID);
//				}
//				if(rightID != playerID && rightID >= 0)
//				{
//					_gameCtrl.net.sendMessage(BOARD_DELTA_CONFIRM, msg, rightID);
//					trace("moveRequest, sending right to " + rightID);
//				}
				
			}
			else
				trace("Illegal move");
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
			var playerIDsInOrderOfPlay:Array = _gameCtrl.net.get(Server.PLAYER_ORDER) as Array;
			if(playerIDsInOrderOfPlay != null && ArrayUtil.contains(playerIDsInOrderOfPlay, playerID))
			{
				return true;
			}
			return false;
//			return ArrayUtil.contains(_playerIDsInOrderOfPlay, playerID);
		}


		/**
		 * 
		 * If someone leaves the game, they are eliminated immediately
		 * 
		 */
		public function occupantChanged( event: OccupantChangedEvent): void
		{
			trace(" occupantChanged="+event);
			if(event.player)//If a player and not a spectator.
			{
				playerLeftOrKnockedOut( event.occupantId );
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
		}



		public var _gameCtrl :GameControl;
		
		//This variable represents the entire game state
		private var _gameModel: JoinGameModel;
		
		
		//The game is played in a circle.  As players are eliminated.		
//		public var _playerIDsInOrderOfPlay: Array;
//		public var _playerToBoardMap :HashMap;
		
		//When all players are here, we proceed to the game.
		public var _playersReady: Array;
		
		//When all players have received the start game state
		public var _playersReceivedStartGameState: Array;
		
		private var _random: Random = new Random();
		
		
		//Server states
//		private var _isGameStateSent: Boolean = false;
		
		public static const BOARD_DELTA_REQUEST :String = "Server:Board Delta Request";
		public static const BOARD_DELTA_CONFIRM :String = "Server:Board Delta Confirm"; 
		public static const BOARD_UPDATE_REQUEST :String = "Server:Board Update Request";
		public static const BOARD_UPDATE_CONFIRM :String = "Server:Board Update Confirm"; 
		
		public static const ALL_PLAYERS_READY :String = "Server:All Players Ready";
		public static const PLAYER_READY :String = "Server:Player Ready";
		public static const PLAYER_RECEIVED_START_GAME_STATE :String = "Server:Player Recieved Start Game State";
		public static const START_PLAY :String = "Server:Start Play";  
		
		/** Name of the shared property that will hold everyone's scores. */
		public static const PLAYER_ORDER :String = "Server:Player Order";
		
		/** Name of the shared property that will hold everyone's scores. */
		public static const PLAYER_KNOCKED_OUT :String = "Server:Player Knocked Out";
		
		/** The seeds for the random number generators generatoing the random piece colors */
		public static const RANDOM_NUMBER_SEEDS :String = "Server:Random Seeds";
		
		
		/** Request the entire game state */
		public static const REQUEST_START_STATE :String = "Server:Request Start State";
		
		private var LOG_TO_GAME:Boolean = false;
	}
}