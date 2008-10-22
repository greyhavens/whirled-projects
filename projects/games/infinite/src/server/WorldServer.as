package server
{
	import com.whirled.game.GameControl;
	
	import world.World;
	
	public class WorldServer
	{
		public function WorldServer(control:GameControl)
		{
			_control = control;
			_world = new World();
		}
		
		protected var _world:World;
		protected var _control:GameControl;
	}
}