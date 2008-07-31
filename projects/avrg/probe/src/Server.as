package {

import com.whirled.avrg.AVRServerGameControl;
import com.whirled.ServerObject;

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
