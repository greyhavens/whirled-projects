package sprites
{
	import arithmetic.Geometry;
	import arithmetic.GraphicCoordinates;
	import arithmetic.GraphicRectangle;
	import arithmetic.Vector;
	
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
			_code = cell.code;
			super(asset, Config.cellSize.dx, Config.cellSize.dy);
			registerEventHandlers(this);
			if (Config.cellDebug) {
				labelPosition(this);
			}
		}
		
		public function get code () :int 
		{
		    return _code;
		}
		
		/**
		 * Prepare this cell for adding to a pool.
		 */
		public function prepareForPool() :void {
		    if (_objective != null) {
		        throw new Error("cannot pool "+this+" while it's still on the objective");
		    }
		    _cell = null;
		    unregisterEventHandlers(this);
		}
		
		public function unpool(cell:Cell, time:Number) :void
		{
            _cell = cell;
            registerEventHandlers(this);
		}
		
		/**
		 * Register event handlers associated with the view for this cell.  May be overridden
		 * by subclasses for things like mouseovers. 
		 */
		protected function registerEventHandlers (source:EventDispatcher) :void
		{
            source.addEventListener(MouseEvent.ROLL_OVER, checkFootprints);
		}
		
		protected function unregisterEventHandlers (source:EventDispatcher) :void
		{
		    source.removeEventListener(MouseEvent.ROLL_OVER, checkFootprints);
		}
		
		protected function checkFootprints(event:MouseEvent) :void
		{
			//Log.debug(this+" checking footprints because of mouse event "+event.type);
			_objective.rolloverCell(this);
		}
		
		protected function clearFootprints(event:MouseEvent) :void
		{
			_objective.moveOutSprite(this);
		}

		/**
		 * Return the graphic center of the cell base.
		 */
		public function get graphicCenter () :GraphicCoordinates
		{
			return Geometry.coordsOf(this).translatedBy(
				Config.cellSize.divideByScalar(2));
		}
			
		public function get bounds () :GraphicRectangle
   		{
   		    return new GraphicRectangle(x,y, width, height);
		}		
			
		/**
		 * Return an anchor point for a pointer attaching to this object in the specified direction.
		 * The default behavior for a cell is to return the center of the square face.
		 * 
		 * Not optimized.
		 */
		public function anchorPoint (direction:Vector) :GraphicCoordinates
		{
		    return graphicCenter.translatedBy(direction.reversed.normalizeF().multiplyByScalar(width/2).toVector());
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
		
		/**
		 * By default, we don't label every cell.
		 */
		public function get showLabel () :Boolean {
		    return false;
		}
		
		public function addToObjective (objective:Objective) :void
		{
			_objective = objective;
			objective.addChildAt(this, 0);
			Geometry.position(this, objective.cellCoordinates(_cell.position));
			startAnimation();
		}
		
		public function removeFromObjective (objective:Objective) :void
		{
		    stopAnimation();
			objective.removeChild(this);
            _objective = null;
		}

		protected function startAnimation () :void
		{
		    // does nothing - overridden by subclasses to register timer events etc.
		}
		
		protected function stopAnimation () :void
		{
		    // does nothing - overridden by subclasses to unregister for timer events etc.
		}
		
		/**
         * Add a label with the current board position to the supplied container
         */
        protected function labelPosition (s:DisplayObjectContainer) :void
        {
            const l:TextField = new TextField();
            l.text = "(" + _cell.position.x + ", " + _cell.position.y + ") "+_cell.position.vicinity;
            s.addChild(l);      
        }
		
		protected var _code:int;
		protected var _cell:Cell;
		protected var _objective:Objective;

        public static const DEBUG:Boolean = Config.cellDebug;       
	}
}