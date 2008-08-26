package joingame.modes
{

	import com.threerings.util.*;
	import com.whirled.contrib.simplegame.*;
	import com.whirled.contrib.simplegame.audio.*;
	import com.whirled.contrib.simplegame.net.*;
	import com.whirled.contrib.simplegame.resource.*;
	import com.whirled.contrib.simplegame.util.*;
	import com.whirled.game.*;
	import com.whirled.net.MessageReceivedEvent;
	
	import joingame.net.JoinGameEvent;
	import joingame.model.*;
	import joingame.view.*;
	import joingame.*;
	
	//The 'game' part of the game
	public class PlayPuzzleMode extends AppMode
	{
		
		/**
		 * When this method is called, it assumes that the game starting data
		 * has already been downloaded to all clients/players.
		 * 
		 */
		override protected function setup () :void
		{
			_gameModel = GameContext.gameState; //new JoinGameModel(AppContext.gameCtrl);
			
			
			
			trace("Starting PlayPuzzleMode for player " + AppContext.gameCtrl.game.getMyId() + ", game model=" + _gameModel);
			
			_gameModel.addEventListener(JoinGameEvent.GAME_OVER, gameOver);
				
			// send property change notifications to the propertyChanged() method
//			AppContext.gameCtrl.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);
	
			// send incoming message notifications to the messageReceived() method
//			AppContext.gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
			
			
			//_modeSprite = new Sprite();
			_modeSprite.graphics.clear();
			_modeSprite.graphics.beginFill( 0xff0000, 0.5 );			
			_modeSprite.graphics.drawRect( 0 , 0 , AppContext.gameCtrl.local.getSize().x, AppContext.gameCtrl.local.getSize().y);
			_modeSprite.graphics.endFill();
			_modeSprite.mouseEnabled = true;
			
			
			_boardsView = new JoinGameBoardsView(GameContext.gameState, AppContext.gameCtrl);
			
			_modeSprite.addChild(_boardsView);
//			
//			myBoardDisplay = new JoinGameBoardGameArea( AppContext.gameCtrl, _gameModel.getBoardForPlayerID( AppContext.gameCtrl.game.getMyId() ), true);
////			myBoardDisplay._boardRepresentation.playerID = AppContext.gameCtrl.game.getMyId();
//			_modeSprite.addChild(myBoardDisplay);
////			myBoardDisplay._boardRepresentation.playerID = 1;
//			
//			leftBoardDisplay = new JoinGameBoardGameArea(AppContext.gameCtrl, _gameModel.getBoardForPlayerID( _gameModel.getPlayerIDToLeftOfPlayer(AppContext.gameCtrl.game.getMyId())    ) );
////			leftBoardDisplay._boardRepresentation.playerID = _gameModel.getPlayerIDToLeftOfPlayer(AppContext.gameCtrl.game.getMyId() );
//			_modeSprite.addChild(leftBoardDisplay);
//			
////			if(SeatingManager.numExpectedPlayers > 2)
////			{
//				rightBoardDisplay = new JoinGameBoardGameArea(AppContext.gameCtrl, _gameModel.getBoardForPlayerID( _gameModel.getPlayerIDToRightOfPlayer(AppContext.gameCtrl.game.getMyId())    ));
////				rightBoardDisplay._boardRepresentation.playerID = _gameModel.getPlayerIDToRightOfPlayer(AppContext.gameCtrl.game.getMyId() );
//				_modeSprite.addChild(rightBoardDisplay);
////			}
			
			
//			trace("\nWhen id="+AppContext.gameCtrl.game.getMyId()+" starts, left="+_gameModel.getPlayerIDToLeftOfPlayer(AppContext.gameCtrl.game.getMyId() )+ ", right="+_gameModel.getPlayerIDToRightOfPlayer(AppContext.gameCtrl.game.getMyId() ));
			
			allOpponentsView = new AllOpponentsView(AppContext.gameCtrl);
			_modeSprite.addChild(allOpponentsView);
			
//			updateGameField();
//			trace("!!!!!!!!!!!Updating game field");
		}
		public function gameOver (event :JoinGameEvent) :void
		{
			trace("game over, going to end screen");
			AppContext.mainLoop.unwindToMode(new GameOverMode());
		}
		
		
		/** Respond to messages from other clients. */
		public function messageReceived (event :MessageReceivedEvent) :void
		{
			
		}
		
//		//Must be called after createOrUpdateOtherPlayerDisplay() because we need the player order
//		private function updateGameField(): void
//		{
////			if(GameContext._playerIDsInOrderOfPlay == null)
////			{
////				return;
////			}
//			
//			leftBoardDisplay.x = Constants.GUI_DISTANCE_BOARD_FROM_LEFT;
//			myBoardDisplay.x = leftBoardDisplay.x + leftBoardDisplay.width + Constants.GUI_BETWEEN_BOARDS;
//			rightBoardDisplay.x = myBoardDisplay.x + myBoardDisplay.width + Constants.GUI_BETWEEN_BOARDS;
//			
//		}
		
		
//		/** Responds to property changes. */
//		public function propertyChanged (event :PropertyChangedEvent) :void
//		{
//			
////			trace("\nWhen id="+AppContext.gameCtrl.game.getMyId()+" propertyChanged, left="+_gameModel.getPlayerIDToLeftOfPlayer(AppContext.gameCtrl.game.getMyId() )+ ", right="+_gameModel.getPlayerIDToRightOfPlayer(AppContext.gameCtrl.game.getMyId() ) );
//			
//			//We assume that the random seeds have already been created.
//			if (event.name == Server.PLAYER_ORDER)
//			{
//				
//				
//				var playerToLeft:int = _gameModel.getPlayerIDToLeftOfPlayer( AppContext.gameCtrl.game.getMyId());
//				var playerToRight:int = _gameModel.getPlayerIDToRightOfPlayer( AppContext.gameCtrl.game.getMyId());
//				
//				trace("playerToLeft="+playerToLeft);
//				trace("playerToRight="+playerToRight);
//				
//				//These should request an update if the player id changes.
//				if(leftBoardDisplay._boardRepresentation.playerID != playerToLeft)
//				{
//					leftBoardDisplay._boardRepresentation.playerID = playerToLeft;
//					
//				}
//				
//				if(rightBoardDisplay._boardRepresentation.playerID != playerToRight)
//				{
//					rightBoardDisplay._boardRepresentation.playerID = playerToRight;
//				}
//			}
//			
//		}
		
		

		
		
		private var allOpponentsView:AllOpponentsView;
		
		private var _boardsView :JoinGameBoardsView;
		
//		private var myBoardDisplay:JoinGameBoardGameArea;
//		private var leftBoardDisplay:JoinGameBoardGameArea;
//		private var rightBoardDisplay:JoinGameBoardGameArea;
		
		
		/*This variable represents the entire game state */
		private var _gameModel: JoinGameModel;
	
	}
}
