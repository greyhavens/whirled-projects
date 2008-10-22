package cells.fruitmachine
{
	import flash.events.Event;	
	import sprites.CellSprite;
    import world.Cell;

	public class FruitMachineView extends CellSprite
	{
		public function FruitMachineView(cell:Cell)
		{
			super(cell, imageForMode(cell as FruitMachineCell));
			listenForAddAndRemove(add, remove);			
		}
		
		protected function listenForAddAndRemove (add:Function, remove:Function) :void
		{
			addEventListener(Event.ADDED, add);
			addEventListener(Event.REMOVED, remove);			
		}		
		
		protected function add(event:Event) :void
		{
			cell.addEventListener(FruitMachineEvent.STATE_CHANGED, change);
		}
		
		protected function remove(event:Event) :void
		{
			cell.removeEventListener(FruitMachineEvent.STATE_CHANGED, change);
		}
		
		protected function change(event:FruitMachineEvent) :void
		{
			asset = imageForMode(event.cell);
		}
		
		protected function imageForMode (cell:FruitMachineCell) :Class
		{
			switch (cell.mode) {
     			case FruitMachineCell.INACTIVE: return fruitMachineInactive;
				case FruitMachineCell.ACTIVE: return fruitMachineActive;
				case FruitMachineCell.ROLLING: return fruitMachineRolling;
				case FruitMachineCell.DEFUNCT: return fruitMachineDefunct;
			}		
			throw new Error("don't understand fruit machine mode: "+cell.mode);
		} 

		[Embed(source="../../../rsrc/png/fruit-machine-inactive.png")]
		protected static const fruitMachineInactive:Class;
		
		[Embed(source="../../../rsrc/png/fruit-machine.png")]
		protected static const fruitMachineActive:Class;
		
		[Embed(source="../../../rsrc/png/fruit-machine-rolling.png")]
		protected static const fruitMachineRolling:Class;
		
		[Embed(source="../../../rsrc/png/fruit-machine-defunct.png")]
		protected static const fruitMachineDefunct:Class;		}
}
