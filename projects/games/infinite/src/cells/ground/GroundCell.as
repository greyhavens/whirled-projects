package cells.ground
{
	import arithmetic.*;
	
	import cells.BackgroundCell;
	import cells.CellCodes;
	
	public class GroundCell extends BackgroundCell
	{
		public function GroundCell(position:BoardCoordinates)
		{
			super(position);
		}
		
		override public function get code () :int
		{
			return CellCodes.GROUND;
		}
		
		override public function get type () :String
		{
			return "ground";
		}				
		
		[Embed(source="../../../rsrc/png/ledge-ground-cell.png")]
		public static const ledgeGroundCell:Class; 
	}
}