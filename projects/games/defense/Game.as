package {

import flash.events.Event;
import flash.geom.Point;

public class Game
{
    // Names of properties set on the distributed object.
    public static const TOWERS :String = "TowersProperty";
    public static const START_TIME :String = "StartTimeProperty";

    public function Game (display :Display)
    {
        _display = display;
        _display.addEventListener(Event.ENTER_FRAME, tickHandler);
    }

    public function handleUnload (event : Event) : void
    {
        _display.removeEventListener(Event.ENTER_FRAME, tickHandler);
        trace("GAME UNLOAD");
    }

    public function startGame () :void
    {
        _display.resetBoard(new BoardDefinition());
    }

    public function endGame () :void
    {
    }

    public function addTower (/* tower definition */) :void
    {
    }

    public function removeTower (/* tower definition */) :void
    {
    }

    public function resetRound () :void
    {
    }

    protected function tickHandler (event :Event) :void
    {
        /*
        if (simulator.isActive) {
            simulator.tick();
        }
        */
    }
    
    protected var _display :Display;

    protected var _towers :Array; // of Tower
    protected var _critters :Array; // of Critter
}
}
