package cells
{
	import arithmetic.*;
	
	import flash.display.DisplayObject;
	
	import sprites.*;

	public class BackgroundCell extends CellBase
	{
		public function BackgroundCell(position:BoardCoordinates)
		{
			super(position);
		}
		
		override public function get view () :DisplayObject
		{
			if (_sprite == null) {
				_sprite = new CellSprite(initialAsset);
				registerEventHandlers(_sprite);
				if (DEBUG) {
					labelPosition(_sprite);
				}
			}
			return _sprite;
		}
		
		
		
		/**
		 * Discard the sprite associated with this cell.  Useful if a cell is no longer being
		 * displayed but is being stored off screen for its state.
		 */
		protected function discardSprite () :void
		{
			_sprite = null;
		}
		
		protected function get sprite () :CellSprite
		{
			if (_sprite == null) {
				const made:DisplayObject = view;
			}
			return _sprite;
		}		
		
		protected function updateAsset() :void
		{
			if (_sprite !=null) {
				_sprite.asset = currentAsset
			}
		}
		
		protected function get currentAsset() :Class
		{
			return initialAsset;
		}
			
		protected function get initialAsset() :Class
		{
			trace ("no artwork supplied for "+this);
			return new BackgroundPanels.error();
		}
		
		// This really should be private since the overriding classes can't know the rules for
		// whether it's null or not.
		protected var _sprite:CellSprite;
	}
}