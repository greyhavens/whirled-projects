package cells.views
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import sprites.SpriteUtil;
	
	public class BaseView extends Sprite implements CellView
	{
		public function BaseView(cell:Cell)
		{
			_cell = cell;
            SpriteUtil.addBackground(this, Config.cellSize.dx, Config.cellSize.dy, backgroundColor);            
			labelPosition(this);
		}
		
		protected function get backgroundColor () :uint
		{
			return SpriteUtil.GREY;
		}
				
		protected var _cell:Cell;
	}
}