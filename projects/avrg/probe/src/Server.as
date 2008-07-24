package {

import com.whirled.ServerObject;
import com.whirled.AVRServerGameControl;

public class Server extends ServerObject
{
    public function Server ()
    {
        _gameCtrl = new AVRServerGameControl(this);
        trace("Hello world!");
    }

    protected var _gameCtrl :AVRServerGameControl;
}

}
