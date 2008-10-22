package world.board
{
	import arithmetic.BoardCoordinates;
	
	import cells.fruitmachine.FruitMachineCell;
	import cells.ground.GroundCell;
	import cells.ladder.LadderBaseCell;
	import cells.ladder.LadderMiddleCell;
	import cells.ladder.LadderTopCell;
	import cells.wall.WallBaseCell;
	import cells.wall.WallCell;
	
	import items.ladder.Ladder;
	import items.oilcan.OilCan;
	import items.spring.Spring;
	import items.teleporter.Teleporter;
	
	import world.Cell;
	
	
	public class BlankBoard implements Board
	{
		public function BlankBoard() 
		{
		}
		
        public function cellAt (position:BoardCoordinates) :Cell
        {
            switch (position.y) {
                case 1: return new GroundCell(position);                               
                case 0: return new WallBaseCell(position);                                             
                default: return new WallCell(position);          
            }
        }

        public function get startingPosition ():BoardCoordinates
        {
            return new BoardCoordinates(0,0);
        }       
	}
}