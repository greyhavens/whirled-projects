package cells.ladder
{
	import arithmetic.*;
	
	import cells.CellCodes;
	import cells.PlayerCell;
	
	import interactions.Oilable;
    import world.Cell;
	
	public class LadderTopCell extends PlayerCell implements Oilable
	{
		public function LadderTopCell(owner:Owner, position:BoardCoordinates) :void
		{
			super(owner, position);
			_owner = owner;
		}
		
		override public function get code () :int
		{
			return CellCodes.LADDER_TOP;
		}
		
		public function oiled () :Cell
		{
			return new OiledLadderTopCell(_owner, _position);
		}
								
		override public function get climbLeftTo():Boolean { return true; }
		override public function get climbRightTo():Boolean { return true; }		
		override public function get climbUpTo() :Boolean { return true; }
		override public function get climbDownTo() :Boolean { return false; }

		override public function get objectName () :String
		{
			return "ladder";
		}

		override public function get type () :String 
		{ 
			return "ladder top";
		}	

		override public function adjacentPartOf (other:Cell) :Boolean
		{				
			return (other is LadderMiddleCell || other is LadderBaseCell) && other.position.below(position)  
		}						
	}
}