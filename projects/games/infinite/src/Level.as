package
{
	public class Level
	{
		public function Level(height:int)		
		{
			_height = height;
		}

		public function get height () :int
		{
			return _height;
		}

		protected var _height:int;
	}
}
