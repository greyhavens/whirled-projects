package client
{
	import arithmetic.Vector;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import paths.Path;
	
	import sprites.CellSprite;
	import sprites.FootstepSprite;
	
	import world.Cell;
	import world.arbitration.BoardArbiter;
	
	public class FootstepControl
	{		
		public function FootstepControl(objective:Objective)
		{
			_objective = objective;
			_arbiter = new BoardArbiter(_objective);
			_sprite = new FootstepSprite(Vector.N);
			_sprite.addEventListener(MouseEvent.MOUSE_OUT, moveoffFootprint);
            _sprite.addEventListener(MouseEvent.MOUSE_DOWN, clickFootprints);			
		}
		
		public function checkFootprints (sprite:CellSprite) :void
        {
           _cellSprite = sprite;

           const path:Path = _arbiter.findPath(_objective.player, sprite.cell);
           if (path == null) {
               return;
           }
           
           _sprite.direction = path.direction;
           _sprite.x = sprite.x;
           _sprite.y = sprite.y;    
           _objective.addChild(_sprite);
        }           
    
        protected function clickFootprints (event:MouseEvent) :void
        {
        	hideFootprint();
            _objective.handleCellClicked(new CellEvent(CellEvent.CELL_CLICKED, cell));
        }       

        public function moveOutSprite (sprite:Sprite) :void 
        {
        	if (sprite == _cellSprite) {
        		_cellSprite = null;
        		hideFootprint();
        	}
        }
    
        public function moveoffFootprint (event:MouseEvent) :void
        {
        	hideFootprint();
        }

        /**
         * Receive notification that a movement is complete.  When this happens, if a sprite is still assigned, then the footprints
         * should be shown.
         */ 
        public function handlePathComplete() :void
        {
        	Log.debug("footstep control handling path complete"); 
        	if (_cellSprite != null) {
        		checkFootprints(_cellSprite);
        	}
        }

        protected function hideFootprint() :void
        {
        	if (_objective.contains(_sprite)) {
               _objective.removeChild(_sprite);
            }
        }
        
        protected function get cell () :Cell
        {
        	return _cellSprite.cell;
        }
		
		protected var _cellSprite:CellSprite;
        protected var _objective:Objective;
        protected var _arbiter:BoardArbiter;
        protected var _sprite:FootstepSprite;        
	}
}