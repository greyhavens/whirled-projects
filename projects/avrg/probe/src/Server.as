package {

import com.whirled.ServerObject;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.contrib.avrg.probe.ServerModule;

public class Server extends ServerObject
{
    public function Server ()
    {
        _ctrl = new AVRServerGameControl(this);
        _module = new ServerModule(_ctrl);
    }

    protected var _ctrl :AVRServerGameControl;
    protected var _module :ServerModule;
}
}
