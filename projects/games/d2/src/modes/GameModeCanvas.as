package modes {

import mx.containers.Canvas;

import com.whirled.contrib.GameMode;
import com.whirled.contrib.GameModeStack;


/**
 * Simple canvas with stubbed-out game mode functions.
 */
public class GameModeCanvas extends Canvas
    implements GameMode
{
    public function GameModeCanvas (main :Main)
    {
        super();
        _main = main;
    }

    // from interface GameMode
    public function pushed () :void
    {
        // no op
    }
    
    // from interface GameMode
    public function popped () :void
    {
        // no op
    }

    // from interface GameMode
    public function pushedOnto (mode :GameMode) :void
    {
        // no op
    }

    // from interface GameMode
    public function poppedFrom (mode :GameMode) :void
    {
        // no op
    }

    protected var _main :Main;
}
}
