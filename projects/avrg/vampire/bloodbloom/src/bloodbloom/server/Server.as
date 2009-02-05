package bloodbloom.server {

import com.whirled.ServerObject;
import com.whirled.game.GameControl;

public class Server extends ServerObject
{
    public function Server ()
    {
        ServerCtx.gameCtrl = new GameControl(this, false);
    }
}

}
