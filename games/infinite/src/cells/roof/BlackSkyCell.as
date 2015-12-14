package cells.roof
{
    import arithmetic.BoardCoordinates;
    
    import cells.BackgroundCell;
    import cells.CellCodes;
    
    public class BlackSkyCell extends BackgroundCell
    {
        public function BlackSkyCell(position:BoardCoordinates)
        {
            super(position);
        }
        
        override public function get code () :int
        {
            return CellCodes.BLACK_SKY;
        }
    
        override public function get type () :String { return "black sky"; }    
    }
}