package world.level
{
	import arithmetic.BoardCoordinates;
	import arithmetic.BoardRectangle;
	import arithmetic.BreadcrumbTrail;
	import arithmetic.Vicinity;
	
	import cells.fruitmachine.FruitMachineCell;
	
	import world.Cell;
	import world.NeighborhoodEvent;
	import world.board.BoardInteractions;
	
	public class MapMaker
	{
		public function MapMaker(board:BoardInteractions, explored:BreadcrumbTrail)
		{
			_board = board;
			explored.addEventListener(NeighborhoodEvent.UNMAPPED, handleUnmappedNeighborhood);
		}
		
		protected function handleUnmappedNeighborhood(event:NeighborhoodEvent) :void
		{
			Log.debug("received neigborhood unmapped event for "+event.hood);
			for each (var vicinity:Vicinity in event.hood.vicinities) {
				createMap(vicinity.region);
			}
		}
		
		protected function createMap (region:BoardRectangle) :void
		{
			Log.debug("creating map for "+region);
			// create boxes for the equivalent of one row of squares, only at random positions
			// in the square.
			for (var i:int = 0; i < Vicinity.SQUARE << 1; i++) {
				var location:BoardCoordinates = region.randomLocation();
                var candidate:Cell = _board.cellAt(location);
                if (candidate.replacable) {
                	_board.replace(FruitMachineCell.withItemAt(location, 
                        ObjectBox.random().item));
                }	
			}			
		}
    
        protected var _board:BoardInteractions;        
	}
}