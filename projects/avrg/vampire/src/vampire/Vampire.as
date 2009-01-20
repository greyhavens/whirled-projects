//
// $Id$
//

package vampire {

import com.threerings.util.Log;

import flash.display.Sprite;

import vampire.client.VampireMain;


[SWF(width="700", height="500")]
public class Vampire extends Sprite
{
    public function Vampire ()
    {
        trace("Vampire()");
        
        addChild( new VampireMain() );
        
//        _game = new Game(new AVRGameControl(this));
//        this.addChild(_game);
    }

//    protected var _game :Game;
}
}
