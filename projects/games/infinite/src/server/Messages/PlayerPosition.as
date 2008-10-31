package server.Messages
{
	import arithmetic.BoardCoordinates;
	
	import flash.utils.ByteArray;
	
	/**
	 * An update of a single user's position.
	 */
	public class PlayerPosition implements Serializable
	{
		public var userId:int;
		public var level:int;
		public var position:BoardCoordinates; 
		
		public function PlayerPosition(userId:int, level:int, position:BoardCoordinates)
		{
			this.userId = userId;
			this.level = level;
			this.position = position;
		}
		
		public function writeToArray (array:ByteArray) :ByteArray
		{
			array.writeInt(userId);
			array.writeInt(level);
			position.writeToArray(array);
			return array;
		}
		
		public static function readFromArray (array:ByteArray) :PlayerPosition
		{
			return new PlayerPosition(
			    array.readInt(),
			    array.readInt(),
			    BoardCoordinates.readFromArray(array)
			);			
		}
		
		public function toString () :String
		{
			return "player "+userId+" at "+position+" on level "+level;
		}
	}
}
