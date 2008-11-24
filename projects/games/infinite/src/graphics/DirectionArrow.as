package graphics
{
	import arithmetic.Vector;
	
	import flash.geom.Matrix;
	
	import sprites.AssetSprite;
	
	public class DirectionArrow extends AssetSprite
	{
		public function DirectionArrow(direction:Vector)
		{
			super(_arrow, 25, 25);
			this.direction = direction;
		}
     
        public function set direction (v:Vector) :void
        {
            var rotation:Matrix = new Matrix();
            rotation.rotate(v.rotation);
            transform.matrix = rotation;            
        }
        
        [Embed(source="../../rsrc/png/arrow.png")]
        protected static const _arrow:Class;
	}
}