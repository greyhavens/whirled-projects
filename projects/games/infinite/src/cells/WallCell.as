package cells
{
	import arithmetic.*;
	
	import interactions.Oilable;
	
	public class WallCell extends WallBaseCell implements Oilable
	{
		public function WallCell(position:BoardCoordinates)
		{
			super(position);
		}
	
		override protected function get initialAsset () :Class
		{
			return wall;
		}			

		public function oiled () :Cell
		{
			return new OiledWallCell(_position);
		}
	
		override public function get type () :String { return "wall"; }	
		
		[Embed(source="png/wall.png")]
		public static const wall:Class;
	}
}