package loopbacktest {

import com.whirled.ServerObject;

public class Server extends ServerObject
{
    public function Server ()
    {
        _controller = new ServerController(this);
    }

    protected var _controller :ServerController;
}

}
