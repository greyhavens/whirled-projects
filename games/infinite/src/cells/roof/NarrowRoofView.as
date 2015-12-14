package cells.roof
{
    import sprites.CellSprite;
    
    import world.Cell;
    
    public class NarrowRoofView extends CellSprite
    {
        public function NarrowRoofView(cell:Cell)
        {
            super(cell, narrowRoof);
        }

        [Embed(source="../../../rsrc/png/narrow-roof.png")]
        public static const narrowRoof:Class;     
    }
}