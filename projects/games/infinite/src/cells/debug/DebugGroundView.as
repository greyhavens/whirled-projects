package cells.debug
{
	public class DebugGroundView extends DebugView
	{
		public function DebugGroundView(cell:Cell)
		{
			super(cell);
		}

        protected override function get backgroundColor () :uint {
            return 0x008000;
        }
	}
}