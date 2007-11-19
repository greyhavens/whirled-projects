package modes
{

import mx.containers.Canvas;

import com.whirled.util.GameMode;
import com.whirled.util.GameModeManager;

/**
 * Simple canvas with stubbed-out game mode functions.
 */
public class GameModeCanvas extends Canvas
    implements GameMode
{
    public function GameModeCanvas (modes :GameModeManager)
    {
        super();
        _modes = modes;
    }

    /** Returns the current GameModeManager. */
    public function getGameModeManager () :GameModeManager
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

    protected var _modes :GameModeManager;
}
}
