package joingame.view
{
	import com.whirled.game.GameControl;
	import com.whirled.net.MessageReceivedEvent;
	
	import flash.display.Sprite;
	
	import joingame.net.JoinGameEvent;
	import joingame.model.*;
	import joingame.*;
	
	/**
	 * Draws the boards, and creates the animations between boards.
	 * 
	 * 
	 */
	public class JoinGameBoardsView extends Sprite
	{
		public function JoinGameBoardsView(joinGameModel :JoinGameModel, gameControl :GameControl)
		{
			
			if (joinGameModel == null || gameControl == null)
			{
				throw new Error("JoinGameBoardsView Problem!!! JoinGameModel or GameControl should not be null");
			}
			
			_gameModel = joinGameModel; //new JoinGameModel(_gameControl);
			_gameControl = gameControl;
			
			
			_gameModel.addEventListener(JoinGameEvent.PLAYER_KNOCKED_OUT, playerKnockedOut);
			_gameModel.addEventListener(JoinGameEvent.RECEIVED_BOARDS_FROM_SERVER, updateBoardDisplays);
			
			// send incoming message notifications to the messageReceived() method
//			_gameControl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
			
			
			updateBoardDisplays();
//			_myBoardDisplay = new JoinGameBoardGameArea( _gameControl, _gameModel.getBoardForPlayerID( _gameControl.game.getMyId() ), true);
//			this.addChild(_myBoardDisplay);
//			
//			_leftBoardDisplay = new JoinGameBoardGameArea(_gameControl, _gameModel.getBoardForPlayerID( _gameModel.getPlayerIDToLeftOfPlayer(_gameControl.game.getMyId())    ) );
//			this.addChild(_leftBoardDisplay);
//			
//			_rightBoardDisplay = new JoinGameBoardGameArea(_gameControl, _gameModel.getBoardForPlayerID( _gameModel.getPlayerIDToRightOfPlayer(_gameControl.game.getMyId())    ));
//			this.addChild(_rightBoardDisplay);
//			
//			
//			trace("\nWhen id="+_gameControl.game.getMyId()+" starts, left="+_gameModel.getPlayerIDToLeftOfPlayer(_gameControl.game.getMyId() )+ ", right="+_gameModel.getPlayerIDToRightOfPlayer(_gameControl.game.getMyId() ));
//			updateGameField();
		}
		
		
		protected function updateBoardDisplays(event :JoinGameEvent = null) :void
		{
			trace("JoinGameBoardsView.updateBoardDisplays()");
			if(_myBoardDisplay == null)
			{
				_myBoardDisplay = new JoinGameBoardGameArea( _gameModel.getBoardForPlayerID( _gameControl.game.getMyId() ), _gameControl, true);
				this.addChild(_myBoardDisplay);
			}
			else
			{
				if(_myBoardDisplay.board.playerID != _gameControl.game.getMyId())
				{
					_myBoardDisplay.board = _gameModel.getBoardForPlayerID( _gameControl.game.getMyId() );
				}
			}
			
			if(_leftBoardDisplay == null)
			{
				_leftBoardDisplay = new JoinGameBoardGameArea( _gameModel.getBoardForPlayerID( _gameModel.getPlayerIDToLeftOfPlayer(_gameControl.game.getMyId())), _gameControl );
				this.addChild(_leftBoardDisplay);
			}
			else
			{
				
				trace( "_leftBoardDisplay.board.playerID=" + _leftBoardDisplay.board.playerID);
				trace( "_gameModel.getPlayerIDToLeftOfPlayer(_gameControl.game.getMyId())=" + _gameModel.getPlayerIDToLeftOfPlayer(_gameControl.game.getMyId()));
				if(_leftBoardDisplay.board.playerID != _gameModel.getPlayerIDToLeftOfPlayer(_gameControl.game.getMyId()))
				{
					trace("setting left player id="+_gameModel.getPlayerIDToLeftOfPlayer(_gameControl.game.getMyId()) );
					_leftBoardDisplay.board = _gameModel.getBoardForPlayerID( _gameModel.getPlayerIDToLeftOfPlayer(_gameControl.game.getMyId())    );
				}
			}
			
			if(_rightBoardDisplay == null)
			{
				_rightBoardDisplay = new JoinGameBoardGameArea(_gameModel.getBoardForPlayerID( _gameModel.getPlayerIDToRightOfPlayer(_gameControl.game.getMyId())), _gameControl);
				this.addChild(_rightBoardDisplay);
			}
			else
			{
				trace( "_rightBoardDisplay.board.playerID=" + _rightBoardDisplay.board.playerID);
				trace( "_gameModel.getPlayerIDToRightOfPlayer(_gameControl.game.getMyId())=" + _gameModel.getPlayerIDToRightOfPlayer(_gameControl.game.getMyId()));
				
				
				if(_rightBoardDisplay.board.playerID != _gameModel.getPlayerIDToRightOfPlayer(_gameControl.game.getMyId()))
				{
					trace("setting left player id="+_gameModel.getPlayerIDToRightOfPlayer(_gameControl.game.getMyId()) );
					_rightBoardDisplay.board = _gameModel.getBoardForPlayerID( _gameModel.getPlayerIDToRightOfPlayer(_gameControl.game.getMyId())    );
				}
			}
			
//			trace("\nWhen id="+_gameControl.game.getMyId()+" starts, left="+_gameModel.getPlayerIDToLeftOfPlayer(_gameControl.game.getMyId() )+ ", right="+_gameModel.getPlayerIDToRightOfPlayer(_gameControl.game.getMyId() ));
			updateGameField();
		}
		
		/** Respond to messages from other clients. */
		protected function playerKnockedOut (event :JoinGameEvent) :void
		{
			trace("playerKnockedOut(), player=" + event.boardPlayerID);
			updateBoardDisplays();
			
//			trace("\nplayerKnockedOut="+event.boardPlayerID);
//			
//			if( _rightBoardDisplay._boardRepresentation.playerID == event.boardPlayerID)
//			{
//				_rightBoardDisplay.board = _gameModel.getBoardForPlayerID( _gameModel.getPlayerIDToRightOfPlayer( _myBoardDisplay._boardRepresentation.playerID));
//			}
//			
//			if( _leftBoardDisplay._boardRepresentation.playerID == event.boardPlayerID)
//			{
//				_leftBoardDisplay.board = _gameModel.getBoardForPlayerID( _gameModel.getPlayerIDToLeftOfPlayer( _myBoardDisplay._boardRepresentation.playerID));
//			}
//			
//			if( _myBoardDisplay._boardRepresentation.playerID == event.boardPlayerID)
//			{
//				_myBoardDisplay.board = _gameModel.getBoardForPlayerID( -1);
//			}
//			
//			updateGameField();
		}
		
		
		
		/** Respond to messages from other clients. */
		public function messageReceivedNOTUSEDYET (event :MessageReceivedEvent) :void
		{
			
		}
		
		/**
		 * 
		 * Must be called after createOrUpdateOtherPlayerDisplay() because we need the player order
		 * 
		 */
		private function updateGameField(): void
		{
//			if(GameContext._playerIDsInOrderOfPlay == null)
//			{
//				return;
//			}
			
			_leftBoardDisplay.x = Constants.GUI_DISTANCE_BOARD_FROM_LEFT;
			_myBoardDisplay.x = _leftBoardDisplay.x + _leftBoardDisplay.width + Constants.GUI_BETWEEN_BOARDS;
			_rightBoardDisplay.x = _myBoardDisplay.x + _myBoardDisplay.width + Constants.GUI_BETWEEN_BOARDS;
			
		}
		
				
		
		private var _myBoardDisplay :JoinGameBoardGameArea;
		private var _leftBoardDisplay :JoinGameBoardGameArea;
		private var _rightBoardDisplay :JoinGameBoardGameArea;
		
		
		/*This variable represents the entire game state */
		private var _gameModel :JoinGameModel;
		
		private var _gameControl :GameControl;

	}
}