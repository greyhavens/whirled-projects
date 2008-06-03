package {

import com.whirled.game.GameControl;
import com.whirled.game.StateChangedEvent;

public class Board
{
    public function Board (ctrl :GameControl)
    {
        _ctrl = ctrl;
    }

    public function reset ()
    {
        var empty :Array = [0, 0, 0, 0, 0, 0, 0, 0, 0];
        _ctrl.net.set("BOARD", empty);
    }

    public function reset ()
    {
        var empty :Array = [0, 0, 0, 0, 0, 0, 0, 0, 0];
        _ctrl.net.set("BOARD", empty);
    }

    protected var _ctrl :GameControl;
}

}
