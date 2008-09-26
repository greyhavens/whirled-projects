package
{
	import arithmetic.*;
	
	import cells.*;
	
	import items.*;
	
	public class SimpleBoard implements Board
	{
		public function SimpleBoard (level:Level)
		{
			
		}

		public function cellAt (position:BoardCoordinates):Cell
		{
			switch (position.y) {
				case 1: return new GroundCell(position);								
			}
			
			switch (position.x) {
				case 10:
					switch (position.y) {
						case 0: 
							return new LadderCell(Nobody.NOBODY, position, LadderCell.BASE);
						case -1: 
						case -2:
							return new LadderCell(Nobody.NOBODY, position, LadderCell.MIDDLE);
						case -3: 
							return new LadderCell(Nobody.NOBODY, position, LadderCell.TOP); 
					};
					break;
					
				case 5:
					switch (position.y) {
						case 0:
							return new LadderCell(Nobody.NOBODY, position, LadderCell.BASE);
						case -1:
						case -2:
						case -3:
						case -4:
						case -5:
							return new LadderCell(Nobody.NOBODY, position, LadderCell.MIDDLE);
						case -6:
							return new LadderCell(Nobody.NOBODY, position, LadderCell.TOP);
					};
					break;

				case -3:
					switch (position.y) {
						case 0:
							return new FruitMachineCell(position, FruitMachineCell.ACTIVE, new ObjectBox(new Spring()));
					};
					break;

				case -5:
					switch (position.y) {
						case 0:
							return new FruitMachineCell(position, FruitMachineCell.ACTIVE, new ObjectBox(new Teleporter()));
					};
					break;
					
				case -7:
					switch (position.y) {
						case 0:
							return new FruitMachineCell(position, FruitMachineCell.ACTIVE, new ObjectBox(new OilCan()));
					};
					break;
					
				case -11:
					switch (position.y) {
						case 0:
							return new FruitMachineCell(position, FruitMachineCell.ACTIVE, new ObjectBox(new Ladder(3)));
					};
					break;		
			}
			
			switch (position.y) {
				case 0: return new WallBaseCell(position);												
			}

			return new WallCell(position);			
		}
		
		public function hasSidewaysPath (start:BoardCoordinates, finish:BoardCoordinates):Boolean
		{
			// for now, there is no path between two positions that are not on the same level.
			if (start.y != finish.y) {
				return false;
			}
			
			// you can't move to a position that you already occupy
			if (start.x == finish.x) {
				return false;
			}
			
			return true;	
		}
				
		public function get startingPosition ():BoardCoordinates
		{
			return new BoardCoordinates(0,0);
		}		
	}
}