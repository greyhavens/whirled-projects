package cells.views
{
    import world.Cell;
    
    public interface Poolable extends CellView
    {       
        function prepareForPool () :void;
        
        function unpool (cell:Cell, time:Number) :void;
    }
}