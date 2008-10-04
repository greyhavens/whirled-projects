package multiplayer
{
	public class PlayerRegister
	{		
		public function addPlayer (playerId:int, player:MultiplayerCharacter) :void
		{
			_dictionary[playerId] = player;
		}
		
		public function findPlayer (playerId:int) :MultiplayerCharacter
		{
			return _dictionary[playerId];
		}
				
		protected var _dictionary:Array = new Array(); 
	}
}