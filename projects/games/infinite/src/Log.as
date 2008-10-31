package
{
	import com.whirled.game.GameControl;
	
	public class Log
	{
        public static var id:String = "unknown";
        
		public static function debug(message:String) :void
		{
			trace (id + ": "+message);
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