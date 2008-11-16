package cells.fruitmachine
{
    import client.ChronometerEvent;
    import client.PhaseShiftTimer;
    
    import sprites.CellSprite;
    
    import world.Cell;

	public class FruitMachineView extends CellSprite
	{
		public function FruitMachineView(cell:Cell, time:Number)
		{
			super(cell, imageForTime(cell as FruitMachineCell, time));
			cell.addEventListener(ChronometerEvent.INSTANT, handleChronometerEvent);
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

        /**
         * set up timers
         */
        override protected function startAnimation () :void
        {
        	const machine:FruitMachineCell = cell as FruitMachineCell;
            _timer = new PhaseShiftTimer(_objective, machine.inception, machine.period);
            _timer.addEventListener(ChronometerEvent.INSTANT, handleChronometerEvent);
            _timer.start();
        }

        /**
         * When the timer goes off, update the current image from the cell.
         */
        protected function handleChronometerEvent (event:ChronometerEvent) :void
        {
            asset = imageForTime(cell as FruitMachineCell, event.serverTime);
        }
                
        /**
         * Stop the animation if any is running.
         */ 
        override protected function stopAnimation () :void
        {
        	//Log.debug(this + " stopping animation");
            if (_timer != null) {
                _timer.stop();
            }
			cell.removeEventListener(ChronometerEvent.INSTANT, handleChronometerEvent);
        }
        
        override public function toString () :String
        {
        	return "view of "+cell;
        }

        protected var _timer:PhaseShiftTimer;

		[Embed(source="../../../rsrc/png/fruit-machine-inactive.png")]
		protected static const fruitMachineInactive:Class;
		
		[Embed(source="../../../rsrc/png/fruit-machine.png")]
		protected static const fruitMachineActive:Class;
		
		[Embed(source="../../../rsrc/png/fruit-machine-rolling.png")]
		protected static const fruitMachineRolling:Class;
		
		[Embed(source="../../../rsrc/png/fruit-machine-defunct.png")]
		protected static const fruitMachineDefunct:Class;		
	}
}
