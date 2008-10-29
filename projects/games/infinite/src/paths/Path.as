package paths
{
	import arithmetic.BoardCoordinates;
	
	import flash.utils.ByteArray;
	
	import server.Messages.Serializable;
	
	public class Path implements Serializable
	{
		public var start:BoardCoordinates;
		public var finish:BoardCoordinates;
		
		public function Path(start:BoardCoordinates, finish:BoardCoordinates)
		{
			this.start = start;
			this.finish = finish;
		}
		
		public function applyTo(movable:PathFollower) :void
		{
			throw new Error("base path type can't actually be applied to a path follower");
		}
		
		
		public function writeToArray(array:ByteArray) :ByteArray
		{
            array.writeInt(start.x);
            array.writeInt(start.y);
            array.writeInt(finish.x);
            array.writeInt(finish.y);
            return array;			
		}		
		
		public static function readFromArray(array:ByteArray) :Path
		{
			return new Path(
			     BoardCoordinates.readFromArray(array),
			     BoardCoordinates.readFromArray(array)
			);
		}
	}
}