package cells.views
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import sprites.SpriteUtil;
	
	public class BaseView extends Sprite
	{
		public function BaseView(cell:Cell)
		{
			_cell = cell;
			const s:Sprite = new Sprite();
			SpriteUtil.addBackground(this, Config.cellSize.dx, Config.cellSize.dy, SpriteUtil.GREY);
			labelPosition(this);
		}
		
		/**
		 * Add a label with the current board position to the supplied container
		 */
		protected function labelPosition (s:DisplayObjectContainer) :void
		{
			const l:TextField = new TextField();
			l.text = "(" + _cell.position.x + ", " + _cell.position.y + ")";
			s.addChild(l);		
		}
		
		protected var _cell:Cell;
	}
}