//
// $Id$

package {

import flash.display.Sprite;
import spades.Spades;
import spades.Debug;
import com.whirled.game.GameControl;
import com.threerings.util.Log;

[SWF(width="800", height="800")]
public class Spades extends Sprite
{
    /** Constructor */
    public function Spades ()
    {
        // Override the debug function
        Debug.debug = debugPrint;

        _gameCtrl = new GameControl(this);
        _game = new spades.Spades(_gameCtrl);
        addChild(_game);
    }

    /** Print a string with local player info prefixed. */
    protected function debugPrint (str :String) :void
    {
        var mySeat :int = _gameCtrl.game.seating.getMyPosition();
        var myName :String = _gameCtrl.game.seating.getPlayerNames()[mySeat];
        Log.getLog(this).info("[" + myName + "@seat" + mySeat + "] " + str);
    }

    protected var _game :spades.Spades;
    protected var _gameCtrl :GameControl;
}

}
