package client.radar
{
	import arithmetic.BoardCoordinates;
	import arithmetic.BoardRectangle;
	
	import client.player.Player;
	import client.player.PlayerEvent;
	
	import flash.display.Sprite;
	
	/**
	 * Show player positions on a grid.
	 */
	public class PixelRadar extends Sprite
	{
		public function PixelRadar() 
		{
		}
		
		public function handlePathComplete(event:PlayerEvent) :void
		{
			// do nothing if we don't know about the local player
			if (_player == null) {
				return;
			}
			
			// ignore players not on the same level as the local player
			if (event.player.levelNumber != _player.levelNumber) {
				return;
			}
			
			_positions[event.player.id] = event.player.position;
		}
		
		public function handleChangedLevel(event:PlayerEvent) :void
		{
			// do nothing if we don't know about the local player
			if (_player == null) {
				return;
			}
			
			// the local player has changed level
			if (event.player.id == _player.id) {
				_positions = new Array();
				_bounds = null;
			}
			
			// some other player has changed level delete their record from the list of those
			// we are tracking
			delete _positions[event.player.id]
		}

        public function set player (player:Player) :void
        {
        	_player = player;
        }
        
        protected function minimalBounds () :BoardRectangle
        {
        	var minX:int = _player.position.x;
        	var minY:int = _player.position.y;
        	var maxX:int = _player.position.x;
        	var maxY:int = _player.position.y;
        	for each (var pos:BoardCoordinates in _positions) {
        		if (minX > pos.x) {
        			minX = pos.x;
        		}
        		if (minY > pos.y) {
        			minY = pos.y;
        		}
        		if (maxX < pos.x) {
        			maxX = pos.x;
        		}
        		if (maxY < pos.y) {
        			maxY = pos.y;
        		}
        	}
            return new BoardRectangle(minX, minY, maxX - minX, maxY - minY);
        }
        
        protected function updateBounds () :void
        {
            // don't want to rescale bounds every frame, so we make them 20% larger
            // than needed, and then rescale if the minimal bounds get within 5%
            const minimal:BoardRectangle = minimalBounds();
            
            // if we have no bounds set, then just make them the minimal bounds
            // padded by 20%
            if (_bounds == null) {
            	_bounds = minimal.percentPad(120, 20);
            	return;            	 
            }
            
            // if we have bounds set, create an inner rectangle the size of the margin 
            // area to compare against the minimal bounds
            const margin:BoardRectangle = _bounds.percentPad(95, -5);
            
            // if the minimal bounds are contained within the margin, then the current bounds
            // are ok.
            if (margin.containsRectangle(minimal)) {
            	return;
            }
            
            _bounds = margin.union(minimal).percentPad(120,20);
        }
        
        protected var _bounds:BoardRectangle;
        
        protected var _positions:Array = new Array();    

        protected var _player:Player;
	}
}