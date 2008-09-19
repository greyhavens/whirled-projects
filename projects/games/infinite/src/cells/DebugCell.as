package cells
{
	import arithmetic.*;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	/**
	 * A debug cell just shows its coordinates within the board.
	 */
	public class DebugCell extends CellBase implements Cell
	{		
		public function DebugCell (position:BoardCoordinates)
		{
			_position = position;
		}

		override public function get view () :DisplayObject 
		{
			if (_view == null) {
				_view = createView();
			}	
			return _view;
		}

		protected function createView () :DisplayObject
		{
			const s:Sprite = new Sprite();
			SpriteUtil.addBackground(s, UNIT.dx, UNIT.dy, backgroundColor);
			
			labelPosition(s);
			
			s.addEventListener(MouseEvent.MOUSE_DOWN, handleCellClicked);
			return s;			
		}
						
		protected function get backgroundColor () :uint {
			return 0x800000;
		}
		
		override public function get type () :String
		{
			return "debug";
		}
		 
		protected var _view :DisplayObject;
						
		protected const DEBUG:Boolean = false;
	}
}