package {

import com.whirled.ServerObject;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.contrib.avrg.probe.ServerStub;

public class Server extends ServerObject
{
    public function Server ()
    {
        _ctrl = new AVRServerGameControl(this);
        _stub = new ServerStub(_ctrl);
    }

    protected var _ctrl :AVRServerGameControl;
    protected var _stub :ServerStub;
}
}
