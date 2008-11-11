package cells.fruitmachine
{
	import arithmetic.*;
	
	import cells.BackgroundCell;
	import cells.CellCodes;
	import cells.CellInteractions;
	
	import client.CellEvent;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import items.*;
	
	import server.Messages.CellState;
	
	import world.Cell;
	
	public class FruitMachineCell extends BackgroundCell
	{
		public function FruitMachineCell (state:CellState)
		{
			super(state.position);
			_box = new ObjectBox(item(state.attributes.item));
			mode = state.attributes.mode;
			
			// we don't need to remove these listeners because the cell itself is the dispatcher.
			addEventListener(CellEvent.ADDED_TO_OBJECTIVE, handleAdded);
			addEventListener(CellEvent.REMOVED_FROM_OBJECTIVE, handleRemoved);			
		    
		}

        override public function get state () :CellState
        {
        	const created:CellState = super.state;
        	created.attributes = {
        		mode: mode,
        		item: _box.item.attributes
        	}
        	return created;
        }

        protected function item (itemAttributes:Object) :Item
        {
        	return _factory.makeItem(itemAttributes);
        }
				
		override public function get code () :int
		{
			return CellCodes.FRUIT_MACHINE;
		}
		
		override public function get type () :String
		{
			return "fruit machine";
		}

		/**
		 * When a fruit machine is added to the objective, it starts a timer to control its state.
		 */
		protected function handleAdded (event:CellEvent) :void
		{
			if (_mode == ACTIVE || _mode == INACTIVE) {
				startActivationTimer();
			}
		}
		
		/**
		 * When a fruit machine is removed from the objective, its timer is stopped and removed.
		 */
		protected function handleRemoved (event:CellEvent) :void
		{
			stopTimer();
		}

		/**
		 * Start a new repeating timer which determines when the machine opens and closes.
		 */
		protected function startActivationTimer () :void
		{
			_timer = new Timer(ACTIVATION_DELAY, 0);
			_timer.addEventListener(TimerEvent.TIMER, switchActivation);
			_timer.start();
		}
		
		/**
		 * Start a new single shot timer which determines when the rolling period finishes.
		 */
		protected function startRollingTimer () :void
		{
			_timer = new Timer(ROLL_PERIOD, 1);
			_timer.addEventListener(TimerEvent.TIMER, rollComplete);
			_timer.start();
		}
		
		/**
		 * Stop and discard the associated timer.
		 */
		protected function stopTimer () :void
		{
			if (_timer != null) {
				_timer.stop();
				_timer = null;			
			}
		}
		
		/**
		 * Handle a timer going off by activating or deactivating the machine. 
		 */
		protected function switchActivation (event:TimerEvent) :void
		{
			if (isActive()) {
				deactivate();
			} else {
				activate();
			}
		}

		public function isActive () :Boolean
		{
			return _mode == ACTIVE;	
		}

		/**
		 * Activate the fruit machine so that it can hand out objects.
		 */
		public function activate () :void
		{
			if (_player == null ||  !_player.canReceiveItem()) {
				mode = ACTIVE;
			} else {
				rollWheel();
			} 						
		}
		
		/**
		 * Deactivate the fruit machine so that it will no longer hand out objects. 
		 */
		public function deactivate () :void
		{
			mode = INACTIVE;
		}

		override public function get climbRightTo () :Boolean
		{
			return true;			
		}

		override public function get climbLeftTo () :Boolean
		{
			return true;
		}

		/**
		 * The player may leave a fruit machine if the machine is not rolling.
		 */
		override public function get leave () :Boolean
		{
			return (_mode != ROLLING);
		}

		override public function playerHasArrived (player:CellInteractions) :void
		{
			_player = player;
			Log.debug ("the player has arrived within the fruit machine");
			if (!isActive()) {
				return;			
			}
			
			if (_player.canReceiveItem()) {
				rollWheel();
			}
		}
		
		override public function playerBeginsToDepart ():void
		{
			_player = null;
		}
		
		/**
		 * Choose an object to give to a player who is currently at the machine.
		 */
		protected function rollWheel () :void
		{
			Log.debug ("rolling fruit machine");
			stopTimer();
			mode = ROLLING;
			startRollingTimer();
		}
		
		/**
		 * Handle the completion of rolling.
		 */
		protected function rollComplete (event:TimerEvent) :void
		{
			mode = DEFUNCT;
			_box.giveObjectTo(_player);
		}

		public function set mode (mode:int) :void
		{
			if (mode != _mode) {
				_mode = mode;
				dispatchEvent(new FruitMachineEvent(FruitMachineEvent.STATE_CHANGED, this));
			}
		}
		
		public function get mode () :int 
		{
			return _mode;
		}

        public static function withItemAt (position:BoardCoordinates, item:Item) :Cell
        {
            const state:CellState = new CellState(CellCodes.FRUIT_MACHINE, position);
            state.attributes = {
                mode: FruitMachineCell.ACTIVE,
                item: item.attributes
            };
            return new FruitMachineCell(state);
        }

        protected var _box:ObjectBox;

		protected var _mode:int;
	
		protected var _timer:Timer;
	
		protected var _player:CellInteractions;
	
	    protected static const _factory:ItemFactory = new ItemFactory(); 
	
		public static const INACTIVE:int = 0;
		public static const ACTIVE:int = 1;
		public static const ROLLING:int = 2;
		public static const DEFUNCT:int = 3;
		
		public static const ACTIVATION_DELAY:int = 10000; // 10 seconds between state changes
		public static const ROLL_PERIOD:int = 3000; // the machine rolls for 5 seconds			
	}
}