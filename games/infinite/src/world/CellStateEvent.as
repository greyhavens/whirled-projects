package world
{
	import flash.events.Event;
	
	import server.Messages.CellState;
	
	import world.level.Level;

	public class CellStateEvent extends Event
	{
		public var level:Level;
		public var cell:Cell;
		
		public function CellStateEvent(type:String, level:Level, cell:Cell)
		{
			super(type);
			this.level = level;
			this.cell = cell;
		}
	
		public static const STATE_CHANGED:String = "state_changed";			
	}
}