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
        	const record:PositionRecord = new PositionRecord(player);
        	_byPosition[player.position.key] = record;
        	_byPlayer[player] = record;
            _ids[player.id] = player;
            _list.push(player);
            
            player.addEventListener(PlayerEvent.MOVE_COMPLETED, handleMoveCompleted);
        }

        /**
         * Update a position record for a player, assuming that we're already tracking the player.
         */ 
        protected function updateRecord (player:Player) :void
        {
            delete _byPosition[(_byPlayer[player] as PositionRecord).coords.key];
            const record:PositionRecord = new PositionRecord(player);
            _byPosition[player.position.key] = record;
            _byPlayer[player] = record;
        }
        
        public function handleMoveCompleted (event:PlayerEvent) :void
        {
        	const found:Player = playerAt(event.player.position);
        	if (found != null && found != event.player) {
        		throw new Error(event.player + " moved to cell occupied by "+
        		  playerAt(event.player.position));        		
        	}
        	updateRecord(event.player);
        }

        public function occupying (position:BoardCoordinates) :Boolean
        {
        	return _byPosition[position.key] != null;
        }

        public function playerAt (position:BoardCoordinates) :Player
        {
        	const found:PositionRecord = (_byPosition[position.key] as PositionRecord);
        	if (found == null) {
        		return null;
        	}
        	return found.player;
        }

        public function find (id:int) :Player
        {
        	return _ids[id] as Player;
        }
        
        /**
         * Return a list of the players
         */ 
        public function get list () :Array
        {
        	return _list;
        }
        
        protected var _ids:Dictionary = new Dictionary();
        protected var _byPosition:Dictionary = new Dictionary();
        protected var _byPlayer:Dictionary = new Dictionary();
        protected var _list:Array = new Array();
	}
}

import world.Player;
import arithmetic.BoardCoordinates;
	

class PositionRecord {
	
	public var player:Player;
	public var coords:BoardCoordinates;
	
	public function PositionRecord (player:Player) 
	{
	   this.player = player;
	   this.coords = player.position;
	}
}