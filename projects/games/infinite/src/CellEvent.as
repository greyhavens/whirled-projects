package
{
	import flash.events.Event;
	
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
	}
}