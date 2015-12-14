package cells.views
{
	import sprites.CellSprite;
	
	public class BackgroundView extends CellSprite
	{
		public BackgroundView(cell:Cell) {
			super(initalAsset);
			
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
	}
}