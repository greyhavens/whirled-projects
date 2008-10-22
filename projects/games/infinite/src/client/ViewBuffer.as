package client
{
	import arithmetic.BoardCoordinates;
	
	import cells.views.CellView;
	
	import flash.utils.Dictionary;
	
	public class ViewBuffer
	{
		public function ViewBuffer()
		{
		}
		
		/**
		 * Store a view in the buffer at its coordinates.
		 */
		public function store (position:BoardCoordinates, view:CellView) :void
		{
			_dictionary[position.key] = view;
		}

		public function find (position:BoardCoordinates) :CellView
		{
		  const found:CellView = _dictionary[position.key] as CellView;
          if (found == null) throw new Error("the viewbuffer doesn't contain a view for "+position);          
          return found;
		}
		
		/**
		 * Remove a view from the buffer and return it.
		 */
		public function take (position:BoardCoordinates) :CellView
		{
			const found:CellView = find(position);
            delete _dictionary[position];
			return found;
		}
		
		protected const _dictionary:Dictionary = new Dictionary();
	}
}