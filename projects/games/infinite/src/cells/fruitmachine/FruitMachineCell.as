package cells.fruitmachine
{
	import arithmetic.*;
	
	import cells.BackgroundCell;
	import cells.CellCodes;
	import cells.CellInteractions;
	
	import client.ChronometerEvent;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import items.*;
	
	import server.Messages.CellState;
	
	import world.Cell;
	import world.Chronometer;
	
	public class FruitMachineCell extends BackgroundCell
	{
		public function FruitMachineCell (state:CellState)
		{
			super(state.position);
			_box = new ObjectBox(item(state.attributes.item));
			_mode = state.attributes.mode;
			_inception = state.attributes.inception; 
		}

        override public function get state () :CellState
        {
        	const created:CellState = super.state;
        	created.attributes = {
        		mode: mode,
        		item: _box.item.attributes,
        		inception: _inception
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
			distributeState();
			startRollingTimer();
		}
		
		/**
		 * Handle the completion of rolling.
		 */
		protected function rollComplete (event:TimerEvent) :void
		{
			mode = DEFUNCT;
			distributeState();
			_box.giveObjectTo(_player);
		}

		protected function set mode (mode:int) :void
		{
			_mode = mode;
		}
		
		protected function get mode () :int 
		{
			return _mode;
		}

        public static function withItemAt (position:BoardCoordinates, item:Item) :Cell
        {
            const state:CellState = new CellState(CellCodes.FRUIT_MACHINE, position);
            state.attributes = {
                mode: FruitMachineCell.ACTIVE,
                item: item.attributes,
                inception: (new Date().getTime()) - (Math.random() * 10000)
            };
            return new FruitMachineCell(state);
        }
        
        /**
         * Return the fruit machine state at a given time.
         */         
        public function stateAt(time:Number) :int
        {
        	// if the mode attribute has been set to one of the static values, we return that.
        	if (_mode == ROLLING || _mode == DEFUNCT) {
        		return _mode;
        	}
        
            if ( (((time - _inception) / ACTIVATION_DELAY) % 2) > 1 ) {
            	return ACTIVE;
            } else {
            	return INACTIVE;
            }        	
        }
        
        /**
         * handle an in-situ state change sent from the server.
         */
        override protected function changeState (clock:Chronometer, state:CellState) :void
        {
        	// we only care about the mode.  The item can't be changed, nor can the inception time.
        	_mode = state.attributes.mode;
        	dispatchEvent(new ChronometerEvent(clock.serverTime));        	
        }

        public function get period () :Number
        {
            return ACTIVATION_DELAY;
        }

        public function get inception () :Number
        {
            return _inception;
        }

        protected var _inception: Number;

        protected var _box:ObjectBox;

		protected var _mode:int;
	
		protected var _timer:Timer;
	
		protected var _player:CellInteractions;
	
	    protected static const _factory:ItemFactory = new ItemFactory(); 
	
	    public static const DYNAMIC:int = 0;
		public static const INACTIVE:int = 1;
		public static const ACTIVE:int = 2;
		public static const ROLLING:int = 3;
		public static const DEFUNCT:int = 4;
		
		public static const ACTIVATION_DELAY:int = 10000; // 10 seconds between state changes
		public static const ROLL_PERIOD:int = 3000; // the machine rolls for 5 seconds			
	}
}