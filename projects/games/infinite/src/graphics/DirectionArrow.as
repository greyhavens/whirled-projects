package graphics
{
	import arithmetic.Vector;
	
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class DirectionArrow extends Sprite
	{
		public function DirectionArrow(direction:Vector)
		{
		 	super();
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
	}
}