package client.radar
{
	import arithmetic.BoardCoordinates;
	import arithmetic.BoardRectangle;
	
	import client.player.Player;
	import client.player.PlayerEvent;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	import graphics.AnnotationShadow;
	
	import sprites.SpriteUtil;
	
	/**
	 * Show player positions on a grid.
	 */
	public class PixelRadar extends Sprite
	{
		public function PixelRadar(radar:Radar, width:int, height:int) 
		{
			_radar = radar;
			_width = width;
			_height = height;
			
			AnnotationShadow.applyTo(this);
		}
		
		public function get player () :Player
		{
			return _radar.player;
		}
		
		public function handlePathComplete(event:PlayerEvent) :void
		{
			// do nothing if we don't know about the local player
			if (player == null) {
				return;
			}
			
			// ignore players not on the same level as the local player
			if (event.player.levelNumber != player.levelNumber) {
				return;
			}
			
			// if it's not the local player then we update the position
			// in our list
			if (event.player.id != player.id) {
                _positions[event.player.id] = event.player.position;
			}
			
			updateBounds();
			render();
		}
		
		public function handleChangedLevel(event:PlayerEvent) :void
		{
			// do nothing if we don't know about the local player
			if (player == null) {
				return;
			}
			
			// the local player has changed level
			if (event.player.id == player.id) {
				_positions = new Array();
				_bounds = null;
			}
			
			// some other player has changed level delete their record from the list of those
			// we are tracking
			delete _positions[event.player.id]
		}
        
        protected function minimalBounds () :BoardRectangle
        {
        	var minX:int = player.position.x;
        	var minY:int = player.position.y;
        	var maxX:int = player.position.x;
        	var maxY:int = player.position.y;
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
            
            _bounds = minimal.percentPad(120, 5);
            return;
            
            // if we have no bounds set, then just make them the minimal bounds
            // padded by 20%
            if (_bounds == null) {
            	_bounds = minimal.percentPad(120, 5);
            	return;            	 
            }
            
//            
//            // if we have bounds set, create an inner rectangle the size of the margin 
//            // area to compare against the minimal bounds
//            const margin:BoardRectangle = _bounds.percentPad(95, -5);
//            Log.debug("margin: "+margin);
//            
//            // if the minimal bounds are contained within the margin, then the current bounds
//            // are ok.
//            if (margin.containsRectangle(minimal)) {
//            	Log.debug("within margin, so bounds remain: "+_bounds);
//            	return;
//            }
//            
//            _bounds = margin.union(minimal).percentPad(120, 5);
//            Log.debug("bounds: "+_bounds);
        }
        
        protected function render () :void
        {
            var g:Graphics = this.graphics;
            g.clear();
            SpriteUtil.addBackground(this, _width, _height, SpriteUtil.DARK_GREY, 0.6);
            
            const spriteRatio:Number = Number(_width) / Number(_height);
            const boundsRatio:Number = _bounds.aspectRatio;
            var scale:Number;
            var xoffset:int;
            var yoffset:int;
            
            if (spriteRatio > boundsRatio) {
            	// the sprite is proportionally wider than the bounds so the bounds will be
            	// centered horizontally and the scaling is based on the height difference
            	scale = Number(_height) / Number(_bounds.height);
            	xoffset = (_width / 2) - ((_bounds.width * scale) / 2);
            	yoffset = 0;
            	
            } else {
            	// the sprite is proportionally narrower than the bounds so the bounds will be
            	// positioned at the bottom of the bounds and the scaling is based on the width
            	// difference
            	scale = Number(_width) / Number(_bounds.width);
            	xoffset = 0;
            	yoffset = _height -  (_bounds.height * scale);
            }
            
            for each (var pos:BoardCoordinates in _positions) {
                var x:int = ((pos.x - _bounds.left) * scale) + xoffset;
                var y:int = ((pos.y - _bounds.top) * scale) + yoffset;
                g.beginFill(SpriteUtil.WHITE, 1);
                g.drawCircle(x,y, 2);
                g.endFill();
            }               
            
            x = ((player.position.x - _bounds.left) * scale) + xoffset;
            y = ((player.position.y - _bounds.top) * scale) + yoffset;
            
            g.beginFill(SpriteUtil.RED, 1);
            g.drawCircle(x,y, 2);
            g.endFill();
        }
        
        public function reset () :void
        {
        	_positions = new Array();
            var g:Graphics = this.graphics;
            g.clear();
            SpriteUtil.addBackground(this, _width, _height, SpriteUtil.DARK_GREY, 0.6);
        }
        
        protected var _width:int;        
        protected var _height:int
        protected var _bounds:BoardRectangle;        
        protected var _positions:Array = new Array();
        protected var _radar:Radar;
	}
}