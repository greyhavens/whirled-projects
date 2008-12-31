package arithmetic
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import server.Messages.Neighborhood;
	
	import world.NeighborhoodEvent;
	
	/**
	 * Track whether a particular area has been visited or not.
	 */
	public class BreadcrumbTrail extends EventDispatcher
	{
		public function BreadcrumbTrail()
		{
		}
		
		/**
		 * Request that the area around the given region be mapped.  A Neighborhood event listing
		 * the unmapped regions is generated if so.
		 */
		public function map (coords:BoardCoordinates) :void
		{
			Log.debug("breadcrumb trail mapping "+coords);
			const unmapped:Neighborhood = visit(coords);
			if (! unmapped.isEmpty()) {
				Log.debug("dispatching Neighborhood unmapped event");
				dispatchEvent(new NeighborhoodEvent(NeighborhoodEvent.UNMAPPED, unmapped));
			}
		}
		
		/**
		 * Register a visit to a particular set of coordinates.  Return a neighborhood of nearby
		 * unmapped regions.
		 */
		public function visit (coords:BoardCoordinates) :Neighborhood 
		{
			const unmapped:Neighborhood = new Neighborhood();
			for each (var hood:Vicinity in coords.vicinity.vicinitiesNearby)
			{
				var key:String = hood.key();
				if (_visited[key] == null) {
					unmapped.add(hood);
					_visited[key] = true;
				}
			}
			return unmapped;
		}

        /**
         * Mark a list of vicinities as mapped.  Used when receiving updates that occur as a result of requests
         * by other clients.
         */ 
        public function markAsMapped (vicinities:Array) :void
        {
            Log.debug("marking cells as mapped.");
            for each (var vicinity:String in vicinities) {
                Log.debug("marking as mapped: "+vicinity);
                _visited[vicinity] = true;
            }
        }
		
		protected const _visited:Dictionary = new Dictionary();
	}
}