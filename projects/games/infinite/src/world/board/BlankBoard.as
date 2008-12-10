package world.board
{
	import arithmetic.BoardCoordinates;
	
	import cells.ground.GroundCell;
	import cells.roof.BlackSkyCell;
	import cells.roof.NarrowRoofCell;
	import cells.wall.WallBaseCell;
	import cells.wall.WallCell;
	
	import world.Cell;
	import world.level.Level;
	
	
	public class BlankBoard implements Board
	{
		public function BlankBoard(number:int, height:int) 
		{
			_number = number;
		    _height = height;
		}
		
		public function cellAt (position:BoardCoordinates) :Cell
		{
			const created:Cell = makeCell(position);
			created.addToLevel(_level);
			return created;
		}
		
        public function makeCell (position:BoardCoordinates) :Cell
        {
            if (position.y < -_height) {
                return new BlackSkyCell(position);   
            } 
            
            switch (position.y) {
                case -_height: return new NarrowRoofCell(position);
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
        	return "a blank board "+_height+" cells high for level "+_level;
        }
        
        protected function set level (level:Level) :void
        {
        	_level = level;
        }
        
        public function get levelNumber () :int
        {
        	return _number;
        }
        
        protected var _number:int
        protected var _level:Level;
        protected var _height:int;
	}
}