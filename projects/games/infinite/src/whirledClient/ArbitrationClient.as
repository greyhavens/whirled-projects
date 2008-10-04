package whirled
{
	import com.whirled.game.NetSubControl;
	import com.whirled.net.MessageReceivedEvent;
	
	import multiplayer.MultiplayerCharacter;
	
	import paths.Path;
	import paths.PathEvent;
	
	import whirledClient.ClientPlayerRegister;
	
	public class ArbitrationClient implements MoveArbiter
	{
		public function ArbitrationClient(control:NetSubControl)
		{
			_control = control;
			_control.addEventListener(MessageReceivedEvent._MSG_RECEIVED, handleMessageReceived);
		}
		
		public function handleMessageReceived (event:MessageReceivedEvent) :void
		{
			if (event.name == ArbitrationServer.PATH_START) {
				const path:Path = event.value as Path;
				const player:MultiplayerCharacter = _playerRegister.findPlayer(event.targetId);
				if (player != null) {
				 	player.dispatchEvent(new PathEvent(path));
				} else {
					throw new Error("received a path start for an unknown player: "+event.targetId);
				}
			}
		}
		
		/**
		 * Send the move over to the server.
		 */
		function proposeMove (player:Character, destination:Cell) :void 		
		{
			_control.sendMessage(ArbitrationServer.PROPOSE_MOVE, new MoveProposal(player, destination);
		}

		protected var _playerRegister:ClientPlayerRegister;
		
		protected var _control:NetSubControl;
	}
}