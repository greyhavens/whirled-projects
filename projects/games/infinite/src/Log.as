package
{
	import com.whirled.game.GameControl;
	
	public class Log
	{
        public static var id:String = "unknown";
        
        /**
         * Log a debug message indicating the id of the client.
         */
		public static function debug (message:String) :void
		{
			trace (id + ": "+message);
		}

		/**
		 * Log a warning message that stands out from the debug messages.
		 */
		public static function warning (message:String) :void
		{
			trace (id + ": WARNING - "+message);
		}
		
        public static function setId (control:GameControl) :void
        {
        	if (control.isConnected()) {
            	id = String(control.game.getMyId());
            } else {
            	id = "not connected";
            }
        	trace ("set log id to "+id);
        }        
	}
}