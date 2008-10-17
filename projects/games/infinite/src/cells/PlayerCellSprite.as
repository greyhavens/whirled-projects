package cells
{
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import sprites.CellSprite;

	public class PlayerCellSprite extends CellSprite
	{
		public function PlayerCellSprite(cell:Cell, asset:Class)
		{
			super(cell, asset);
		}		
		
		override protected function registerEventHandlers (source:EventDispatcher) :void
		{
			super.registerEventHandlers(source);
			source.addEventListener(MouseEvent.ROLL_OVER, handleRollOver);
			source.addEventListener(MouseEvent.ROLL_OUT, handleRollOut);	
		}
		
		protected function handleRollOver (event:MouseEvent) :void
		{
			_objective.displayOwnership(_cell);
		}
		
		protected function handleRollOut (event:MouseEvent) :void
		{
			_objective.hideOwnership(_cell);
		}
	}
}