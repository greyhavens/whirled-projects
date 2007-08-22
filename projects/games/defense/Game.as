package {

import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;

public class Game
{
    // Names of properties set on the distributed object.
    public static const TOWERS :String = "TowersProperty";
    public static const START_TIME :String = "StartTimeProperty";

    public function Game (display :Display)
    {
        _display = display;
        _board = new Board(display.def.height, display.def.width);

        _display.addEventListener(Event.ENTER_FRAME, tickHandler);
        _display.setCursor(new Cursor(this, _display));
    }

    public function get def () :BoardDefinition
    {
        return _display.def;
    }
    
    public function handleUnload (event : Event) : void
    {
        _display.removeEventListener(Event.ENTER_FRAME, tickHandler);
        trace("GAME UNLOAD");
    }

    public function startGame () :void
    {
        _display.resetBoard();
        _critters = new Array();
        _towers = new Array();
    }

    public function endGame () :void
    {
        _towers = null;
        _critters = null;
    }

    public function addTower (tower :Tower) :void
    {
        _towers.push(tower);
        _board.setState(tower.getBoardLocation(), Board.OCCUPIED);

        tower.addToDisplay(_display);
    }

    public function removeTower (tower :Tower) :void
    {
        // todo
    }

    public function resetRound () :void
    {
    }

    public function checkLocation (r :Rectangle) :Boolean
    {
        return _board.allClear(r);
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
    protected var _board :Board;
}
}
