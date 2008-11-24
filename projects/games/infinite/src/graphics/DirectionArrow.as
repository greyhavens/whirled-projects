package graphics
{
	import arithmetic.Vector;
	
	import sprites.AssetSprite;
	
	public class DirectionArrow extends AssetSprite
	{
		public function DirectionArrow(direction:Vector)
		{
			super(_arrow, 25, 25);
			_direction = direction
		}

        protected var _direction:Vector
        
        [Embed(source="../../../rsrc/png/fruit-machine-inactive.png")]
        protected static const _arrow:Class;
	}
}