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
		
		public function get id () :int 
		{
		    return ID;
		}
		
		protected var _name:String;
		
		public static const NOBODY:Nobody = new Nobody("nobody");
		public static const ID:int = 0;
	}
}