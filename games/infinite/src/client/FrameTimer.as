package client
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class FrameTimer extends Timer
	{		
		public function FrameTimer()
		{
			// The frame rate timer creates one tick for every frame, at no more than the
			// maximum frame rate. 
			super(FRAME_INTERVAL);
			
			// create an initial previous frame time that is one interval behind the current time
			const current:Date = new Date();
			_previousTime = new Date();
			_previousTime.time = current.time - FRAME_INTERVAL;
			 
			addEventListener(TimerEvent.TIMER, handleTimerEvent);
		}

		protected function handleTimerEvent(event:TimerEvent) :void
		{
			event.updateAfterEvent();
			const frameEvent:FrameEvent = 
				new FrameEvent(new Date(), _previousTime);
			_previousTime = frameEvent.currentTime;	
			dispatchEvent(frameEvent);
		}

		protected var _previousTime:Date; 

		/** The target frame rate for the game in frames per second **/
		public const FRAME_RATE:int = 50;
		public const FRAME_INTERVAL:int = 1000 / FRAME_RATE;
	}
}