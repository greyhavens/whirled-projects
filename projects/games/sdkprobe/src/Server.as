package {

import com.whirled.ServerObject;
import com.whirled.GameControl;

public class Server extends ServerObject
{
    public function Server ()
    {
        _ctrl = new GameControl(this);
    }

    protected var _ctrl :GameControl;
}

}
