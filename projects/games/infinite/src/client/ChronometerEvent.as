package client
{
	import flash.events.Event;

    /**
     * An event that is fired when a timer that is operating in server time goes off.
     */
	public class ChronometerEvent extends Event
	{
	    public var serverTime:Number;
	    
		public function ChronometerEvent(serverTime:Number)
		{
			super(INSTANT);
			this.serverTime = serverTime;
		}			

		public static const INSTANT:String = "instant";		
	}
}