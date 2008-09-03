//
// $Id$
//

package ghostbusters {

import flash.display.Sprite;

import com.whirled.avrg.AVRGameControl;

import ghostbusters.client.Game;

[SWF(width="700", height="500")]
public class GH extends Sprite
{
    public function GH ()
    {
        _game = new Game(new AVRGameControl(this));
        this.addChild(_game);
    }

    protected var _game :Game;
}
}
