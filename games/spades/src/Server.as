package {

import com.whirled.ServerObject;
import com.whirled.game.GameControl;
import spades.Controller;

public class Server extends ServerObject
{
    public function Server ()
    {
        new Controller(new GameControl (this), null);
    }
}

}
