package world.board
{
	import arithmetic.BoardCoordinates;
	import arithmetic.VoidBoardRectangle;
	
	import cells.ground.GroundCell;
	import cells.wall.WallBaseCell;
	import cells.wall.WallCell;
	
	import world.Cell;
	import world.level.Level;
	
	
	public class BlankBoard implements Board
	{
		public function BlankBoard() 
		{
		}
		
		public function cellAt (position:BoardCoordinates) :Cell
		{
			const created:Cell = makeCell(position);
			created.addToLevel(_level);
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
        
        protected function set level (level:Level) :void
        {
        	_level = level;
        }
        
        protected var _level:Level;
	}
}