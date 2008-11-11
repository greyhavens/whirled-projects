package cells.fruitmachine
{
	import sprites.CellSprite;
	
	import world.Cell;

	public class FruitMachineView extends CellSprite
	{
		public function FruitMachineView(cell:Cell, time:Number)
		{
			super(cell, imageForTime (cell as FruitMachineCell, time));
		}
						
		protected function imageForTime (cell:FruitMachineCell, time:Number) :Class
		{
			const state:int = cell.stateAt(time);
			switch (state) {
     			case FruitMachineCell.INACTIVE: return fruitMachineInactive;
				case FruitMachineCell.ACTIVE: return fruitMachineActive;
				case FruitMachineCell.ROLLING: return fruitMachineRolling;
				case FruitMachineCell.DEFUNCT: return fruitMachineDefunct;
			}		
			throw new Error("don't understand fruit machine mode: "+state);
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
