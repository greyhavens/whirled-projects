package sprites
{
	import arithmetic.Geometry;
	import arithmetic.GraphicCoordinates;
	import arithmetic.Vector;
	
	import cells.CellObjective;
	import cells.views.CellView;
	
	import client.Objective;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import world.Cell;
		
	public class CellSprite extends AssetSprite implements CellView
	{
		public function CellSprite(cell:Cell, asset:Class)
		{
			_cell = cell;
			super(asset, Config.cellSize.dx, Config.cellSize.dy);
			registerEventHandlers(this);
			if (Config.cellDebug) {
				labelPosition(this);
			}
		}
		
		/**
		 * Register event handlers associated with the view for this cell.  May be overridden
		 * by subclasses for things like mouseovers. 
		 */
		protected function registerEventHandlers (source:EventDispatcher) :void
		{
			source.addEventListener(MouseEvent.MOUSE_DOWN, handleCellClicked);			
		}

		protected function handleCellClicked (event:MouseEvent) :void
		{
			dispatchEvent(new CellEvent(CellEvent.CELL_CLICKED, _cell));			
		}	
			
		/**
		 * Return the graphic center of the cell base.
		 */
		public function get graphicCenter () :GraphicCoordinates
		{
			return Geometry.coordsOf(this).translatedBy(
				Config.cellSize.divideByScalar(2));
		}
			
		/**
		 * Return an anchor point for a pointer attaching to this object in the specified direction.
		 * The default behavior for a cell is to return the center of the square face.
		 * 
		 * Not optimized.
		 */
		public function anchorPoint (direction:Vector) :GraphicCoordinates
		{
			return graphicCenter.translatedBy(
				Config.cellSize.divideByScalar(2).multiplyByVector(direction.reversed).xComponent());
		}		
		
		public function get cell () :Cell {
			return _cell;
		}
		
		public function get objectName () :String {
			return _cell.objectName;
		}
		
		public function get owner () :Owner {
			return _cell.owner;
		}
		
		public function addToObjective (objective:Objective) :void
		{
			_objective = objective;
			objective.addChildAt(this, 0);
			Geometry.position(this, objective.cellCoordinates(_cell.position));			
		}
		
		public function removeFromObjective (objective:Objective) :void
		{
			objective.removeChild(this);
			_objective = null;
		}
		
		/**
         * Add a label with the current board position to the supplied container
         */
        protected function labelPosition (s:DisplayObjectContainer) :void
        {
            const l:TextField = new TextField();
            l.text = "(" + _cell.position.x + ", " + _cell.position.y + ")";
            s.addChild(l);      
        }
		
		protected var _cell:Cell;
		protected var _objective:CellObjective;

        public static const DEBUG:Boolean = Config.cellDebug;       
	}
}