package joingame
{
	public class Constants
	{
		public static const NORMAL_COLOR:Number = 0xff9933;
		public static const MOUSE_OVER_COLOR:Number = 0x1add25;
		

		
		public static const PUZZLE_HEIGHT :int = 500;
		
		public static const PUZZLE_STARTING_COLS :int = 6;
		public static const PUZZLE_STARTING_ROWS :int = 8;
		
		public static const MAX_BUILDING_SIZE :int = 500; 
		
		public static const PUZZLE_TILE_SIZE :int = 40;
		public static const PUZZLE_TILE_SIZE_WHEN_DEAD :int = 10;
		
		public static const CONNECTION_MINIMUM :int = 4; 

		
		
		
		public static const HEALING_ALLOWED :Boolean = true;
		
		public static const ENCLOSED_UNCONNECTABLE_REGIONS_BECOME_DEAD :Boolean = true;
		
		public static const MINIMUM_PIECES_TO_STAY_ALIVE :int = 4;
		
		public static const MAXIMUM_BOARD_SIZE :int = 500;    
		
		public static const CONTROL_MODE_ADJACENT :int = 1;
		public static const CONTROL_MODE_SELECTED :int = 2;
		
		public static const TIME_UNTIL_DEAD_BOTTOM_ROW_REMOVAL :int = 8000;
		
		
		//Piece data
		public static const PIECE_TYPE_NORMAL :int = 0;
		public static const PIECE_TYPE_DEAD :int = 1; //Destroyed pieces
		public static const PIECE_TYPE_EMPTY :int = 2; //
		public static const PIECE_TYPE_INACTIVE :int = 3; //Placeholder, for pieces that are used to fill the array, but are not in the game, e.g. when building a few peces on top
		public static const PIECE_TYPE_POTENTIALLY_DEAD :int = 4; //Normal pieces that cannot be moved due to no possible joins
		
		public static const PIECE_COLOR_DEAD :int = 0x747474;
		public static const PIECE_COLOR_EMPTY :int = 0xffffff;
		public static const PIECE_COLOR_POTENTIALLY_DEAD :int = 0x999999;
		
		public static const PIECE_COLORS_ARRAY:Array = new Array(0x1add25, 0xf2ab11, 0x1161f2, 0xf211ab, 0x00dcff);
		
		
		public static const ATTACK_LEFT :int = -1;
		public static const ATTACK_RIGHT :int = 1;
		public static const ATTACK_BOTH :int = 0;
		
		//GUI COnfig
		public static const GUI_DISTANCE_BOARD_FROM_LEFT: int = 30;
		public static const GUI_BETWEEN_BOARDS: int = 40;
		public static const GUI_BOARD_FLOOR_GAP: int = 0;//60;
		
		
		
	}
}
 
 
 
