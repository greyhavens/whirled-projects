package graphics
{
	import arithmetic.Vector;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	
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
            _instance.rotation = v.rotation;
//            rotateAroundCenter(v.rotation);
        }

         private function rotateAroundCenter (angleDegrees:Number) :void
         {
              const ptRotationPoint:Point = new Point(x + (width / 2), y + (height/ 2));
              var m:Matrix = transform.matrix;
              m.tx -= ptRotationPoint.x;
              m.ty -= ptRotationPoint.y;
              m.rotate (angleDegrees*(Math.PI/180));
              m.tx += ptRotationPoint.x;
              m.ty += ptRotationPoint.y;
              transform.matrix=m;
         }
        
        [Embed(source="../../rsrc/png/arrow.png")]
        protected static const _arrow:Class;
	}
}