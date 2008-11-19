package sprites
{
	import arithmetic.Vector;
	
	import world.Cell;
	
	public class FootstepSprite extends AssetSprite
	{		
        public function FootstepSprite(direction:Vector)
        {
            super(assetForDirection(direction), Config.cellSize.dx, Config.cellSize.dy);
        }
        
        public function set direction (v:Vector) :void
        {
        	asset = assetForDirection(v);
        }
                
        protected function assetForDirection (direction:Vector) :Class
        {
        	if (direction.equals(Vector.UP)) {
        		return footstepUp;
        	} 
        	
        	if (direction.equals(Vector.DOWN)) {
        		return footstepDown;
        	}
        	
        	if (direction.equals(Vector.LEFT)) {
        		return footstepLeft;
        	}
        	
        	if (direction.equals(Vector.RIGHT)) {
        	   return footstepRight;
        	}
        	
        	// return upward footsteps as the generic icon
        	return footstepUp;
        }
        
        
        [Embed(source="../../rsrc/png/footsteps-up-overlay.png")]
        protected static const footstepUp:Class;
        
        [Embed(source="../../rsrc/png/footsteps-down-overlay.png")]
        protected static const footstepDown:Class;

        [Embed(source="../../rsrc/png/footsteps-left-overlay.png")]
        protected static const footstepLeft:Class;

        [Embed(source="../../rsrc/png/footsteps-right-overlay.png")]
        protected static const footstepRight:Class;
	}
}