package cells.ladder
{
	import arithmetic.*;
	
	import cells.CellCodes;
	import cells.PlayerCell;
	
	import interactions.Oilable;
    import world.Cell;
	
	public class LadderMiddleCell extends PlayerCell implements Oilable
	{
		public function LadderMiddleCell(owner:Owner, position:BoardCoordinates) :void
		{
			super(owner, position);
		}
		
		override public function get code () :int
		{
			return CellCodes.LADDER_MIDDLE;
		}
		
		public function oiled () :Cell
		{
			return new OiledLadderMiddleCell(_owner, _position);
		}

		override public function get climbLeftTo():Boolean { return true; }
		override public function get climbRightTo():Boolean { return true; }
		override public function get climbUpTo() :Boolean { return true; }
		override public function get climbDownTo() :Boolean	{ return true; }

		override public function get objectName () :String
		{
			return "ladder";
		}

		override public function get type () :String 
		{ 
			return "ladder middle";
		}	

		override public function adjacentPartOf (other:Cell) :Boolean
		{
			if ((other is LadderMiddleCell || other is LadderTopCell) && other.position.above(position))
			{
				return true;
			} 
			else if ((other is LadderMiddleCell || other is LadderBaseCell) && other.position.below(position)) 
			{
				return true;
			}
			else {
				return false;
			}									
		}						
	}
}