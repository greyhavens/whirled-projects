package sprites
{
	public class PlayerSprite extends AssetSprite
	{
		public function PlayerSprite()
		{
			super(simplePlayer, CellBase.UNIT.dx, CellBase.UNIT.dy);
		}

		[Embed(source="png/simple-player.png")]
		protected static const simplePlayer:Class;			
	}
}