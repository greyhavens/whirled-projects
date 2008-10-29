package server.Messages
{
	import arithmetic.BoardCoordinates;
	
	import flash.utils.ByteArray;
	
	public class LevelEntered implements Serializable
	{
		public var userId:int;
		public var level:int;
		public var position:BoardCoordinates; 
		
		public function LevelEntered(userId:int, level:int, position:BoardCoordinates)
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
		
		public static function readFromArray (array:ByteArray) :LevelEntered
		{
			return new LevelEntered(
			    array.readInt(),
			    array.readInt(),
			    BoardCoordinates.readFromArray(array)
			);			
		}
	}
}
