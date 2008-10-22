package cells.debug
{
	import arithmetic.*;
	
	import cells.CellBase;
	import cells.CellCodes;
	
	import flash.display.DisplayObject;
    import world.Cell;

	/**
	 * A debug cell just shows its coordinates within the board.
	 */
	public class DebugCell extends CellBase implements Cell
	{		
		public function DebugCell (position:BoardCoordinates)
		{
			super(position);
		}
		
		override public function get type () :String
		{
			return "debug";
		}
		 
		override public function get code () :int
		{
			return CellCodes.DEBUG;
		}
		 
        override public function get climbLeftTo() :Boolean { return true; }
        override public function get climbRightTo() :Boolean { return true; }
				 
		protected var _view :DisplayObject;
						
		protected const DEBUG:Boolean = false;
	}
}