package {

import flash.events.Event;

public class Controller
{
    public function Controller (game :Defense)
    {
        _game = game;
    }

    public function handleUnload (event : Event) : void
    {
        trace("CONTROLLER UNLOAD");
    }
    
    protected var _game :Defense;
}
}
