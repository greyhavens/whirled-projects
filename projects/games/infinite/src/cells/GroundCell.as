package cells
{
	import arithmetic.*;
	
	import flash.display.DisplayObject;
	
	public class GroundCell extends BackgroundCell
	{
		public function GroundCell(position:BoardCoordinates)
		{
			super(position);
		}

		override protected function get initialAsset () :Class
		{
			return ledgeGroundCell;
		}
		
		override public function get type () :String
		{
			return "ground";
		}				
		
		[Embed(source="../../rsrc/png/ledge-ground-cell.png")]
		public static const ledgeGroundCell:Class; 
	}
}