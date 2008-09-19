package sprites
{
	import arithmetic.Vector;

	public class ItemSprite extends AssetSprite
	{
		public function ItemSprite(asset:Class)
		{
			super(asset, UNIT.dx, UNIT.dy);
		}

		public static const UNIT:Vector = new Vector(50,50);
	}
}