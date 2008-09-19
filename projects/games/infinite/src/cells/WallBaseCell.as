package cells
{
	import arithmetic.BoardCoordinates;
	
	public class WallBaseCell extends BackgroundCell
	{
		public function WallBaseCell(position:BoardCoordinates)
		{
			super(position);
		}
		override protected function get initialAsset () :Class
		{
			return wall;
		}			
	
		override public function get type () :String { return "wall base"; }	
		override public function get climbLeftTo () :Boolean { return true; }
		override public function get climbRightTo () :Boolean { return true; }
		override public function get replacable () :Boolean { return true; }
		override public function get canBecomeWindow() :Boolean { return true; }
		
		[Embed(source="png/wall.png")]
		public static const wall:Class;
	}
}