package server
{
	import com.whirled.game.GameControl;
	import com.whirled.net.MessageReceivedEvent;
	
	import world.World;
	
	public class WorldServer
	{
		public function WorldServer(control:GameControl)
		{
            _world = new World();
			_control = control;
	        control.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, handleMessageReceived);		
		}
		
		protected function handleMessageReceived(event:MessageReceivedEvent) :void
		{
			const message:int = int(event.name);
			switch (message) {
				case CLIENT_ENTERS: clientEnters(event);
			}			
			throw new Error("don't understand message "+event.name+" from client "+event.senderId);
		}
		
		/**
		 * Handle a message that a client has entered.
		 */
		protected function clientEnters (event:MessageReceivedEvent) :void
		{
	       _world.playerEnters(event.senderId);
		}
		
		protected var _world:World;
		protected var _control:GameControl;
		
	    public static const CLIENT_ENTERS:int = 0; 
	}
}