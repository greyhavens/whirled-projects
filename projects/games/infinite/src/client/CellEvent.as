package client
{
	import flash.events.Event;
	
	import world.Cell;
	
	public class CellEvent extends Event
	{
		public var cell:Cell;
		
		public function CellEvent(type:String, cell:Cell)
		{
			super(type);
			this.cell = cell;
		}
		
		public static const CELL_CLICKED:String = "cell_clicked";		
		public static const CELL_REPLACED:String = "cell_replaced";
		public static const ADDED_TO_OBJECTIVE:String = "added_to_objective";
		public static const REMOVED_FROM_OBJECTIVE:String = "removed_from_objective";
		public static const STATE_CHANGED:String = "state_changed";
	}
}