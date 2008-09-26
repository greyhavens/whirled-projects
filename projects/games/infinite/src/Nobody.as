package
{
	import flash.display.DisplayObject;

	public class Nobody implements Owner
	{
		public function Nobody(name:String)
		{
			_name = name;
		}

		public function get name () :String
		{
			return _name;
		}
		
		protected var _name:String;
		
		public static const NOBODY:Nobody = new Nobody("nobody");
	}
}