package cells.fruitmachine
{
	import flash.events.Event;

	public class FruitMachineEvent extends Event
	{
		public static const STATE_CHANGED:String = "stateChanged";
		
		public function FruitMachineEvent(type:String, cell:FruitMachineCell)
		{
			super(type, bubbles, cancelable);
			_cell = cell;	
		}

		public function get cell () :FruitMachineCell 
		{
			return _cell;
		}

		protected var _cell:FruitMachineCell;		
	}
}