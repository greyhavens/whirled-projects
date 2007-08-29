package {

import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;

public class Game
{
    public function Game (board :Board, display :Display)
    {
        _board = board;
        _display = display;

        _display.addEventListener(Event.ENTER_FRAME, handleGameTick);

        // initialize the cursor with dummy data - it will all get overwritten, eventually
        _cursor = new Tower(new TowerDef(0, 0, Tower.TYPE_SIMPLE), -1, Tower.makeGuid());
    }

    public function handleUnload (event : Event) : void
    {
        _display.removeEventListener(Event.ENTER_FRAME, handleGameTick);
        trace("GAME UNLOAD");
    }

    /** Handles the start of a new game. */
    public function startGame () :void
    {
        _display.resetBoard();
        
        _towers = new Array(Board.HEIGHT * Board.WIDTH);
        _critters = new Array();
    }

    public function endGame () :void
    {
        _towers = null;
        _critters = null;
    }

    public function resetRound () :void
    {
    }

    public function handleAddTower (tower :Tower, index :int) :void
    {
        _towers.push(tower);
        _display.handleAddTower(tower);
        _board.markAsOccupied(tower.def, tower.player);
    }

    public function handleRemoveTower (towerId :int) :void
    {
    }

    public function handleMouseMove (logical :Point) :void
    {
        var def :TowerDef = new TowerDef(logical.x, logical.y, _cursor.def.type);
        if (! _cursor.def.equals(def)) {
            var onBoard :Boolean = _board.isOnBoard(def);
            var overEmptySpace :Boolean = onBoard && _board.isUnoccupied(def);
            if (onBoard) {
                _cursor.def = def;
                _display.showCursor(def, overEmptySpace);
            } else {
                _display.hideCursor();                    
            }
        }
    }
        
    protected function handleGameTick (event :Event) :void
    {
    }

    protected var _board :Board;
    protected var _display :Display;

    protected var _cursor :Tower;
    protected var _towers :Array; // of Tower
    protected var _critters :Array; // of Critter
}
}
