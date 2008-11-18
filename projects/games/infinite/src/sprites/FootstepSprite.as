package sprites
{
	import arithmetic.Vector;
	
	public class FootstepSprite extends AssetSprite
	{
        public function FootstepSprite(direction:Vector)
        {
            super(assetForDirection(direction), Config.cellSize.dx, Config.cellSize.dy);
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
        }
        
        [Embed(source="../../../rsrc/png/footstep-overlay.png")]
        protected static const footstepOverlay:Class;        
        
        [Embed(source="../../../rsrc/png/footstep-up-overlay.png")]
        protected static const footstepUp:Class;
        
        [Embed(source="../../../rsrc/png/footstep-down-overlay.png")]
        protected static const footstepUp:Class;

        [Embed(source="../../../rsrc/png/footstep-left-overlay.png")]
        protected static const footstepUp:Class;

        [Embed(source="../../../rsrc/png/footstep-right-overlay.png")]
        protected static const footstepUp:Class;
	}
}