package world.board
{
	import arithmetic.BoardCoordinates;
	
	import cells.CellWorld;
	import cells.ground.GroundCell;
	import cells.wall.WallBaseCell;
	import cells.wall.WallCell;
	
	import world.Cell;
	
	
	public class BlankBoard implements Board
	{
		public function BlankBoard(world:CellWorld) 
		{
			_world = world;
		}
		
		public function cellAt (position:BoardCoordinates) :Cell
		{
			const created:Cell = makeCell(position);
			created.addToWorld(_world);
			return created;
		}
		
        public function makeCell (position:BoardCoordinates) :Cell
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
        
        public function toString () :String
        {
        	return "a blank board";
        }
        
        protected var _world:CellWorld;
	}
}