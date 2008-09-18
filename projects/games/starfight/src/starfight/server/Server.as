package starfight.server {

import com.whirled.ServerObject;

public class Server extends ServerObject
{
    public function Server ()
    {
        _appCtrl = new ServerAppController(this);
    }

    protected var _appCtrl :ServerAppController;
}

}
