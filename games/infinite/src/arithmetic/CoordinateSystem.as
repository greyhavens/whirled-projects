package arithmetic
{
	public class CoordinateSystem
	{
		public function CoordinateSystem(local:GraphicCoordinates, named:GraphicCoordinates)
		{
			_offset = named.distanceTo(local);
		}
		
		/** 
		 * Translate from this coordinate system to the local coordinate system 
		 */
		public function toLocal (point:GraphicCoordinates) :GraphicCoordinates
		{
			return point.translatedBy(_offset);
		}

		protected var _offset:Vector;	
	}
}