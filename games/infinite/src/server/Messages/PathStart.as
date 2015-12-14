package server.Messages
{
	import flash.utils.ByteArray;
	
	import paths.Path;
	
	public class PathStart implements Serializable
	{
		public var userId:int;
		public var path:Path;
		
		public function PathStart(userId:int, path:Path)
		{
		  this.userId = userId;
		  this.path = path;
		}
		
		public function writeToArray(array:ByteArray) :ByteArray
		{
			array.writeInt(userId);
			path.writeToArray(array);
			return array;
		}
		
		public static function readFromArray(array:ByteArray) :PathStart
		{
			return new PathStart(
			     array.readInt(),
			     Path.readFromArray(array)
			)
		}
	}
}