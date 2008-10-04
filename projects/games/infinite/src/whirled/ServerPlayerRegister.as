package whirled
{
	import com.whirled.game.GameSubControl;
	import com.whirled.game.OccupantChangedEvent;
	
	import multiplayer.MultiplayerCharacter;
	import multiplayer.PlayerRegister;
	
	public class ServerPlayerRegister extends PlayerRegister
	{
		public function ServerPlayerRegister(control:GameSubControl)
		{		
			_control = control;
			_control.addEventListener(OccupantChangedEvent.OCCUPANT_ENTERED, handleOccupantEntered);
		}
		
		public function handleOccupantEntered (event:OccupantChangedEvent) :void
		{
			// when a new player joins the game, the Register is responsible for creating their
			// server side representation, and positioning them appropriately
			if (event.player) {
				const player:ServerCharacter = new ServerCharacter(event.occupantId);
				_dictionary[event.occupantId] = player;
			}
		}
		protected var _control:GameSubControl;
	}
}