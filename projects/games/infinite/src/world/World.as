package world
{
	/**
	 * This is the actual implementation of the game world.  It is instantiated on the server if
	 * the game is running in multi-player mode, or on the client if it's running in standalone mode.
	 */
	public class World
	{
		public function World()
		{
			_players = new PlayerRegister();
		}
		
		/**
		 * A player enters the world.
		 */
		public function playerEnters(id:int) :void
		{
	     
		}
		
		protected var _players:PlayerRegister;
	}
}