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
        _display.addEventListener(Event.ENTER_FRAME, tickHandler);
        _display.setCursor(new Cursor(this, _display));
        
        _board = new Board(display.def.height, display.def.width);
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

    public function addTower (type :int, x :int, y :int) :void
    {
        var tower :Tower = new Tower(type, this);
        tower.addToDisplay(_display);
        tower.setBoardLocation(x, y); // must happen after adding to display

        _towers.push(tower);
        _board.setState(tower.getBoardLocation(), Board.OCCUPIED);
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
