package cells
{
	import arithmetic.*;
	
	import interactions.Oilable;
	
	public class LadderCell extends BackgroundCell implements Oilable
	{
		public function LadderCell(position:BoardCoordinates, type:int) :void
		{
			super(position);
			_part = type;
		}
		
		public function oiled () :Cell
		{
			return new OiledLadderCell(_position, _part);
		}
		
		override protected function get initialAsset() :Class
		{
			switch (_part) {
				case BASE: return ladderBase;
				case MIDDLE: return ladderMiddle;
				case TOP: return ladderTop;
				default: return super.initialAsset;
			}
		}

		override public function get climbLeftTo():Boolean { return true; }
		override public function get climbRightTo():Boolean { return true; }
		
		override public function get climbUpTo() :Boolean 
		{
			switch (_part) {
				case TOP: return true;
				case MIDDLE: return true;
			} 	
			
			return false;
		}

		override public function get climbDownTo() :Boolean
		{
			switch (_part) { 
				case BASE: return true;
				case MIDDLE: return true;
			}
			
			return false;
		}

		override public function get type () :String 
		{ 
			switch (_part) {
				case BASE: return "ladder base";
				case MIDDLE: return "ladder middle";
				case TOP: return "ladder top";
			}
			return "unknown ladder section";	
		}	

		override public function adjacentPartOf (cell:Cell) :Boolean
		{
			const other:LadderCell = cell as LadderCell;
			if (other == null) {
				return false;
			}
				
			switch (_part) {
				case BASE:
					return other.position.above(position) && (other._part == MIDDLE || other._part == TOP)
					  
				case MIDDLE:
					if (other.position.above(position) && (other._part == MIDDLE || other._part == TOP))
					{
						return true;
					} 
					else if (other.position.below(position) && (other._part == MIDDLE || other._part == BASE)) 
					{
						return true;
					}
					else {
						return false;
					}
										
				case TOP:
					return other.position.below(position) && (other._part == MIDDLE || other._part == BASE)
				
				default: return false;
			}
		}

		protected var _part:int;

		public static const BASE:int = 0;
		public static const MIDDLE:int = 1;
		public static const TOP:int = 2;		
				
		[Embed(source="png/ladder-base.png")]
		public static const ladderBase:Class;
		
		[Embed(source="png/ladder-middle.png")]		
		public static const ladderMiddle:Class;
		
		[Embed(source="png/ladder-top.png")]
		public static const ladderTop:Class;	
	}
}