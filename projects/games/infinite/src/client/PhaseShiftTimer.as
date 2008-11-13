package client 
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import world.Chronometer;

    public class PhaseShiftTimer extends Timer 
    {
        /**
         * Create a new PhaseShiftTimer.  This timer acts as though it's been running since the
         * 'inception' time provided with the period given, which means that it's first run time
         * may be shorter or longer than a normal period in order to allow it to synchronize
         * with where it would have been if it had really started at 'inception'.  The inception
         * time is expected to be given in the same timebase as the supplied chronometer.
         */
        public function PhaseShiftTimer (clock:Chronometer, inception:Number, period:Number) 
        {
            // set the initial delay to the computed phase shift and run for one repeat
            super(period - ((clock.serverTime - inception) % period), 1);
            _period = period;
            _clock = clock;
			addEventListener(TimerEvent.TIMER, handlePhaseShift);
		}
				
	    /**
	     * The first time the timer goes off, we set the delay to the normal period, and the repeat
	     * count to go forever, and then switch out the handler, so in future it's just a normal
	     * timer.
	     */
		protected function handlePhaseShift(event:TimerEvent) :void
		{
		    removeEventListener(TimerEvent.TIMER, handlePhaseShift);
		    addEventListener(TimerEvent.TIMER, handleTimerEvent)
		    delay = _period;
		    repeatCount = 0;
		    start();
		    handleTimerEvent(event);
        }

		protected function handleTimerEvent(event:TimerEvent) :void
		{
		    dispatchEvent(new ChronometerEvent(_clock.serverTime));
        }
 
        protected var _clock:Chronometer;
        protected var _period:Number;
    }
}