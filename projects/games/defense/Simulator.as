package {

import flash.events.Event;
    
/**
 * Contains all the game logic for directing critters on the map.
 */
public class Simulator
{
    public function Simulator (board :Board, game :Game)
    {
        _board = board;
        _game = game;
    }

    public function handleUnload (event : Event) :void
    {
        trace("SIMULATOR UNLOAD");
    }

    public function handleGameTick () :void
    {
    }

    protected var _board :Board;
    protected var _game :Game;
}
}
