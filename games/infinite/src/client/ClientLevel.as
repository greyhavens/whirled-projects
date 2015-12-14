package client
{
    import com.whirled.game.NetSubControl;
        
	public class ClientLevel extends SlotObject
	{
		public var number:int;
		
		public function ClientLevel(control:NetSubControl, number:int)
		{
		    super (control, "level", String(number));
			this.number = number;			
		}

        public function set height (value:int) :void
        {
            writeInt(HEIGHT, value);
            Log.debug("SET HEIGHT OF LEVEL: "+number+" to "+value);
        }
        
        public function get height () :int
        {
            const value:int = readInt(HEIGHT);
            Log.debug("READ HEIGHT OF LEVEL: "+number+" as "+value);
            return value;
        }
		
		/**
		 * The actual top of the level.  A player who is on this row is standing on the roof.
		 */
		public function get top () :int
		{
		    return -height;
		}		
		
		// slot definitons
		protected static const HEIGHT:int = 1;
	}
}
