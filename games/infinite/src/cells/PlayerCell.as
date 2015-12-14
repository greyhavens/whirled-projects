package cells
{
	import arithmetic.BoardCoordinates;
	
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	public class PlayerCell extends BackgroundCell
	{
		public function PlayerCell(owner:Owner, position:BoardCoordinates)
		{
			super(position);
			_owner = owner;
		}
		
		override public function get owner () :Owner
		{
			return _owner;
		}

		protected var _owner:Owner;
	}
}