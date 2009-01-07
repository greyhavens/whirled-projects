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
        }
        
        public function get height () :int
        {
            return readInt(HEIGHT);
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
