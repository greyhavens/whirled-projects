package sprites
{
	public class CellSprite extends AssetSprite
	{
		public function CellSprite(asset:Class)
		{
			super(asset, Config.cellSize.dx, Config.cellSize.dy);
		}						
	}
}