package sprites
{
	public class PlayerSprite extends AssetSprite
	{
		public function PlayerSprite()
		{
			super(simplePlayer, Config.cellSize.dx, Config.cellSize.dy);
		}

		[Embed(source="../../rsrc/png/simple-player.png")]
		protected static const simplePlayer:Class;			
	}
}