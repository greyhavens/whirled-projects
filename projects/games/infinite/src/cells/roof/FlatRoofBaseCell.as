package cells.roof
{
    public class FlatRoofBaseCell extends BackgroundCell
    {
        public function FlatRoofBaseCell(position:BoardCoordinates)
        {
            super(position);
        }
        
        override public function get code () :int
        {
            return CellCodes.FLAT_ROOF_BASE;
        }
    
        override public function get type () :String { return "flat roof base"; }    
    }
}