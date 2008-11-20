package arithmetic
{
	import flash.display.DisplayObject;
	import flash.text.TextField;
	
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
		
		/**
		 * Position one object at the center of another.
		 */
		public static function centerTextIn (container:DisplayObject, target:TextField) :void
		{
			const x:int = (container.width / 2) - (target.textWidth / 2);
		    const y:int = (container.height / 2) - (target.textHeight / 2);
		    Log.debug("text position: "+x+", "+y);
		    target.x = x;
		    target.y = y;	
		}
	}
}