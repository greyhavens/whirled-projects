package sprites
{
	import arithmetic.Vector;

	public class ItemSprite extends AssetSprite
	{
		public var position:int;

		public function ItemSprite(asset:Class)
		{
			super(asset, UNIT.dx, UNIT.dy);
		}
        
        public function greyOut() :void
        {
        	darken(0.75);
        }
        
        public function ungrey() :void
        {
        	clearOverlay();
        }

		public static const UNIT:Vector = new Vector(50,50);
	}
}