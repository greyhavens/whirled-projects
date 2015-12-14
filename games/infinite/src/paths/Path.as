package paths
{
	import arithmetic.BoardCoordinates;
	import arithmetic.Vector;
	
	import flash.utils.ByteArray;
	
	import server.Messages.Serializable;
	
	public class Path implements Serializable
	{
		public var type:int;
		public var start:BoardCoordinates;
		public var finish:BoardCoordinates;
		
		public function Path(type:int, start:BoardCoordinates, finish:BoardCoordinates)
		{
			this.type = type;
			this.start = start;
			this.finish = finish;
		}
		
		public function toString () :String
		{
			return "path from "+start+" to "+finish;
		}
		
		public function get direction () :Vector
		{
			return start.distanceTo(finish).normalize();
		}
		
		public function applyTo(movable:PathFollower) :void
		{
			switch (type) {
				case CLIMB: return movable.climb(finish);
				case SIDEWAYS: return movable.moveSideways(finish);
				case FALL: return movable.fall(finish);
			}
			throw new Error("unknown movement type "+type);
		}
				
		public function writeToArray(array:ByteArray) :ByteArray
		{
			array.writeInt(type);
			start.writeToArray(array);
			finish.writeToArray(array);
            return array;			
		}		
		
		public static function readFromArray(array:ByteArray) :Path
		{
			return new Path(
			     array.readInt(),
			     BoardCoordinates.readFromArray(array),
			     BoardCoordinates.readFromArray(array)
			);
		
		}
		
		public static function sideways(start:BoardCoordinates, finish:BoardCoordinates) :Path
		{
			return new Path(SIDEWAYS, start, finish);
		}
		
		public static function climb(start:BoardCoordinates, finish:BoardCoordinates) :Path
		{
			return new Path(CLIMB, start, finish);
		}		
		
		public static const SIDEWAYS:int = 0;
		public static const CLIMB:int = 1;
		public static const FALL:int = 2;
	}
}