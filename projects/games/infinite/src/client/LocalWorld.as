package client
{
	import flash.events.EventDispatcher;
	
	import world.ClientWorld;
	import world.World;
	import world.WorldClient;
	
	public class LocalWorld extends EventDispatcher implements ClientWorld
	{
		public function LocalWorld()
		{
			_world = new World();
		}
		
		public function get worldType () :String
		{
			return "standalone";
		}
		
		public function enter (client:WorldClient) :void
		{
			
		}
		
		protected var _world:World;
	}
}