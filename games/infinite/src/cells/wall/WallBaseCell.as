package cells.wall
{
	import arithmetic.BoardCoordinates;
	
	import cells.BackgroundCell;
	import cells.CellCodes;
	
	public class WallBaseCell extends BackgroundCell
	{
		public function WallBaseCell(position:BoardCoordinates)
		{
			super(position);
		}
		
		override public function get code () :int
		{
			return CellCodes.WALL_BASE;
		}
	
		override public function get type () :String { return "wall base"; }	
		override public function get climbLeftTo () :Boolean { return true; }
		override public function get climbRightTo () :Boolean { return true; }
		override public function get replacable () :Boolean { return true; }
		override public function get canBecomeWindow() :Boolean { return true; }
        override public function get canBeStartingPosition() :Boolean { return true; }
	}
}