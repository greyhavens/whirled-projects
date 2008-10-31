package world
{
	import flash.events.Event;
	
	import server.Messages.Neighborhood;

	public class NeighborhoodEvent extends Event
	{
		public var hood:Neighborhood;
		
		public function NeighborhoodEvent(type:String, hood:Neighborhood)
		{			
			super(type);
			this.hood = hood;
		}		

        override public function clone () :Event
        {
        	return new NeighborhoodEvent(type, hood);
        }
		
		public static const UNMAPPED:String = "unmapped";
	}
}