package arithmetic
{
	import flash.display.DisplayObject;
	
	public class Geometry
	{
		public function Geometry()
		{
		}
		
		public static function coordsOf(object:DisplayObject) :GraphicCoordinates
		{
			return new GraphicCoordinates (
				object.x,
				object.y
			);
		}
		
		public static function position (object:DisplayObject, pos:GraphicCoordinates) :void 
		{
			object.x = pos.x;
			object.y = pos.y;
		}

		
		public static function moveBy(v:Vector, object:DisplayObject) :void
		{
			object.x += v.dx;
			object.y += v.dy;
		}	
	}
}