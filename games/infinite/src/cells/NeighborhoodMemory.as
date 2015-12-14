package cells
{
	import arithmetic.BoardCoordinates;
	import arithmetic.Vicinity;
	
	import flash.utils.Dictionary;
	
	import world.Cell;
	
	public class NeighborhoodMemory implements CellMemory
	{
		public function NeighborhoodMemory()
		{
		}

        public function remember (cell:Cell) :void
        {
        	_cells[cell.position.key] = cell;
        	findStore(cell.position.vicinity).remember(cell);
        }
        
        public function forget (cell:Cell) :void
        {
        	delete _cells[cell.position.key]
        	findStore(cell.position.vicinity).forget(cell);
        }
        
        public function recall (position:BoardCoordinates) :Cell
        {
        	return _cells[position.key] as Cell;
        }
        
        public function inVicinity (vicinity:Vicinity) :Array
        {
        	return findStore(vicinity).array;
        }
        
        protected function findStore (vicinity:Vicinity) :Store
        {
        	const key:String = vicinity.key();
        	var store:Store = _vicinities[key] as Store;
        	if (store == null) {
        		store = new Store();
        		_vicinities[key] = store;
        	}
        	return store;
        }

        protected const _cells:Dictionary = new Dictionary();
        protected const _vicinities:Dictionary = new Dictionary();
	}
	
}

import flash.utils.Dictionary;
import world.Cell;	

class Store {
	
	public function remember (cell:Cell) :void
	{
	   if (dictionary[cell.position.key] != null) {
	       array[dictionary[cell.position.key]] = cell;	
	   } else {	   
           dictionary[cell.position.key] = array.push(cell);
       }		
	}
	
	public function forget (cell:Cell) :void
	{
		if (dictionary[cell.position.key] != null) {
			delete array[dictionary[cell.position.key]];
			delete dictionary[cell.position.key];
		}
	}
		
	protected const dictionary:Dictionary = new Dictionary();
	public const array:Array = new Array();
} 
