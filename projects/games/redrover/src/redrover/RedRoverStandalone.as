package redrover {

import redrover.server.*;

[SWF(width="700", height="500", frameRate="30")]
public class RedRoverStandalone extends RedRover
{
    public static function DEBUG_REMOVE_ME () :void
    {
        var c :Class = Server;
    }

    public function RedRoverStandalone ()
    {
        DEBUG_REMOVE_ME();
        Constants.DEBUG_LOAD_LEVELS_FROM_DISK = true;
    }

}

}
