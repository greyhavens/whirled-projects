package server.Messages
{
	import flash.utils.ByteArray;

	public class EnterLevel implements Serializable
	{
		public var level:int;
		public var height:int;
		public var position:PlayerPosition;
		
		public function EnterLevel(level:int, height:int, position:PlayerPosition)
		{
			this.level = level;
			this.height = height;
			this.position = position;
		}

		public function writeToArray(array:ByteArray) :ByteArray
		{
			array.writeInt(level);
			array.writeInt(height);
			position.writeToArray(array);
			return array;
		}
		
		public static function readFromArray(array:ByteArray) :EnterLevel
		{
			return new EnterLevel(
			    array.readInt(),
			    array.readInt(),
			    PlayerPosition.readFromArray(array)
			);
		}	
	}
}