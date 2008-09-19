package cells
{
	public class DebugGroundCell extends DebugCell
	{
		public function DebugGroundCell(x:int, y:int)
		{
			super(x, y);
		}
		
		protected override function get backgroundColor () :uint {
			return 0x008000;
		}
		
		override public function toString () :String
		{
			return "Ground cell at "+position;
		}
	}
}