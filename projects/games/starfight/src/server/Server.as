package server {

import com.whirled.ServerObject;

public class Server extends ServerObject
{
    public function Server ()
    {
        _gameMgr = new ServerGameManager(this);
    }

    protected var _gameMgr :ServerGameManager;
}

}
