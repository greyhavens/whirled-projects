package cells.ladder
{
	public class OiledLadderBaseView extends LadderBaseView
	{
		public function OiledLadderBaseView(cell:Cell)
		{
			super(cell);
		}

		override protected function get ladderAsset () :Class
		{
			return oiledLadderBase;
		}

		[Embed(source="../../../rsrc/png/ladder-base-oiled.png")]
		public static const oiledLadderBase:Class;	
	}
}