package
{
	import com.threerings.util.*;
	import com.whirled.game.*;
	
	import com.whirled.contrib.simplegame.*;
	import com.whirled.contrib.simplegame.audio.AudioManager;
	import com.whirled.contrib.simplegame.resource.*;
	import com.whirled.contrib.simplegame.util.Rand;
	import com.whirled.game.GameControl;

	import flash.display.Sprite;
	import flash.events.Event;
	
	import joingame.view.AllOpponentsView;
	import joingame.modes.*;
	import joingame.*;
	
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	
	
	[SWF(width="700", height="500", frameRate="30")]
	public class JoinGame extends Sprite
	{
		
		public function JoinGame()
		{
			AppContext.mainSprite = this;

	        // setup GameControl
	        AppContext.gameCtrl = new GameControl(this, true);
	        var isConnected :Boolean = AppContext.gameCtrl.isConnected();
			
			graphics.clear();
	        this.graphics.beginFill(0);
	        this.graphics.drawRect(0, 0, 650, 450);
	        this.graphics.endFill();
	
	        this.addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);
	
//	
//			AppContext.gameCtrl.net.sendMessage(Server.PLAYER_READY, {}, NetSubControl.TO_SERVER_AGENT);
//			
//			return;
	
	        // setup main loop
	        AppContext.mainLoop = new MainLoop(this, (isConnected ? AppContext.gameCtrl.local : this.stage));
	        AppContext.mainLoop.setup();
	
		        // custom resource factories
//		        ResourceManager.instance.registerResourceType("level", LevelResource);
////////////////???????????????
//		        ResourceManager.instance.registerResourceType("gameData", GameDataResource);
//		        ResourceManager.instance.registerResourceType("gameVariants", GameVariantsResource);
		
		        // sound volume
//		        AudioManager.instance.masterControls.volume(Constants.SOUND_MASTER_VOLUME);
		
		        // create a new random stream for the puzzle
		        AppContext.randStreamPuzzle = Rand.addStream();
		

		        AppContext.mainLoop.pushMode(new WaitingForReadyPlayersMode());
		        AppContext.mainLoop.pushMode(new LoadingMode());
		        AppContext.mainLoop.run();
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			//create a main instance of the gameController class
//			_control = new GameControl(this);
//		
//			trace("testing");
//			if (!_control.isConnected())
//			{
//				// zoiks! no Whirled
//				// display a splash screen and exit
////				return;
//			}
			
			// listen for an unload event
//			root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);
						
			// send property change notifications to the propertyChanged() method
//			_control.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);
	
			// send incoming message notifications to the messageReceived() method
//			_control.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
			
			
	
//			graphics.clear();
//			graphics.beginFill( 0xffffff, 1 );			
//			graphics.drawRect( 0 , 0 , _control.local.getSize().x, _control.local.getSize().y);
//			graphics.endFill();
//			mouseEnabled = true;
			
//			myBoardDisplay = new JoinGameBoardDisplay( _control, true);
//			myBoardDisplay._boardRepresentation.playerID = _control.game.getMyId();
//			addChild(myBoardDisplay);
//			
//			leftBoardDisplay = new JoinGameBoardDisplay(_control, false);
//			addChild(leftBoardDisplay);
//			
//			rightBoardDisplay = new JoinGameBoardDisplay(_control, false);
//			addChild(rightBoardDisplay);
//			
//			updateGameField();
//			
//			allOpponentsView = new AllOpponentsView(_control);
//			addChild(allOpponentsView);
			
			
		}
		
//		protected function handleUnload (...ignored) :void
//		{
//			AppContext.mainLoop.shutdown();
//		}
		

		

//		/**
//		 * This is called when your game is unloaded.
//		 */
		protected function handleUnload (event :Event) :void
		{
			// stop any sounds, clean up any resources that need it
//			 _inputFieldVerticalJoinsNeededForAddRow.removeEventListener(KeyboardEvent.KEY_DOWN, keyEventHandler);
		}
		
		
//		/** Responds to property changes. */
//		public function propertyChanged (event :PropertyChangedEvent) :void
//		{
//			if (event.name == Server.PLAYER_ORDER)
//			{
////				LOG("\nReceived player order ");
//				_playerIDsInOrderOfPlay = event.newValue as Array;
////				LOG("_playerIDsInOrderOfPlay="+_playerIDsInOrderOfPlay);
//				
//				
//				var playerToLeft:int = Server.getPlayerIDToLeft( _control.game.getMyId(), _playerIDsInOrderOfPlay);
//				var playerToRight:int = Server.getPlayerIDToRight( _control.game.getMyId(), _playerIDsInOrderOfPlay);
//				
//				//These should request an update if the player id changes.
//				if(leftBoardDisplay._boardRepresentation.playerID != playerToLeft)
//				{
//					leftBoardDisplay._boardRepresentation.playerID = playerToLeft;
//				}
//				
//				if(rightBoardDisplay._boardRepresentation.playerID != playerToRight)
//				{
//					rightBoardDisplay._boardRepresentation.playerID = playerToRight;
//				}
//			}
//			
//			
//		}
		
		
//		public var _control :GameControl;
	
		//The game is played in a circle.  As players are eliminated.		
//		private var _playerIDsInOrderOfPlay: Array;	
//		
//		private var allOpponentsView:AllOpponentsView;
//		
//		private var myBoardDisplay:JoinGameBoardDisplay;
//		private var leftBoardDisplay:JoinGameBoardDisplay;
//		private var rightBoardDisplay:JoinGameBoardDisplay;


		//If we are having problems with the alpha server side code, we can run like a non-server-side game 
		private var server: Server;
		
	}
	

}