package cells.wall
{
	import cells.CellCodes;
	
	import interactions.Sabotage;
	import interactions.SabotageType;
	
	import server.Messages.CellState;

	public class OiledWallCell extends WallBaseCell implements Sabotage
	{
		public function OiledWallCell(state:CellState)
		{
			super(state.position);
			_saboteurId = state.attributes.saboteurId;
		}
		
		override public function get code () :int
		{
			return CellCodes.OILED_WALL;
		}
		
		override public function get grip () :Boolean
		{
			return false;
		}		
		
		override public function get type () :String { return "oiled wall"; }

        public function get saboteurId () :int
        {
            return _saboteurId;
        }

        public function get sabotageType () :String
        {
            return SabotageType.OILED;
        }
		
		protected var _saboteurId:int;			
	}
}