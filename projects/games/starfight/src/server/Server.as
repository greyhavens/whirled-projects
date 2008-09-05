package server {

import com.whirled.ServerObject;

import server.*;

public class Server
{
    public function Server ()
    {
        _gameMgr = new GameManager(new ServerObject());
        _gameMgr.firstStart();
    }

    protected var _gameMgr :GameManager;
}

}
