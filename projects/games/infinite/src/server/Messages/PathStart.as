package server.Messages
{
	import paths.Path;
	
	public class PathStart
	{
		public var userId:int;
		public var path:Path;
		
		public function PathStart(userId:int, path:Path)
		{
		  this.userId = userId;
		  this.path = path;
		}
	}
}