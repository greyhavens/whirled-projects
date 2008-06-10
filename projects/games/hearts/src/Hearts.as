//
// $Id$

package {

import flash.display.Sprite;
import hearts.Controller;
import hearts.Debug;
import hearts.Model;
import hearts.graphics.TableSprite;
import com.whirled.game.GameControl;
import com.threerings.util.Log;
import hearts.sound.SoundPlayer;
import com.whirled.contrib.card.Debug;

/** Main entry point for the hearts game. This is required to be a Sprite by flash. It constructs 
 *  a spades controller and then adds a new TableSprite create from the controller's model. */
[SWF(width="800", height="800")]
public class Spades extends Sprite
{
    /** Constructor */
    public function Spades ()
    {
        _gameCtrl = new GameControl(this);

        var mySeat :int = _gameCtrl.game.seating.getMyPosition();
        var config :Object = _gameCtrl.game.getConfig();
        var debugSeat :int = ("debugSeat" in config) ? config.debugSeat : -1;
        var fn :Function;
        if (debugSeat == -2) { // all
            fn = debugPrint;
        }
        else if (debugSeat == -1) { // none
            fn = ignore;
        }
        else if (debugSeat == mySeat) {
            fn = debugPrint;
        }
        else {
            fn = ignore;
        }

        com.whirled.contrib.card.Debug.debug = fn;
        spades.Debug.debug = fn;

        new Controller(_gameCtrl, createViews);
    }

    protected function createViews (model :Model) :void
    {
        var mySeat :int = _gameCtrl.game.seating.getMyPosition();
        var config :Object = _gameCtrl.game.getConfig();
        var soundSeat :int = ("soundSeat" in config) ? config.soundSeat : -1;
        if (soundSeat == -1 || soundSeat == mySeat) {
            new SoundPlayer(model);
        }
        addChild(new TableSprite(model));
    }

    /** Print a string with local player info prefixed. */
    protected function debugPrint (str :String) :void
    {
        var mySeat :int = _gameCtrl.game.seating.getMyPosition();
        var myName :String = _gameCtrl.game.seating.getPlayerNames()[mySeat];
        Log.getLog(this).info("[" + myName + "@seat" + mySeat + "] " + str);
    }

    protected function ignore (str :String) :void
    {
    }

    protected var _gameCtrl :GameControl;
}

}
