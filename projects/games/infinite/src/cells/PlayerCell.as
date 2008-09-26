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
		
		override protected function registerEventHandlers (source:EventDispatcher) :void
		{
			super.registerEventHandlers(source);
			source.addEventListener(MouseEvent.ROLL_OVER, handleRollOver);
			source.addEventListener(MouseEvent.ROLL_OUT, handleRollOut);	
		}
		
		protected function handleRollOver (event:MouseEvent) :void
		{
			_objective.displayOwnership(this);
		}
		
		protected function handleRollOut (event:MouseEvent) :void
		{
			_objective.hideOwnership(this);
		}

		override public function get owner () :Owner
		{
			return _owner;
		}

		protected var _owner:Owner;
	}
}