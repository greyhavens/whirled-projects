package cells
{
	import arithmetic.BoardCoordinates;

	public class OiledWallCell extends WallCell
	{
		public function OiledWallCell(position:BoardCoordinates)
		{
			super(position);
		}
		
		override public function get grip () :Boolean
		{
			return false;
		}		
		
		override protected function get initialAsset () :Class
		{
			return oiledWall;
		}

		override public function get type () :String { return "oiled wall"; }	
		
		[Embed(source="../../rsrc/png/wall-oiled.png")]
		public static const oiledWall:Class;
	}
}