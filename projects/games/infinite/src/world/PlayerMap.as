package world
{
	import arithmetic.BoardCoordinates;
	
	import flash.utils.Dictionary;
	
	public class PlayerMap
	{
		public function PlayerMap()
		{
		}

        public function trackPlayer (player:Player) :void
        {
        	if (playerAt(player.position) != null) {
        		throw new Error("already tracking a player at "+player.position);
        	}
        	_positions[player.position.key] = player;
            _ids[player.id] = player;
            player.addEventListener(PlayerEvent.MOVE_COMPLETED, handleMoveCompleted);
        }
        
        public function handleMoveCompleted (event:PlayerEvent) :void
        {
        	if (playerAt(event.player.position) != null) {
        		throw new Error(event.player + " moved to cell occupied by "+
        		  playerAt(event.player.position));        		
        	}
        	_positions[event.player.position.key] = event.player;
        }

        public function occupying (position:BoardCoordinates) :Boolean
        {
        	return _positions[position.key] != null;
        }

        public function playerAt (position:BoardCoordinates) :Player
        {
        	return _positions[position.key] as Player;
        }

        public function find (id:int) :Player
        {
        	return _ids[id] as Player;
        }
        
        protected var _ids:Dictionary = new Dictionary();
        protected var _positions:Dictionary = new Dictionary();
	}
}