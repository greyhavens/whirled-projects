//
// $Id$

package {

import flash.display.Sprite;
import spades.Controller;
import spades.Debug;
import spades.graphics.TableSprite;
import com.whirled.game.GameControl;
import com.threerings.util.Log;

/** Main entry point for the spades game. This is required to be a Sprite by flash. It constructs 
 *  a spades controller and then adds a new TableSprite create from the controller's model. */
[SWF(width="800", height="800")]
public class Spades extends Sprite
{
    /** Constructor */
    public function Spades ()
    {
        // Override the debug function
        Debug.debug = debugPrint;

        _gameCtrl = new GameControl(this);

        var spadesCtrl :Controller = new Controller(_gameCtrl);
        var table :TableSprite = new TableSprite(spadesCtrl.model);
        addChild(table);
    }

    /** Print a string with local player info prefixed. */
    protected function debugPrint (str :String) :void
    {
        var mySeat :int = _gameCtrl.game.seating.getMyPosition();
        var myName :String = _gameCtrl.game.seating.getPlayerNames()[mySeat];
        Log.getLog(this).info("[" + myName + "@seat" + mySeat + "] " + str);
    }

    protected var _gameCtrl :GameControl;
}

}
