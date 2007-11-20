package modes
{

import mx.containers.Canvas;

import com.threerings.ezgame.util.GameMode;
import com.threerings.ezgame.util.GameModeStack;


/**
 * Simple canvas with stubbed-out game mode functions.
 */
public class GameModeCanvas extends Canvas
    implements GameMode
{
    public function GameModeCanvas (modes :GameModeStack)
    {
        super();
        _modes = modes;
    }

    /** Returns the current GameModeStack. */
    public function getGameModeStack () :GameModeStack
    {
        return _modes;
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

    protected var _modes :GameModeStack;
}
}
