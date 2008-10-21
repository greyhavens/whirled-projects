package whirled
{
	import arbitration.MoveArbiter;
	
	import com.whirled.game.NetSubControl;
	import com.whirled.net.MessageReceivedEvent;
	
	import multiplayer.MultiplayerCharacter;
	
	public class ArbitrationServer
	{
		public function ArbitrationServer(control:NetSubControl)
		{
			_control = control;
			_control.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, handleMessageReceived);
		}
		
		public function handleMessageReceived (event:MessageReceivedEvent) :void
		{
			// other handlers may be processing the same message.  All that needs to be done here
			// is to decide quickly whether this one is for us and then turn it into a method call			
			if (event.name == PROPOSE_MOVE) {
				var proposal:MoveProposal = event.value as MoveProposal;
				if (proposal == null) {
					throw new Error("received a "+event.name+
						" message but couldn't cast the value "+event.value+" to MoveProposal"); 
				}

				const player:MultiplayerCharacter = _players.findPlayer(event.senderId);
				const cell:Cell = _board.cellAt(proposal.destination);
				if (player.cell.position.equals(proposal.origin)) {
					_arbiter.proposeMove(player, cell);
				} else {
					throw new Error("the server thinks "+player+
						" is in a different place than the client which thinks it's "+
						proposal.origin);
				}
			}
		}

		protected var _players :ServerPlayerRegister;

		protected var _control:NetSubControl;

		protected var _arbiter:MoveArbiter;
		
		protected var _board:BoardAccess;
		
		public static const PROPOSE_MOVE:String = "propose_move";
		
		public static const PATH_START:String = "path_start";
	}
}