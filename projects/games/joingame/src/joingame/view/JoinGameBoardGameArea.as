package joingame.view
{
	import com.whirled.contrib.simplegame.objects.*;
	import com.whirled.contrib.simplegame.resource.*;
	import com.whirled.contrib.simplegame.tasks.*;
	import com.whirled.contrib.simplegame.util.*;
	import com.whirled.game.GameControl;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import joingame.net.JoinGameEvent;
	import joingame.model.*;
	import joingame.*;
	
	//Contains a board representation, from which it receives animation request events. 
	public class JoinGameBoardGameArea extends Sprite
	{
		public function JoinGameBoardGameArea( boardRepresentation:JoinGameBoardRepresentation, control:GameControl, activePlayersBoard:Boolean = false)
		{
			//The board representation needs the game control to receive update events and to know the height of the display
			_control = control;
			
//			pieceImages = new SWF_PIECES();
			
			if (boardRepresentation == null)
			{
				throw new Error("JoinGameBoardGameArea Problem!!! boardRepresentation should not be null");
			}
        
			this.board = boardRepresentation;
			
			
			graphics.clear();
			graphics.beginFill( 0x66ff00, 0.5 );			
			graphics.drawRect( 0 , 0 , 200, 200);
			graphics.endFill();
			mouseEnabled = true;
	
			this.x = 10;
			this.y = 10;
			
			
			
			
			
			
//			//Get the size by loading up a piece
//			if (null == SWF_CLASSES)
//	        {
//	            SWF_CLASSES = [];
//	            var swf :SwfResource = (ResourceManager.instance.getResource("puzzlePieces") as SwfResource);
//	            for each (var className :String in SWF_CLASS_NAMES)
//	            {
//	                SWF_CLASSES.push(swf.getClass(className));
//	            }
//	        }
//
//
//
//	        var pieceClass :Class = SWF_CLASSES[1];
//	        var pieceMovie :MovieClip = new pieceClass();
//			this.tileSize = pieceMovie.width;
		
		
		
			this.tileSize = Constants.PUZZLE_TILE_SIZE;
			
			
			_activePlayersBoard = activePlayersBoard;
			
			//Add mouse listeners if appropriate
			if(_activePlayersBoard)
			{
				addEventListener(MouseEvent.CLICK, mouseClicked);
				addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
				addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
				 
				graphics.clear();
				graphics.beginFill( 0x00cccc, 0.5 );			
				graphics.drawRect( 0 , 0 , 200, 200);
				graphics.endFill();
			}
			
		}
		
		
		/** Respond to messages from other clients. */
		protected function boardChanged (event :JoinGameEvent) :void
		{
			trace("BoardUpdateEvent: Board updated, so updating display");
			updatePieceDimensionsAndCoordinatesAndAddPiecesIfNecessary();			
		}
		
		
		protected function getPieceXLoc (xCoord :int) :int
		{
//			return ((xCoord + 0.5) * _tileSize) - xCoord;
			return xCoord * _tileSize;
		}
	
		protected function getPieceYLoc (yCoord :int) :int
		{
//			return ((yCoord + 0.5) * _tileSize) - yCoord;
			return yCoord * _tileSize;
		}
		
		
		protected function updatePieceDimensionsAndCoordinatesAndAddPiecesIfNecessary(): void
		{
//			trace("\nupdatePieceDimensionsAndCoordinatesAndAddPiecesIfNecessary()\n ");
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
//					addChild(_boardPieces[k]);
				}
				var piece: JoinGamePiece = _boardPieces[k] as JoinGamePiece;
				piece.boardIndex = k;
				piece.type = _boardRepresentation._boardPieceTypes[k];
				piece.color = _boardRepresentation._boardPieceColors[k];
				
				piece.x = getPieceXLoc(  _boardRepresentation.idxToX(k));
				piece.y = getPieceYLoc(  _boardRepresentation.idxToY(k));
//				trace(" piece color="+piece.color + ", x="+piece.x + ", piece.y="+piece.x + ", size="+piece.size);
			}
			
			y = _control.local.getSize().y -_boardRepresentation._rows*_tileSize;
			
					 
			addAllBoardComponents();
			
			
		}
		
		protected function removeAllBoardComponents(): void
		{
			while(numChildren > 0)
			{
				removeChildAt(0);
			}
		}
		
		protected function addAllBoardComponents(): void
		{
			for( var i: int = 0; i < _boardPieces.length; i++)
			{
				if(_boardPieces[i] != null)
				{
					addChild( _boardPieces[i]);
				}
			}
			
//			var headshot:DisplayObject = SeatingManager.getPlayerHeadshot( AppContext.gameCtrl.game.seating.getPlayerPosition(_boardRepresentation.playerID));
//			if(headshot != null)
//			{
////				headshot.x = -headshot.width;
////				headshot.y = -headshot.height;
////				addChild( headshot );
//			}
		}
		
		
				
		protected function mouseClicked (e :MouseEvent) :void
		{
//			trace("clicked");
//			AppContext.gameCtrl.game.systemMessage
			trace("mouseclicked, width, height=" + this.width + ", " + this.height);
			
//			_boardRepresentation.playerID = _control.game.getMyId();
//			AppContext.gameCtrl.net.sendMessageToAgent(Server.BOARD_UPDATE_REQUEST,  {});
			
//			var msg :Object = new Object;
//			msg[0] = _control.game.getMyId();
//			msg[1] = _control.game.getMyId();
//			
//			if(Constants.IS_BEREAU)
//			{
//				AppContext.gameCtrl.net.sendMessageToAgent(Server.BOARD_UPDATE_REQUEST,  msg);
//			}
//			else
//			{
//				AppContext.gameCtrl.net.sendMessage(Server.BOARD_UPDATE_REQUEST,  msg);
//			}
//			_boardRepresentation.playerID = _control.game.getMyId();
			
			
			
//			return;
			
			if( _selectedPiece != null )
			{
				var mouseIndexX :int = ((e.localX) / (_tileSize));
				var mouseIndexY :int = ((e.localY) / (_tileSize ));
			
			
				trace("mouseclicked, e.localX=" + e.localX);
				trace("mouseclicked, _tileSize=" + _tileSize);
						
				trace("mouseclicked, coords=" + mouseIndexX + ", " + mouseIndexY);
				
				var row:int = _boardRepresentation.idxToX( _selectedPiece.boardIndex);
				
				
				
				var pieceToSwap:JoinGamePiece = getPieceAt(row, mouseIndexY);
				requestMove(_selectedPiece, pieceToSwap);
				
				
//				if(pieceToSwap != null && _selectedPiece.boardIndex != pieceToSwap.boardIndex)
//				{
//					
////					LOG_TO_GAME ? GameContext.LOG("\nSwapping [" + row + ", " + _boardRepresentation.idxToY( _selectedPiece.boardIndex) + "] and ["+_boardRepresentation.idxToX( pieceToSwap.boardIndex) + ", " + _boardRepresentation.idxToY( pieceToSwap.boardIndex) + "]"): null;
//					//We assume the move is legal, as far as we know.  The server checks the legality of the move.
//					var msg :Object = new Object;
//					msg[0] = _control.game.getMyId();
//					msg[1] = _boardRepresentation.playerID;
//					msg[2] = _boardRepresentation.idxToX(_selectedPiece.boardIndex);
//					msg[3] = _boardRepresentation.idxToY(_selectedPiece.boardIndex);
//					msg[4] = _boardRepresentation.idxToX(pieceToSwap.boardIndex);
//					msg[5] = _boardRepresentation.idxToY(pieceToSwap.boardIndex);
//					
////					_control.net.sendMessage(Server.BOARD_DELTA_REQUEST, msg, NetSubControl.TO_SERVER_AGENT);
//					
//					_control.net.agent.sendMessage(Server.BOARD_DELTA_REQUEST, msg);
//				}
				
				
				_selectedPiece = null;
				_mostRecentSwappedPiece = null;
			}
			else
			{
				trace("selected piece is null");
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
				trace("client requesting move " + from + " -> " + target );
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
		

		
		protected function mouseMove (e :MouseEvent) :void
		{
			var mouseIndexX :int = ((e.localX) / (_tileSize));
			var mouseIndexY :int = ((e.localY) / (_tileSize ));
				
//			trace(" mouse move " + mouseIndexX + ", " + mouseIndexY);
//			AppContext.gameCtrl.game.systemMessage(" mouse move " + mouseIndexX + ", " + mouseIndexY);
			
				if(_selectedPiece != null)
				{
					var row:int = _boardRepresentation.idxToX( _selectedPiece.boardIndex);
					var pieceToSwap:JoinGamePiece = getPieceAt(row, mouseIndexY);
					
					_selectedPiece.y = e.localY - _selectedPiece.height/2;
					if( _selectedPiece.y < 0)
					{
						_selectedPiece.y = 0;
					}
					else if( _selectedPiece.y + _selectedPiece.size > _boardRepresentation._rows * _selectedPiece.size)
					{
						_selectedPiece.y = this.height - _selectedPiece.size;
					}
					
					if(pieceToSwap != _selectedPiece && pieceToSwap.type == Constants.PIECE_TYPE_NORMAL)
					{
						
						if(_mostRecentSwappedPiece == pieceToSwap)
						{
							trace("We have already swapped that piece.");
							return;
						}
						_mostRecentSwappedPiece = pieceToSwap;
						
						
						
						
//						return;
						
//						var wasSwaps:Boolean = false;
						
						movePieceToLocationAndShufflePieces(_selectedPiece.boardIndex, pieceToSwap.boardIndex);
						
						
						
//						shufflePieceToLocation( , row, , row);
//						swapPieces (_selectedPiece.boardIndex, pieceToSwap.boardIndex);
//						_lastSwap[0] =  idxToX(_selectedPiece.boardIndex);
//						_lastSwap[1] =  idxToY(_selectedPiece.boardIndex);
//						var joins:Array = updateBoardReturningJoinsThatForm();
//						
//						while(joins.length > 0)
//						{
//							wasSwaps = true;
//							(parent as JoinGame).notifyOfJoinsFound(joins);
//							 joins = updateBoardReturningJoinsThatForm();
//						}
//						if(!wasSwaps)
//						{
////							swapPiecesInternal (_selectedPiece.boardIndex, pieceToSwap.boardIndex);
//							
////							var tempIndex = _selectedPiece.boardIndex;
////							_selectedPiece.boardIndex = pieceToSwap.boardIndex;
////							pieceToSwap.boardIndex = tempIndex;
////							pieceToSwap.y = getPieceYLoc( idxToY(_selectedPiece.boardIndex));
////							_selectedPiece.y = getPieceYLoc( idxToY(pieceToSwap.boardIndex));
////							
////							_board[_selectedPiece.boardIndex] = _selectedPiece.boardIndex;
////							_board[pieceToSwap.boardIndex] = pieceToSwap.boardIndex;
//						}
//						else
//						{
//							sendServerCurrentState();
//							_selectedPiece = null;
//							pieceToSwap = null;
//							_lastSwappedPiece = null;
//							updatePieceDimensionsAndCoordinatesAndAddPiecesIfNecessary();
//						}
					}
					
					
					return;
					
					
					
					
					var lowestSwappableY:int = idxToY(getHighestSwappablePiece( _selectedPiece).boardIndex);
					var highestSwappableY:int = idxToY(getLowestSwappablePiece( _selectedPiece).boardIndex);
	
					//Reset the location of the pieces in the same row
					var row:int = idxToX( _selectedPiece.boardIndex);
//					for(var j: int = 0; j < _rows ; j++)
//					{
//						var piece: JoinGamePiece = getPieceAt(row, j);
//						if( piece != null && piece != _selectedPiece)
//						{
//							piece.y = getPieceYLoc(j);
//							
//						}
//					}
//					_selectedPiece.y = e.localY - _tileSize/2;
						
//					var mouseIndexX :int = (e.localX / (_tileSize - 1));
					var mouseIndexY :int = (e.localY / (_tileSize ));
					
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
							
							
//						}

//						if(_lastSelectedPieceRow != null)
//						{
//							_lastSelectedPieceRow.y = getPieceYLoc( idxToY(_lastSelectedPieceRow.boardIndex) );
//						}
						
						//Only do the checking and moving if the selected piece has moved
//						if(pieceToSwap != null  && pieceToSwap != _selectedPiece && pieceToSwap !=_lastSwappedPiece)
//						{
//							_selectedPieceSprite.x = pieceToSwap.x;
//							_selectedPieceSprite.y = pieceToSwap.y;
//							addChild(_selectedPieceSprite);
//							setChildIndex( _selectedPieceSprite, numChildren - 1);//Make sure it's on top  of the other pieces
//							
//							_lastSwappedPieceSprite.x = _selectedPiece.x;
//							_lastSwappedPieceSprite.y = _selectedPiece.y;
//							addChild(_lastSwappedPieceSprite);
//							setChildIndex( _lastSwappedPieceSprite, numChildren - 1);//Make sure it's on top  of the other pieces
//							
//							_lastSwappedPiece = pieceToSwap;
							
//							LOG("\nHERE");
//							_lastSelectedPieceRow = idxToY(pieceToSwap.boardIndex);
//							_lastSwappedPiece
	//						setChildIndex( pieceToSwap, numChildren - 2);//Make sure it's on top  of the other pieces
							
							
//							swapPiecesInternal (_selectedPiece.boardIndex, pieceToSwap.boardIndex);
							
							
//							var tempIndex = _selectedPiece.boardIndex;
//							_selectedPiece.boardIndex = pieceToSwap.boardIndex;
//							pieceToSwap.boardIndex = tempIndex;
//							
//							_board[_selectedPiece.boardIndex] = _selectedPiece.boardIndex;
//							_board[pieceToSwap.boardIndex] = pieceToSwap.boardIndex;
							
							var wasSwaps:Boolean = false;
							var joins:Array = updateBoardReturningJoinsThatForm();
							while(joins.length > 0)
							{
								wasSwaps = true;
								(parent as JoinGame).notifyOfJoinsFound(joins);
								 joins = updateBoardReturningJoinsThatForm();
							}
				//			setBoardFromCompactRepresentation(getBoardAsCompactRepresentation());
//							LOG("\n after remove");
				//			printMatrix();
							
							
			
							if(!wasSwaps)
							{
//								LOG(", There were no swaps");
//								swapPiecesInternal (_selectedPiece.boardIndex, pieceToSwap.boardIndex);
								
//								var tempIndex = _selectedPiece.boardIndex;
//								_selectedPiece.boardIndex = pieceToSwap.boardIndex;
//								pieceToSwap.boardIndex = tempIndex;
//								pieceToSwap.y = getPieceYLoc( idxToY(_selectedPiece.boardIndex));
//								_selectedPiece.y = getPieceYLoc( idxToY(pieceToSwap.boardIndex));
//								
//								_board[_selectedPiece.boardIndex] = _selectedPiece.boardIndex;
//								_board[pieceToSwap.boardIndex] = pieceToSwap.boardIndex;
							}
							else
							{
//								LOG(", There were swaps");
								sendServerCurrentState();
								_selectedPiece = null;
								pieceToSwap = null;
								_lastSwappedPiece = null;
								updatePieceDimensionsAndCoordinatesAndAddPiecesIfNecessary();
								
								
								
								_previousMouseOverIndex = -1;
								_previousMouseOverColor = -1;
								_mouseOverIndex = -1;
								_mouseOverColor = -1;
					
					
//								_lastSelectedPieceRow = null;
							}
							
	//						LOG("\n_selectedPiece.boardIndex="+_selectedPiece.boardIndex);
	//						LOG("\nselected piece.y="+_selectedPiece.y);
	//						LOG("\nadjusting to y="+pieceToSwap.y+" of potential piece ("+row+", " + mouseIndexY +"), color="+pieceToSwap.color);
						}
						
						
//						setChildIndex( _selectedPiece, numChildren - 1);//Make sure it's on top  of the other pieces
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
			trace("Function deprecated, shufflePieceToLocation()!!!!!");
//			if( pieceX == locX || pieceY == locY)
//			{
//				return;
//			}
//			
//			//First set the selected piece to the target coords
//			
//			
//			
//			var increment:int = pieceY > locY ? -1 : 1;
//			//Swap up or down, depending on the relative position of the pieces.
//			for( var j:int = pieceY; pieceY > locY ? j > locY : j < locY ; j+= increment)
//			{
//				var swap1:int  = _boardRepresentation.coordsToIdx(px1, j);
//				var swap2:int  = _boardRepresentation.coordsToIdx(px1, j + increment);
//				
//				swapPieces (swap1,swap2);
//			}
			
		} 
		
		public function movePieceToLocationAndShufflePiecesOLDDELETE(index1 :int, index2 :int) :void
		{
			trace("Function deprecated, movePieceToLocationAndShufflePiecesOLDDELETE()!!!!!");
			
//			var px1 :int = idxToX(index1);
//			var py1 :int = idxToY(index1);
//			var px2 :int = idxToX(index2);
//			var py2 :int = idxToY(index2);
//			
//			if(px1 != px2)
//			{
////				LOG("movePieceToLocationAndShufflePieces: x coords not identical");
//				return;	
//			}
//			
//			var increment:int = py1 > py2 ? -1 : 1;
////			LOG("movePieceToLocationAndShufflePieces " + px1 + " " + py1 + " " + px2 + " " + py2 );
//			//Swap up or down, depending on the relative position of the pieces.
//			for( var j:int = py1; py1 > py2 ? j > py2 : j < py2 ; j+= increment)
//			{
//				var swap1:int  = coordsToIdx(px1, j);
//				var swap2:int  = coordsToIdx(px1, j + increment);
//				
////				LOG("\nSwapping y " + j + " " +  (j + increment));
//				swapPieces (swap1,swap2);
//			}
		}
		
		/**
		 * Moves pieces but does not change thier index, so it's only 
		 * temporary until we recieve the update confirm from the server.
		 */
		public function movePieceToLocationAndShufflePieces(index1 :int, index2 :int) :void
		{
			
			trace("movePieceToLocationAndShufflePieces( " + index1 + ", " + index2 + ")");
			var px1 :int = _boardRepresentation.idxToX(index1);
			var py1 :int = _boardRepresentation.idxToY(index1);
			var py2 :int = _boardRepresentation.idxToY(index2);
			
			if(py1 == py2)
			{
				trace("movePieceToLocationAndShufflePieces, y coords same, doing nothing");
				return;	
			}
			
			//First set all the pieces to their normal values, except the first/selected piece
			for( var j:int = 0; j < _boardRepresentation._rows ; j++)
			{
				if( j != py1 && getPieceAt(px1, j) != _selectedPiece)//We don't reset the selected pieces poisition
				{
					getPieceAt(px1, j).y = getPieceYLoc( _boardRepresentation.idxToY( _boardRepresentation.coordsToIdx(px1, j)));
				}
			}
			setChildIndex( (_boardPieces[index1] as JoinGamePiece), numChildren - 1);
			
			
			trace("Before moving, Selected piece.y="+(_boardPieces[index1] as JoinGamePiece).y);
//			(_boardPieces[index1] as JoinGamePiece).y = getPieceYLoc( _boardRepresentation.idxToY(_boardRepresentation.coordsToIdx(px1, py2)));
			trace("Setting selected piece.y="+(_boardPieces[index1] as JoinGamePiece).y);
			
			
			//Then go through the in between pieces, adjusting thier y coord by one piece height increment
			//If the first piece starts with a higher (lower y) than the second piece, it moves down, so 
			//all the other pieces must move up by one (lower their y by one).
			var increment:int = py1 < py2 ? 1 : -1;
			//Swap up or down, depending on the relative position of the pieces.
			for( var j:int = py1 + increment; py1 > py2 ? j >= py2 : j <= py2 ; j+= increment)
			{
				trace("changing piece (" + px1 + ", " + j + "), index=" + getPieceAt(px1, j).boardIndex);
				
				getPieceAt(px1, j).y = getPieceYLoc( _boardRepresentation.idxToY( _boardRepresentation.coordsToIdx(px1, j - increment)));
				trace("setting y=" + getPieceAt(px1, j).y);
//				piece.y = getPieceYLoc(  _boardRepresentation.idxToY(k));
			}
			
			//And reset all those pieces below/above the change to thier no
		}
		 
		 
		protected function swapPiecesInternal (index1 :int, index2 :int) :void
		{
			trace("Function deprecated, swapPiecesInternal()!!!!!");
//			var piece1 :JoinGamePiece = (_board[index1] as JoinGamePiece);
//			var piece2 :JoinGamePiece = (_board[index2] as JoinGamePiece);
//	
//			if (null != piece1) {
//				piece1.boardIndex = index2;
//			}
//	
//			if (null != piece2) {
//				piece2.boardIndex = index1;
//			}
//	
//			_board[index1] = piece2;
//			_board[index2] = piece1;
		}


		public function swapPieces (index1 :int, index2 :int) :void
		{
			trace("Function deprecated, swapPieces()!!!!!");
//			swapPiecesInternal(index1, index2);
//			var px1 :int = getPieceXLoc( idxToX(index1));
//			var py1 :int = getPieceYLoc( idxToY(index1));
//			var px2 :int = getPieceXLoc( idxToX(index2));
//			var py2 :int = getPieceYLoc( idxToY(index2));
//	
//			var piece1 :JoinGamePiece = _board[index1];
//			var piece2 :JoinGamePiece = _board[index2];
//			
//			piece1.x = px1;
//			piece1.y = py1;
//			piece2.x = px2;
//			piece2.y = py2;
		}
			
		protected function mouseDown (e :MouseEvent) :void
		{
			
//				LOG("mouseDown");
//				var mouseIndexX :int = (e.localX / (_tileSize - 1));
//				var mouseIndexY :int = (e.localY / (_tileSize - 1));
				
				var mouseIndexX :int = ((e.localX) / (_tileSize));
				var mouseIndexY :int = ((e.localY) / (_tileSize ));
			
			
				trace(" mouse down " + mouseIndexX + ", " + mouseIndexY);
				
				if(_selectedPiece == null)
				{
					_selectedPiece = getPieceAt(mouseIndexX, mouseIndexY);
					
					
					return;
					
//					_lastSelectedPieceRow = -1;
					if(_selectedPiece != null  && _selectedPiece.type == Constants.PIECE_TYPE_NORMAL)//Handle the row highlighting
					{
						_selectedIndex = _selectedPiece.boardIndex;
						_selectedColor = _selectedPiece.color;
					
						
//						_selectedPieceSprite.color = _selectedPiece.color; //Covers the current piece
//						_selectedPieceSprite.size = _selectedPiece.size;
						
						
//						addChild(_columnHighlight);
//						setChildIndex( _selectedPiece, numChildren - 1);//Make sure it's on top  of the other pieces
						_columnHighlight.graphics.clear();
						_columnHighlight.graphics.lineStyle(4, 0xf2f2f2, 0.5);
						var highestPiece:JoinGamePiece = getHighestSwappablePiece(_selectedPiece);
						var highestY:int = getPieceYLoc( idxToY(highestPiece.boardIndex));
						
//						LOG("\nHighest piece = (" + idxToX(highestPiece.boardIndex) + ", " + idxToY(highestPiece.boardIndex) + ")");
						
						
						var lowestPiece:JoinGamePiece = getLowestSwappablePiece(_selectedPiece);
						var lowestY:int = getPieceYLoc( idxToY(lowestPiece.boardIndex)) + _tileSize;
						var barHeight:int = lowestY - highestY  ;
						
//						LOG("\nLowest piece = (" + idxToX(lowestPiece.boardIndex) + ", " + idxToY(lowestPiece.boardIndex) + ")");
						
						_columnHighlight.graphics.drawRect(  getPieceXLoc( idxToX(_selectedPiece.boardIndex)),   highestY  , _tileSize, barHeight);
						
						
//						addChild(_selectedPieceSprite);
						
					}
					else
					{
						_selectedPiece = null;
					}
				}
			
		}
		
		public function set tileSize (newsize :int) :void
		{
			_tileSize = newsize;
			if(_boardPieces != null)
			{
				for(var i: int = 0; i < _boardPieces.length; i++)
				{
					var piece: JoinGamePiece = JoinGamePiece (_boardPieces[i]);
					if(piece != null)
						piece.size = _tileSize;
				}
			}
			updatePieceDimensionsAndCoordinatesAndAddPiecesIfNecessary();	
		}
		
		public function set board (board :JoinGameBoardRepresentation) :void
		{
			if(_boardRepresentation != null)
			{
				_boardRepresentation.removeEventListener(JoinGameEvent.BOARD_UPDATED, this.boardChanged);
			}
			
			_boardRepresentation = board;
			
			if(board != null)
			{
				//We listen for when the board (representation on the server) is changed and add
				//animations accordingly.
				_boardRepresentation.addEventListener(JoinGameEvent.BOARD_UPDATED, this.boardChanged);
			}
			updatePieceDimensionsAndCoordinatesAndAddPiecesIfNecessary();
		}
		
		public function get board () :JoinGameBoardRepresentation
		{
			return _boardRepresentation;
		}


		public function set activePlayersBoard (b :Boolean) :void
		{
			_activePlayersBoard = b;
		}
		
		
		private var _activePlayersBoard:Boolean;
		public var _boardRepresentation: JoinGameBoardRepresentation;
		private var _tileSize : int;
		private var _boardPieces: Array;
		
		private var _selectedPiece : JoinGamePiece;
		private var _mostRecentSwappedPiece : JoinGamePiece;
		
		
		//Game control needed to send move requests.
		public var _control :GameControl;
		
		private var LOG_TO_GAME:Boolean = false;
		
		
		protected static var SWF_CLASSES :Array;
    	protected static const SWF_CLASS_NAMES :Array = [ "piece_01", "piece_02", "piece_03", "piece_04", "piece_05" ];
		
		
	}
}

