package ghostbusters.client.fight.ouija {
    
import flash.events.Event;

public class BoardSelectionEvent extends Event
{
    public static const NAME :String = "BoardSelectionEvent";
    
    public function BoardSelectionEvent (selectionIndex :int)
    {
        super(NAME, false, false);
        
        _selectionIndex = selectionIndex;
    }
    
    public function get selectionIndex () :int
    {
        return _selectionIndex;
    }
    
    public function get selectionString () :String
    {
        return Board.selectionIndexToString(_selectionIndex);
    }
    
    protected var _selectionIndex :int;
    
}

}
