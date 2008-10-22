package whirled
{
	import arbitration.MovableCharacter;
	
	import com.whirled.game.NetSubControl;
	
	import flash.events.EventDispatcher;
	
	import paths.PathEvent;
	
    import world.Cell;
	
	public class ServerCharacter extends EventDispatcher implements MovableCharacter, WhirledCharacter
	{
		public function ServerCharacter(playerId:int) 
		{
			id = playerId;
			addEventListener(PathEvent.PATH_START, handlePathStart);
		}

		public function handlePathStart(event:PathEvent) :void
		{
			_control.sendMessage(PathEvent.PATH_START, event.path, id);
		}		

		public function get cell () :Cell
		{
			return null;
		} 
		
		public function get playerId () :int 
		{
			return id;
		} 

		protected var _control:NetSubControl;

		protected var id:int;
	}
}