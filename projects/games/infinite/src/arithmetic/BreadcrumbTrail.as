package arithmetic
{
	import flash.utils.Dictionary;
	
	import server.Messages.Neighborhood;
	
	/**
	 * Track whether a particular area has been visited or not.
	 */
	public class BreadcrumbTrail
	{
		public function BreadcrumbTrail()
		{
		}
		
		/**
		 * Register a visit to a particular set of coordinates.  Return a neighborhood of nearby
		 * unmapped regions.
		 */
		public function visit (coords:BoardCoordinates) :Neighborhood 
		{
			const unmapped:Neighborhood = new Neighborhood();
			for each (var hood:String in coords.vicinity.neighborhood)
			{
				if (_visited[hood] == null) {
					unmapped.add(hood);
					_visited[hood] = true;
				}
			}
			return unmapped;
		}
		
		protected const _visited:Dictionary = new Dictionary();
	}
}