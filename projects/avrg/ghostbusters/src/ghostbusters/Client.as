//
// $Id$
//

package ghostbusters {

import flash.display.Sprite;

import com.whirled.avrg.AVRGameControl;

import ghostbusters.client.Game;

[SWF(width="700", height="500")]
public class Client extends Sprite
{
    public function Client ()
    {
        _game = new Game(new AVRGameControl(this));
        this.addChild(_game);
    }

    protected var _game :Game;
}
}
