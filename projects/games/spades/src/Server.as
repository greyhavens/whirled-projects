package {

import flash.display.DisplayObject;
import com.whirled.game.GameControl;
import spades.Controller;

public class Server extends DisplayObject
{
    public function Server ()
    {
        new Controller(new GameControl (this), null);
    }
}

}
