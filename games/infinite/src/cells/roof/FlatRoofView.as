package cells.roof
{
    import sprites.CellSprite;
    
    import world.Cell;
    
    public class FlatRoofView extends CellSprite
    {
        public function FlatRoofView(cell:Cell)
        {
            super(cell, flatRoof);
        }

        [Embed(source="../../../rsrc/png/flat-roof.png")]
        public static const flatRoof:Class;     
    }
}