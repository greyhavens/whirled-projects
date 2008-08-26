package joingame.net
{
	import flash.events.Event;

	public class JoinGameEvent extends Event
	{
		public function JoinGameEvent(type:String)
		{
			super(type, false, false);
		}
		
		//The player ID that is actively playing the game
		public var clientPlayerID:int;
		//The player ID of the board that needs to update.  Not always the same as clientPlayerID
		//because clients show the boards to the left and right
		public var boardPlayerID:int;
		
		public var boardRepresentation:Array;
		
		public var joins:Array;
		
		public static const BOARD_UPDATED :String = "JoinGame Event: Board Updated";
		public static const RECEIVED_BOARDS_FROM_SERVER :String = "JoinGame Event: Boards Received From Server";
		
		public static const ATTACKING_JOINS :String = "JoinGame Event: Attacking Joins";
		
		public static const PLAYER_KNOCKED_OUT :String = "JoinGame Event: Player Knocked Out";
		
		public static const GAME_OVER :String = "JoinGame Event: Game Over";
		
		
		//Animations
		public static const CREATE_ANIMATION_PIECE_FALLING :String = "JoinGame Event: Animate Piece Falling";
		public static const CREATE_ANIMATION_HORIZONTAL_JOIN_ATTACK :String = "JoinGame Event: Animate Horizontal Join Attack";
	}
}