package joingame.model
{
	/**
	 * Represents a type of join of pieces.
	 * This information is used to decide the action, e.g. attack  or build up.
	 */ 
	public class JoinGameJoin
	{
		public function JoinGameJoin(width: int, height:int, color:int, type:int=0)
		{
			_widthInPieces = width;
			_heighInPiecest = height;
			_color = color;
			_joinType = type;
			_pieces = new Array();
			
			attackRow = -1;
			_buildCol = -1;
		}
		
		
		public function isContainsPieceIndex(index: int): Boolean
		{
			for(var i:int  = 0; i < _pieces.length; i++)
			{
				if(index ==  _pieces[i])
				{
					return true;
				} 
			}
			return false;
		}
		
		
		
		public var _widthInPieces: int;
		public var _heighInPiecest: int;
		public var _color: int;
		public var _joinType: int;
		public var _pieces: Array;
		
		public var attackRow:int;
		
		//Attack left (-1) or right (1), or both (0)
		public var attackSide: int;
		
		public var _buildCol: int;
		
		public static const LEFT :int = -1;
		public static const RIGHT :int = 1;
		public static const ATTACK_BOTH :int = 0;
	}
}