//
// $Id$

package {

import flash.display.Sprite;
import spades.Spades;
import com.whirled.game.GameControl;

[SWF(width="800", height="800")]
public class Spades extends Sprite
{
    public function Spades ()
    {
        _gameCtrl = new GameControl(this);

        _game = new spades.Spades(_gameCtrl);
        addChild(_game);
    }

    protected var _game :spades.Spades;
    protected var _gameCtrl :GameControl;
}

}
