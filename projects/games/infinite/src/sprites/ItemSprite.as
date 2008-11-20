package sprites
{
	import arithmetic.Vector;

	public class ItemSprite extends AssetSprite
	{
		public var position:int;

		public function ItemSprite(asset:Class)
		{
			super(asset, Config.itemSize.dx, Config.itemSize.dy);
		}
        
        public function greyOut() :void
        {
        	darken(0.75);
        }
        
        public function ungrey() :void
        {
        	clearOverlay();
        }
	}
}
