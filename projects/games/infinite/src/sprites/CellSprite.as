package sprites
{
	public class CellSprite extends AssetSprite
	{
		public function CellSprite(asset:Class)
		{
			super(asset, CellBase.UNIT.dx, CellBase.UNIT.dy);
		}						
	}
}