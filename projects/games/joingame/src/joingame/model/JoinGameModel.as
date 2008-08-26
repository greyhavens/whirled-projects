package joingame.model
{
	import com.threerings.util.ArrayUtil;
	import com.threerings.util.HashMap;
	import com.threerings.util.Random;
	import com.whirled.game.GameControl;
	import com.whirled.net.MessageReceivedEvent;
	
	import flash.events.EventDispatcher;
	
	import joingame.net.JoinGameEvent;
	import joingame.Constants;
	
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
			
			
			
			
			//Add the null board, for showing destroyed or missing players
			var board:JoinGameBoardRepresentation = new JoinGameBoardRepresentation();
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
			
			trace("\n getModelMemento():\n " + boards);
			
			return boards;
		}
		
		public function setModelMemento(representation:Array): void
		{
			trace("setModelMemento()");
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
			
			trace("_currentSeatedPlayerIds=" + _currentSeatedPlayerIds);
			trace("_initialSeatedPlayerIds=" + _initialSeatedPlayerIds);
			trace("_playerIdsInOrderOfLoss=" + _playerIdsInOrderOfLoss);
			
			for( i = 3; i < representation.length; i++)
			{
				var currentBoardRep:Array = representation[i] as Array;
				var playerID:int = currentBoardRep[0] as int;
				board = new JoinGameBoardRepresentation(_gameCtrl);
				board.setBoardFromCompactRepresentation( currentBoardRep );
				_playerToBoardMap.put( playerID, board);
				trace("putting board for player=" + playerID);
			}
			
			dispatchEvent(new JoinGameEvent(JoinGameEvent.RECEIVED_BOARDS_FROM_SERVER));
			
		}
		

		private static function getPlayerIDToLeft(myid:int, _playerIDsInOrderOfPlay:Array): int 
		{
			if( _playerIDsInOrderOfPlay== null || _playerIDsInOrderOfPlay.length <= 1)
				return -1;
			
			
			var myIDIndex: int = ArrayUtil.indexOf(_playerIDsInOrderOfPlay, myid );
			if( myIDIndex != -1)
			{
				//If there is only me, I am to my left
//				if(_playerIDsInOrderOfPlay.length == 1)
//				{
//					return myid;
//				}
				
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
//				if(_playerIDsInOrderOfPlay.length == 1)
//				{
//					return myid ;
//				}
				
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
		
		//The JoinGameBoard handles much of its own events,
		//however it notifies the main game class if pieces
		//have been swapped, so this class can decide what to do
		/**
		 * board: the board that performed the joins.
		 * 
		 */
		public function doJoins(board:JoinGameBoardRepresentation, joinArray:Array): void
		{
//			trace("doJoins(), joinArray.length=" + joinArray.length);
			
			for(var i: int = 0; i < joinArray.length; i++)
			{
				var join: JoinGameJoin = joinArray[i] as JoinGameJoin;
				if(join != null)
				{
//					trace("doJoins(), join._widthInPieces="+join._widthInPieces);
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
//							LOG("\nmy id="+_gameCtrl.game.getMyId() + ", allids=" +_playerIDsInOrderOfPlay +",  Sending attack to "+idOfPlayerToAttack + ", side="+sideAttackComesFromForAttacked);

							doAttack(_playerToBoardMap.get(idOfPlayerToAttack), sideAttackComesFromForAttacked, join.attackRow, 1);

//							sendMessageAttackPlayerFromSideAndRowWithValue(idOfPlayerToAttack, sideAttackComesFromForAttacked, join.attackRow, 1);
						}	
						else if( join._widthInPieces == 5)
						{
//							sendMessageAttackPlayerFromSideAndRowWithValue(idLeft, JoinGameJoin.RIGHT, join.attackRow, 1);
//							sendMessageAttackPlayerFromSideAndRowWithValue(idRight, JoinGameJoin.LEFT, join.attackRow, 1);
							
							doAttack(_playerToBoardMap.get(idLeft), Constants.ATTACK_RIGHT, join.attackRow, 1);
							doAttack(_playerToBoardMap.get(idRight), Constants.ATTACK_LEFT, join.attackRow, 1);
						}	
						if( join._widthInPieces ==6)
						{
//							LOG("\nmy id="+_gameCtrl.game.getMyId() + ", allids=" +_playerIDsInOrderOfPlay +",  Sending attack to "+idOfPlayerToAttack + ", side="+sideAttackComesFromForAttacked);
//							sendMessageAttackPlayerFromSideAndRowWithValue(idOfPlayerToAttack, sideAttackComesFromForAttacked, join.attackRow, damageFor7Join);
							doAttack(_playerToBoardMap.get(idOfPlayerToAttack), sideAttackComesFromForAttacked, join.attackRow, damageFor7Join);
						}	
						if( join._widthInPieces ==7)
						{
							
							if(idLeft == idRight)
							{
								if(_random.nextBoolean())
								{
									doAttack(_playerToBoardMap.get(idLeft), Constants.ATTACK_RIGHT, join.attackRow, damageFor7Join);
//									sendMessageAttackPlayerFromSideAndRowWithValue(idLeft, JoinGameJoin.RIGHT, join.attackRow, damageFor7Join);
								}
								else
								{
//									sendMessageAttackPlayerFromSideAndRowWithValue(idRight, JoinGameJoin.LEFT, join.attackRow, damageFor7Join);
									doAttack(_playerToBoardMap.get(idRight), Constants.ATTACK_RIGHT, join.attackRow, damageFor7Join);
								}
								
							}
							else
							{
//								sendMessageAttackPlayerFromSideAndRowWithValue(idLeft, JoinGameJoin.RIGHT, join.attackRow, damageFor7Join);
//								sendMessageAttackPlayerFromSideAndRowWithValue(idRight, JoinGameJoin.LEFT, join.attackRow, damageFor7Join);
								doAttack(_playerToBoardMap.get(idLeft), Constants.ATTACK_RIGHT, join.attackRow, damageFor7Join);
								doAttack(_playerToBoardMap.get(idRight), Constants.ATTACK_LEFT, join.attackRow, damageFor7Join);
							}
						}	
//						_board._shieldsLeft++;
//						_board._shieldsRight++;
//						_board.drawShields();
						
						
						
//						_board.setBoardFromCompactRepresentation(_board.getBoardAsCompactRepresentation());
//						_board.addRow();
//						_board.removeRowCountingFromBottom(join.attackRow);
					}
					
					//Build up
					if(join._heighInPiecest > 1 )
					{
//						LOG("\nVertical join at col " + join._buildCol );
						
						board.addNewPieceToColumnAndLeftAndRight(join._buildCol );
						
						if(Constants.ENCLOSED_UNCONNECTABLE_REGIONS_BECOME_DEAD)
						{
							board.markPotentiallyDead();
						}
//						if(! checkForBoardDeath())
//							getMyBoard().sendServerCurrentState();
						
						
//						_board.updateBoard();
						
//						//A vertical col on the sides is wall building
//						if(join._buildCol == 0 || join._buildCol == _board._cols - 1)
//						{
//							
//							_board._shieldsLeft++;
//							_board._shieldsRight++;
//							_board.drawShields();
//							_board.sendServerCurrentState();
//						}
//						else
//						{
//							_board._verticalJoinsCompleted++;
//							_board.addNewPieceToColumn(join._buildCol );
////							addRows(_board);
//							_board.setBoardFromCompactRepresentation(_board.getBoardAsCompactRepresentation());
//							_board.sendServerCurrentState();
//						}
					}				
				} 
			}
			
			if(Constants.ENCLOSED_UNCONNECTABLE_REGIONS_BECOME_DEAD)
			{
				board.markPotentiallyDead();
			}
//			if(! checkForBoardDeath())
//				getMyBoard().sendServerCurrentState();
			
			
			
			//Temp victory conditions, 10 rows high
//			if(getMyBoard().getHighestRowWIthValidPiece() >= 10)
//			{
//				var msg :Object = new Object;
//				msg[0] = _gameCtrl.game.getMyId();
//				if(_gameCtrl.net.isConnected())
//					_gameCtrl.net.sendMessage(PLAYER_KNOCKED_OUT, msg);
//			}
		}
		
		public function doAttack(board: JoinGameBoardRepresentation, side:int, rowsFromBottom: int, attackValue: int): void
		{
			if( board == null)
			{
				trace("doAttack( board is null)");
				return;
			}
//			trace("attacking!!!!");
			var targetRow: int = (board._rows-1) - rowsFromBottom;
			while(attackValue> 0)
			{
				board.turnPieceDeadAtRowAndSide( targetRow, side);
				attackValue--;
			}
//			var update:JoinGameEvent = new JoinGameEvent(JoinGameEvent.BOARD_UPDATED);
//			update.boardPlayerID = board.playerID;
//			board.dispatchEvent(update);
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
			
			if(board != null)
			{
				//We listen for when the board (representation on the server) is changed and add
				//animations accordingly.
//				board.addEventListener(BoardUpdateEvent.BOARD_UPDATED, boardChanged);
//				board.addEventListener(BoardUpdateEvent.ATTACKING_JOINS, boardChanged);
			}
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
			
			var event :JoinGameEvent = new JoinGameEvent(JoinGameEvent.PLAYER_KNOCKED_OUT);
			event.boardPlayerID = playerID;
			dispatchEvent(event);
			
			if( _currentSeatedPlayerIds.length <= 1)
			{
				event = new JoinGameEvent(JoinGameEvent.GAME_OVER);
				dispatchEvent(event);
			}
		}
		
		
		
//		/** Respond to messages from other clients. */
//		protected function boardChanged (event :BoardUpdateEvent) :void
//		{
//			
//			
//			if (event.type == BoardUpdateEvent.ATTACKING_JOINS)
//			{
//				
//				// Convert the event value back to an object, and pop the info
//				var id :int = event.boardPlayerID;
//				
//				var board:JoinGameBoardRepresentation = _playerToBoardMap.get(id);
//				
////				LOG("Attack to rowsFromBottom  " + rowsFromBottom);
//				if(board != null)
//				{
//					
//					
//					
//					
//					
//					
//					var side:int = event.value[1] as int;
//					var rowsFromBottom:int = event.value[2] as int;
//					var value:int = event.value[3] as int;
//				
//					var targetRow: int = (getMyBoard().getRows()-1) - rowsFromBottom;
//					
////					LOG("\nmyid="+_gameCtrl.game.getMyId()+", Attack to row  " + targetRow + " from " + id + ", at side=" + side);
//					
//					
//					
////					LOG("\nplayerids=  " + _playerIDsInOrderOfPlay);
//					
//					while(value> 0)
//					{
//						getMyBoard().turnPieceDeadAtRowAndSide( targetRow, side);
//						value--;
//					}
//					
//					
//					
////					if(id == getPlayerIDToLeft() && side ==  JoinGameJoin.LEFT)
////					{
////						while(value> 0)
////						{
////							_board.turnPieceDeadAtRowAndSide( targetRow, JoinGameJoin.LEFT);
////							value--;
////						}
////					}
////					else if(id == getPlayerIDToRight() && side ==  JoinGameJoin.RIGHT)
////					{
////						while(value> 0)
////						{
////							_board.turnPieceDeadAtRowAndSide( targetRow, JoinGameJoin.RIGHT);
////							value--;
////						}
////					}
//					
//					if(Constants.ENCLOSED_UNCONNECTABLE_REGIONS_BECOME_DEAD)
//					{
//						getMyBoard().convertDeadToDead();
//					}
//					if(! checkForBoardDeath())
//						getMyBoard().sendServerCurrentState();
//					
//					 
//					
////					if(targetRow >= 0 && targetRow < _board.getRows())
////					{
////					
////						if(_board._shieldsLeft >= 1)
////						{
////							_board._shieldsLeft--;
////							_board._shieldsRight--;
////							_board.drawShields();
////						}
////						else
////						{
////							
////							_board.turnPieceDeadAtRowAndSide( targetRow, true);
////							
////							if(_board.getRows() > 6)
////							{
//////								_board.removeRow(targetRow);
//////								_board.setBoardFromCompactRepresentation(_board.getBoardAsCompactRepresentation());
//////								_boardRIGHT.drawPartialNewRow();
////							}
////						}
////						_board.sendServerCurrentState();
////					}
////					else
////						LOG("Attack to row  " + targetRow + " but row doesn't exist");
//				}
//			}
//			
//			
//			/*If there are joins resulting in attacks, make the pieces in the other boards dead*/
//			updatePieceDimensionsAndCoordinatesAndAddPiecesIfNecessary();			
//		}
		
		override public function toString():String
		{
			return "Players=" + _playerToBoardMap.keys().toString() + "\n Boards=" + _playerToBoardMap.values().toString();
		}
		
		
		public function deltaConfirm(boardId :int, fromIndex :int, toIndex :int) :void
		{
//			trace("deltaConfirm()");
			var board: JoinGameBoardRepresentation = _playerToBoardMap.get(boardId) as JoinGameBoardRepresentation;;	
				
			if( board == null)
			{
				trace("delta confirm for a null board with id=" + boardId);
				return;
			}	
				
//			trace("movePieceToLocationAndShufflePieces()");
			board.movePieceToLocationAndShufflePieces( fromIndex, toIndex);
			
			
			var wasJoins :Boolean = false;	
			var joins:Array = board.checkForJoins();
			while(joins.length > 0)
			{
				wasJoins = true;
				doJoins(board, joins);
//				trace(" joins found, checking again");
				joins = board.checkForJoins();
				
			}
			
			
			
			if(wasJoins)
			{
				var id :int;
				var adjacentBoard :JoinGameBoardRepresentation;
					
				if(Constants.ENCLOSED_UNCONNECTABLE_REGIONS_BECOME_DEAD)
				{
					convertDeadToDead(board);
					id = getPlayerIDToLeftOfPlayer(board.playerID);
					if(id >= 0)
					{
	//					trace("convertingDead on player=" + id);
						adjacentBoard = getBoardForPlayerID(id);
						convertDeadToDead(adjacentBoard);
						adjacentBoard.sendBoardUpdateEvent();
					}
					id = getPlayerIDToRightOfPlayer(board.playerID);
					if(id >= 0)
					{
	//					trace("convertingDead on player=" + id);
						adjacentBoard = getBoardForPlayerID(id);
						convertDeadToDead(adjacentBoard);
						adjacentBoard.sendBoardUpdateEvent();
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
			
			
			
	
			if( !board.isAlive())
			{
				removePlayer(board.playerID);
			}
			
			
			//Check for player death
			
			
//			if(! checkForBoardDeath())
//			{
//				getMyBoard().sendServerCurrentState();
//			}			
				
			board.sendBoardUpdateEvent();		
			
//			var update:JoinGameEvent = new JoinGameEvent(JoinGameEvent.BOARD_UPDATED);
//			update.boardPlayerID = board.playerID;
//			update.joins = joins;
//			
//			//ATM we just redraw the entire board.
//			board.dispatchEvent(update);	
					
					
					
					
//					var update:BoardUpdateEvent = new BoardUpdateEvent(BoardUpdateEvent.BOARD_UPDATED);
//					update.boardPlayerID = board.playerID;
//					update.joins = joins;
//					
//					//ATM we just redraw the entire board.
//					this.dispatchEvent(update);
					
					
					//From Tims PuzzleBoard.as
					
					
					// let's only animate if the game isn't running slowly
//			        var animate :Boolean = !PerfMonitor.isLowFramerate;
//			
//			        // remove the cleared pieces from the board
//			        for each (var piece :Piece in clearPieces) {
//			            if (animate) {
//			                // animate the pieces exploding
//			                var pieceAnim :SerialTask = new SerialTask();
//			                pieceAnim.addTask(ScaleTask.CreateEaseOut(0.3, 0.3, PIECE_SCALE_DOWN_TIME));
//			                pieceAnim.addTask(new SelfDestructTask());
//			                piece.addTask(pieceAnim);
//			
//			            } else {
//			                piece.destroySelf();
//			            }
//			
//			            // remove the pieces from the board array
//			            _board[piece.boardIndex] = null;
//			        }
//			
//			        // when the pieces are done clearing,
//			        // drop the pieces above them.
//			        this.addTask(new SerialTask(
//			            new TimedTask(PIECE_SCALE_DOWN_TIME),
//			            new FunctionTask(function () :void { dropPieces(animate); } )));
//			            
//			
		}
		
		
		/**
		 * Converts the pieces that cannot possiblly form joins into 
		 * "dead" pieces, marking them as unavailable.
		 * 
		 */
		private function convertDeadToDead(board :JoinGameBoardRepresentation):void
		{
//			trace("convertDeadToDead for board " + board.playerID);
			var k: int;
			var i: int;
			for(k = 0; k < board._boardPieceTypes.length; k++)
			{
				if(board._boardPieceTypes[k] == Constants.PIECE_TYPE_POTENTIALLY_DEAD)
				{
					board._boardPieceTypes[k] = Constants.PIECE_TYPE_NORMAL;
				}
			}
			var contiguousRegions:Array = board.getContiguousRegions();
			
//			trace("contiguousRegions.length=" + contiguousRegions.length);
			
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
//					trace("converting to dead=" + arrayOfContiguousPieces);
					for(i = 0; i < arrayOfContiguousPieces.length; i++)
					{
						board._boardPieceTypes[ int(arrayOfContiguousPieces[i]) ] = Constants.PIECE_TYPE_POTENTIALLY_DEAD;
					}
				}
				else
				{
//					trace("Not converting to dead");
				}
			}
			
		}
		
		
		/** Respond to messages from other clients. */
		public function messageReceived (event :MessageReceivedEvent) :void
		{
			
			var id :int;
			var board: JoinGameBoardRepresentation;
			
			//If the update refers to us, update, and notify the display
			if (event.name == Server.BOARD_DELTA_CONFIRM)
			{
				
//				if(_playerID >= 0)
//				{
//					trace("Player: " + AppContext.gameCtrl.game.getMyId() + ", " + Server.BOARD_DELTA_CONFIRM+ "[ " + event.value[0]+ " " + event.value[1]+ " " + event.value[2] + " ]");
//				}
				id = int(event.value[0]);
				board = _playerToBoardMap.get(id) as JoinGameBoardRepresentation;
				var fromIndex :int = int(event.value[1]);
				var toIndex :int = int(event.value[2]);
				
				
				trace("Player: " + _gameCtrl.game.getMyId() + ", " + Server.BOARD_DELTA_CONFIRM+ "[ board=" + event.value[0]+ " " + event.value[1]+ " " + event.value[2] + " ]");
				
				
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
				var boardID :int = int(event.value[1]);
				
				board = _playerToBoardMap.get(id) as JoinGameBoardRepresentation;
				var boardRep:Array = event.value[2] as Array;
				board.setBoardFromCompactRepresentation(boardRep);
				dispatchEvent(new JoinGameEvent(JoinGameEvent.BOARD_UPDATED));
			}
			if (event.name == Server.PLAYER_KNOCKED_OUT)
			{
				
				id = int(event.value[0]);
				if(id >= 0)
				{
					removePlayer(id);
				}
			}
			
		}
		
		
//		/**
//		 * 
//		 * The game is played in a circle.  As players are eliminated.
//		 */ 		
//		public function get playerIDsInOrderOfPlay():Array
//		{
//			return _gameCtrl.net.get(Server.PLAYER_ORDER) as Array;
//		}
		
		private var _gameCtrl :GameControl;
		private var _playerToBoardMap :HashMap;
		public var _currentSeatedPlayerIds:Array;
		public var _initialSeatedPlayerIds:Array;
		private var _playerIdsInOrderOfLoss:Array;
		
		private var _random: Random = new Random();
	}
}