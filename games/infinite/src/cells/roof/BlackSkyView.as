package cells.roof
{
    import sprites.CellSprite;
    
    import world.Cell;
    
    public class BlackSkyView extends CellSprite
    {
        public function BlackSkyView(cell:Cell)
        {
            super(cell, blackSky);
        }

        [Embed(source="../../../rsrc/png/black-sky.png")]
        public static const blackSky:Class;     
    }
}