//
// $Id$

package locksmith.server {

import com.whirled.ServerObject;
import com.whirled.game.GameControl;

public class Server extends ServerObject
{
    public function Server ()
    {
        _control = new ServerLocksmithController(this);
    }

    protected var _control :ServerLocksmithController;
}
}
