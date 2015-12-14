package cells.roof
{
    import sprites.CellSprite;
    
    import world.Cell;
    
    public class FlatRoofBaseView extends CellSprite
    {
        public function FlatRoofBaseView(cell:Cell)
        {
            super(cell, flatRoofBase);
        }

        [Embed(source="../../../rsrc/png/flat-roof-base.png")]
        public static const flatRoofBase:Class;     
    }
}