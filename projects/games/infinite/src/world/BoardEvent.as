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
	
	    override public function clone () :Event
	    {
	        return new BoardEvent(type, position);
	    }
		
        public static const CELL_REPLACED:String = "cell_replaced";       		
	}
}