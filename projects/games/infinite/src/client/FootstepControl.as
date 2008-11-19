package client
{
	import arithmetic.Vector;
	
	import flash.events.MouseEvent;
	
	import paths.Path;
	
	import sprites.CellSprite;
	import sprites.FootstepSprite;
	
	import world.Cell;
	import world.arbitration.BoardArbiter;
	
	public class FootstepControl
	{
		public var cell:Cell;		
		
		public function FootstepControl(objective:Objective)
		{
			_objective = objective;
			_arbiter = new BoardArbiter(_objective);
			_sprite = new FootstepSprite(Vector.N);
			_sprite.addEventListener(MouseEvent.MOUSE_OUT, clearFootprints);
            _sprite.addEventListener(MouseEvent.MOUSE_DOWN, clickFootprints);			
		}
		
		public function checkFootprints (cell:Cell, sprite:CellSprite) :void
        {
           Log.debug("working out whether to display footprints for cell "+cell);
           const path:Path = _arbiter.findPath(_objective.player, cell);
           if (path == null) {
               return;
           }
           
           this.cell = cell;
           _sprite.direction = path.direction;
           _sprite.x = sprite.x;
           _sprite.y = sprite.y;    
           _objective.addChild(_sprite);
        }           
    
        protected function clickFootprints (event:MouseEvent) :void
        {
            clearFootprints(event);
            _objective.handleCellClicked(new CellEvent(CellEvent.CELL_CLICKED, cell));
        }       

    
        public function clearFootprints (event:MouseEvent) :void
        {
            if (_objective.contains(_sprite)) {
               _objective.removeChild(_sprite);
            }           
        }
		
        protected var _objective:Objective;
        protected var _arbiter:BoardArbiter;
        protected var _sprite:FootstepSprite;        
	}
}