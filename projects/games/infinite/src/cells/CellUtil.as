package cells
{
    import server.Messages.CellState;
    
    import world.Cell;
    
    public class CellUtil
    {
        public static function sabotagedState(cell:Cell, saboteur:Owner) :CellState
        {
            const state:CellState = cell.state;
            state.attributes.saboteur = saboteur.id;
            return state;
        }
    }
}