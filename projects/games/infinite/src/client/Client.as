package client
{
	import arithmetic.Geometry;
	import arithmetic.GraphicRectangle;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import inventory.InventoryDisplay;
	
	import sprites.SpriteUtil;
	
	import world.InfiniteWorld;
	import world.DebugBoard;
	import world.SimpleBoard;
	
	public class Client extends Sprite
	{
		public function Client(world:InfiniteWorld)
		{
			_world = world;
			
			// set the overall size of the game
			SpriteUtil.addBackground(this, GAME_WIDTH, GAME_HEIGHT, SpriteUtil.GREY);
			this.x = 0;
			this.y = 0;			
			
			_viewer = new Viewer(680, 420);
			
			_viewer.x = 10;
			_viewer.y = 10;
			addChild(_viewer);		
			
			_inventory = new InventoryDisplay(680, 50);
			const invView:DisplayObject = _inventory.view;
			invView.x = 10;
			invView.y = 440;			
			addChild(invView);
			
			var frame:GraphicRectangle = GraphicRectangle.fromDisplayObject(this);
			
			const modeView:TextField = new TextField();
			modeView.text = mode + " mode";
			var rect:GraphicRectangle = GraphicRectangle.fromText(modeView).paddedBy(10).alignBottomRightTo(frame);		
			Geometry.position(modeView, rect.origin);
			addChild(modeView);
						
			_frameTimer = new FrameTimer();
			_frameTimer.start();
				
			startGame();			
		}
				
		public function startGame () :void 
		{
			if (Config.boardDebug) {
    			_board = new DebugBoard(LEVEL1);
            } else {
			    _board = new SimpleBoard(LEVEL1);
            }
            
			_player = new PlayerCharacter("robin", _inventory);
			_viewer.board = _board;
			_viewer.player = _player;
			_controller = new PlayerController(_frameTimer, _viewer, _player, _inventory);
			
			trace("game size at end: "+width+", "+height);
		}	
		
		public function get mode () :String 
		{
			return "standalone";
		}	
		
		protected var _world:InfiniteWorld;
		
		protected var _controller:PlayerController;
		protected var _board:Board;
		protected var _viewer:Viewer;
		protected var _inventory:InventoryDisplay;
		protected var _player:PlayerCharacter;
		protected var _frameTimer:FrameTimer;		
		
		protected const GAME_WIDTH:int = 700;
		protected const GAME_HEIGHT:int = 500;
		
		protected const LEVEL1:Level = new Level(50);
	}	
}