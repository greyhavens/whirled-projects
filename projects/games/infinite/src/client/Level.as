package client
{
	public class Level
	{
		public var number:int;
		public var height:int;
		
		public function Level(number:int, height:int)
		{
			this.number = number;
			this.height = height;
		}
		
		/**
		 * The actual top of the level.  A player who is on this row is standing on the roof.
		 */
		public function get top () :int
		{
		    return -height;
		}
	}
}
