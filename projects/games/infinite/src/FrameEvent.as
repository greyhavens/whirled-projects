package
{
	import flash.events.Event;

	public class FrameEvent extends Event
	{
		/** the time that this frame starts */
		public var currentTime:Date;
		
		/** the time that the previous frame started */
		public var previousTime:Date;
		
		/** the time between the previous frame and this frame in milliseconds */
		public var duration:int; 
		
		public function FrameEvent(time:Date, previousTime:Date)
		{
			super(FRAME_START);
			this.currentTime = time;
			this.previousTime = previousTime;
			duration = time.time - previousTime.time;
		}			

		/** the number of milliseconds between the given time and this event */
		public function since(start:Date) :int
		{
			return currentTime.time - start.time;
		}

		public static const FRAME_START:String = "frameStart";		
	}
}