package
{
	import arithmetic.BoardCoordinates;
	
	import flash.utils.Dictionary;
	
	/**
	 * A different kind of cell buffer used by cells that have some state that needs to be remembered
	 * when they would otherwise be scrolled off the board.
	 */
	public class CellDictionary implements CellMemory
	{
		public function CellDictionary()
		{
		}
		
		public function remember (cell:Cell) :void
		{
			// trace ("remembering "+cell+" key: "+cell.position.key);
			_dictionary[cell.position.key] = cell;
		}
		
		public function forget (cell:Cell) :void
		{
			delete _dictionary[cell.position.key];
		}
					
		public function recall (position:BoardCoordinates) :Cell
		{
			return _dictionary[position.key];
		}
			
		protected var _dictionary:Dictionary = new Dictionary();
	}
}