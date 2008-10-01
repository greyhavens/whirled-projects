package cells
{
	import arithmetic.*;
	
	import interactions.Oilable;
	
	public class LadderCell extends PlayerCell implements Oilable
	{
		public function LadderCell(owner:Owner, position:BoardCoordinates, type:int) :void
		{
			super(owner, position);
			_owner = owner;
			_part = type;
		}
		
		public function oiled () :Cell
		{
			return new OiledLadderCell(_owner, _position, _part);
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

		override public function get objectName () :String
		{
			return "ladder";
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
		
		/** 
		 * When labelling the base, we want to point at the base of the ladder, not the side
		 * of the cell.
		 */
		override public function anchorPoint (direction:Vector) :GraphicCoordinates
		{			
			if (_part == BASE) {
				return new GraphicCoordinates(
				 	super.anchorPoint(direction).x,
				 	GraphicCoordinates.fromDisplayObject(view).translatedBy(FIRSTRUNG).y
				 );
			} else {
				return super.anchorPoint(direction);
			}
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
				
		// A ladder cell can represent various parts of a ladder.  This value determines which part
		// this one represents.
		protected var _part:int;

		// Various different ladder parts.
		public static const BASE:int = 0;
		public static const MIDDLE:int = 1;
		public static const TOP:int = 2;
				
		// The ladder is this percentage of the way down the cell.
		public static const FIRSTRUNG:Vector = 
			Vector.DOWN.multiplyByVector(Config.cellSize).multiplyByScalar(0.1);
				
		[Embed(source="../../rsrc/png/ladder-base.png")]
		public static const ladderBase:Class;
		
		[Embed(source="../../rsrc/png/ladder-middle.png")]		
		public static const ladderMiddle:Class;
		
		[Embed(source="../../rsrc/png/ladder-top.png")]
		public static const ladderTop:Class;	
	}
}