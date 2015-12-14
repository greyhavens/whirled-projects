package cells.roof
{
    public class FlatRoofCell extends BackgroundCell
    {
        public function FlatRoofCell(position:BoardCoordinates)
        {
            super(position);
        }
        
        override public function get code () :int
        {
            return CellCodes.FLAT_ROOF;
        }
    
        override public function get type () :String { return "flat roof"; }    
    }
}