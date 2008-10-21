package cells.debug
{
	import cells.views.BaseView;
	
	import sprites.SpriteUtil;
	
	public class DebugView extends BaseView
	{
		public function DebugView(cell:Cell)
		{
			super(cell);
		}
                        
        override protected function get backgroundColor () :uint {
            return 0x800000;
        }
	}
}