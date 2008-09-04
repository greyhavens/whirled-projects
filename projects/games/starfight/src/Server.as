package {

import com.whirled.ServerObject;

public class Server
{
    public function Server ()
    {
        _gameMgr = new GameManager(new ServerObject());
    }

    protected var _gameMgr :GameManager;
}

}
