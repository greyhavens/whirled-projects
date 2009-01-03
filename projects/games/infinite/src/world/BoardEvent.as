package world
{
	import arithmetic.BoardCoordinates;
	
	import flash.events.Event;

	public class BoardEvent extends Event
	{
		public var position:BoardCoordinates;
		
		public function BoardEvent(type:String, position:BoardCoordinates)
		{
			super(type);
			this.position = position;
		}
		
        public static const CELL_UPDATED:String = "cell_updated";       		
	}
}