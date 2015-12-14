package cells
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	
	/**
	 * Represents an empty cell in the gameboard.
	 */
	public class EmptyCell extends CellBase implements Cell
	{			
		public function EmptyCell (position:BoardCoordinates)
		{
			_position = position;
		}

		public function get view () :DisplayObject
		{
			// create a grey filled rectangle and return it
			const s:Shape = new Shape();
			with (s.graphics) {
				beginFill("0x808080", 1.0);
				drawRect(0,0, CELL_WITH, CELL_HEIGHT);
				endFill();
			}			
			return s;
		}
		
		public function get position () :BoardCoordinates
		{
			return _position;
		}	
		
		protected var _position:BoardCoordinates;
	}
}