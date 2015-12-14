package cells
{
	import cells.debug.*;
	import cells.fruitmachine.*;
	import cells.ground.*;
	import cells.ladder.*;
	import cells.roof.*;
	import cells.views.*;
	import cells.wall.*;
	
	import world.Cell;
	
	/**
	 * The view factory is used by the objective to obtain a new view for a specific cell.  Thus the
	 * cells can be used on the server and client alike.
	 */
	public class ViewFactory
	{
		public function ViewFactory()
		{
		}
		
		public function viewOf (cell:Cell, time:Number) :CellView 
		{
		    return makeView(cell, time);
		}
		
		protected function makeView (cell:Cell, time:Number) :CellView
		{
		    var found:CellView;
		    
		    switch (cell.code) {
                case CellCodes.WALL:
                    // start pooling wall views
                    found = getFromPool(cell, time);
                    if (found != null) {
                        return found;
                    }
                    return new WallView(cell);
                    
                case CellCodes.OILED_WALL: return new OiledWallView(cell);
                case CellCodes.LADDER_BASE: return new LadderBaseView(cell);
                case CellCodes.LADDER_MIDDLE: return new LadderMiddleView(cell);
                case CellCodes.LADDER_TOP: return new LadderTopView(cell);
                case CellCodes.FRUIT_MACHINE: 
                    found = getFromPool(cell, time);
                    if (found != null) {
                        return found;
                    } 
                    return new FruitMachineView(cell, time);
                    
                return new FruitMachineView(cell, time);
                case CellCodes.OILED_LADDER_BASE: return new OiledLadderBaseView(cell);
                case CellCodes.OILED_LADDER_MIDDLE: return new LadderMiddleView(cell);
                case CellCodes.OILED_LADDER_TOP: return new LadderTopView(cell);
                case CellCodes.WALL_BASE: return new WallBaseView(cell);
                case CellCodes.GROUND: return new GroundView(cell);
                case CellCodes.DEBUG: return new DebugView(cell);
                case CellCodes.DEBUG_GROUND: return new DebugGroundView(cell);
                case CellCodes.NARROW_ROOF: return new NarrowRoofView(cell);
                case CellCodes.BLACK_SKY: return new BlackSkyView(cell);
                case CellCodes.FLAT_ROOF_BASE: return new FlatRoofBaseView(cell);
                case CellCodes.FLAT_ROOF: return new FlatRoofView(cell);                
            }
            throw new Error("the viewfactory doesn't know how to construct a view for "+cell);
		}
		
		public function getFromPool(cell:Cell, time:Number) :CellView
		{
		    const array:Array = pool(cell.code);
		    if (array.length > 0) {		        
    		    const found:Poolable = pool(cell.code).pop();
    		    found.unpool(cell, time);
    		    return found;
    		}
    		return null;
		}
		
		public function addToPool(poolable:Poolable) :void
		{
            poolable.prepareForPool();
	        pool(poolable.code).push(poolable);
		}
		
		protected function pool(code:int) :Array 
		{
		    var found:Array = _pools[code];
		    if (found == null) {
		        found = new Array();
		        _pools[code] = found;
		    }
		    return found;
		}
		
		protected var _pools:Array = new Array();		
	}
}