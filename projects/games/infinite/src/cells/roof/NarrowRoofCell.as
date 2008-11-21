package cells.roof
{
    import arithmetic.BoardCoordinates;
    
    import cells.BackgroundCell;
    import cells.CellCodes;
    
    public class NarrowRoofCell extends BackgroundCell
    {
        public function NarrowRoofCell(position:BoardCoordinates)
        {
            super(position);
        }
        
        override public function get code () :int
        {
            return CellCodes.NARROW_ROOF;
        }
    
        override public function get type () :String { return "narrow roof"; }    
    }
}