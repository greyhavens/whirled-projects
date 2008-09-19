package
{
	import flash.display.DisplayObject;
	
	public class CliffEdgeCell extends BackgroundCell
	{
		public function CliffEdgeCell (position:BoardCoordinates) :void
		{
			super(position);
		}
		
		override protected function makeAsset () :DisplayObject
		{
			return new BackgroundPanels.cliffEdge();
		}
	}
}