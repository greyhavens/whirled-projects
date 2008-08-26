package joingame.view
{
	import flash.display.Sprite;
	import com.whirled.game.*;
	
	import com.threerings.util.*;
	
	import flash.display.DisplayObject;
	
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import com.whirled.net.PropertyChangedEvent;
	import com.whirled.game.NetSubControl;
	
	public class AllOpponentsView extends Sprite
	{
		public function AllOpponentsView(control:GameControl)
		{
			_control = control;
			
			_playerIdToHeadShotMap = new HashMap();
			_playerHeadshotPositionInPyramid = new Array();
			
			// send property change notifications to the propertyChanged() method
			_control.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);
		}
		
		
		/** Responds to property changes. */
		public function propertyChanged (event :PropertyChangedEvent) :void
		{
			if (event.name == Server.PLAYER_ORDER)
			{
//				LOG("\nReceived player order ");
				_playerIDsInOrderOfPlay = event.newValue as Array;
//				LOG("_playerIDsInOrderOfPlay="+_playerIDsInOrderOfPlay);
				
				for(var i: int = 0; i < _playerIDsInOrderOfPlay.length;i++)
				{
					var id:int = _playerIDsInOrderOfPlay[i] as int;
					if( !_playerIdToHeadShotMap.containsKey(id))
					{
						_playerIdToHeadShotMap.put(id, _control.local.getHeadShot( id));
					}
					
				}
 				
 				//Make sure there are arrays smaller than this one
 				for(var v:int = 0; v < _playerIDsInOrderOfPlay.length; v++)
				{
					if(_playerHeadshotPositionInPyramid[v] == null)
					{
						var tmpArray: Array = new Array();
						for(var k: int = 0; k < v+1; k++)
						{
							tmpArray.push(null);
						}
						_playerHeadshotPositionInPyramid[v] = tmpArray;
					}
				}
 				_playerHeadshotPositionInPyramid[_playerIDsInOrderOfPlay.length - 1] = ArrayUtil.copyOf(_playerIDsInOrderOfPlay);
 				
 				createOrUpdateOtherPlayerDisplay(); 	
				
			}
			
			
		}
		
		
		private function createOrUpdateOtherPlayerDisplay(): void
		{
			this.x = 30;
			this.y = 80;
			this.scaleX = 0.3;
			this.scaleY = 0.3;
				
			var headshot: DisplayObject;
			
			var ids:Array = _playerIdToHeadShotMap.keys();
			for( var i:int = 0; i < ids.length;i++)
			{
				var id:int = ids[i] as int;
				headshot = _playerIdToHeadShotMap.get(id) as DisplayObject; 
				
				if( headshot != null)
				{
					this..addChild(headshot);
				}
			}
		
		
			//Start drawing the players at the bottom, updating for the higher levels
			var HEADSHOT_SIZE:int = 80;
			var currentXAddition: int  = 0;
			for(var pyramidIndex:int = _playerHeadshotPositionInPyramid.length - 1; pyramidIndex >= 0; pyramidIndex--)
			{
				var playerIDArray: Array = _playerHeadshotPositionInPyramid[ pyramidIndex] as Array;
				
				if(playerIDArray != null)
				{
					for( var headshotArrayIndex: int = 0; headshotArrayIndex < playerIDArray.length; headshotArrayIndex++)
					{
						this.graphics
//						_playersDisplay.graphics.beginFill( 0xab6300, 1 );
						this.graphics.lineStyle(2, 0x000000);
						var boxsize: int = 15;
						this.graphics.drawRect( headshotArrayIndex*HEADSHOT_SIZE+currentXAddition - boxsize/2, pyramidIndex*HEADSHOT_SIZE -boxsize/2 ,boxsize, boxsize);
						this.graphics.endFill();
						
						
						headshot = _playerIdToHeadShotMap.get( playerIDArray[headshotArrayIndex] ) as DisplayObject;
						if(headshot != null)
						{
							headshot.x = headshotArrayIndex*HEADSHOT_SIZE+ currentXAddition - headshot.width/2;
							headshot.y = pyramidIndex*HEADSHOT_SIZE - headshot.height/2;
						}
						
						
					}
				}
				
				//If there is a player at the top, draw the winner sign
				if(pyramidIndex == 0 && playerIDArray[0] != null)
				{
					// Text format
				        var format :TextFormat = new TextFormat();
				        format.font = "Arial";
				        format.size = 12;
				        format.color = 0xff0033;
				        format.bold = true;
				        
				        
				        // Input field
				        var winnerText:TextField= new TextField();
				        winnerText.defaultTextFormat = format;
				        winnerText.text = "WINNER!!!!!";
				        winnerText.x = headshotArrayIndex*HEADSHOT_SIZE+ currentXAddition - 200;
				        winnerText.y = pyramidIndex*HEADSHOT_SIZE - 40;
				        winnerText.width = 100;
				        winnerText.height = winnerText.textHeight + 2;
				        winnerText.type = TextFieldType.DYNAMIC;
				        winnerText.border = false;
				        this.addChild(winnerText);

				}
				currentXAddition += HEADSHOT_SIZE/2;
			}
		}
		
		
		public var _control :GameControl;
	
		//The game is played in a circle.  As players are eliminated.		
		private var _playerIDsInOrderOfPlay: Array;	
		
		protected var _playerIdToHeadShotMap: HashMap;
		
		//Array of arrays of headshots.  The first array is length 1, each other array is bigger by 1.  This 
		//represents a pyramid, with losing players remaining where they are, and others ascending 
		//to a level one smaller than the previous.
		protected var _playerHeadshotPositionInPyramid: Array;
	}
}