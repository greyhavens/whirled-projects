package cells.ladder
{
	import arithmetic.*;
	
	import cells.CellCodes;
	import cells.PlayerCell;
	
	import interactions.Oilable;
    import world.Cell;
	
	public class LadderBaseCell extends PlayerCell implements Oilable
	{
		public function LadderBaseCell(owner:Owner, position:BoardCoordinates) :void
		{
			super(owner, position);
		}
		
		override public function get code () :int
		{
			return CellCodes.LADDER_BASE;
		}
		
		public function oiled () :Cell
		{
			return new OiledLadderBaseCell(_owner, _position);
		}
								
		override public function get climbLeftTo():Boolean { return true; }
		override public function get climbRightTo():Boolean { return true; }		
		override public function get climbUpTo() :Boolean { return false; }
		override public function get climbDownTo() :Boolean { return true; }

		override public function get objectName () :String
		{
			return "ladder";
		}

		override public function get type () :String 
		{ 
			return "ladder base";
		}	

		override public function adjacentPartOf (other:Cell) :Boolean
		{
			return (other is LadderMiddleCell || other is LadderTopCell) && other.position.above(position) 
		}
						
		// A ladder cell can represent various parts of a ladder.  This value determines which part
		// this one represents.
		protected var _part:int;

		// Various different ladder parts.
		public static const BASE:int = 0;
		public static const MIDDLE:int = 1;
		public static const TOP:int = 2;				
	}
}